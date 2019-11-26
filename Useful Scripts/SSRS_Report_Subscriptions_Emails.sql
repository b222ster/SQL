/*tbl_SSRS_Subscription_Detail*/
DECLARE @Date DATETIME, @DaysOfWeek INT, @DaysOfMonth INT;
SET @Date = GETDATE();
SELECT @DaysOfWeek = CASE DATEPART(DW, @Date)
                         WHEN 1 THEN 1  --Sunday
                         WHEN 2 THEN 2  --Monday
                         WHEN 3 THEN 4  --Tuesday
                         WHEN 4 THEN 8  --Wednesday
                         WHEN 5 THEN 16 --Thursday
                         WHEN 6 THEN 32 --Friday
                         WHEN 7 THEN 64 --Saturday
                     END;
SELECT @DaysOfMonth = CASE DATEPART(D, @Date)
                          WHEN 1 THEN 1
                          ELSE POWER(2, (CAST(DATEPART(D, @Date) AS INT) - 1))
                      END;			  

SELECT * FROM (
SELECT DISTINCT 
       SUB.ReportPath
     , SUB.ReportName
     , SUB.ReportOwner
     , ModifiedDate
     , Description
     , EventType
     , DeliveryExtension
     , LastStatus
     , LastRunTime
     , SubscriptionID
     , EMail.value('Value[1]', 'VARCHAR(1000)') AS EmailAddresses
	 , ISNULL(EMail.value('(./*:Name/text())[1]', 'nvarchar(1024)'), 'Value') AS SettingName
     , EMail.value('(./*:Value/text())[1]', 'nvarchar(4000)') AS SettingValue
FROM
(
    SELECT C.[Path] AS ReportPath
         , C.Name AS ReportName
         , U.UserName AS ReportOwner
         , SB.ModifiedDate
         , SB.Description
         , SB.EventType
         , SB.DeliveryExtension
         , SB.LastStatus
         , SB.LastRunTime
         , S.NextRunTime
         , S.Name AS ScheduleName
         , C.Description AS ReportDescription
         , SB.SubscriptionID
         , S.LastRunStatus
         , CONVERT(XML, SB.ExtensionSettings) AS Ext
    FROM ReportServer.dbo.ReportSchedule RS
         JOIN ReportServer.dbo.Schedule S ON S.ScheduleID = RS.ScheduleID
                                             AND S.RecurrenceType = 2
                                             OR (S.RecurrenceType = 4
                                                 AND (S.DaysOfWeek = @DaysOfWeek))
                                             OR (S.RecurrenceType = 5
                                                 AND (S.DaysOfMonth = @DaysOfMonth))
         JOIN ReportServer.dbo.[Catalog] C ON C.ItemID = RS.ReportID
         JOIN ReportServer.dbo.Subscriptions SB ON SB.SubscriptionID = RS.SubscriptionID
         JOIN ReportServer.dbo.Users U ON U.UserID = SB.OwnerID
) SUB
CROSS APPLY Ext.nodes('/ParameterValues/ParameterValue') AS SubEMail(EMail)
WHERE EMail.value('Value[1]', 'VARCHAR(1000)') LIKE '%[^ ]@%';