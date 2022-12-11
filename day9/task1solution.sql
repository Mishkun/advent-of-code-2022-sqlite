create table inp(cmdstr text);

.import input.txt inp
.mode table

with recursive parsed as(
     select substr(cmdstr, 1, 1) as direction,
            cast(substr(cmdstr, 3) as int) as amount,
            row_number() over () as n
     from inp
),
lowered as(
    with recursive multiplied as(
         select direction, amount, n from parsed
         union all
         select direction, amount - 1 as amount, n from multiplied
         where amount <> 1
    ) select direction, row_number() over (order by n) as n from multiplied
),
solution as(
    select 's' as dir, 0 as hi, 0 as hj, 0 as ti, 0 as tj, 1 as step
    union all
    select
        direction as dir,
        case direction
            when 'U' then hi + 1
            when 'D' then hi - 1
            else hi
        end as hi,
        case direction
            when 'R' then hj + 1
            when 'L' then hj - 1
            else hj
        end as hj,
        case direction
            when 'U' then iif(hi > ti, ti + 1, ti)
            when 'D' then iif(hi < ti, ti - 1, ti)
            when 'R' then iif(hj > tj, hi, ti)
            when 'L' then iif(hj < tj, hi, ti)
            else ti
        end as ti,
        case direction
            when 'R' then iif(hj > tj, tj + 1, tj)
            when 'L' then iif(hj < tj, tj - 1, tj)
            when 'U' then iif(hi > ti, hj, tj)
            when 'D' then iif(hi < ti, hj, tj)
            else tj
        end as tj,
        step + 1 as step
    from solution
    join lowered on n = step
),
uniq as(
     select distinct ti,tj from solution
)
select count(*) as answer from uniq
