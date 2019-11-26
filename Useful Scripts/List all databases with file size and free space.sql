DECLARE @DBInfo TABLE
(ServerName       VARCHAR(100)
, DatabaseName     VARCHAR(100)
, FileSizeMB       INT
, LogicalFileName  SYSNAME
, PhysicalFileName NVARCHAR(520)
, STATUS           SYSNAME
, Updateability    SYSNAME
, RecoveryMode     SYSNAME
, FreeSpaceMB      INT
, FreeSpacePct     VARCHAR(7)
, FreeSpacePages   INT
, PollDate         DATETIME
, NextGrowth       VARCHAR(100)
, FileName         VARCHAR(255)
, Drive            VARCHAR(255)
, FreeSpaceInMB    VARCHAR(255)
, StartTime        DATETIME
, EndTime          DATETIME
);
DECLARE @command VARCHAR(5000);
SELECT @command = 'Use [?]
DECLARE @path NVARCHAR(260)
SELECT @path = REVERSE(SUBSTRING(REVERSE([path]), CHARINDEX(''\'', REVERSE([path])), 260)) + N''log.trc''
FROM sys.traces
WHERE is_default = 1

 SELECT  
@@servername as ServerName,  
''?''  AS DatabaseName,  
CAST(sysfiles.size/128.0 AS int) AS FileSize,  
sysfiles.name AS LogicalFileName, sysfiles.filename AS PhysicalFileName,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Status'')) AS Status,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Updateability'')) AS Updateability,  
CONVERT(sysname,DatabasePropertyEx(''?'',''Recovery'')) AS RecoveryMode,  
CAST(sysfiles.size/128.0 - CAST(FILEPROPERTY(sysfiles.name,''SpaceUsed'') AS int)/128.0 AS int) AS FreeSpaceMB,  
CAST(100 * (CAST (((sysfiles.size/128.0 -CAST(FILEPROPERTY(sysfiles.name,  
''SpaceUsed'') AS int)/128.0)/(sysfiles.size/128.0))  
AS decimal(4,2))) AS varchar(8)) + ''%'' AS FreeSpacePct,  
GETDATE() as PollDate,
 CASE WHEN sys.master_files.is_percent_growth = 0 
        THEN CONVERT(VARCHAR, sys.master_files.growth * 8 / 1024) + '' MB'' 
        ELSE CONVERT(VARCHAR, (sys.master_files.size * 8 / 1024) * (sys.master_files.growth / 100)) + '' MB''
       END AS NextGrowth
	    , sys.master_files.name as FileName
		, dovs.volume_mount_point AS Drive
     , CONVERT(VARCHAR(255), CONVERT(INT, dovs.available_bytes / 1048576.0)) + ''MB'' AS FreeSpaceInMB
	 , StartTime
	 ,EndTime
 FROM dbo.sysfiles 
 INNER JOIN sys.master_files ON sys.master_files.name  = ''?''
 LEFT OUTER JOIN (
SELECT DISTINCT
       DatabaseName
     , FileName

     , MAX(StartTime) AS StartTime
     , MAX(EndTime) AS EndTime
FROM ::fn_trace_gettable(@path, DEFAULT) AS fn_trace_gettable_1
WHERE(EventClass IN(92, 93))
GROUP BY DatabaseName
       , FileName

) as MD1 on MD1.DatabaseName = ''?''
 CROSS APPLY sys.dm_os_volume_stats(sys.master_files.database_id, sys.master_files.FILE_ID) dovs';
INSERT INTO @DBInfo
(ServerName
, DatabaseName
, FileSizeMB
, LogicalFileName
, PhysicalFileName
, STATUS
, Updateability
, RecoveryMode
, FreeSpaceMB
, FreeSpacePct
, PollDate
, NextGrowth
, FileName
, Drive
, FreeSpaceInMB
, StartTime
, EndTime
)
EXEC sp_MSForEachDB 
     @command;
SELECT ServerName
     , DatabaseName
     , FileSizeMB
	 , FreeSpaceMB
     , FreeSpacePct
	 , NextGrowth
     , StartTime as LastGrowthStartTime
     , EndTime as LastGrowthEndTime
     , FileName
     , LogicalFileName
     , PhysicalFileName
     , Drive
     , FreeSpaceInMB
     , STATUS
     , Updateability
     , RecoveryMode
     , PollDate
FROM @DBInfo
ORDER BY ServerName
       , DatabaseName;