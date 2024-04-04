-- (1)for first part roles are being created 
CREATE ROLE admin;
CREATE ROLE developer;
CREATE ROLE PII;

--(2)2nd part of creating the warehouse named assingment_wh with medium size ;
create WAREHOUSE assingment_wh WAREHOUSE_SIZE='MEDIUM' 
                WAREHOUSE_TYPE='STANDARD' 
                AUTO_RESUME=true 
                AUTO_SUSPEND=600 ;
                


--(4) creation of database 
create database assingment_db;

--(5) creation of schema
create schema my_schema;


--before swtiching to admin granting all privileges to each roles;
-- Grant privileges to admin;
GRANT ALL PRIVILEGES ON DATABASE assingment_db TO ROLE admin;
GRANT ALL PRIVILEGES ON SCHEMA my_schema TO ROLE admin;

-- Grant privileges to create and modify objects to the developer role
GRANT CREATE TABLE, CREATE VIEW, CREATE PIPE, CREATE STAGE ON SCHEMA my_schema TO ROLE developer;

-- Grant privileges related to data ingestion to the PiL role
GRANT USAGE ON DATABASE assingment_db TO ROLE PII;
GRANT USAGE ON SCHEMA my_schema TO ROLE PII;
--GRANT ALL PRIVILEGES ON STAGE my_stage TO ROLE PII;

-- Grant membership of roles to establish hierarchy
GRANT ROLE admin TO ROLE accountadmin;
GRANT ROLE developer TO ROLE admin;
GRANT ROLE PII TO ROLE accountadmin;

--(3) 
use role admin;




--(6) creating table employee_data_internal from emp_assingment.csv for internal staging
CREATE TABLE my_schema.employee_data_internal (
    EMPLOYEE_ID INT,
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    EMAIL VARCHAR(100),
    PHONE_NUMBER VARCHAR(20),
    HIRE_DATE DATE,
    JOB_ID VARCHAR(20),
    SALARY DECIMAL(10, 2),
    MANAGER_ID INT,
    DEPARTMENT_ID INT
);
-- (7)creating table employee_data_internal from emp_assingment.csv for external staging
CREATE OR REPLACE TABLE my_schema.employee_data_external (
    EMPLOYEE_ID INT,
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    EMAIL VARCHAR(100),
    PHONE_NUMBER VARCHAR(20),
    HIRE_DATE DATE,
    JOB_ID VARCHAR(20),
    SALARY DECIMAL(10, 2),
    MANAGER_ID INT,
    DEPARTMENT_ID INT
);
--creating a new stage;
create stage my_emp_stage;
--granting all permissions to admin role
GRANT ALL PRIVILEGES ON STAGE my_emp_stage TO ROLE admin;


--(8) creating internal stages;

--(created in terminal)PUT file:///Users/devanshpanda/Downloads/emp_assignment.csv @my_emp_stage;

--(COPIED INTO INTERNAL TABLE)(9)
COPY INTO my_schema.employee_data_internal
                                  FROM @my_emp_stage
                                  FILE_FORMAT = (
                                      TYPE = CSV
                                      SKIP_HEADER = 1,DATE_FORMAT='YYYY-MM-DD'
                                  )
                                  PATTERN = '.*emp_assignment\.csv\.gz'
                                  ON_ERROR = 'SKIP_FILE';

--using assingment_db.my_schema for furthur queries
use assingment_db.my_schema;

--creating csv file format to read file from external stage;
create or replace file format assingment_db.my_schema.my_csv_format
type = csv
field_delimiter = ','
skip_header = 1
null_if = ('NULL', 'null')
empty_field_as_null = true;



-- creating a storage integration  s3_int2 using role accountadmin
create or replace storage integration s3_int2 type = external_stage storage_provider= s3   enabled = true storage_aws_role_arn='arn:aws:iam::637423503468:role/newemprole' storage_allowed_locations =('s3://assingmentbucket');


--using role accountadmin
grant ownership on integration s3_int2 to role admin;

--creating  external stage for s3  using role admin  and loading to external stage;
create stage my_emp_external_stage STORAGE_INTEGRATION =s3_int2 URL='s3://assingmentbucket/emp_assignment.csv' file_format=my_csv_format;


-- loading from external stage to employee_data_external;
copy into employee_data_external from @my_emp_external_stage;

--10) for staging the parquet file user1data.parquet; in terminal
--PUT file:///Users/devanshpanda/Downloads/userdata1.parquet @my_emp_stage;

 --creating new file type
create file format my_parquet_format TYPE =parquet;

--(11)selecting using inferschema 
select * from table (INFER_SCHEMA (LOCATION =>'@my_emp_stage',FILE
                                            _FORMAT=>'my_parquet_format'));

--(12)creating a mask for the question
CREATE MASKING POLICY PII_masking_policy
  AS (val STRING)
  RETURNS STRING ->
  CASE
    WHEN CURRENT_ROLE() = 'DEVELOPER' THEN '**MASKED**'
    ELSE val
  END;

