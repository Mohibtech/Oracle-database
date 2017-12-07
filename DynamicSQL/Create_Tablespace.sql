set echo      off
set verify    off
set feedback  off
set heading   off
set head      off
set linesize  180
set long  99999
set pages  0
set trimspool    on
set termout      off
set serveroutput off

spool 'E:\MISC\SQLPLUS\Tblspc.sql'

select 'select dbms_metadata.get_ddl(''TABLESPACE'','''   ||  tablespace_name || ''') from dual;'   
from dba_tablespaces;

spool off;

BEGIN
     dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'SQLTERMINATOR', true );
     dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'PRETTY', true );
     dbms_metadata.set_transform_param (dbms_metadata.session_transform,'STORAGE' ,false);
     dbms_metadata.set_transform_param (dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES' , false);
     dbms_metadata.set_transform_param (dbms_metadata.session_transform,'REF_CONSTRAINTS' , false);
     dbms_metadata.set_transform_param (dbms_metadata.session_transform,'CONSTRAINTS' , false);
END;

/

spool 'E:\MISC\SQLPLUS\Final_Tblspc_Create.sql'

@@Tblspc.sql

spool off
