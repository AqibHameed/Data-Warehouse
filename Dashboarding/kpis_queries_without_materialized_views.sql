--Queries  without Materilized views 

a) Give me FH and TO per aircraft (also per model) per day (also per month and per year). 

SELECT a.ID_REGISTRATION_CODE, a.MODEL, t.DATE_DAY, t.CALENDAR_MONTH, t.CALENDAR_YEAR,
  SUM(ac.flightHours) as FH, SUM(ac.flightCycles) as TOC -- TO is a reserved name in ORACLE
  FROM AIRCRAFTDT a, TIMEDT t, AircraftUsageFT ac
  WHERE ac.aircraftCodeID=a.ID_REGISTRATION_CODE
  AND ac.timeID=t.ID_TIME
  GROUP BY a.ID_REGISTRATION_CODE, a.MODEL, t.DATE_DAY, t.CALENDAR_MONTH, t.CALENDAR_YEAR
  ORDER BY a.ID_REGISTRATION_CODE, a.MODEL, t.DATE_DAY, t.CALENDAR_MONTH, t.CALENDAR_YEAR;

b) Give me ADIS, ADOS, ADOSS, ADOSU, DYR, CNR, TDR, ADD per aircraft (also per model) 
per month (also per year).  

SELECT a.ID_REGISTRATION_CODE, a.MODEL, t.CALENDAR_MONTH, t.CALENDAR_YEAR,
    SUM(ac.aircrafInService) as ADIS,
    SUM(ac.scheduledOutOfService) as ADOSS,
    SUM(ac.unScheduledOutOfService) as ADOSU,
    SUM(ac.scheduledOutOfService) + SUM(ac.unScheduledOutOfService) as ADOS,
    SUM(ac.delays)/SUM(ac.flightCycles)*100 as DYR,
    SUM(ac.cancellations) AS CN,
    SUM(ac.delays) AS DC,   
    SUM(ac.cancellations)/SUM(ac.flightCycles)*100 as CNR,
    100 - ((SUM(ac.cancellations) + SUM(ac.delays))/SUM(ac.flightCycles))*100 as TDR,
    SUM(ac.delayedMinutes)/SUM(ac.delays)*100 as AVGDD -- ADD is a reserved name in ORACLE
    FROM AIRCRAFTDT a, TIMEDT t, AircraftUsageFT ac
    WHERE ac.aircraftCodeID=a.ID_REGISTRATION_CODE AND ac.timeID=t.ID_TIME
    GROUP BY a.ID_REGISTRATION_CODE, a.MODEL, t.CALENDAR_MONTH, t.CALENDAR_YEAR
    ORDER BY a.ID_REGISTRATION_CODE, a.MODEL, t.CALENDAR_MONTH, t.CALENDAR_YEAR;

c) Give me the RRh, RRc, PRRh, PRRc, MRRh and MRRc per aircraft (also per model and 
manufacturer) per month (also per year). 

SELECT a.ID_REGISTRATION_CODE, a.MODEL, a.MANUFACTURER, t.CALENDAR_MONTH, t.CALENDAR_YEAR,
       1000*SUM(lb.counter)/SUM(ac.flightHours) as RRh,
       100*SUM(lb.counter)/SUM(ac.flightCycles) as RRc,
       1000*SUM(CASE WHEN r.role='P' THEN lb.counter ELSE 0 END)/SUM(ac.flightHours) as PRRh,
       100*SUM(CASE WHEN r.role='P' THEN lb.counter ELSE 0 END)/SUM(ac.flightCycles) as PRRc,
       1000*SUM(CASE WHEN r.role='M' THEN lb.counter ELSE 0 END)/SUM(ac.flightHours) as MRRh,
       100*SUM(CASE WHEN r.role='M' THEN lb.counter ELSE 0 END)/SUM(ac.flightCycles) as MRRc
  FROM AIRCRAFTDT a, TIMEDT t, REPORTDT r, AircraftUsageFT ac, LOGBOOKFT lb
  WHERE lb.aircraftCodeID=a.ID_REGISTRATION_CODE
  AND lb.timeID=t.ID_TIME
  AND lb.reportID=r.ID_REPORT 
  GROUP BY a.ID_REGISTRATION_CODE, a.MODEL, a.MANUFACTURER, t.CALENDAR_MONTH, t.CALENDAR_YEAR
  ORDER BY a.ID_REGISTRATION_CODE, a.MODEL, a.MANUFACTURER, t.CALENDAR_MONTH, t.CALENDAR_YEAR;

d) Give me the MRRh and MRRc per airport of the reporting person per aircraft (also per 
model). 

SELECT a.ID_REGISTRATION_CODE, a.MODEL, r.PERSON_AIRPORT, r.ID_PERSON, 
       1000*SUM(CASE WHEN r.role='M' THEN lb.counter ELSE 0 END)/SUM(ac.flightHours) as MRRh,
       100*SUM(CASE WHEN r.role='M' THEN lb.counter ELSE 0 END)/SUM(ac.flightCycles) as MRRc
  FROM AIRCRAFTDT a, TIMEDT t, REPORTDT r, AircraftUsageFT ac, LOGBOOKFT lb
  WHERE lb.aircraftCodeID=a.ID_REGISTRATION_CODE
  AND lb.timeID=t.ID_TIME
  AND lb.reportID=r.ID_REPORT 
  GROUP BY a.ID_REGISTRATION_CODE, a.MODEL, r.PERSON_AIRPORT, r.ID_PERSON 
  ORDER BY a.ID_REGISTRATION_CODE, a.MODEL, r.PERSON_AIRPORT, r.ID_PERSON;


