set lines 200
col begin_time for a25 heading "Fecha|Inicio"
col max_read_avg   for a20 heading "Promedio|Maximo|Lectura"
col min_read_avg   for a20 heading "Promedio|Minimo|Lectura"
col avg_read_time  for a20 heading "Promedio|Tiempo|Lectura"
col max_write_avg  for a20 heading "Promedio|Maximo|Escritura"
col min_write_avg  for a20 heading "Promedio|Minimo|Escritura"
col avg_write_time for a20 heading "Promedio|Tiempo|Escritura"

--Las metricas que da Oracle son en Centesimas de segundo
SELECT
   to_char(begin_time,'yyyy-mm-dd hh24:mi:ss') begin_time
  ,case when max(average_read_time) <         100 then to_char(max(average_read_time),'9G990D99')||' cs'
        when max(average_read_time) <    (100*60) then to_char(max(average_read_time),'9G990D99')||' s'
        when max(average_read_time) < (100*60*60) then to_char(max(average_read_time),'9G990D99')||' min' 
   end max_read_avg
  ,case when min(average_read_time) <         100 then to_char(min(average_read_time),'9G990D99')||' cs'
        when min(average_read_time) <    (100*60) then to_char(min(average_read_time),'9G990D99')||' s'
        when min(average_read_time) < (100*60*60) then to_char(min(average_read_time),'9G990D99')||' min' 
   end min_read_avg
  ,case when avg(average_read_time) <         100 then to_char(avg(average_read_time),'9G990D99')||' cs'
        when avg(average_read_time) <    (100*60) then to_char(avg(average_read_time),'9G990D99')||' s'
        when avg(average_read_time) < (100*60*60) then to_char(avg(average_read_time),'9G990D99')||' min' 
   end avg_read_time
  ,case when max(average_write_time) <         100 then to_char(max(average_write_time),'9G990D99')||' cs'
        when max(average_write_time) <    (100*60) then to_char(max(average_write_time),'9G990D99')||' s'
        when max(average_write_time) < (100*60*60) then to_char(max(average_write_time),'9G990D99')||' min' 
   end max_write_avg
  ,case when min(average_write_time) <         100 then to_char(min(average_write_time),'9G990D99')||' cs'
        when min(average_write_time) <    (100*60) then to_char(min(average_write_time),'9G990D99')||' s'
        when min(average_write_time) < (100*60*60) then to_char(min(average_write_time),'9G990D99')||' min' 
   end min_write_avg
  ,case when avg(average_write_time) <         100 then to_char(avg(average_write_time),'9G990D99')||' cs'
        when avg(average_write_time) <    (100*60) then to_char(avg(average_write_time),'9G990D99')||' s'
        when avg(average_write_time) < (100*60*60) then to_char(avg(average_write_time),'9G990D99')||' min' 
   end avg_write_time
FROM v$filemetric_history
GROUP BY
   begin_time
  ,end_time
ORDER BY 1
;
