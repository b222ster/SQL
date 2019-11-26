/*First see which database files have the most IO bottleneck by running this query(Query by Glenn Berry)*/
SELECT DB_NAME(fs.database_id) AS [Database Name]
     , mf.physical_name
     , io_stall_read_ms
     , num_of_reads
     , CAST(io_stall_read_ms / (1.0 + num_of_reads) AS NUMERIC(10, 1)) AS [avg_read_stall_ms]
     , io_stall_write_ms
     , num_of_writes
     , CAST(io_stall_write_ms / (1.0 + num_of_writes) AS NUMERIC(10, 1)) AS [avg_write_stall_ms]
     , io_stall_read_ms + io_stall_write_ms AS [io_stalls]
     , num_of_reads + num_of_writes AS [total_io]
     , CAST((io_stall_read_ms + io_stall_write_ms) / (1.0 + num_of_reads + num_of_writes) AS NUMERIC(10, 1)) AS [avg_io_stall_ms]
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS fs
     INNER JOIN sys.master_files AS mf WITH(NOLOCK) ON fs.database_id = mf.database_id
                                                       AND fs.[file_id] = mf.[file_id]
ORDER BY avg_io_stall_ms DESC OPTION(RECOMPILE);

/*
Then run this query to see the top ten events your server is waiting on(query by Jonathan Kehayias). 
You will also find similar query from Glenn Berry diagnostic queries
*/
SELECT TOP 10 wait_type
            , max_wait_time_ms wait_time_ms
            , signal_wait_time_ms
            , wait_time_ms - signal_wait_time_ms AS resource_wait_time_ms
            , 100.0 * wait_time_ms / SUM(wait_time_ms) OVER() AS percent_total_waits
            , 100.0 * signal_wait_time_ms / SUM(signal_wait_time_ms) OVER() AS percent_total_signal_waits
            , 100.0 * (wait_time_ms - signal_wait_time_ms) / SUM(wait_time_ms) OVER() AS percent_total_resource_waits
FROM sys.dm_os_wait_stats
WHERE wait_time_ms > 0 -- remove zero wait_time
      AND wait_type NOT IN -- filter out additional irrelevant waits
('SLEEP_TASK', 'BROKER_TASK_STOP'
, 'BROKER_TO_FLUSH'
, 'SQLTRACE_BUFFER_FLUSH'
, 'CLR_AUTO_EVENT'
, 'CLR_MANUAL_EVENT'
, 'LAZYWRITER_SLEEP'
, 'SLEEP_SYSTEMTASK'
, 'SLEEP_BPOOL_FLUSH'
, 'BROKER_EVENTHANDLER'
, 'XE_DISPATCHER_WAIT'
, 'FT_IFTSHC_MUTEX'
, 'CHECKPOINT_QUEUE'
, 'FT_IFTS_SCHEDULER_IDLE_WAIT'
, 'BROKER_TRANSMITTER'
, 'FT_IFTSHC_MUTEX'
, 'KSOURCE_WAKEUP'
, 'LAZYWRITER_SLEEP'
, 'LOGMGR_QUEUE'
, 'ONDEMAND_TASK_QUEUE'
, 'REQUEST_FOR_DEADLOCK_SEARCH'
, 'XE_TIMER_EVENT'
, 'BAD_PAGE_PROCESS'
, 'DBMIRROR_EVENTS_QUEUE'
, 'BROKER_RECEIVE_WAITFOR'
, 'PREEMPTIVE_OS_GETPROCADDRESS'
, 'PREEMPTIVE_OS_AUTHENTICATIONOPS'
, 'WAITFOR'
, 'DISPATCHER_QUEUE_SEMAPHORE'
, 'XE_DISPATCHER_JOIN'
, 'RESOURCE_QUEUE')
ORDER BY wait_time_ms DESC;




/*The script allows to filter on read and write latencies and it joins with sys.master files to get database names and file paths*/
SELECT [ReadLatency] = CASE
                           WHEN [num_of_reads] = 0 THEN 0
                           ELSE([io_stall_read_ms] / [num_of_reads])
                       END
     , [WriteLatency] = CASE
                            WHEN [num_of_writes] = 0 THEN 0
                            ELSE([io_stall_write_ms] / [num_of_writes])
                        END
     , [Latency] = CASE
                       WHEN([num_of_reads] = 0
                            AND [num_of_writes] = 0) THEN 0
                       ELSE([io_stall] / ([num_of_reads] + [num_of_writes]))
                   END
     , [AvgMBPerRead] = CASE
                           WHEN [num_of_reads] = 0 THEN 0
                           ELSE([num_of_bytes_read] / [num_of_reads])/1024
                       END
     , [AvgMBPerWrite] = CASE
                            WHEN [num_of_writes] = 0 THEN 0
                            ELSE([num_of_bytes_written] / [num_of_writes])/1024
                        END
     , [AvgMBPerTransfer] = CASE
                               WHEN([num_of_reads] = 0
                                    AND [num_of_writes] = 0) THEN 0
                               ELSE(([num_of_bytes_read] + [num_of_bytes_written]) / ([num_of_reads] + [num_of_writes]))/1024
                           END
     , LEFT([mf].[physical_name], 2) AS [Drive]
     , DB_NAME([vfs].[database_id]) AS [DB]
     , [mf].[physical_name]
	 ,SUBSTRING(mf.physical_name, len(mf.physical_name)-CHARINDEX('\',REVERSE(mf.physical_name))+2, 100) as DB
	 , @@SERVERNAME as ServerName
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [vfs]
     JOIN sys.master_files AS [mf] ON [vfs].[database_id] = [mf].[database_id]
                                      AND [vfs].[file_id] = [mf].[file_id]
-- WHERE [vfs].[file_id] = 2 -- log files
-- ORDER BY [Latency] DESC
-- ORDER BY [ReadLatency] DESC
ORDER BY [WriteLatency] DESC;
GO



SELECT DB_NAME(mf.database_id) AS [Database]
     , mf.physical_name
     , r.io_pending
     , r.io_pending_ms_ticks
     , r.io_type
     , fs.num_of_reads
     , fs.num_of_writes
FROM sys.dm_io_pending_io_requests AS r
     INNER JOIN sys.dm_io_virtual_file_stats(NULL, NULL) AS fs ON r.io_handle = fs.file_handle
     INNER JOIN sys.master_files AS mf ON fs.database_id = mf.database_id
                                          AND fs.file_id = mf.file_id
ORDER BY r.io_pending
       , r.io_pending_ms_ticks DESC;