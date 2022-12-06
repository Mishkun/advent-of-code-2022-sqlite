create table inp(x text);
.import input.txt inp
.mode table

with recursive parsed as (
     select x,
            null as window,
            1 as pos
     from inp
     union all
     select x,
            substr(x, pos-2, 4) as window,
            pos + 1 as pos
     from parsed
     where pos < length(x)
),
destructured as (
     select window,
            substr(window, 1, 1) as ch,
            pos,
            1 as windowpos
     from parsed
     union all
     select window,
            substr(window, windowpos + 1, 1) as ch,
            pos,
            windowpos + 1 as windowpos
     from destructured
     where windowpos < length(window)
),
dist as (
    select distinct window, ch, pos from destructured
    order by pos
)
select pos as answer from dist
group by pos
having count(ch) = 4
order by pos
limit 1
