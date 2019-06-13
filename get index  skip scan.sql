select c.sql_text, c.sql_id, b.object_name, d.mb
  from v$sql_plan b,
       v$sql c,
       (select owner, segment_name, sum(bytes / 1024 / 1024) mb
          from dba_segments
         group by owner, segment_name) d
 where b.sql_id = c.sql_id
   and b.CHILD_NUMBER = c.CHILD_NUMBER
   and b.OBJECT_OWNER = 'SCOTT'
   and b.OPTIONS = 'SKIP SCAN'
   and b.OBJECT_OWNER = d.owner
   and b.object_name = d.segment_name
 order by 4 desc;


create table t_skip as select * from dba_objects;

create index idx_owner_id on t_skip(owner,object_id);
------对表进行统计信息收集。
BEGIN
  DBMS_STATS.gather_table_stats(ownname => 'SCOTT',
                                tabname => 'T_SKIP',
                                estimate_percent => 100,
                                method_opt => 'for all columns size skewonly',
                                no_invalidate => FALSE,
                                degree => 1,
                                cascade => TRUE);
END;
/

