--USE OBKFeeds;
--GO
SELECT ServerName
     , DatabaseName
     , SchemaName
     , TableName
     , [RowCount]
     , DateImported
FROM
(
    SELECT TOP (100) PERCENT @@SERVERNAME AS ServerName
                           , DB_NAME() AS DatabaseName
                           , SCHEMA_NAME(sOBJ.schema_id) AS SchemaName
                           , QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)) + '.' + QUOTENAME(sOBJ.name) AS TableName
                           , SUM(sdmvPTNS.row_count) AS [RowCount]
                           , GETDATE() AS DateImported
    FROM sys.objects AS sOBJ
         INNER JOIN sys.dm_db_partition_stats AS sdmvPTNS ON sOBJ.object_id = sdmvPTNS.object_id
    WHERE(1 = 1)
         AND (sOBJ.type = 'U')
         AND (sOBJ.is_ms_shipped = 0x0)
         AND (sdmvPTNS.index_id < 2)
    GROUP BY sOBJ.schema_id
           , sOBJ.name
    ORDER BY TableName
) AS MainData
WHERE (1 = 1);



-- -- MDSArchive
-- SELECT @@SERVERNAME AS [ServerName]
--      , DB_NAME() AS [DatabaseName]
--      , SCHEMA_NAME() AS [SchemaName]
--      , 'tbl_Adastra_MDSArchive' AS [TableName]
-- 	 , 'Testing row counts' as [TestDescription]
-- 	 , CAST(takenat as date) as [CountDate]
--      , COUNT(*) AS [Count]
--      , GETDATE() AS [DateImported]
-- FROM tbl_Adastra_MDSArchive
-- WHERE(1 = 1)
--      AND CAST(takenat as date) >= CAST(DATEADD(Day, -30, GETDATE())as date) --DateFrom
-- 	 AND CAST(takenat as date) <= CAST(GETDATE() as date) --DateTo
-- GROUP BY
-- CAST(takenat as date)
-- ORDER BY CountDate;


-- -- RS111_Combined
-- SELECT @@SERVERNAME AS [ServerName]
--      , DB_NAME() AS [DatabaseName]
--      , SCHEMA_NAME() AS [SchemaName]
--      , 'tbl_Adastra_RS111_Combined' AS [TableName]
-- 	 , 'Testing row counts' as [TestDescription]
-- 	 , CAST(ActiveDate as date) as [CountDate]
--      , COUNT(*) AS [Count]
--      , GETDATE() AS [DateImported]
-- FROM tbl_Adastra_RS111_Combined
-- WHERE(1 = 1)
--      AND CAST(ActiveDate as date) >= CAST(DATEADD(Day, -30, GETDATE()) as date)--DateFrom
-- 	 AND CAST(ActiveDate as date) <=  CAST(GETDATE()					   as date)--DateTo
-- GROUP BY
-- CAST(ActiveDate as date)
-- ORDER BY 
-- CountDate;
-- GO 
-- USE OBKFeeds;

-- GO
-- SELECT * FROM [dbo].[tbl_TestTableCounts]
-- where CountDate = '2019-04-30'