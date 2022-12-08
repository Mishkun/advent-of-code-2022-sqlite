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
up as (
   select *,
         json_group_array(val) over (partition by i order by j desc rows between current row and unbounded following EXCLUDE CURRENT ROW) as rank_i,
         json_group_array(val) over (partition by i order by j rows between current row and unbounded following EXCLUDE CURRENT ROW) as rank_i_rev,
         json_group_array(val) over (partition by j order by i desc rows between current row and unbounded following EXCLUDE CURRENT ROW) as rank_j,
         json_group_array(val) over (partition by j order by i rows between current row and unbounded following EXCLUDE CURRENT ROW) as rank_j_rev
    from parsed
    order by i,j
)
-- visibility as (
--      select ifnull(rank_i, -1) < val or
--             ifnull(rank_i_rev, -1) < val or
--             ifnull(rank_j, -1) < val or
--             ifnull(rank_j_rev, -1) < val as visibility
--      from ranked
-- )
-- up as (
--    select i, j, val,
--           json_insert(rank_i, '$[#]', 10) as rank_i,
--           json_insert(rank_i_rev, '$[#]', 10) as rank_i_rev,
--           json_insert(rank_j, '$[#]', 10) as rank_j,
--           json_insert(rank_j_rev, '$[#]', 10) as rank_j_rev from cons
-- )
, left_lookup as (
  with decons as (
  select
  val,
  i,
  j,
  rank_i_js.value as ifo,
  rank_i_js.id as ifa,
  rank_i
  from up, json_each(rank_i) as rank_i_js
  ),
  ranked as (select i, j, val, ifa, max(ifo) over (partition by i,j order by ifa) as rank, rank_i from decons),
  filt as (
  select distinct i, j, val, ifa, rank, rank_i from ranked where rank >= val
  union all
  select distinct i, j, val, max(ifa) over (partition by i,j) as ifa, rank, rank_i from ranked
  )
  select distinct i, j, val, first_value(ifa) over (partition by i,j order by ifa) as ifa, rank, rank_i from filt
)
, right_lookup as (
  with decons as (
  select
  val,
  i,
  j,
  rank_i_js.value as ifo,
  rank_i_js.id as ifa
  from up, json_each(rank_i_rev) as rank_i_js
  ),
  ranked as (select i, j, val, ifa, max(ifo) over (partition by i,j order by ifa) as rank from decons),
  filt as (
  select distinct i, j, val, ifa, rank from ranked where rank >= val
  union all
  select distinct i, j, val, max(ifa) over (partition by i,j) as ifa, rank from ranked
  )
  select distinct i, j, val, first_value(ifa) over (partition by i,j order by ifa) as ifa, rank from filt
),
down_lookup as (
  with decons as (
  select
  val,
  i,
  j,
  rank_i_js.value as ifo,
  rank_i_js.id as ifa,
  rank_j_rev as rank_j
  from up, json_each(rank_j_rev) as rank_i_js
  ),
  ranked as (select i, j, val, ifa, max(ifo) over (partition by i,j order by ifa) as rank, rank_j from decons),
  filt as (
  select distinct i, j, val, ifa, rank, rank_j from ranked where rank >= val
  union all
  select distinct i, j, val, max(ifa) over (partition by i,j) as ifa, rank, rank_j from ranked
  )
  select distinct i, j, val, first_value(ifa) over (partition by i,j order by ifa) as ifa, rank, rank_j from filt
  order by i,j
),
up_lookup as (
  with decons as (
  select
  val,
  i,
  j,
  rank_i_js.value as ifo,
  rank_i_js.id as ifa,
  rank_j
  from up, json_each(rank_j) as rank_i_js
  ),
  ranked as (select i, j, val, ifa, max(ifo) over (partition by i,j order by ifa) as rank, rank_j from decons),
  filt as (
  select distinct i, j, val, ifa, rank, rank_j from ranked where rank >= val
  union all
  select distinct i, j, val, max(ifa) over (partition by i,j) as ifa, rank, rank_j from ranked
  )
  select distinct i, j, val, first_value(ifa) over (partition by i,j order by ifa) as ifa, rank, rank_j from filt
  order by i,j
),
-- select * from up_lookup
solution as (
select distinct r.i,r.j, r.val, (r.ifa * l.ifa * u.ifa * d.ifa) as answer from right_lookup as r
inner join left_lookup as l on r.i = l.i and r.j = l.j
inner join up_lookup as u on r.i = u.i and r.j = u.j
inner join down_lookup as d on r.i = d.i and r.j = d.j
-- where r.i <> select(max(i) from up) and r.j <> (select max(j) from up) and r.i <> 0 and r.j <> 0
order by r.i,r.j
)
select max(answer) from solution
