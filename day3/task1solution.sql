create table sacks(code text);

.mode table
.import input.txt sacks

with recursive compartments as (
     select
        code as orig,
        substr(code, 1, length(code)/2) as l,
        substr(code, length(code)/2 + 1, length(code)/2) as r
     from sacks
),
counts as (
       select *, 1 as subcount from compartments
       union all
       select orig, l, r, subcount + 1 as subcount from counts
       where subcount < length(l)
),
lcodes as (
     select orig, substr(l, subcount, 1) as lletter from counts
),
rcodes as (
     select orig, substr(r, subcount, 1) as rletter from counts
),
pairs as (
      select distinct lcodes.orig, rletter, lletter from rcodes
      inner join lcodes on lcodes.orig = rcodes.orig and rletter = lletter
)
select sum(
    iif(
        LOWER(rletter) <> rletter,
        unicode(rletter) - unicode('A') + 27,
        unicode(rletter) - unicode('a') + 1)) as solution from pairs;
