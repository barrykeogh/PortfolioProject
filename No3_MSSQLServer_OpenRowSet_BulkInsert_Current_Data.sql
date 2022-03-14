-- DROP TABLE finances.dbo.Current_Import_CSV;

--CREATE TABLE finances.dbo.Current_Import_CSV (
--	Date varchar(20)
--	, Type varchar(10)
--	, Description varchar(100)
--	, Value float
--	, Balance float
--	, Name varchar(20)
--	, Account varchar(50)
--	);

INSERT INTO finances.dbo.Current_Import_CSV
	SELECT * FROM
	OPENROWSET(
		BULK 'C:\dev\workspace\Portfolio\DataAnalyst_2_Finances\RawData\Current.csv'
		, FORMATFILE = 'C:\dev\workspace\Portfolio\DataAnalyst_2_Finances\OpenRowSet_BulkImport_Scripts\MSSQLServer_OpenRowSet_BulkInsert_Current_Data.txt'
		, FIRSTROW=2
		, FORMAT='CSV'
	) AS TMP;

-- DROP TABLE finances.dbo.CurrentAcc;

--CREATE TABLE finances.dbo.CurrentAcc (
--	Date datetime
--	, CF_FISCAL_YEAR varchar(20)
--	, Type varchar(20)
--	, Description varchar(100)
--	, Value float
--	, Balance float
--	);

WITH Current_ETL AS (SELECT
	CONVERT(datetime, date, 103) as date
	, CASE 
		WHEN CONVERT(INT,SUBSTRING(date,4,2)) <= 9 THEN CONVERT(VARCHAR, (CONVERT(INT, SUBSTRING(date, 7,4))-1)) + '/' + RIGHT(CONVERT(VARCHAR, CONVERT(INT, SUBSTRING(date, 7,4))),2)
		ELSE CONVERT(VARCHAR, (CONVERT(INT, SUBSTRING(date, 7,4)))) + '/' +  RIGHT(CONVERT(VARCHAR, (CONVERT(INT, SUBSTRING(date, 7,4))+1)), 2)
			END AS CF_FISCAL_YEAR 
	, CASE WHEN type = 'D/D' AND VALUE > 0 THEN 'PAYMENT_IN'
		WHEN type = 'D/D' AND VALUE < 0 THEN 'PAYMENT_OUT'
		WHEN type = 'BAC' AND VALUE > 0 THEN 'PAYMENT_IN'
		WHEN type = 'BAC' AND VALUE < 0 THEN 'PAYMENT_OUT'
		WHEN type = 'POS' AND VALUE > 0 THEN 'PAYMENT_IN'
		WHEN type = 'POS' AND VALUE < 0 THEN 'PAYMENT_OUT'
		WHEN type = 'DPC' AND VALUE > 0 THEN 'PAYMENT_IN'
		WHEN type = 'DPC' AND VALUE < 0 THEN 'PAYMENT_OUT'
		ELSE 'ERROR' END AS type
	, description
	, value
	, balance
	FROM finances.dbo.Current_Import_CSV)
--SELECT * FROM Current_ETL;
INSERT INTO finances.dbo.CurrentAcc
SELECT * 
FROM Current_ETL
ORDER BY value desc;
	
