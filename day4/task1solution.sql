create table ranges(fst text, snd text);

.mode table
.separator ","
.import input.txt ranges

with numranges as (
     select
        cast(substr(fst, 1, instr(fst, '-')) as int) as fstleft,
        cast(substr(fst, instr(fst, '-')+1) as int) as fstright,
        cast(substr(snd, 1, instr(fst, '-')) as int) as sndleft,
        cast(substr(snd, instr(snd, '-')+1) as int) as sndright
    from ranges
) select count(*) from numranges
where
fstleft <= sndleft and fstright >= sndright or
fstleft >= sndleft and fstright <= sndright;
