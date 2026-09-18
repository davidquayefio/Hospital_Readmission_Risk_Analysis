SELECT COUNT(*) AS total_records
FROM diabetic_data_raw;

select * from
diabetic_data_raw
limit 10;

SET SQL_SAFE_UPDATES = 0;

update diabetic_data_raw
set race = nullif(race, '?'),
	weight = nullif(weight, '?'),
    payer_code = nullif(payer_code, '?'),
    medical_specialty = nullif(medical_specialty, '?'),
    diag_1 = nullif(diag_1, '?'),
	diag_2 = nullif(diag_2, '?'),
    diag_3 = nullif(diag_3, '?');
    
    
-- select * from diabetic_data_raw;

select 
	round(sum(weight is null)/ count(*) * 100, 1) as pct_missing_weight,
    round(sum(payer_code is null)/ count(*) * 100, 1) as pct_missing_payer,
    round(sum(medical_specialty is null)/ count(*) * 100, 1) as pct_missing_specialty
from diabetic_data_raw;

-- Step 2
select 
	patient_nbr,
    count(*) as encounter_count
from diabetic_data_raw
group by patient_nbr
having count(*) > 1
order by encounter_count desc
limit 10;

create table diabetic_data_deadup AS 
select t.*
from diabetic_data_raw as t
inner join (select 
	patient_nbr,
    min(encounter_id) as first_encounter
from diabetic_data_raw
group by patient_nbr) first_enc
on t.patient_nbr = first_enc.patient_nbr
and t.encounter_id = first_enc.first_encounter;

select count(*) from diabetic_data_deadup;

-- Step 3
SELECT
    discharge_disposition_id,
    COUNT(*) AS encounter_count
FROM diabetic_data_raw
GROUP BY discharge_disposition_id
ORDER BY encounter_count DESC;

select * from ids_mapping_raw
where description like '%hospice%' or description like '%expired%' or description like '%deceased%';

delete from diabetic_data_deadup
where discharge_disposition_id in (11, 13, 14, 9, 20, 21, 26);

-- Step 4

select * from ids_mapping_raw;

create table discharge_disposition_map (
	discharge_disposition_id int, 
    description varchar(150)
);

create table admission_source_map (
	admission_source_id int, 
    description varchar(150)
);

describe discharge_disposition_map;
describe admission_source_map;

insert into discharge_disposition_map (
discharge_disposition_id, description) values
(1, 'Discharged to home'),
(2, 'Discharged/transferred to another short term hospital'),
(3, 'Discharged/transferred to SNF'),
(4, 'Discharged/transferred to ICF'),
(5, 'Discharged/transferred to another type of inpatient care institution'),
(6, 'Discharged/transferred to home with home health service'),
(7, 'Left AMA'),
(8, 'Discharged/transferred to home under care of Home IV provider'),
(9, 'Admitted as an inpatient to this hospital'),
(10, 'Neonate discharged to another hospital for neonatal aftercare'),
(11, 'Expired'),
(12, 'Still patient or expected to return for outpatient services'),
(13, 'Hospice / home'),
(14, 'Hospice / medical facility'),
(15, 'Discharged/transferred within this institution to Medicare approved swing bed'),
(16, 'Discharged/transferred/referred another institution for outpatient services'),
(17, 'Discharged/transferred/referred to this institution for outpatient services'),
(18, NULL),
(19, 'Expired at home. Medicaid only, hospice.'),
(20, 'Expired in a medical facility. Medicaid only, hospice.'),
(21, 'Expired, place unknown. Medicaid only, hospice.'),
(22, 'Discharged/transferred to another rehab fac including rehab units of a hospital.'),
(23, 'Discharged/transferred to a long term care hospital.'),
(24, 'Discharged/transferred to a nursing facility certified under Medicaid but not certified under Medicare.'),
(25, 'Not Mapped'),
(26, 'Unknown/Invalid'),
(27, 'Discharged/transferred to a federal health care facility.'),
(28, 'Discharged/transferred/referred to a psychiatric hospital or psychiatric distinct part unit of a hospital'),
(29, 'Discharged/transferred to a Critical Access Hospital (CAH).'),
(30, 'Discharged/transferred to another Type of Health Care Institution not Defined Elsewhere');

insert into admission_source_map (
admission_source_id, description) values 
(1, 'Physician Referral'),
(2, 'Clinic Referral'),
(3, 'HMO Referral'),
(4, 'Transfer from a hospital'),
(5, 'Transfer from a Skilled Nursing Facility (SNF)'),
(6, 'Transfer from another health care facility'),
(7, 'Emergency Room'),
(8, 'Court/Law Enforcement'),
(9, 'Not Available'),
(10, 'Transfer from critical access hospital'),
(11, 'Normal Delivery'),
(12, 'Premature Delivery'),
(13, 'Sick Baby'),
(14, 'Extramural Birth'),
(15, 'Not Available'),
(17, NULL),
(18, 'Transfer From Another Home Health Agency'),
(19, 'Readmission to Same Home Health Agency'),
(20, 'Not Mapped'),
(21, 'Unknown/Invalid'),
(22, 'Transfer from hospital inpatient/same facility resulting in a separate claim'),
(23, 'Born inside this hospital'),
(24, 'Born outside this hospital'),
(25, 'Transfer from Ambulatory Surgery Center'),
(26, 'Transfer from Hospice');

select * from discharge_disposition_map;
select * from admission_source_map;

-- Step 5 
select * from diabetic_data_deadup
limit 50;

