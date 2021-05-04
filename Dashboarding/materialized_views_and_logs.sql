-- Matrilized view Log for each table, these log kkp the record of the changes in the tables and also keep the record of both table and the views where the changing are happend.

--Matrilized view Logs

CREATE MATERIALIZED VIEW LOG ON AIRCRAFTDT
WITH ROWID, SEQUENCE(ID_REGISTRATION_CODE, MODEL, MANUFACTURER)
INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW LOG ON TIMEDT
WITH ROWID, SEQUENCE(ID_TIME, DATE_DAY, CALENDAR_MONTH, CALENDAR_YEAR)
INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW LOG ON AircraftUsageFT
WITH ROWID, SEQUENCE(
   aircraftCodeID,
   timeID,
   scheduledOutOfService,
   unScheduledOutOfService,
   aircrafInService,
   flightHours,
   flightCycles,
   delays,
   delayedMinutes,
   cancellations)
INCLUDING NEW VALUES;

--Matrilized view Aircraft_Usage

CREATE MATERIALIZED VIEW MV_AIRCRAFTUTILIZED
BUILD IMMEDIATE
REFRESH FAST
ON DEMAND
-- UPDATE EACH DAY AT 00:00
START WITH SYSDATE NEXT TRUNC(SYSDATE,'DD') + 1 
ENABLE QUERY REWRITE
 AS
  SELECT a.ID_REGISTRATION_CODE, a.MODEL, t.DATE_DAY, t.CALENDAR_MONTH, t.CALENDAR_YEAR,
    COUNT(*),
    SUM(ac.aircrafInService) as ADIS,
    SUM(ac.scheduledOutOfService) as ADOSS,
    SUM(ac.unScheduledOutOfService) as ADOSU,
    SUM(ac.flightHours) as FH, 
    SUM(ac.flightCycles) as TOC,
    SUM(ac.cancellations) AS CN,
    SUM(ac.delays) AS DC,
    SUM(ac.delayedMinutes) AS DelayDuration
  FROM AIRCRAFTDT a, TIMEDT t, AircraftUsageFT ac
  WHERE ac.aircraftCodeID=a.ID_REGISTRATION_CODE
  AND ac.timeID=t.ID_TIME
  GROUP BY a.ID_REGISTRATION_CODE, a.MODEL, t.DATE_DAY, t.CALENDAR_MONTH, t.CALENDAR_YEAR;

--Matrilized view Logs

CREATE MATERIALIZED VIEW LOG ON REPORTDT
WITH ROWID, SEQUENCE(
   ID_REPORT,  
   ID_PERSON,  
   PERSON_AIRPORT,
   role)
INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW LOG ON LOGBOOKFT
WITH ROWID, SEQUENCE(
   aircraftCodeID,
   timeID,
   reportID,
   counter)
INCLUDING NEW VALUES;

--Matrilized view LOGBOOKREPORT
CREATE MATERIALIZED VIEW MV_LOGBOOKREPORT
BUILD IMMEDIATE
REFRESH FAST
ON DEMAND
-- UPDATE EACH DAY AT 00:00
START WITH SYSDATE NEXT TRUNC(SYSDATE,'DD') + 1 
ENABLE QUERY REWRITE
 AS
  SELECT a.ID_REGISTRATION_CODE, a.MODEL, a.MANUFACTURER, t.CALENDAR_MONTH, t.CALENDAR_YEAR,r.PERSON_AIRPORT, r.ID_PERSON,
    COUNT(*),
    SUM(lb.counter) as COUNTER,
    SUM(ac.flightHours) as FH, 
    SUM(ac.flightCycles) as TOC, -- TO is a reserved name in ORACLE
    SUM(CASE WHEN r.role='P' THEN lb.counter ELSE 0 END) AS PRR,
    SUM(CASE WHEN r.role='M' THEN lb.counter ELSE 0 END) AS MRR
  FROM AIRCRAFTDT a, TIMEDT t, AircraftUsageFT ac, REPORTDT r, LOGBOOKFT lb
  WHERE ac.aircraftCodeID=a.ID_REGISTRATION_CODE
  AND ac.timeID=t.ID_TIME
  AND lb.reportID=r.ID_REPORT 
  GROUP BY a.ID_REGISTRATION_CODE, a.MODEL, a.MANUFACTURER, t.CALENDAR_MONTH, t.CALENDAR_YEAR,r.PERSON_AIRPORT, r.ID_PERSON;


