CREATE TABLE [dbo].[tbl_SQLAudit_History]
(event_time						DATETIME
, sequence_number				INT
, action_id						VARCHAR(10)
, server_principal_name			VARCHAR(255)
, server_instance_name			VARCHAR(255)
, database_name					VARCHAR(255)
, schema_name					VARCHAR(255)
, object_name					VARCHAR(500)
, statement						VARCHAR(MAX)
);

EXECUTE [dbo].[sp_SqlAuditCaptureAuditLogs]


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