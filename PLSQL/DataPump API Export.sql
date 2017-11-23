-- Exporting User Schema HR using Data Pump API

DECLARE
	handle number;
	file_exist boolean;
	ln_size number;
	ln_block_size number;
BEGIN
	UTL_FILE.fgetattr('BACKUPS' ,'HR_BACKUP.DMP' , file_exist, ln_size, ln_block_size);

	IF file_exist THEN 
		utl_file.fremove('BACKUPS' , 'HR_BACKUP.DMP' );
	END IF ;

	handle := dbms_datapump.open(
		operation => 'EXPORT' ,
		job_mode => 'SCHEMA');

	dbms_datapump.set_parameter(
		handle => handle,
		name   => 'COMPRESSION', 
		value  => 'ALL' );

	dbms_datapump.set_parallel(
		handle => handle, 
		degree => 4);

	dbms_datapump.add_file(
		handle    =>handle ,
		filename  =>'HR_BACKUP.DMP', 
		directory => 'BACKUPS', 
		filetype  => 1);

	dbms_datapump.metadata_filter(
		handle => handle ,
		name   => 'SCHEMA_EXPR' , 
		value  => 'IN(''HR'')' );

	dbms_datapump.start_job(handle=>handle);
	dbms_datapump.detach(handle=>handle);
END;
