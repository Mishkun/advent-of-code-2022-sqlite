create table inp(x text);

.import input.txt inp
.mode table

with recursive preparsed as(
     select
            case when x = '$ cd ..' then 'dc'
                 when x like '$ cd %' then 'cd'
                 when x like 'dir %' then 'dir'
                 else 'file'
            end as t,
            case when x = '$ cd ..' then null
                 when x like '$ cd %' then substr(x, 6)
                 when x like 'dir %' then substr(x, 5)
                 else substr(x, instr(x, ' ') + 1)
            end as nm,
            iif(x not like '$%' and x not like 'dir%', cast(substr(x, 1, instr(x, ' ')) as int), null) as bytes,
            row_number() over (order by (select null)) as n from inp
            where x <> '$ ls' and  x <> '$ cd /'
),
-- parse directory structure, saving current path in pth
parsed as (
      select 'root' as t, '/' as nm, null as bytes, json_array('/') as pth, 1 as step
      union all
      select
        preparsed.t,
        case when preparsed.t = 'dir' or preparsed.t = 'file'
             then json_insert(pth, '$[#]', preparsed.nm)
             else preparsed.nm
        end as nm,
        preparsed.bytes,
        case when preparsed.t = 'cd'
             then json_insert(pth, '$[#]', preparsed.nm)
             when preparsed.t = 'dc'
             then json_remove(pth, '$[#-1]')
             else pth
        end as pth,
        step + 1 as step
        from parsed
        inner join preparsed
             on n = step
),
only_dirs as (
       select json_remove(nm, '$[#-1]') as nm, sum(bytes) as bytes from parsed
       where t = 'file'
       group by json_remove(nm, '$[#-1]')
),
solution as (
     select json_each.value as dirnm, sum(bytes) as bytes from only_dirs, json_each(only_dirs.nm)
     group by json_extract(nm, printf('$[%s]', iif(json_each.key > 0,json_each.key - 1, 0))) || json_each.value
     order by nm
)
select sum(bytes) from solution
where bytes <= 100000;
