create table guide(opponent text, mine text);

.separator " "
.import input.txt guide

select
sum(
  case opponent || mine
       when 'AX' then 3 -- rock scis (3) loose (0)
       when 'AY' then 4 -- rock rock (1) draw (3)
       when 'AZ' then 8 -- rock papr (2) win (6)
       when 'BX' then 1 -- papr rock (1) loose (0)
       when 'BY' then 5 -- papr papr (2) draw (3)
       when 'BZ' then 9 -- papr scis (3) win (6)
       when 'CX' then 2 -- scis papr (2) loose (0)
       when 'CY' then 6 -- scis scis (3) draw (3)
       when 'CZ' then 7 -- scis rock (1) win (6)
  end
)
from guide
