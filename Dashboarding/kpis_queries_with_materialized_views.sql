--Queries  with Materilized views 
a) Give me FH and TO per aircraft (also per model) per day (also per month and per year). 

SELECT mac.ID_REGISTRATION_CODE, mac.MODEL, mac.DATE_DAY, mac.CALENDAR_MONTH, mac.CALENDAR_YEAR,
  SUM(mac.FH) as FH, SUM(mac.TOC) as TOC -- TO is a reserved name in ORACLE
  FROM MV_AIRCRAFTUTILIZED mac, AIRCRAFTDT a
  WHERE mac.ID_REGISTRATION_CODE=a.ID_REGISTRATION_CODE
  GROUP BY mac.ID_REGISTRATION_CODE, mac.MODEL, mac.DATE_DAY, mac.CALENDAR_MONTH, mac.CALENDAR_YEAR
  ORDER BY mac.ID_REGISTRATION_CODE, mac.MODEL, mac.DATE_DAY, mac.CALENDAR_MONTH, mac.CALENDAR_YEAR;
b) Give me ADIS, ADOS, ADOSS, ADOSU, DYR, CNR, TDR, ADD per aircraft (also per model) 

SELECT mac.ID_REGISTRATION_CODE, mac.MODEL, mac.CALENDAR_MONTH, mac.CALENDAR_YEAR,
    SUM(mac.ADIS) as ADIS,
    SUM(mac.ADOSS) as ADOSS,
    SUM(mac.ADOSU) as ADOSU,
    SUM(mac.ADOSS) + SUM(mac.ADOSU) as ADOS,
    SUM(mac.DC)/SUM(mac.TOC)*100 as DYR,
    SUM(mac.CN) AS CN,
    SUM(mac.DC) AS DC,   
    SUM(mac.CN)/SUM(mac.TOC)*100 as CNR,
    100 - ((SUM(mac.CN) + SUM(mac.DC))/SUM(mac.TOC))*100 as TDR,
    SUM(mac.DelayDuration)/SUM(mac.DC)*100 as AVGDD -- ADD is a reserved name in ORACLE
    FROM MV_AIRCRAFTUTILIZED mac, AIRCRAFTDT a
    WHERE mac.ID_REGISTRATION_CODE=a.ID_REGISTRATION_CODE
    GROUP BY mac.ID_REGISTRATION_CODE, mac.MODEL, mac.CALENDAR_MONTH, mac.CALENDAR_YEAR
    ORDER BY mac.ID_REGISTRATION_CODE, mac.MODEL, mac.CALENDAR_MONTH, mac.CALENDAR_YEAR;

c) Give me the RRh, RRc, PRRh, PRRc, MRRh and MRRc per aircraft (also per model and 
manufacturer) per month (also per year). 

SELECT mlb.ID_REGISTRATION_CODE, mlb.MODEL, mlb.MANUFACTURER, mlb.CALENDAR_MONTH, mlb.CALENDAR_YEAR,
       1000*SUM(mlb.COUNTER)/SUM(mlb.FH) as RRh,
       100*SUM(mlb.counter)/SUM(mlb.TOC) as RRc,
       1000*SUM(mlb.PRR)/SUM(mlb.FH) as PRRh,
       100*SUM(mlb.PRR)/SUM(mlb.TOC) as PRRc,
       1000*SUM(mlb.MRR)/SUM(mlb.FH) as MRRh,
       100*SUM(mlb.MRR)/SUM(mlb.TOC) as MRRc
  FROM MV_LOGBOOKREPORT mlb, AIRCRAFTDT a
  WHERE mlb.ID_REGISTRATION_CODE=a.ID_REGISTRATION_CODE
  GROUP BY mlb.ID_REGISTRATION_CODE, mlb.MODEL, mlb.MANUFACTURER, mlb.CALENDAR_MONTH, mlb.CALENDAR_YEAR
  ORDER BY mlb.ID_REGISTRATION_CODE, mlb.MODEL, mlb.MANUFACTURER, mlb.CALENDAR_MONTH, mlb.CALENDAR_YEAR;

d) Give me the MRRh and MRRc per airport of the reporting person per aircraft (also per 
model). 

SELECT mlb.ID_REGISTRATION_CODE, mlb.MODEL, mlb.PERSON_AIRPORT, mlb.ID_PERSON, 
       1000*SUM(mlb.MRR)/SUM(mlb.FH) as MRRh,
       100*SUM(mlb.MRR)/SUM(mlb.TOC) as MRRc
  FROM MV_LOGBOOKREPORT mlb, AIRCRAFTDT a
  WHERE mlb.ID_REGISTRATION_CODE=a.ID_REGISTRATION_CODE
  GROUP BY mlb.ID_REGISTRATION_CODE, mlb.MODEL, mlb.PERSON_AIRPORT, mlb.ID_PERSON
  ORDER BY mlb.ID_REGISTRATION_CODE, mlb.MODEL, mlb.PERSON_AIRPORT, mlb.ID_PERSON;
