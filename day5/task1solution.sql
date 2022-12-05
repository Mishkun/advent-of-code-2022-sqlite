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
         select head, step as stack_num, row_num  from stacks_prep
         where trim(head) <> ''
    )
    select
        group_concat(head, "") filter (where stack_num=1) over w as stack1,
        group_concat(head, "") filter (where stack_num=2) over w as stack2,
        group_concat(head, "") filter (where stack_num=3) over w as stack3,
        group_concat(head, "") filter (where stack_num=4) over w as stack4,
        group_concat(head, "") filter (where stack_num=5) over w as stack5,
        group_concat(head, "") filter (where stack_num=6) over w as stack6,
        group_concat(head, "") filter (where stack_num=7) over w as stack7,
        group_concat(head, "") filter (where stack_num=8) over w as stack8,
        group_concat(head, "") filter (where stack_num=9) over w as stack9
    from trimmed
    window w as (order by row_num desc rows between unbounded preceding and unbounded following)
    limit 1
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
     select *, 0 as stp from stacks
     union all
     select
        case when f = 1 then
             substr(stack1, 1, length(stack1) - 1)
             when t = 1 then
                case f
                when 2 then stack1 || substr(stack2, -1, 1)
                when 3 then stack1 || substr(stack3, -1, 1)
                when 4 then stack1 || substr(stack4, -1, 1)
                when 5 then stack1 || substr(stack5, -1, 1)
                when 6 then stack1 || substr(stack6, -1, 1)
                when 7 then stack1 || substr(stack7, -1, 1)
                when 8 then stack1 || substr(stack8, -1, 1)
                when 9 then stack1 || substr(stack9, -1, 1)
                else stack1
                end
        else stack1
        end as stack1,
        case when f = 2 then
             substr(stack2, 1, length(stack2) - 1)
             when t = 2 then
                case f
                when 1 then stack2 || substr(stack1, -1, 1)
                when 3 then stack2 || substr(stack3, -1, 1)
                when 4 then stack2 || substr(stack4, -1, 1)
                when 5 then stack2 || substr(stack5, -1, 1)
                when 6 then stack2 || substr(stack6, -1, 1)
                when 7 then stack2 || substr(stack7, -1, 1)
                when 8 then stack2 || substr(stack8, -1, 1)
                when 9 then stack2 || substr(stack9, -1, 1)
                else stack2
                end
        else stack2
        end as stack2,
        case when f = 3 then
             substr(stack3, 1, length(stack3) - 1)
             when t = 3 then
                case f
                when 1 then stack3 || substr(stack1, -1, 1)
                when 2 then stack3 || substr(stack2, -1, 1)
                when 4 then stack3 || substr(stack4, -1, 1)
                when 5 then stack3 || substr(stack5, -1, 1)
                when 6 then stack3 || substr(stack6, -1, 1)
                when 7 then stack3 || substr(stack7, -1, 1)
                when 8 then stack3 || substr(stack8, -1, 1)
                when 9 then stack3 || substr(stack9, -1, 1)
                else stack3
                end
        else stack3
        end as stack3,
        case when f = 4 then
             substr(stack4, 1, length(stack4) - 1)
             when t = 4 then
                case f
                when 1 then stack4 || substr(stack1, -1, 1)
                when 2 then stack4 || substr(stack2, -1, 1)
                when 3 then stack4 || substr(stack3, -1, 1)
                when 5 then stack4 || substr(stack5, -1, 1)
                when 6 then stack4 || substr(stack6, -1, 1)
                when 7 then stack4 || substr(stack7, -1, 1)
                when 8 then stack4 || substr(stack8, -1, 1)
                when 9 then stack4 || substr(stack9, -1, 1)
                else stack4
                end
        else stack4
        end as stack4,
        case when f = 5 then
             substr(stack5, 1, length(stack5) - 1)
             when t = 5 then
                case f
                when 1 then stack5 || substr(stack1, -1, 1)
                when 2 then stack5 || substr(stack2, -1, 1)
                when 3 then stack5 || substr(stack3, -1, 1)
                when 4 then stack5 || substr(stack4, -1, 1)
                when 6 then stack5 || substr(stack6, -1, 1)
                when 7 then stack5 || substr(stack7, -1, 1)
                when 8 then stack5 || substr(stack8, -1, 1)
                when 9 then stack5 || substr(stack9, -1, 1)
                else stack5
                end
        else stack5
        end as stack5,
        case when f = 6 then
             substr(stack6, 1, length(stack6) - 1)
             when t = 6 then
                case f
                when 1 then stack6 || substr(stack1, -1, 1)
                when 2 then stack6 || substr(stack2, -1, 1)
                when 3 then stack6 || substr(stack3, -1, 1)
                when 4 then stack6 || substr(stack4, -1, 1)
                when 5 then stack6 || substr(stack5, -1, 1)
                when 7 then stack6 || substr(stack7, -1, 1)
                when 8 then stack6 || substr(stack8, -1, 1)
                when 9 then stack6 || substr(stack9, -1, 1)
                else stack6
                end
        else stack6
        end as stack6,
        case when f = 7 then
             substr(stack7, 1, length(stack7) - 1)
             when t = 7 then
                case f
                when 1 then stack7 || substr(stack1, -1, 1)
                when 2 then stack7 || substr(stack2, -1, 1)
                when 3 then stack7 || substr(stack3, -1, 1)
                when 4 then stack7 || substr(stack4, -1, 1)
                when 5 then stack7 || substr(stack5, -1, 1)
                when 6 then stack7 || substr(stack6, -1, 1)
                when 8 then stack7 || substr(stack8, -1, 1)
                when 9 then stack7 || substr(stack9, -1, 1)
                else stack7
                end
        else stack7
        end as stack7,
        case when f = 8 then
             substr(stack8, 1, length(stack8) - 1)
             when t = 8 then
                case f
                when 1 then stack8 || substr(stack1, -1, 1)
                when 2 then stack8 || substr(stack2, -1, 1)
                when 3 then stack8 || substr(stack3, -1, 1)
                when 4 then stack8 || substr(stack4, -1, 1)
                when 5 then stack8 || substr(stack5, -1, 1)
                when 6 then stack8 || substr(stack6, -1, 1)
                when 7 then stack8 || substr(stack7, -1, 1)
                when 9 then stack8 || substr(stack9, -1, 1)
                else stack8
                end
        else stack8
        end as stack8,
        case when f = 9 then
             substr(stack9, 1, length(stack9) - 1)
             when t = 9 then
                case f
                when 1 then stack9 || substr(stack1, -1, 1)
                when 2 then stack9 || substr(stack2, -1, 1)
                when 3 then stack9 || substr(stack3, -1, 1)
                when 4 then stack9 || substr(stack4, -1, 1)
                when 5 then stack9 || substr(stack5, -1, 1)
                when 6 then stack9 || substr(stack6, -1, 1)
                when 7 then stack9 || substr(stack7, -1, 1)
                when 8 then stack9 || substr(stack8, -1, 1)
                else stack9
                end
        else stack9
        end as stack9,
        stp + 1
     from solution
     join moves on  moves.step = solution.stp + 1
     order by stp desc
),
tops as (
     select crate from(
            select *, row_number() over (partition by stack_num order by row_num) as num from stacks
            order by stack_num
     ) where num = 1
)
select
             substr(stack1, -1, 1) ||
             substr(stack2, -1, 1) ||
             substr(stack3, -1, 1) ||
             substr(stack4, -1, 1) ||
             substr(stack5, -1, 1) ||
             substr(stack6, -1, 1) ||
             substr(stack7, -1, 1) ||
             substr(stack8, -1, 1) ||
             substr(stack9, -1, 1) as solution
from solution order by stp desc limit 1;
