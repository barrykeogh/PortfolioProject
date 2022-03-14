# PortfolioProject - Overview of the work contained within each file of my PortfolioProject Repository

No1_Portfolio_Oracle_Coronavirus.sql
------------------------------------
Data loaded from CSV file onto an Oracle Database Schema using Oracle DATA IMPORT WIZARD
 - Table Joins
 - Common Table Expressions (CTE)
 - Windows Functions (FUNCTION() OVER(PARTITION BY field list ORDER BY field list ROWS BETWEEN CURRENT AND number FOLLOWING)
 - Datatype Conversion


No2_Portfolio_MSSQLServer_DataCleansing_NashvilleHousing.sql
------------------------------------------------------------
Data loaded from CSV file onto MS SQL Server Database using SQL Server Import and Export Wizard
 - Add & Rename Columns
 - Self-Joins
 - Splitting Column data with Functions (CHARINDEX, REVERSE, LEFT, SUBSTRING, LEN, PARSENAME, TRIM, REPLACE)
 - Common Table Expressions
 - Windows Functions (ROWNUMBER, RANK)
 - CASE Statements


No3_MSSQLServer_OpenRowSet_BulkInsert_Current_Data.sql
------------------------------------------------------
No4_MSSQLServer_OpenRowSet_BulkInsert_Current_Data.txt
------------------------------------------------------
MS SQL Server Script and format file to perform the following
- Create Staging table
- Import data using OPENROWSET and BULKINSERT functions with format file
- Create data table
- Use CTE to perform Transformation and Load data from staging table


No5_Excel_DataAnalysis_CSV_PowerQuery_PivotTables_ArrayLists.xlsx
-----------------------------------------------------------------
Excel spreadsheet providing analysis of financial data using;
 - CSV source data files
 - PowerQuery to load and transform data from source
 - Pivot tables to present data analysis
 - ArrayList functions to map reference data to source data for analysis


No6_Excel_DataAnalysis_MSSQLServer_PowerQuery_PivotTables.xlsx
--------------------------------------------------------------
Excel spreadsheet providing analysis of financial data using;
 - MS SQL SERVER database table source data
 - PowerQuery to load and transform data from source
 - Pivot tables to present data analysis
