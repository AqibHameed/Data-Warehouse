-- TABLE CREATION

--Schema of the Tables

CREATE TABLE "AQIB.HAMEED".AIRCRAFTDT(
   ID_REGISTRATION_CODE CHAR(6),
   MODEL VARCHAR2 (255 CHAR) NOT NULL,
   MANUFACTURER VARCHAR2 (255 CHAR) NOT NULL,
   PRIMARY KEY (ID_REGISTRATION_CODE)
);

CREATE TABLE "AQIB.HAMEED".TIMEDT(
   ID_TIME CHAR(6),
   DATE_DAY DATE NOT NULL,
   CALENDAR_MONTH VARCHAR2 (25 CHAR) NOT NULL,
   CALENDAR_YEAR VARCHAR2 (25 CHAR) NOT NULL,
   PRIMARY KEY (ID_TIME)
);



CREATE TABLE "AQIB.HAMEED".AircraftUsageFT(
   aircraftCodeID CHAR(6),
   timeID CHAR(6),
   scheduledOutOfService NUMBER(3),
   unScheduledOutOfService NUMBER(3),
   aircrafInService NUMBER(3),
   flightHours NUMBER(3),
   flightCycles NUMBER(3),
   delays NUMBER(3),
   delayedMinutes NUMBER(3),
   cancellations NUMBER(2),
   PRIMARY KEY (aircraftCodeID, timeID),
   FOREIGN KEY (aircraftCodeID) REFERENCES AIRCRAFTDT(ID_REGISTRATION_CODE),
   FOREIGN KEY (timeID) REFERENCES TIMEDT(ID_TIME)

);

CREATE TABLE "AQIB.HAMEED".REPORTDT (
   ID_REPORT CHAR(6),  
   ID_PERSON CHAR(6),  
   PERSON_AIRPORT CHAR(10),
   role CHAR(1) CHECK (role IN ('P','M')) NOT NULL,
   PRIMARY KEY (ID_REPORT)
);

CREATE TABLE "AQIB.HAMEED".LOGBOOKFT(
   aircraftCodeID CHAR(6),
   timeID CHAR(6),
   reportID CHAR(6),
   counter NUMBER(3),
   PRIMARY KEY (aircraftCodeID, timeID, reportID),
   FOREIGN KEY (aircraftCodeID) REFERENCES AIRCRAFTDT(ID_REGISTRATION_CODE),
   FOREIGN KEY (timeID) REFERENCES TIMEDT(ID_TIME),
   FOREIGN KEY (reportID) REFERENCES REPORTDT(ID_REPORT)

);





-- Materialized view Log for each table, these log kkp the record of the changes in the tables and also keep the record of both table and the views where the changing are happend.

--Materialized view Logs

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

--Materialized view Aircraft_Usage per month per aircraft code

CREATE MATERIALIZED VIEW MV_AIRCRAFTUTILIZED_MONTH
BUILD IMMEDIATE
REFRESH FAST
ON DEMAND
-- UPDATE FROM NOW, MONTHLY AT 00:00
START WITH SYSDATE NEXT (ADD_MONTHS(TRUNC(SYSDATE,'MM'),1)) 
ENABLE QUERY REWRITE
 AS
  SELECT a.ID_REGISTRATION_CODE, t.CALENDAR_MONTH,
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
  GROUP BY a.ID_REGISTRATION_CODE, t.CALENDAR_MONTH;


--Materialized view Aircraft_Usage per year per aircraft code

CREATE MATERIALIZED VIEW MV_AIRCRAFTUTILIZED_YEAR
BUILD IMMEDIATE
REFRESH FAST
ON DEMAND
-- UPDATE FROM NOW, YEARLY AT 00:00
START WITH SYSDATE NEXT (ADD_MONTHS(TRUNC(SYSDATE,'MM'),1)) 
ENABLE QUERY REWRITE
 AS
  SELECT a.ID_REGISTRATION_CODE,t.CALENDAR_YEAR,
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
  GROUP BY a.ID_REGISTRATION_CODE, t.CALENDAR_YEAR;



--Materialized view Logs

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

--Materialized view LOGBOOKREPORT per month per aircraft code

CREATE MATERIALIZED VIEW MV_LOGBOOKREPORT_MONTH
BUILD IMMEDIATE
REFRESH FAST
ON DEMAND
-- UPDATE FROM NOW, MONTHLY AT 00:00
START WITH SYSDATE NEXT (ADD_MONTHS(TRUNC(SYSDATE,'MM'),1))
ENABLE QUERY REWRITE
 AS
  SELECT a.ID_REGISTRATION_CODE, t.CALENDAR_MONTH,
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
  GROUP BY a.ID_REGISTRATION_CODE,t.CALENDAR_MONTH;




--Materialized view LOGBOOKREPORT per year per aircraft code

CREATE MATERIALIZED VIEW MV_LOGBOOKREPORT_YEAR
BUILD IMMEDIATE
REFRESH FAST
ON DEMAND
-- UPDATE FROM NOW, YEARLY AT 00:00
START WITH SYSDATE NEXT (ADD_MONTHS(TRUNC(SYSDATE,'MM'),1))
ENABLE QUERY REWRITE
 AS
  SELECT a.ID_REGISTRATION_CODE, t.CALENDAR_YEAR,
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
  GROUP BY a.ID_REGISTRATION_CODE, t.CALENDAR_YEAR;


