SET NOCOUNT ON;
-- list jobs and schedule info with daily and weekly schedules
-- jobs with a daily schedule
SELECT sysjobs.name job_name
     , sysjobs.enabled job_enabled
     , sysschedules.name schedule_name
     , sysschedules.freq_recurrence_factor
     , CASE
           WHEN freq_type = 4 THEN 'Daily'
       END frequency
     , 'every ' + CAST(freq_interval AS VARCHAR(3)) + ' day(s)' Days
     , CASE
           WHEN freq_subday_type = 2 THEN ' every ' + CAST(freq_subday_interval AS VARCHAR(7)) + ' seconds' + ' starting at ' + STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
           WHEN freq_subday_type = 4 THEN ' every ' + CAST(freq_subday_interval AS VARCHAR(7)) + ' minutes' + ' starting at ' + STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
           WHEN freq_subday_type = 8 THEN ' every ' + CAST(freq_subday_interval AS VARCHAR(7)) + ' hours' + ' starting at ' + STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
           ELSE ' starting at ' + STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
       END time
FROM msdb.dbo.sysjobs
     INNER JOIN msdb.dbo.sysjobschedules ON sysjobs.job_id = sysjobschedules.job_id
     INNER JOIN msdb.dbo.sysschedules ON sysjobschedules.schedule_id = sysschedules.schedule_id
WHERE freq_type = 4
UNION

-- jobs with a weekly schedule
SELECT sysjobs.name job_name
     , sysjobs.enabled job_enabled
     , sysschedules.name schedule_name
     , sysschedules.freq_recurrence_factor
     , CASE
           WHEN freq_type = 8 THEN 'Weekly'
       END frequency
     , replace(CASE
                   WHEN freq_interval&1 = 1 THEN 'Sunday, '
                   ELSE ''
               END + CASE
                         WHEN freq_interval&2 = 2 THEN 'Monday, '
                         ELSE ''
                     END + CASE
                               WHEN freq_interval&4 = 4 THEN 'Tuesday, '
                               ELSE ''
                           END + CASE
                                     WHEN freq_interval&8 = 8 THEN 'Wednesday, '
                                     ELSE ''
                                 END + CASE
                                           WHEN freq_interval&16 = 16 THEN 'Thursday, '
                                           ELSE ''
                                       END + CASE
                                                 WHEN freq_interval&32 = 32 THEN 'Friday, '
                                                 ELSE ''
                                             END + CASE
                                                       WHEN freq_interval&64 = 64 THEN 'Saturday, '
                                                       ELSE ''
                                                   END, ', ', '') Days
     , CASE
           WHEN freq_subday_type = 2 THEN ' every ' + CAST(freq_subday_interval AS VARCHAR(7)) + ' seconds' + ' starting at ' + STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
           WHEN freq_subday_type = 4 THEN ' every ' + CAST(freq_subday_interval AS VARCHAR(7)) + ' minutes' + ' starting at ' + STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
           WHEN freq_subday_type = 8 THEN ' every ' + CAST(freq_subday_interval AS VARCHAR(7)) + ' hours' + ' starting at ' + STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
           ELSE ' starting at ' + STUFF(STUFF(RIGHT(REPLICATE('0', 6) + CAST(active_start_time AS VARCHAR(6)), 6), 3, 0, ':'), 6, 0, ':')
       END time
FROM msdb.dbo.sysjobs
     INNER JOIN msdb.dbo.sysjobschedules ON sysjobs.job_id = sysjobschedules.job_id
     INNER JOIN msdb.dbo.sysschedules ON sysjobschedules.schedule_id = sysschedules.schedule_id
WHERE freq_type = 8
 AND category_id != 100
ORDER BY job_enabled, time DESC;