create table sacks(code text);

.mode table
.import input.txt sacks

with groups as (
     select
        code,
        (row_number() over (order by (select null)) - 1) / 3 as group_num
     from sacks
),
rowed as (
      select distinct
        nth_value(code, 1) over w as fst,
        nth_value(code, 2) over w as snd,
        nth_value(code, 3) over w as thrd,
        group_num
      from groups
      window w as (partition by group_num)
),
counts as (
       select
        group_num,
        fst,
        snd,
        thrd,
        substr(fst,1,1) as fstl,
        substr(snd,1,1) as sndl,
        substr(thrd,1,1) as thrdl,
        1 as subcount
       from rowed
       union all
       select
        group_num,
        fst,
        snd,
        thrd,
        substr(fst, subcount + 1, 1) as fstl,
        substr(snd, subcount + 1, 1) as sndl,
        substr(thrd, subcount + 1, 1) as thrdl,
        subcount + 1 as subcount
       from counts
       where
         subcount < length(fst)
         or subcount < length(snd)
         or subcount < length(thrd)
       order by group_num
),
sim as (
    select distinct
        fstc.group_num,
        fstc.fstl as letter
    from counts as fstc
    inner join counts as sndc on fstc.group_num = sndc.group_num and fstc.fstl = sndc.sndl
    inner join counts as thrdc on thrdc.group_num = sndc.group_num and thrdc.thrdl = sndc.sndl
)

select sum(
    iif(
        LOWER(letter) <> letter,
        unicode(letter) - unicode('A') + 27,
        unicode(letter) - unicode('a') + 1)) as solution from sim;