alter table diabetic_data_deadup add column age_midpoint int;

update diabetic_data_deadup
set age_midpoint = case
	when age = '[0-10)' then 5
    when age = '[10-20)' then 15
    when age = '[20-30)' then 25
    when age = '[30-40)' then 35
    when age = '[40-50)' then 45
    when age = '[50-60)' then 55
    when age = '[60-70)' then 65
    when age = '[70-80)' then 75
    when age = '[80-90)' then 85
    when age = '[90-100)' then 95
end;

-- Exploratory Data Analysis
select 
	readmitted,
    count(*) as encounter_count,
    round(count(*) / (select count(*) from diabetic_data_deadup)
    * 100, 1) as pct_of_total
    from diabetic_data_deadup
    group by readmitted
    order by encounter_count desc;
    
select 
	age, 
    age_midpoint, 
    count(*) as total_encounters, 
    sum(readmitted = '<30') as readmitted_under_30,
    round(sum(readmitted = '<30') / count(*) * 100, 1) as readmission_rate_pct
from diabetic_data_deadup
group by age, age_midpoint
order by age, age_midpoint;

select
	description as admission_type, 
    count(*) as total_encounters, 
    round(sum(d.readmitted = '<30') / count(*) * 100, 1)as readmission_rate_pct
from diabetic_data_deadup as d
join ids_mapping_raw as m
on d.admission_type_id = m.admission_type_id
group by m.description
order by readmission_rate_pct desc;

-- Advanced Techniques
with patient_risk_base as (
	select
		encounter_id,
        patient_nbr,
        age_midpoint,
        time_in_hospital,
        num_lab_procedures,
        number_diagnoses,
        number_inpatient,
        number_emergency,
        number_outpatient,
        diag_1,
        readmitted,
        case when readmitted = '<30' then 1 else 0 end
        as is_readmitted_30
	from diabetic_data_deadup
)
select * from
patient_risk_base
limit 50;

with patient_risk_base as (
	select
		encounter_id, age_midpoint, num_medications, readmitted,
        case when readmitted = '<30' then 1 else 0 end as is_readmitted_30
	from diabetic_data_deadup
)
select 
	encounter_id,
    age_midpoint,
    num_medications,
    rank() over (partition by age_midpoint order by num_medications desc)
    as med_rank_age_group
from patient_risk_base
order by age_midpoint, med_rank_age_group
limit 100;



select 
	encounter_id,
    num_medications,
    case
		when num_medications <= 10 then 'Low'
        when num_medications between 11 and 20 then 'Medium'
        else 'High'
	end as medication_burden_tier,
    
    case
		when number_diagnoses <= 5 then 'Low Complexity'
        when number_diagnoses between 6 and 9 then 'Moderate Complexity'
        else 'High Complexity'
	end as diagnosis_complexity_tier
from diabetic_data_deadup;

USE hospital_readmissions;

DESCRIBE diabetic_data_deadup;

-- diag_1 notes 
-- 390 - 459: Diseases of the circulatory system
-- 460 - 519: Diseases of the respiratory system 
-- 520 - 579: Diseases of the digestive system
-- 580 - 629: Diseases of the genitourinary system
-- 800 - 999: Injury and poisoning 

WITH diag_categorized AS (
    SELECT
        encounter_id,
        readmitted,

        CASE
            WHEN diag_1 LIKE '250%' THEN 'Diabetes'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 390 AND 459
                THEN 'Circulatory'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 460 AND 519
                THEN 'Respiratory'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 520 AND 579
                THEN 'Digestive'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 580 AND 629
                THEN 'Genitourinary'
            WHEN CAST(LEFT(diag_1, 3) AS UNSIGNED) BETWEEN 800 AND 999
                THEN 'Injury & Poison'
            ELSE 'Other'
        END AS diagnosis_category,

        CASE
            WHEN readmitted = '<30' THEN 1
            ELSE 0
        END AS is_readmitted_30

    FROM diabetic_data_deadup
    WHERE diag_1 IS NOT NULL
)

SELECT
    diagnosis_category,
    COUNT(*) AS total_encounters,
    ROUND(AVG(is_readmitted_30) * 100, 1) AS readmitted_rate_pct

FROM diag_categorized

GROUP BY diagnosis_category

HAVING AVG(is_readmitted_30) > (
    SELECT AVG(is_readmitted_30)
    FROM diag_categorized
)

ORDER BY readmitted_rate_pct DESC;

-- section 4

-- finding 1. Top diagonsis categories driving readmission
-- finding  2. Does a medication change at discharge readmission?

SELECT 
    `change`,
    COUNT(*) AS total_encounters,
    ROUND(AVG(readmitted = '<30') * 100, 1) AS readmission_rate_pct
FROM diabetic_data_deadup
GROUP BY `change`;

-- finding 3. Discharge disposition impact.
select 
	m.description as discharge_disposition,
    count(*) as total_encounters,
    round(sum(d.readmitted = '<30') / count(*) * 100, 1) as readmission_rate_pct
from diabetic_data_deadup as d
join discharge_disposition_map as m 
on d.discharge_disposition_id = m.discharge_disposition_id
group by m.description
having count(*) > 100
order by readmission_rate_pct desc
limit 10;

-- finding 4. A1C testing and readmission

select 
	A1Cresult,
    count(*) as total_encounters,
    round(sum(readmitted = '<30') / count(*) * 100, 1) as readmission_rate_pct
from diabetic_data_deadup
group by A1Cresult;
    