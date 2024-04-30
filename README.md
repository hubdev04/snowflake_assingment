# Snowflake Assignment Readme
This repository contains code and documentation for the Snowflake assignment.

# Data Infrastructure Overview
   • The Snowflake warehouse used for this assignment is named assingment_wh.
   • The database utilized in this assignment is called assingment_db under and schema my_schema.

# CSV File Used
The CSV file used in this assignment is named emp_assignment.csv. It contains the data required for the loading.

# External Stage Table
An external stage table was created so that using  Amazon S3 we can get the data back . The stage table provides a way to load data from files stored in an S3 bucket directly into Snowflake.

# Stage Table Details
Name: my_emp_stage for internal staging , my_emp_external_stage for external staging 

#  Folder Strucutre

    .
    ├── src 
        ├── assingment.sql                        # Source files (containing .sql file)
    ├── data
        ├── emp_assingment.csv                    # contains emp_assingment.csv dataset
    └── README.md

# Usage 
    • According to the sql commands written in ./src/assingment.sql we have created warehouse,database and schema
    • After that according to question requirements, created different roles and assinged grants accordingly
    • Using admin role run all the queries according to the comments (sometimes we need accountadmin to grant privileges to admin)
    • Created Table and loaded data from internal and external stages as mentioned above.


# Loaded data in table 
- for internal staging
<img width="1440" alt="Screenshot 2024-04-10 at 12 15 43 PM" src="https://github.com/hubdev04/snowflake_assingment/assets/76955127/31500a87-3c21-46f5-833b-cc2127af3198">

- from external staging
  <img width="1440" alt="Screenshot 2024-04-10 at 12 28 49 PM" src="https://github.com/hubdev04/snowflake_assingment/assets/76955127/dbb03a82-e881-43f9-a4f3-d60448212d9e">

- for parquet file
  
<img width="833" alt="Screenshot 2024-04-04 at 3 35 14 PM" src="https://github.com/hubdev04/snowflake_assingment/assets/76955127/6475da55-60c5-46bb-8383-81cc528ddba0">
