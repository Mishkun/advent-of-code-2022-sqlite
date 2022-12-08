create table inp(x text);

.import input.txt inp
.mode table

with recursive parsed as (
     with numbered as (select *, row_number() over () as i from inp)
     select x, cast(substr(x, 1, 1) as int) as val, 1 as j, i from numbered
     union all
     select x, cast(substr(x, j + 1, 1) as int) as val, j + 1, i from parsed
     where j < length(x)
),
ranked as (
     select *,
         max(val) over (partition by i order by j rows between unbounded preceding and current row EXCLUDE CURRENT ROW) as rank_i,
         max(val) over (partition by i order by j rows between current row and unbounded following EXCLUDE CURRENT ROW) as rank_i_rev,
         max(val) over (partition by j order by i rows between unbounded preceding and current row EXCLUDE CURRENT ROW) as rank_j,
         max(val) over (partition by j order by i rows between current row and unbounded following EXCLUDE CURRENT ROW) as rank_j_rev
     from parsed
     order by j
),
visibility as (
     select ifnull(rank_i, -1) < val or
            ifnull(rank_i_rev, -1) < val or
            ifnull(rank_j, -1) < val or
            ifnull(rank_j_rev, -1) < val as visibility
     from ranked
)
select sum(visibility) as answer from visibility
