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
h_instructions as(
    select 0 as hi, 0 as hj, 1 as step
    union all
    select
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
            step + 1 as step
    from h_instructions
    join lowered on n = step
),
instructions_1 as(
    with recursive solution as (
    select 0 as ti, 0 as tj, 1 as step
    union all
    select case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then ti
                when ti > hi then ti - 1
                when ti < hi then ti + 1
                else ti
           end as ti,
           case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then tj
                when tj > hj then tj - 1
                when tj < hj then tj + 1
                else tj
           end as tj,
           t.step + 1 as step
    from solution as t
    join h_instructions as h on h.step = t.step
    ) select ti as hi, tj as hj, step from solution
),
instructions_2 as(
    with recursive solution as (
    select 0 as ti, 0 as tj, 1 as step
    union all
    select case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then ti
                when ti > hi then ti - 1
                when ti < hi then ti + 1
                else ti
           end as ti,
           case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then tj
                when tj > hj then tj - 1
                when tj < hj then tj + 1
                else tj
           end as tj,
           t.step + 1 as step
    from solution as t
    join instructions_1 as h on h.step = t.step
    ) select ti as hi, tj as hj, step from solution
),
instructions_3 as(
    with recursive solution as (
    select 0 as ti, 0 as tj, 1 as step
    union all
    select case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then ti
                when ti > hi then ti - 1
                when ti < hi then ti + 1
                else ti
           end as ti,
           case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then tj
                when tj > hj then tj - 1
                when tj < hj then tj + 1
                else tj
           end as tj,
           t.step + 1 as step
    from solution as t
    join instructions_2 as h on h.step = t.step
    ) select ti as hi, tj as hj, step from solution
),
instructions_4 as(
    with recursive solution as (
    select 0 as ti, 0 as tj, 1 as step
    union all
    select case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then ti
                when ti > hi then ti - 1
                when ti < hi then ti + 1
                else ti
           end as ti,
           case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then tj
                when tj > hj then tj - 1
                when tj < hj then tj + 1
                else tj
           end as tj,
           t.step + 1 as step
    from solution as t
    join instructions_3 as h on h.step = t.step
    ) select ti as hi, tj as hj, step from solution
),
instructions_5 as(
    with recursive solution as (
    select 0 as ti, 0 as tj, 1 as step
    union all
    select case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then ti
                when ti > hi then ti - 1
                when ti < hi then ti + 1
                else ti
           end as ti,
           case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then tj
                when tj > hj then tj - 1
                when tj < hj then tj + 1
                else tj
           end as tj,
           t.step + 1 as step
    from solution as t
    join instructions_4 as h on h.step = t.step
    ) select ti as hi, tj as hj, step from solution
),
instructions_6 as(
    with recursive solution as (
    select 0 as ti, 0 as tj, 1 as step
    union all
    select case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then ti
                when ti > hi then ti - 1
                when ti < hi then ti + 1
                else ti
           end as ti,
           case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then tj
                when tj > hj then tj - 1
                when tj < hj then tj + 1
                else tj
           end as tj,
           t.step + 1 as step
    from solution as t
    join instructions_5 as h on h.step = t.step
    ) select ti as hi, tj as hj, step from solution
),
instructions_7 as(
    with recursive solution as (
    select 0 as ti, 0 as tj, 1 as step
    union all
    select case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then ti
                when ti > hi then ti - 1
                when ti < hi then ti + 1
                else ti
           end as ti,
           case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then tj
                when tj > hj then tj - 1
                when tj < hj then tj + 1
                else tj
           end as tj,
           t.step + 1 as step
    from solution as t
    join instructions_6 as h on h.step = t.step
    ) select ti as hi, tj as hj, step from solution
),
instructions_8 as(
    with recursive solution as (
    select 0 as ti, 0 as tj, 1 as step
    union all
    select case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then ti
                when ti > hi then ti - 1
                when ti < hi then ti + 1
                else ti
           end as ti,
           case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then tj
                when tj > hj then tj - 1
                when tj < hj then tj + 1
                else tj
           end as tj,
           t.step + 1 as step
    from solution as t
    join instructions_7 as h on h.step = t.step
    ) select ti as hi, tj as hj, step from solution
),
instructions_9 as(
    with recursive solution as (
    select 0 as ti, 0 as tj, 1 as step
    union all
    select case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then ti
                when ti > hi then ti - 1
                when ti < hi then ti + 1
                else ti
           end as ti,
           case when hi - ti in (-1, 0, 1) and hj - tj in (-1, 0, 1) then tj
                when tj > hj then tj - 1
                when tj < hj then tj + 1
                else tj
           end as tj,
           t.step + 1 as step
    from solution as t
    join instructions_8 as h on h.step = t.step
    ) select ti as hi, tj as hj, step from solution
),
uniq as(select distinct hi, hj from instructions_9)
select count(*) from uniq
