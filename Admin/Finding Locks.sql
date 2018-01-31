-- Queries for finding Locks

select c.owner, c.object_name, c.object_type, a.locked_mode 
   b.sid, b.serial#, b.status, b.osuser, b.machine
from v$locked_object a , v$session b, dba_objects c
where b.sid = a.session_id
and   a.object_id = c.object_id

--Similar to above except using inline tables
select a.session_id,a.oracle_username, a.os_user_name, b.owner "OBJECT OWNER", b.object_name,b.object_type, a.locked_mode 
from 
 (select object_id, SESSION_ID, ORACLE_USERNAME, OS_USER_NAME, LOCKED_MODE from v$locked_object) a, 
 (select object_id, owner, object_name,object_type from dba_objects) b
where a.object_id=b.object_id;

-- Show all sessions waiting for any lock:
select event,p1,p2,p3 from v$session_wait 
where wait_time=0 and event='enqueue';

-- Show sessions waiting for a TX lock:
select * from v$lock where type='TX' and request > 0;

-- Show sessions holding a TX lock:
select * from v$lock where type='TX' and lmode > 0;


-- DBA_BLOCKERS - Shows non-waiting sessions holding locks being waited-on
-- DBA_DDL_LOCKS - Shows all DDL locks held or being requested
-- DBA_DML_LOCKS - Shows all DML locks held or being requested
-- DBA_LOCK_INTERNAL - Displays 1 row for every lock or latch held or being requested with the username of who is holding the lock
-- DBA_LOCKS - Shows all locks or latches held or being requested
-- DBA_WAITERS - Shows all sessions waiting on, but not holding waited for locks
