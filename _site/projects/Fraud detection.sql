-- Show patients that attended the highest number of appointments and the amount billed for each of those appointments
WITH stats AS (
  SELECT  ROUND((SUM(DISTINCT b.amount))/COUNT(a.appointment_id),2) as AVG_COST_PER_APPOINTMENT
FROM data-analytics-bootcamp-4.Hospital_management.billing as b
JOIN data-analytics-bootcamp-4.Hospital_management.patients as p
    ON b.patient_id = p.patient_id
JOIN data-analytics-bootcamp-4.Hospital_management.appointments as a
    ON a.patient_id = p.patient_id
)
SELECT b.patient_id,
      CONCAT(p.first_name, ' ', p.last_name) AS full_name,
      ROUND(SUM(DISTINCT b.amount),2) AS total_billed,
      COUNT(DISTINCT a.appointment_id) AS number_appointments,
      ROUND(SUM(b.amount)/COUNT(a.appointment_id),2) AS cost_per_appointment,      ROUND(SUM(b.amount)/COUNT(a.appointment_id)-s.AVG_COST_PER_APPOINTMENT,2) AS difference_from_average_appointment_cost
FROM data-analytics-bootcamp-4.Hospital_management.billing as b
JOIN data-analytics-bootcamp-4.Hospital_management.patients as p
    ON b.patient_id = p.patient_id
JOIN data-analytics-bootcamp-4.Hospital_management.appointments as a
    ON a.patient_id = p.patient_id
JOIN data-analytics-bootcamp-4.Hospital_management.treatments as t
  ON a.appointment_id = t.appointment_id
JOIN stats as s ON b.patient_id = p.patient_id
GROUP BY b.patient_id, full_name, s.AVG_COST_PER_APPOINTMENT
ORDER BY total_billed DESC;

-- Show the total billed by the identified high-risk patients
SELECT ROUND(SUM(b.amount),2) AS total_billed
FROM data-analytics-bootcamp-4.Hospital_management.billing as b
JOIN data-analytics-bootcamp-4.Hospital_management.patients as p
    ON b.patient_id = p.patient_id
WHERE  p.patient_id IN ('P012', 'P049', 'P016', 'P036', 'P025', 'P005', 'P035');

-- Show patients who have received 3 or more advanced protocol treatments
SELECT a.patient_id, 
CONCAT(p.first_name, ' ', p.last_name) AS full_name, t.description, 
COUNT(t.description) as number_of_treatments
FROM data-analytics-bootcamp-4.Hospital_management.treatments as t
JOIN data-analytics-bootcamp-4.Hospital_management.appointments as a
    ON t.appointment_id = a.appointment_id
JOIN data-analytics-bootcamp-4.Hospital_management.patients as p
    ON a.patient_id = p.patient_id
WHERE t.description = 'Advanced protocol'
GROUP BY a.patient_id, full_name, t.description
HAVING COUNT(t.description) > 2
ORDER BY COUNT(t.description) DESC;

-- Show high-risk patients by type of treatment and % of standard and basic screenings
SELECT p.patient_id, CONCAT(p.first_name, ' ', p.last_name) AS full_name,
    COUNT(t.description) AS number_treatments,
    SUM(CASE
        WHEN description = 'Advanced protocol' THEN 1
        ELSE 0
        END) AS number_advanced_protocol,
    SUM(CASE
        WHEN description = 'Standard procedure' THEN 1
        ELSE 0
        END) AS number_standard_procedure,
    SUM(CASE
        WHEN description = 'Basic screening' THEN 1
        ELSE 0
        END) AS number_basic_screening,
    ROUND(SUM(CASE
        WHEN description = 'Basic screening' THEN 1
        WHEN description = 'Standard procedure' THEN 1
        ELSE 0
        END)/COUNT(t.description)*100,1) AS percentage_basic_or_standard
FROM data-analytics-bootcamp-4.Hospital_management.treatments as t
JOIN data-analytics-bootcamp-4.Hospital_management.appointments as a
    ON t.appointment_id = a.appointment_id
