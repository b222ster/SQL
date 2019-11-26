USE ReportServer;
GO
SELECT ReportPath
     , ReportName
     , SubscriptionID
     , [Next Run Date]
     , [Next Run Time]
     , CAST([To]				AS VARCHAR(4000)) AS [To]			
     , CAST(CC					AS VARCHAR(4000)) AS CC				
     , CAST([Render Format]		AS VARCHAR(4000)) AS [Render Format]	
     , CAST(Subject				AS VARCHAR(4000)) AS Subject			
     , frequency
     , LastStatus
     , EventType
     , LastRunTime
     , DeliveryExtension
     , Version
     , DateImported
FROM
(
    SELECT c.Path AS ReportPath
         , c.Name AS ReportName
         , S.SubscriptionID
         , CASE next_run_date
               WHEN 0 THEN NULL
               ELSE SUBSTRING(CONVERT(VARCHAR(15), next_run_date), 1, 4) + '/' + SUBSTRING(CONVERT(VARCHAR(15), next_run_date), 5, 2) + '/' + SUBSTRING(CONVERT(VARCHAR(15), next_run_date), 7, 2)
           END AS [Next Run Date]
         , ISNULL(CASE LEN(next_run_time)
                      WHEN 3 THEN CAST('00:0' + LEFT(RIGHT(next_run_time, 3), 1) + ':' + RIGHT(next_run_time, 2) AS CHAR(8))
                      WHEN 4 THEN CAST('00:' + LEFT(RIGHT(next_run_time, 4), 2) + ':' + RIGHT(next_run_time, 2) AS CHAR(8))
                      WHEN 5 THEN CAST('0' + LEFT(RIGHT(next_run_time, 5), 1) + ':' + LEFT(RIGHT(next_run_time, 4), 2) + ':' + RIGHT(next_run_time, 2) AS CHAR(8))
                      WHEN 6 THEN CAST(LEFT(RIGHT(next_run_time, 6), 2) + ':' + LEFT(RIGHT(next_run_time, 4), 2) + ':' + RIGHT(next_run_time, 2) AS CHAR(8))
                  END, 'NA') AS [Next Run Time]
         , CONVERT(XML, S.ExtensionSettings).value('(//ParameterValue/Value[../Name="TO"])[1]', 'nvarchar(4000)') AS [To]
         , CONVERT(XML, S.ExtensionSettings).value('(//ParameterValue/Value[../Name="CC"])[1]', 'nvarchar(4000)') AS CC
         , CONVERT(XML, S.ExtensionSettings).value('(//ParameterValue/Value[../Name="RenderFormat"])[1]', 'nvarchar(4000)') AS [Render Format]
         , CONVERT(XML, S.ExtensionSettings).value('(//ParameterValue/Value[../Name="Subject"])[1]', 'nvarchar(4000)') AS Subject
         , CASE
               WHEN MinutesInterval IS NOT NULL THEN 'Every ' + CAST(MinutesInterval AS VARCHAR(10)) + ' Minutes'
               WHEN daysofmonth = 1 THEN '1 Day of Month'
               WHEN daysofmonth = 2 THEN '2 Day of Month'
               WHEN daysofmonth = 4 THEN '3 Day of Month'
               WHEN daysofmonth = 8 THEN '4 Day of Month'
               WHEN daysofmonth = 16 THEN '5 Day of Month'
               WHEN daysofmonth = 32 THEN '6 Day of Month'
               WHEN daysofmonth = 64 THEN '7 Day of Month'
               WHEN daysofmonth = 128 THEN '8 Day of Month'
               WHEN daysofmonth = 256 THEN '9 Day of Month'
               WHEN daysofmonth = 512 THEN '10 Day of Month'
               WHEN daysofmonth = 1024 THEN '11 Day of Month'
               WHEN daysofmonth = 2048 THEN '12 Day of Month'
               WHEN daysofmonth = 4096 THEN '13 Day of Month'
               WHEN daysofmonth = 8192 THEN '14 Day of Month'
               WHEN daysofmonth = 16384 THEN '15 Day of Month'
               WHEN daysofmonth = 32768 THEN '16 Day of Month'
               WHEN daysofmonth = 65536 THEN '17 Day of Month'
               WHEN daysofmonth = 131072 THEN '18 Day of Month'
               WHEN daysofmonth = 262144 THEN '19 Day of Month'
               WHEN daysofmonth = 524288 THEN '20 Day of Month'
               WHEN daysofmonth = 1048576 THEN '21 Day of Month'
               WHEN daysofmonth = 2097152 THEN '22 Day of Month'
               WHEN daysofmonth = 4194304 THEN '23 Day of Month'
               WHEN daysofmonth = 8388608 THEN '24 Day of Month'
               WHEN daysofmonth = 16777216 THEN '25 Day of Month'
               WHEN daysofmonth = 33554432 THEN '26 Day of Month'
               WHEN daysofmonth = 67108864 THEN '27 Day of Month'
               WHEN daysofmonth = 134217728 THEN '28 Day of Month'
               WHEN daysofmonth = 268435456 THEN '29 Day of Month'
               WHEN daysofmonth = 536870912 THEN '30 Day of Month'
               WHEN daysofmonth = 1073741824 THEN '31 Day of  Month'
               WHEN daysofmonth = 8193 THEN '1 and 14 day'
               WHEN DaysOfMonth = 16385 THEN '1 and 15 Day of Month'
               WHEN DaysOfMonth = 1048704 THEN '8 and 21 Day of Month'
               WHEN DaysOfMonth IS NOT NULL THEN CAST(DaysOfMonth AS VARCHAR(10)) + ' Day of Month'
               WHEN DaysOfWeek = 1 THEN 'Monday'
               WHEN DaysOfWeek = 2 THEN 'Tuesday'
               WHEN DaysOfWeek = 4 THEN 'Wednesday'
               WHEN DaysOfWeek = 8 THEN 'Thursday'
               WHEN DaysOfWeek = 16 THEN 'Friday'
               WHEN DaysOfWeek = 32 THEN 'Saturday'
               WHEN DaysOfWeek = 64 THEN 'Sunday'
               WHEN DaysOfWeek = 62 THEN 'Monday – Friday'
               WHEN DaysOfWeek = 120 THEN 'Wednesday – Saturday'
               WHEN DaysOfWeek = 126 THEN 'Monday – Saturday'
               WHEN DaysOfWeek = 127 THEN 'Daily'
           END + ' — Start Time : ' + CAST(DATEPART(hh, SCH.StartDate) AS VARCHAR(2)) + CASE
                                                                                            WHEN LEN(CAST(DATEPART(n, SCH.StartDate) AS VARCHAR(2))) = 1 THEN ':0' + CAST(DATEPART(n, SCH.StartDate) AS VARCHAR(2))
                                                                                            ELSE ':' + CAST(DATEPART(n, SCH.StartDate) AS VARCHAR(2))
                                                                                        END + '' AS frequency
         , S.LastStatus
         , SCH.EventType
         , SCH.LastRunTime
         , S.DeliveryExtension
         , S.Version
         , GETDATE() AS DateImported
    FROM Catalog AS c
         INNER JOIN Subscriptions AS S ON c.ItemID = S.Report_OID
         INNER JOIN ReportSchedule AS R ON S.SubscriptionID = R.SubscriptionID
         INNER JOIN Schedule AS SCH ON R.ScheduleID = SCH.ScheduleID
         INNER JOIN msdb.dbo.sysjobs AS J ON CONVERT(NVARCHAR(128), R.ScheduleID) = J.name
         INNER JOIN msdb.dbo.sysjobschedules AS JS ON J.job_id = JS.job_id
    WHERE(1 = 1)
) AS MainData;
GO