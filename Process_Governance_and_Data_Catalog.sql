CREATE TABLE Process_Governance_120K_Records (
    Workflow_ID TEXT,
    Date_Logged TEXT,
    Department TEXT,
    Process_Type TEXT,
    Status TEXT,
    Processing_Time_Hours TEXT,
    Metadata_Completeness TEXT,
    SOP_Available TEXT
);

SET GLOBAL local_infile=1;

SHOW GLOBAL VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Process_Governance_120K_Records.csv'
INTO TABLE Process_Governance_120K_Records
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

#query 1 - resume metrics
SELECT 
    COUNT(*) AS Total_Workflows_Audited,
    SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) AS Total_Failures,
    ROUND((SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Overall_Failure_Rate_Pct,
    ROUND((SUM(CASE WHEN Metadata_Completeness = 'Missing/Incomplete' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Overall_Missing_Docs_Pct
FROM Process_Governance_120K_Records;

#Query 2 - departmental metrics
SELECT 
    Department,
    COUNT(*) AS Department_Volume,
    ROUND((SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Failure_Rate_Pct,
    ROUND((SUM(CASE WHEN SOP_Available = 'No' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Missing_SOP_Pct
FROM Process_Governance_120K_Records
GROUP BY Department
ORDER BY Failure_Rate_Pct DESC;

#query 3
SELECT 
    Process_Type,
    COUNT(*) AS Process_Volume,
    SUM(CASE WHEN Metadata_Completeness = 'Missing/Incomplete' THEN 1 ELSE 0 END) AS Missing_Metadata_Count,
    ROUND((SUM(CASE WHEN Status = 'Failed' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Failure_Rate_Pct
FROM Process_Governance_120K_Records
GROUP BY Process_Type
ORDER BY Missing_Metadata_Count DESC;







