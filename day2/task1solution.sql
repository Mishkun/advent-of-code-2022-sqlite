create table guide(opponent text, mine text);

.separator " "
.import input.txt guide

select
sum(
  case opponent || mine
       when 'AX' then 4 -- rock (1) draw (3)
       when 'AY' then 8 -- papr (2) win (6)
       when 'AZ' then 3 -- scis (3) loose (0)
       when 'BX' then 1 -- rock (1) loose (0)
       when 'BY' then 5 -- papr (2) draw (3)
       when 'BZ' then 9 -- scis (3) win (6)
       when 'CX' then 7 -- rock (1) win (6)
       when 'CY' then 2 -- papr (2) loose (0)
       when 'CZ' then 6 -- scis (3) draw (3)
  end
)
from guide
