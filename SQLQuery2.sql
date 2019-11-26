SELECT sys.databases.name as db
     , sys.master_files.name as file_name
     , CONVERT(VARCHAR, sys.master_files.size * 8 / 1024) + ' MB' AS [Total disk space]
     , CASE WHEN sys.master_files.is_percent_growth = 0 
        THEN CONVERT(VARCHAR, sys.master_files.growth * 8 / 1024) + ' MB' 
        ELSE CONVERT(VARCHAR, (sys.master_files.size * 8 / 1024) * (sys.master_files.growth / 100)) + ' MB'
       END AS NextGrowth
     , sys.master_files.is_percent_growth
     , dovs.volume_mount_point AS Drive
     , CONVERT(VARCHAR(255), CONVERT(INT, dovs.available_bytes / 1048576.0)) + ' MB' AS FreeSpaceInMB
FROM sys.databases
     INNER JOIN sys.master_files ON sys.databases.database_id = sys.master_files.database_id
    CROSS APPLY sys.dm_os_volume_stats(sys.master_files.database_id, sys.master_files.FILE_ID) dovs

ORDER BY sys.databases.name;


/*GROUP BY sys.databases.name
        , sys.master_files.name
       , sys.master_files.growth
       , sys.master_files.is_percent_growth*/

	   SELECT        fileid, groupid, size, maxsize, growth, status, perf, name, filename
FROM            sysfiles