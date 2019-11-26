WITH
[Sub_Parameters] AS
    (SELECT 
        [SubscriptionID],
        [Parameters] = CONVERT(XML,a.[Parameters]),
        [ExtensionSettings] = CONVERT(XML,a.[ExtensionSettings])
     FROM [Subscriptions] a
    )

, [MySubscriptions] AS (
    SELECT --DISTINCT 
        [SubscriptionID],
        [ParameterName] = QUOTENAME(p.value('(Name)[1]', 'nvarchar(max)')),
        [ParameterValue] = p.value('(Value)[1]', 'nvarchar(max)')
    FROM [Sub_Parameters] a
    CROSS APPLY [Parameters].nodes('/ParameterValues/ParameterValue') t(p)
    UNION
    SELECT --DISTINCT 
        [SubscriptionID],
        [ExtensionSettingName] = QUOTENAME(e.value('(Name)[1]', 'nvarchar(max)')),
        [ExtensionSettingValue] = e.value('(Value)[1]', 'nvarchar(max)')
    FROM [Sub_Parameters] a
    CROSS APPLY [ExtensionSettings].nodes('/ParameterValues/ParameterValue') t(e)
    )

, [SubscriptionsAnalysis] AS (
    SELECT
        a.[SubscriptionID],
        a.[ParameterName],
        [ParameterValue] =
              (SELECT STUFF((SELECT [ParameterValue] + ', ' as [text()] 
               FROM [MySubscriptions] 
               WHERE [SubscriptionID] = a.[SubscriptionID] 
                   AND [ParameterName] = a.[ParameterName] FOR XML PATH('')),1, 0, '')+'')
    FROM [MySubscriptions] a
    GROUP BY a.[SubscriptionID],a.[ParameterName]
    )

SELECT
    a.[SubscriptionID],
    c.[UserName] AS [Owner], 
    b.[Name],
    b.[Path],
    a.[Locale], 
    a.[InactiveFlags], 
    d.[UserName] AS [Modified_by], 
    a.[ModifiedDate], 
    a.[Description], 
    a.[LastStatus], 
    a.[EventType], 
    a.[LastRunTime], 
    a.[DeliveryExtension],
    a.[Version],
    e.[ParameterName],
    LEFT(e.[ParameterValue],LEN(e.[ParameterValue])-1) as [ParameterValue],
    SUBSTRING(b.[PATH],2,LEN(b.[PATH])-(CHARINDEX('/',REVERSE(b.[PATH]))+1)) AS [ProjectName]
FROM [Subscriptions] a 
INNER JOIN [Catalog] AS b ON a.[Report_OID] = b.[ItemID]
LEFT OUTER JOIN [Users] AS c ON a.[OwnerID] = c.[UserID]
LEFT OUTER JOIN [Users] AS d ON a.[ModifiedByID] = d.[Userid]
LEFT OUTER JOIN [SubscriptionsAnalysis] AS e ON a.[SubscriptionID] = e.[SubscriptionID]
	WHERE (1 = 1)
	AND b.Name like '%111_BSW_CallLog%'