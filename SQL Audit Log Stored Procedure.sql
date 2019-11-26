USE [OBKFeeds];
GO

/****** Object:  StoredProcedure [dbo].[sp_SqlAuditCaptureAuditLogs]    Script Date: 28/05/2019 15:30:14 ******/

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE PROCEDURE [dbo].[sp_SqlAuditCaptureAuditLogs]
AS
    BEGIN
        SET XACT_ABORT ON;
        EXEC xp_cmdshell 
             'powershell.exe "Move-Item C:\SQLData\MSSQL12.MSSQLSERVER\MSSQL\Audits\*.sqlaudit C:\SQLData\MSSQL12.MSSQLSERVER\MSSQL\Audits\SQLAuditLogs_Staging -ErrorAction SilentlyContinue"', 
             no_output;
        DECLARE @TableSize TABLE(TotalSizeIN_MB NUMERIC(36, 2));
        INSERT INTO @TableSize
               SELECT Total_MB
               FROM
               (
                   SELECT s.Name AS SchemaName
                        , t.Name AS TableName
                        , p.rows AS RowCounts
                        , CAST(ROUND((SUM(a.used_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Used_MB
                        , CAST(ROUND((SUM(a.total_pages) - SUM(a.used_pages)) / 128.00, 2) AS NUMERIC(36, 2)) AS Unused_MB
                        , CAST(ROUND((SUM(a.total_pages) / 128.00), 2) AS NUMERIC(36, 2)) AS Total_MB
                   FROM sys.tables t
                        INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
                        INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID
                                                       AND i.index_id = p.index_id
                        INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
                        INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
                   WHERE(1 = 1)
                        AND s.name = 'dbo'
                        AND t.name = 'tbl_SQLAudit_History'
                   GROUP BY t.Name
                          , s.Name
                          , p.Rows
               ) AS MainData;
        -- Add Results in a variable
        DECLARE @TotalTableSize NUMERIC(36, 2)=
        (
            SELECT TotalSizeIN_MB
            FROM @TableSize
        );
        -- IF TableTotalSize > 1024.00 MB (1 GB) THEN TRUNCATE OTHERWISE JUST SELECT
        IF @TotalTableSize > '1024.00'
            TRUNCATE TABLE [dbo].[tbl_SQLAudit_History];
            ELSE
            INSERT INTO [dbo].[tbl_SQLAudit_History]
            (event_time
           , sequence_number
           , action_id
           , server_principal_name
           , server_instance_name
           , database_name
           , schema_name
           , object_name
           , statement
            )
                   SELECT event_time
                        , sequence_number
                        , action_id
                        , server_principal_name
                        , server_instance_name
                        , database_name
                        , schema_name
                        , object_name
                        , statement
                   FROM sys.fn_get_audit_file('C:\SQLData\MSSQL12.MSSQLSERVER\MSSQL\Audits\*.*', DEFAULT, DEFAULT);
        EXEC xp_cmdshell 
             'powershell.exe "Remove-Item C:\SQLData\MSSQL12.MSSQLSERVER\MSSQL\Audits\*.* -ErrorAction SilentlyContinue"', 
             no_output;
    END;
GO