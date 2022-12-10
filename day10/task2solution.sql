create table inp(cmdstr text);

.import input.txt inp
.mode table

with recursive parsed as(
     select case when cmdstr like 'addx %' then 'addx'
                 else 'noop'
            end as cmd,
            case when cmdstr like 'addx %' then cast(substr(cmdstr, 6) as int)
                 else 0
            end as amount,
            row_number() over () as n from inp
),
lowered as(
     with add_noop as (
        select * from parsed
        union all
        select 'noop' as cmd, 0 as amount, n from parsed
        where cmd = 'addx'
     ) select cmd, amount, row_number() over (order by n,cmd desc) as n from add_noop
),
exe as(
     select 1 as x, 0 as step, 'start' as comd
     union all
     select x + amount, step + 1, cmd from exe
     join lowered on step + 1 = n
     limit -1
     offset 1
),
signal as(
     with cut_by_row as (
     select ifnull(lag(x) over (order by step), 1) as signal, step, ntile(6) over (order by step) as rw from exe
     )
     select signal, (row_number() over (partition by rw order by step)) - 1 as step, rw from cut_by_row
),
drawn as(
      select *,
             case when step in (signal - 1, signal, signal + 1) then
                  '#'
             else
                  '.'
             end as img
             from signal
)
select distinct group_concat(img,"") over (partition by rw) as answer from drawn
