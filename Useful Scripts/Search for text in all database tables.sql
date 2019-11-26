CREATE TABLE #result(
  id      INT IDENTITY, -- just for register seek order
  tblName VARCHAR(255),
  colName VARCHAR(255),
  qtRows  INT
)
go

DECLARE @toLookFor VARCHAR(255)
--SET @toLookFor = '[input your search criteria here]'
SET @toLookFor = 'Vocational'

DECLARE cCursor CURSOR LOCAL FAST_FORWARD FOR
SELECT
  '[' + usr.name + '].[' + tbl.name + ']' AS tblName,
  '[' + col.name + ']' AS colName,
  LOWER(typ.name) AS typName
FROM
  sysobjects tbl
    INNER JOIN(
      syscolumns col
        INNER JOIN systypes typ
        ON typ.xtype = col.xtype
    )
    ON col.id = tbl.id
    --
    LEFT OUTER JOIN sysusers usr
    ON usr.uid = tbl.uid

WHERE tbl.xtype = 'U'
  AND LOWER(typ.name) IN(
        'char', 'nchar',
        'varchar', 'nvarchar',
        'text', 'ntext'
      )
ORDER BY tbl.name, col.colorder
--
DECLARE @tblName VARCHAR(255)
DECLARE @colName VARCHAR(255)
DECLARE @typName VARCHAR(255)
--
DECLARE @sql  NVARCHAR(4000)
DECLARE @crlf CHAR(2)

SET @crlf = CHAR(13) + CHAR(10)

OPEN cCursor
FETCH cCursor
INTO @tblName, @colName, @typName

WHILE @@fetch_status = 0
BEGIN
  IF @typName IN('text', 'ntext')
  BEGIN
    SET @sql = ''
    SET @sql = @sql + 'INSERT INTO #result(tblName, colName, qtRows)' + @crlf
    SET @sql = @sql + 'SELECT @tblName, @colName, COUNT(*)' + @crlf
    SET @sql = @sql + 'FROM ' + @tblName + @crlf
    SET @sql = @sql + 'WHERE PATINDEX(''%'' + @toLookFor + ''%'', ' + @colName + ') > 0' + @crlf
  END
  ELSE
  BEGIN
    SET @sql = ''
    SET @sql = @sql + 'INSERT INTO #result(tblName, colName, qtRows)' + @crlf
    SET @sql = @sql + 'SELECT @tblName, @colName, COUNT(*)' + @crlf
    SET @sql = @sql + 'FROM ' + @tblName + @crlf
    SET @sql = @sql + 'WHERE ' + @colName + ' LIKE ''%'' + @toLookFor + ''%''' + @crlf
  END

  EXECUTE sp_executesql
            @sql,
            N'@tblName varchar(255), @colName varchar(255), @toLookFor varchar(255)',
            @tblName, @colName, @toLookFor

  FETCH cCursor
  INTO @tblName, @colName, @typName
END

SELECT *
FROM #result
WHERE qtRows > 0
ORDER BY id
GO

DROP TABLE #result
go