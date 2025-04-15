# Snowflake + DBT Full Project
## Project Overview
In this end-to-end project, we are leveraging **Snowflake** as the data platform and **DBT (Data Build Tool)** to
manage the data transformation pipeline. The project walks through all the key stepsfrom setting up Snowflake and DBT
to creating transformations, documenting models, and deploying the DBT docs on the web.
---
## Part 1: Setup and Initial Configuration
### 1. Snowflake Account Setup
Start with a free trial Snowflake account, which provides access to Snowflakes cloud-based data warehouse.
### 2. DBT Setup
- Install DBT via the official guide.
- Configure the `profiles.yml` to connect DBT with Snowflake.
### 3. Directory Structure
```plaintext
dbt_project/
 models/
 staging/
 stg_avg_telemetry.sql
 stg_error_data.sql
 stg_failure_data.sql
 stg_maintenance_data.sql
 final_table/
 comprehensiveInsights.sql
 dbt_project.yml
 profiles.yml
 target/
```
### 4. Sample Data
- **Telemetry Data:** Voltage, pressure, vibration data.
- **Error Data:** Logs from machine errors.
- **Failure Data:** Failure incidents.
- **Maintenance Data:** Maintenance events.
---
## Part 2: Data Transformations
### 1. Staging Tables
Each staging model handles raw-to-clean transformation.
Example: `stg_avg_telemetry.sql`
```sql
WITH TelemetryFeatures AS (
 SELECT t.DATETIME, t.MACHINEID, t.VOLT, t.ROTATE, t.PRESSURE, t.VIBRATION, m.MODEL, m.AGE
 FROM DBT_TEST.DBO.PDM_TELEMETRY t
 JOIN DBT_TEST.DBO.PDM_MACHINES m ON t.MACHINEID = m.MACHINEID
),
AvgTelemetry AS (
 SELECT MACHINEID, AVG(VOLT) AS AVG_VOLT, AVG(ROTATE) AS AVG_ROTATE, AVG(PRESSURE) AS
AVG_PRESSURE, AVG(VIBRATION) AS AVG_VIBRATION
 FROM TelemetryFeatures
 GROUP BY MACHINEID
)
SELECT * FROM AvgTelemetry;
```
### 2. Final Table: `comprehensiveInsights`
```sql
{{ config(materialized='table') }}
WITH TelemetryFeatures AS (
 SELECT * FROM {{ref('stg_telemetry_features')}}
),
AvgTelemetry AS (
 SELECT * FROM {{ref('stg_avg_telemetry')}}
),
ErrorData AS (
 SELECT * FROM {{ref('stg_error_data')}}
),
MaintenanceData AS (
 SELECT * FROM {{ref('stg_maintenance_data')}}
),
FailureData AS (
 SELECT * FROM {{ref('stg_failure_data')}}
),
ComprehensiveInsights AS (
 SELECT tf.DATETIME, tf.MACHINEID, tf.MODEL, tf.AGE,
 at.AVG_VOLT, at.AVG_ROTATE, at.AVG_PRESSURE, at.AVG_VIBRATION,
 ed.ERRORID, md.COMP, fd.FAILURE
 FROM TelemetryFeatures tf
 LEFT JOIN AvgTelemetry at ON tf.MACHINEID = at.MACHINEID
 LEFT JOIN ErrorData ed ON tf.MACHINEID = ed.MACHINEID AND tf.DATETIME = ed.DATETIME
 LEFT JOIN MaintenanceData md ON tf.MACHINEID = md.MACHINEID AND tf.DATETIME = md.DATETIME
 LEFT JOIN FailureData fd ON tf.MACHINEID = fd.MACHINEID AND tf.DATETIME = fd.DATETIME
)
SELECT * FROM ComprehensiveInsights;
```
---
## Part 3: Documentation and Deployment
### 1. DBT Docs
```bash
dbt docs generate # Generates the documentation
dbt docs serve # Serves the docs locally on port 8080
```
### 2. Version Control with GitHub
- Use `.gitignore` to exclude:
 - `.env`
 - `.venv/`
 - `dbt/`
 - `logs/`
### 3. Deploying DBT Docs
- **Vercel:** Link your GitHub and deploy.
- **GitHub Pages:** Push docs to `gh-pages` branch and enable GitHub Pages.
---
## Final Steps: Running the Project
### 1. DBT Run
```bash
dbt run
```
### 2. Verify in Snowflake
- Staging tables DBO schema
- Final table Main schema
---
## Conclusion
This project demonstrates how to leverage **Snowflake** and **DBT** to build a robust, well-documented, and
deployable data transformation pipeline.
