#Export Data Pump 

###Exporting Full Database Metadata
~~~sql
DIRECTORY=BACKUPS
DUMPFILE=FULLDB_METADATA.DMP  
LOGFILE=FULLDB_METADATA.log  
FULL=Y
CONTENT=METADATA_ONLY
COMPRESSION=ALL
~~~

###Exporting Schema 
~~~sql
DIRECTORY=BACKUPS
DUMPFILE=SCHEMA_MX02.DMP
SCHEMAS = MX02
LOGFILE=SCHEMA_MX02.log   
PARALLEL=4
COMPRESSION=ALL
~~~

###FULL Schema Metadata ONLY
~~~sql
DIRECTORY=BACKUPS
DUMPFILE=SCHEMA_MX02_METADATA.DMP
SCHEMAS = MX02
LOGFILE=SCHEMA_MX02_METADATA.log   
CONTENT=METADATA_ONLY
PARALLEL=4
COMPRESSION=ALL
~~~

###Exporting Single Table (Partitioned)
~~~sql
userid=mohib/passwd
Directory=MX_DB_BACKUP_DIR
Dumpfile=MX01_TABLE_DG0.DMP
logfile=MX01_Table_DG0.log
Tables=MX01.MX01_DG0
Parallel=8
Compression=all
~~~

###Exporting Multiple Tables
~~~sql
userid=TKMX/Aa
Directory=BACKUPS
Dumpfile=MX02_TABLES.DMP
logfile=MX02_Tables.log
Tables=MX02.TKMX02_DG0, MX02.MX02_DG1, MX02.MX02_DG2, MX02.MX02_DG3
Content=DATA_ONLY
Parallel=8
Compression=all
~~~

###Exporting Table Partition
~~~sql
userid=STAR/passwd
tables=STAR.STAR_DG0:PT_STAR_DG0_20150101
directory=BACKUPS
dumpfile=CC_DG0.dmp
logfile=CC_DG0.log
compression=all
parallel=8
~~~
