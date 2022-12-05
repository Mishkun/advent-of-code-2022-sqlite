create table inp(x text);

.import input.txt inp
.mode table

with recursive numbered_inp as (
     select x, row_number() over (order by (select null)) as row_num from inp
),
stacks_inp as (
     select x, row_num from numbered_inp where row_num < (select row_num from numbered_inp where x = '') - 1
),
stacks_prep as (
     select substr(x, 2, 1) as head, substr(x, 5) as tail, 1 as step, row_num from stacks_inp
     union all
     select substr(tail, 2, 1) as head, substr(tail, 5) as tail, step + 1 as step, row_num from stacks_prep
     where tail <> ''
),
stacks as (
    with trimmed as (
         select head,
         step as stack_num,
         (select max(row_num) from stacks_prep) - row_num + 1 as row_num
         from stacks_prep
         where trim(head) <> ''
    ),
    maxed as (
          with max_by_stack as (
          select stack_num, max(row_num) as max_num
          from trimmed
          group by stack_num
          )
          select stack_num, json_group_array(max_num) over (order by stack_num rows between unbounded preceding and unbounded following) as max_map from max_by_stack
    )
    select head, trimmed.stack_num, row_num, max_map from trimmed join maxed on maxed.stack_num = trimmed.stack_num
),
moves_inp as (
     select x, row_num from numbered_inp where row_num > (select row_num from numbered_inp where x = '')
),
moves_prep as (
     select
        cast(substr(x, 6, 2) as int) as how_much,  cast(substr(x, 13, 2) as int) as f, cast(substr(x, -1, 1) as int) as t, row_num from moves_inp
     union all
     select how_much - 1 as how_much, f, t, row_num from moves_prep where how_much > 1
),
-- +---+---+------+
-- | f | t | step |
-- +---+---+------+
-- | 2 | 1 | 1    |
-- | 1 | 3 | 2    |
-- | 1 | 3 | 3    |
-- | 1 | 3 | 4    |
-- | 2 | 1 | 5    |
-- | 2 | 1 | 6    |
-- | 1 | 2 | 7    |
-- +---+---+------+
moves as (
     select cast(f as int) as f, cast(t as int) as t, row_number() over (order by row_num) as step from moves_prep
),
solution as (
     select *, 0 as stp, null as f, null as t from stacks
     union all
     select
        head,
        iif(stack_num = moves.f and row_num = json_extract(max_map, printf("$[%s]", stack_num-1)),
            moves.t,
            stack_num) as stack_num,
        iif(stack_num = moves.f and row_num = json_extract(max_map, printf("$[%s]", stack_num-1)),
            json_extract(max_map, printf("$[%s]", moves.t-1)) + 1,
            row_num) as row_num,
        json_replace(
            json_replace(max_map, printf("$[%s]", moves.f-1), json_extract(max_map, printf("$[%s]", moves.f-1)) - 1),
            printf("$[%s]", moves.t-1), json_extract(max_map, printf("$[%s]", moves.t-1)) + 1) as max_map,
        stp + 1,
        moves.f,
        moves.t
     from solution
     left join moves on stp + 1 = moves.step
     where stp < (select count(*) from moves)
),
last_iter as (
    select head, stack_num, row_num from solution where stp = (select count(*) from moves)
),
tops as (
     select head from(
            select *, row_number() over (partition by stack_num order by row_num desc) as num from last_iter
            order by stack_num
     ) where num = 1
)
select group_concat(head, "") from tops;
