WITH XMLNAMESPACES(DEFAULT 'http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition', 'http://schemas.microsoft.com/SQLServer/reporting/reportdesigner' AS ReportDefinition)
     SELECT MD1.*
     FROM
     (
         SELECT CATDATA.Name AS ReportName
              , CATDATA.Path AS ReportPathLocation
              , STUFF(CATDATA.Path, 1, 1, '') AS Path
              , CATDATA.Name + ' - ' + xmlSorceumn.value('(@Name)[1]', 'VARCHAR(250)') AS DataSetName
              , xmlSorceumn.value('(Query/DataSourceName)[1]', 'VARCHAR(250)') AS DataSoureName
			  , xmlSorceumn.value('(Query/CommandText)[1]', 'VARCHAR(2500)') AS CommandText
         FROM
         (
             SELECT C.Name
                  , c.Path
                  , CONVERT(XML, CONVERT(VARBINARY(MAX), C.Content)) AS reportXML
             FROM ReportServer.dbo.Catalog C
             WHERE C.Content IS NOT NULL
                   AND C.Type = 2
         ) CATDATA
         CROSS APPLY reportXML.nodes('/Report/DataSets/DataSet') xmltable(xmlSorceumn)
         WHERE xmlSorceumn.value('(Query/CommandText)[1]', 'VARCHAR(250)') LIKE '%Case%'
--ORDER BY CATDATA.Name
     ) AS MD1
     WHERE(1 = 1)
          AND MD1.ReportPathLocation NOT LIKE '%Archived%'
     ORDER BY md1.ReportName;