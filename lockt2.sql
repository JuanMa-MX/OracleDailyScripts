set lines 200
col sess_info for a120 word_wrap

select
   lpad (lvl, 2)         || ' '
 ||lpad ('>', lvl*2, '-')|| ' '
 ||sid || ', ' || serial#|| ' '
 ||username              || ' '
 ||machine               || ' '
 ||osuser                || ' '
 ||program               || ' - '
 ||event sess_info
,to_char (cast (numtodsinterval (seconds_in_wait, 'SECOND') as interval day(2) to second(0))) waiting
,inst_id inst
from
(
   select
     level lvl
    ,connect_by_isleaf leaf
    ,inst_id
    ,sid
    ,serial#
    ,username
    ,machine
    ,osuser
    ,program
    ,event
    ,seconds_in_wait
    ,blocking_session
  from  gv$session
     connect by prior sid = blocking_session
     start with blocking_session is null
) where (lvl = 1 and leaf = 0) or (lvl > 1)
;
