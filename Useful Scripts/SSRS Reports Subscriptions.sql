WITH subscriptionXmL
     AS (SELECT SubscriptionID
              , OwnerID
              , Report_OID
              , Locale
              , InactiveFlags
              , ExtensionSettings
              , CONVERT(XML, ExtensionSettings) AS ExtensionSettingsXML
              , ModifiedByID
              , ModifiedDate
              , Description
              , LastStatus
              , EventType
              , MatchData
              , LastRunTime
              , Parameters
              , DeliveryExtension
              , Version
         FROM ReportServer.dbo.Subscriptions),
     -- Get the settings as pairs
     SettingsCTE
     AS (SELECT SubscriptionID
              , ExtensionSettings
                -- include other fields if you need them.
              , ISNULL(Settings.value('(./*:Name/text())[1]', 'nvarchar(1024)'), 'Value') AS SettingName
              , Settings.value('(./*:Value/text())[1]', 'nvarchar(max)') AS SettingValue
         FROM subscriptionXmL
              CROSS APPLY subscriptionXmL.ExtensionSettingsXML.nodes('//*:ParameterValue') Queries(Settings))
     SELECT SubscriptionID
	-- , ExtensionSettings
	 , SettingName
	 , SettingValue
     FROM SettingsCTE
     WHERE settingName IN
     ('TO'
    , 'CC'
    , 'BCC'
     );
GO
USE [ReportServer];  -- You may change the database name. 
GO
SELECT CAT.Path AS ReportPath
     , USR.UserName AS SubscriptionOwner
     , SUB.ModifiedDate
     , SUB.Description
     , SUB.EventType
     , SUB.DeliveryExtension
     , SUB.LastStatus
     , SUB.LastRunTime
     , SCH.NextRunTime
     , SCH.Name AS ScheduleName
     , CAT.Description AS ReportDescription
     , SUB.SubscriptionID
     , SCH.LastRunStatus
FROM Subscriptions AS SUB
     INNER JOIN Users AS USR ON SUB.OwnerID = USR.UserID
     INNER JOIN Catalog AS CAT ON SUB.Report_OID = CAT.ItemID
     INNER JOIN ReportSchedule AS RS ON SUB.Report_OID = RS.ReportID
                                        AND SUB.SubscriptionID = RS.SubscriptionID
     INNER JOIN Schedule AS SCH ON RS.ScheduleID = SCH.ScheduleID
ORDER BY SubscriptionOwner
       , ReportPath;
