USE ReportServer;
GO

--Find schedule ID
SELECT ScheduleID
FROM ReportSchedule		 
WHERE (SubscriptionID = '950630eb-0418-4f2c-8245-89b98803a942')

EXEC ReportServer.dbo.AddEvent @EventType='TimedSubscription', 
@EventData='0f9108de-81fd-473a-9e0e-fc9f96d748f1'