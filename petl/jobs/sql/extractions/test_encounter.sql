SELECT  patient_id,
        encounter_id,
        encounter_type
FROM encounter WHERE voided = 0 LIMIT 10;
