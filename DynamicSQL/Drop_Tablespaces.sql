-- Setting Session Parameters
BEGIN
     dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'SQLTERMINATOR', true );
     dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'PRETTY', true );
     dbms_metadata.set_transform_param (dbms_metadata.session_transform,'STORAGE' ,false);
     dbms_metadata.set_transform_param (dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES' , false);
     dbms_metadata.set_transform_param (dbms_metadata.session_transform,'REF_CONSTRAINTS' , false);
     dbms_metadata.set_transform_param (dbms_metadata.session_transform,'CONSTRAINTS' , false);
END;

-- Generate DROP Tablespace queries using Dynamic SQL
select 'DROP TABLESPACE "' || tablespace_name ||'"'||' INCLUDING CONTENTS AND DATAFILES;' 
from dba_tablespaces
where tablespace_name like 'TEST%';
