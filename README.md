
# Hospital Readmission Risk Analysis

<p align="center">
  <img src="images/hospital.png" alt="Hospital Readmission Risk Analysis" width="220">
</p>

## Business Problem

Hospital readmissions within 30 days of discharge can create significant financial and operational pressure for hospitals. This project analyzes **101,766 patient encounters from 130 U.S. hospitals between 1999 and 2008** to identify patient characteristics, diagnoses, and care patterns associated with higher readmission risk.

The goal is to help care teams identify high-risk patients, prioritize follow-up resources, and identify areas where discharge and care processes could potentially be improved.

---

## Dataset

**Dataset:** Diabetes 130-US Hospitals for Years 1999–2008

- **Source:** UCI Machine Learning Repository
- **License:** CC BY 4.0
- **Patient Encounters:** 101,766
- **Hospitals:** 130 U.S. hospitals
- **Time Period:** 1999–2008
- **Primary Outcome:** Hospital readmission within 30 days

---

## Tools

- **Database:** MySQL
- **Interface:** MySQL Workbench
- **Language:** SQL

---

## SQL Techniques Used

- Common Table Expressions (CTEs)
- Window Functions
- `RANK()`
- `NTILE()`
- `CASE` statements
- Correlated Subqueries
- `HAVING`
- Multi-table Joins
- Aggregation and Grouping
- Data Cleaning and Transformation

---

## Methodology

### 1. Data Cleaning

The dataset was prepared for analysis by:

- Replacing placeholder missing-value indicators with `NULL`.
- Removing a column containing approximately 97% missing data.
- Retaining one encounter per patient to reduce potential duplication bias.
- Excluding patients classified as inactive or discharged to hospice.

### 2. Exploratory Analysis

The analysis established baseline readmission patterns across key patient and encounter characteristics, including:

- Age groups
- Admission types
- Diagnosis categories
- Prior inpatient utilization
- Discharge disposition

### 3. Advanced Analysis

A reusable high-risk patient cohort was created using a **CTE**. Window functions were then used to examine risk patterns and medication burden.

The analysis included:

- Ranking medication burden within age groups using `RANK()`.
- Dividing patients into risk quartiles using `NTILE(4)`.
- Creating business-readable risk tiers using `CASE`.
- Examining readmission patterns by medication use and number of diagnoses.
- Using correlated subqueries with `HAVING` to identify diagnosis categories with readmission rates above the overall population average.
- Joining reference tables to convert numerical codes into meaningful clinical and operational labels.

---

## Key SQL Techniques

### Common Table Expressions

CTEs were used to create a clean, reusable patient risk cohort that could be referenced across multiple analytical queries.

```sql
WITH high_risk_patients AS (
    SELECT
        patient_nbr,
        encounter_id,
        readmitted
    FROM diabetic_data
    WHERE ...
)
SELECT *
FROM high_risk_patients;
````

### Window Functions

Window functions were used to analyze patient risk and medication burden without collapsing the underlying records.

#### RANK()

```sql
RANK() OVER (
    PARTITION BY age
    ORDER BY num_medications DESC
)
```

This was used to rank medication burden within age groups.

#### NTILE()

```sql
NTILE(4) OVER (
    ORDER BY risk_score DESC
)
```

This was used to divide patients into four risk quartiles.

### CASE-Based Risk Tiering

`CASE` statements were used to transform numerical or continuous variables into business-readable risk categories.

```sql
CASE
    WHEN risk_score >= 3 THEN 'High Risk'
    WHEN risk_score >= 2 THEN 'Medium Risk'
    ELSE 'Low Risk'
END AS risk_tier
```

### Correlated Subqueries

Correlated subqueries combined with `HAVING` were used to identify diagnosis categories with readmission rates above the overall population average.

### Multi-Table Joins

Reference tables were joined to convert numerical codes into readable clinical and operational labels, making the analysis easier to interpret.

---

## Key Findings

### 1. Diagnosis Category

Circulatory and diabetes diagnoses had the highest readmission rates among the diagnosis categories examined, and both exceeded the overall average readmission rate.

### 2. Prior Hospital Utilization

Patients with more prior inpatient visits during the previous year showed substantially higher readmission risk, indicating that prior utilization is an important predictive signal within the analysis.

### 3. Discharge Disposition

Readmission rates varied across discharge disposition categories. Patients discharged to certain facility types had different readmission rates compared with patients discharged home.

### 4. Medication Changes and A1C Testing

Patterns involving medication changes at discharge and A1C testing during the hospital stay were also examined. These findings align with the original clinical research questions associated with the dataset.

---

## Recommendations

Based on the analysis:

* Prioritize discharge planning and follow-up for patients with a history of frequent hospital utilization.
* Strengthen care coordination for patients with circulatory conditions and diabetes, given their higher observed readmission rates.
* Review discharge processes across facilities with higher observed readmission rates to identify opportunities for process improvement.
* Use patient-level risk indicators to help prioritize follow-up resources rather than treating all patients as having the same readmission risk.

---

## Project Takeaway

This project demonstrates how SQL can be used beyond basic data retrieval to perform a complete analytical workflow—from **data cleaning and cohort construction to risk segmentation and business-focused insights**.

The analysis combines relational database techniques with statistical thinking to investigate factors associated with hospital readmission and translate those patterns into practical insights for care coordination and discharge planning.

---

## Project Structure

```text
Hospital_Readmission_Risk_Analysis/
│
├── README.md
│
├── data/
│   └── diabetic_data.csv
│
├── sql/
│   ├── 01_data_cleaning.sql
│   ├── 02_exploratory_analysis.sql
│   ├── 03_risk_analysis.sql
│   ├── 04_diagnosis_analysis.sql
│   └── 05_final_analysis.sql
│
└── results/
    └── analysis_results/
```

---

## Skills Demonstrated

Through this project, I applied SQL to a real-world healthcare dataset and demonstrated practical skills in:

* Data cleaning
* Data transformation
* Exploratory data analysis
* Healthcare analytics
* Risk segmentation
* Cohort construction
* Statistical thinking
* Relational database analysis
* Advanced SQL querying
* Business-focused interpretation of analytical results

---

## Conclusion

The analysis shows how historical patient and encounter-level data can be used to identify patterns associated with hospital readmission.

Prior hospital utilization, diagnosis category, discharge disposition, medication-related patterns, and other patient characteristics provide useful signals for understanding differences in observed readmission rates.

The project also demonstrates the use of advanced SQL techniques to move from raw healthcare data to structured analytical insights that can support further investigation and data-informed care planning.

