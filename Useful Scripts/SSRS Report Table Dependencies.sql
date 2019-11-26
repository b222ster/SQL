WITH Reports
     AS (SELECT Name AS ReportName
              , CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), Content)) AS ReportContent
         FROM Catalog
         WHERE Name IS NOT NULL)
     SELECT ReportName
     FROM Reports
     WHERE ReportContent LIKE '%Case%';