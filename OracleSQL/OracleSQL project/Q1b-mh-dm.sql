/* FIT9132 2019 S1 Assignment 2 Q1-Part B ANSWERS
    Student Name:tianxin hang
    Student ID:26792923
   Comments to your marker:
   
*/

/* (i)*/
DROP SEQUENCE patient_seq;

DROP SEQUENCE admission_seq;

DROP SEQUENCE adm_prc_seq;

CREATE SEQUENCE patient_seq START WITH 200000 INCREMENT BY 10;

CREATE SEQUENCE admission_seq START WITH 200000 INCREMENT BY 10;

CREATE SEQUENCE adm_prc_seq START WITH 200000 INCREMENT BY 10;





/* (ii)*/

INSERT INTO patient (
    patient_id,
    patient_fname,
    patient_lname,
    patient_address,
    patient_dob,
    patient_contact_phn
) VALUES (
    patient_seq.NEXTVAL,
    'Peter',
    'Xiue',
    '14 Narrow Lane Caulfield, VIC, 3162',
    TO_DATE('01-10-1981', 'DD-MM-YYYY'),
    '0123456789'
);


INSERT INTO admission (
    adm_no,
    adm_date_time,
    adm_discharge,
    patient_id,
    doctor_id
) VALUES (
    admission_seq.NEXTVAL,
    TO_DATE('16-05-2019 10:00:00', 'DD-MM-YYYY hh:mi:ss AM'),
    NULL,
    patient_seq.CURRVAL,
    (
        SELECT
            doctor_id
        FROM
            doctor
        WHERE
            doctor_title = 'Dr'
            AND doctor_fname = 'Sawyer'
            AND upper(doctor_lname) = 'HAISELL'
    )
);
commit;








/* (iii)*/

UPDATE doctor_speciality
SET
    spec_code = (
        SELECT
            spec_code
        FROM
            speciality
        WHERE
            spec_description = 'Vascular surgery'
    )
WHERE
    spec_code = (
        SELECT
            spec_code
        FROM
            speciality
        WHERE
            spec_description = 'Thoracic surgery'
    )
    AND doctor_id = (
        SELECT
            d.doctor_id
        FROM
            doctor_speciality   ds
            JOIN doctor              d
            ON ds.doctor_id = d.doctor_id
        WHERE
            initcap(lower(doctor_fname)) = 'Decca'
            AND upper(doctor_lname) = 'BLANKHORN'
            AND spec_code = (
                SELECT
                    spec_code
                FROM
                    speciality
                WHERE
                    spec_description = 'Thoracic surgery'
            )
    );

COMMIT;






      
/* (iv)*/

DELETE FROM doctor_speciality
WHERE
    spec_code = (
        SELECT
            s.spec_code
        FROM
            doctor_speciality ds
            JOIN speciality s
            ON ds.spec_code = s.spec_code
        WHERE
            spec_description = 'Medical genetics'
    );

DELETE FROM speciality
WHERE
    spec_description = 'Medical genetics';

COMMIT;