JOIN data-analytics-bootcamp-4.Hospital_management.patients as p
    ON a.patient_id = p.patient_id
WHERE p.patient_id IN ('P012', 'P049', 'P016', 'P036', 'P025', 'P005', 'P035')
GROUP BY p.patient_id, full_name
ORDER BY number_advanced_protocol;

-- Show high-risk patients by treatment type
SELECT p.patient_id, CONCAT(p.first_name, ' ', p.last_name) AS full_name,
    COUNT(t.description) AS number_treatments,
    SUM(CASE
        WHEN t.treatment_type = 'Physiotherapy' THEN 1
        ELSE 0
        END) AS number_physiotherapy,
    SUM(CASE
        WHEN t.treatment_type = 'X-Ray' THEN 1
        ELSE 0
        END) AS number_Xray,
    SUM(CASE
        WHEN t.treatment_type = 'ECG' THEN 1
        ELSE 0
        END) AS number_ECG,
    SUM(CASE
        WHEN t.treatment_type = 'Chemotherapy' THEN 1
        ELSE 0
        END) AS number_Chemotherapy,
    SUM(CASE
        WHEN t.treatment_type = 'MRI' THEN 1
        ELSE 0
        END) AS number_MRI
FROM data-analytics-bootcamp-4.Hospital_management.treatments as t
JOIN data-analytics-bootcamp-4.Hospital_management.appointments as a
    ON t.appointment_id = a.appointment_id
JOIN data-analytics-bootcamp-4.Hospital_management.patients as p
    ON a.patient_id = p.patient_id
WHERE p.patient_id IN ('P012', 'P049', 'P016', 'P036', 'P025', 'P005', 'P035')
GROUP BY p.patient_id, full_name
ORDER BY number_treatments DESC;


-- Show specialization of the doctors that saw the highest numbers of selected high-risk patients
SELECT d.specialization, 
    COUNT(DISTINCT a.appointment_id) AS total_appointments, 
    ROUND(SUM(b.amount),2) AS total_billed
FROM data-analytics-bootcamp-4.Hospital_management.doctors as d
JOIN data-analytics-bootcamp-4.Hospital_management.appointments as a
    ON d.doctor_id = a.doctor_id
JOIN data-analytics-bootcamp-4.Hospital_management.patients as p
    ON a.patient_id = p.patient_id
JOIN data-analytics-bootcamp-4.Hospital_management.billing as b
    ON b.patient_id = p.patient_id
WHERE a.patient_id IN ('P012', 'P049', 'P016', 'P036', 'P025', 'P005', 'P035')
GROUP BY d.specialization
ORDER BY total_appointments DESC;

-- Show doctors that saw the selected high-risk patients most frequently
SELECT d.doctor_id, CONCAT(d.first_name, ' ', d.last_name) AS full_name, COUNT(a.appointment_id) AS total_appointments
FROM data-analytics-bootcamp-4.Hospital_management.doctors as d
JOIN data-analytics-bootcamp-4.Hospital_management.appointments as a
    ON d.doctor_id = a.doctor_id
JOIN data-analytics-bootcamp-4.Hospital_management.patients as p
    ON a.patient_id = p.patient_id
WHERE p.patient_id IN ('P012', 'P049', 'P016', 'P036', 'P025', 'P005', 'P035')
GROUP BY d.doctor_id, full_name
ORDER BY total_appointments DESC
LIMIT 5;

-- Calculate age of high-risk patients
SELECT patient_id, 
        date_of_birth,
        CONCAT(p.first_name, ' ', p.last_name) AS full_name,
        FLOOR(DATE_DIFF('2026-02-10',date_of_birth, DAY)/365) AS age
FROM data-analytics-bootcamp-4.Hospital_management.patients as P
WHERE patient_id IN ('P012', 'P049', 'P016', 'P036', 'P025', 'P005', 'P035')
ORDER BY age;
