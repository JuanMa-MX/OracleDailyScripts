--        Nombre:
--         Autor: Juan Manuel Cruz Lopez (JohnXJean)
--   Descripcion:
--           Uso:
--Requerimientos:
--Licenciamiento:
--        Creado:
--       Soporte: johnxjean@gmail.com
--Support: johnxjean@gmail.com
SET LINES 180
SET PAGES 1000

accept where_ char default '1=1' -
prompt 'Sentencia WHERE? start_date sid username [1=1]: '

PROMPT
PROMPT WHERE (1): start_date < <sysdate> AND sid=<sid>

COL sid FOR A10
COL ses_status FOR A10
COL tx_status FOR A10
COL last_call_et FOR A12
COL time_tx_active FOR A14

SELECT s.sid||'' sid
      ,s.status ses_status
      ,TO_CHAR(CAST(numtodsinterval(((sysdate-t.start_date)*(1*24*60*60)), 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) last_call_et
      ,t.status tx_status
      ,TO_CHAR(CAST(numtodsinterval(((sysdate-t.start_date)*(1*24*60*60)), 'SECOND') AS INTERVAL DAY(2) TO SECOND(0))) time_tx_active
      ,t.start_date
FROM v$transaction t
    ,v$session     s
WHERE t.ses_addr = s.saddr
  AND &&where_
ORDER BY t.start_date
;
