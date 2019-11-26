USE Adastra3;
DECLARE @tableName NVARCHAR(100);
SET @tableName = 'RSECDSParameters'; -- change with table name
SELECT 
	--TABLE_CATALOG
     --, TABLE_SCHEMA
      TABLE_NAME
     , COLUMN_NAME
     --, IS_NULLABLE
     , CASE
           WHEN CHARACTER_MAXIMUM_LENGTH IS NULL THEN DATA_TYPE
           ELSE DATA_TYPE + '(' + CAST(ISNULL(CHARACTER_MAXIMUM_LENGTH, '') AS VARCHAR) + ')'
       END AS DataType
     --, [identity]
FROM
(
    SELECT TABLE_CATALOG
         , TABLE_SCHEMA
         , TABLE_NAME
         , COLUMN_NAME
         , IS_NULLABLE
         , DATA_TYPE
         , COLUMNPROPERTY(OBJECT_ID(TABLE_NAME), COLUMN_NAME, 'IsIdentity') AS [identity]
         , CHARACTER_MAXIMUM_LENGTH
    FROM INFORMATION_SCHEMA.COLUMNS AS [column]
    WHERE(1 = 1)
         AND (TABLE_NAME = @tableName)
) AS MD1;
--  AND [column].[COLUMN_NAME] LIKE '%NationalProviderGroupCode%';
--and [column].[TABLE_SCHEMA] like '%ECDS%'