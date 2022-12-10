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
solution as(
     select (lag(x) over (order by step))*step as signal, step from exe
)
select sum(signal) as answer from solution
where (step / 20) % 2 == 1 and step % 20 == 0
