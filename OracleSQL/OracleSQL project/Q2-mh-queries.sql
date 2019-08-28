/* FIT9132 2019 S1 Assignment 2 Q2 ANSWERS
   Student Name:tianxin hang
    Student ID:26792923

   Comments to your marker:
   
*/

/* (i)*/
SELECT
    doctor_title,
    doctor_fname,
    doctor_lname,
    doctor_phone
FROM
    doctor              d
    JOIN doctor_speciality   ds
    ON d.doctor_id = ds.doctor_id
    JOIN speciality          s
    ON ds.spec_code = s.spec_code
WHERE
    upper(spec_description) = 'ORTHOPEDIC SURGERY'
ORDER BY
    doctor_lname,
    doctor_fname;






/* (ii)*/

SELECT
    item_code,
    item_description,
    item_stock,
    c.cc_title
FROM
    item         i
    JOIN costcentre   c
    ON i.cc_code = c.cc_code
WHERE
    item_stock > 50
    AND lower(item_description) LIKE '%disposable%'
ORDER BY
    item_code;







    
/* (iii)*/

SELECT
    p.patient_id,
    patient_fname
    || ' '
    || patient_lname AS "Patient Name",
    TO_CHAR(adm_date_time, 'dd-Mon-yyyy hh24:mi') AS admdatetime,
    doctor_title
    || ' '
    || doctor_fname
    || ' '
    || doctor_lname AS "Doctor Name"
FROM
    patient     p
    JOIN admission   a
    ON p.patient_id = a.patient_id
    JOIN doctor      d
    ON a.doctor_id = d.doctor_id
WHERE
    TO_CHAR(adm_date_time, 'dd-Mon-yyyy') LIKE '14-Mar-2019'
ORDER BY
    admdatetime;

/* demo*/
/* select to_char(adm_date_time,'dd-mm-yyyy hh24:mi')*/
/* from admission;*/






/* (iv)*/

SELECT
    proc_code,
    proc_name,
    proc_description,
    '$' || TO_CHAR(proc_std_cost, 'FM999.00') AS proc_cost
FROM
    procedure
WHERE
    proc_std_cost < (
        SELECT
            AVG(proc_std_cost)
        FROM
            procedure
    )
ORDER BY
    proc_std_cost DESC;






 
/* (v)*/

SELECT
    p.patient_id,
    patient_lname,
    patient_fname,
    TO_CHAR(patient_dob, 'dd-Mon-yyyy') AS dob,
    COUNT(adm_no) AS numberadmissions
FROM
    patient     p
    JOIN admission   a
    ON p.patient_id = a.patient_id
GROUP BY
    p.patient_id,
    patient_fname,
    patient_lname,
    patient_dob
HAVING
    COUNT(adm_no) > 2
ORDER BY
    COUNT(adm_no) DESC,
    p.patient_dob ASC,;


    
/* (vi)*/
SELECT
    adm_no,
    p.patient_id,
    patient_fname,
    patient_lname,
    trunc(adm_discharge - adm_date_time)
    || ' days '
       || round(mod(adm_discharge - adm_date_time, 1) * 24, 1)
          || ' hrs' AS staylength
FROM
    admission   a
    JOIN patient     p
    ON a.patient_id = p.patient_id
WHERE
    adm_discharge IS NOT NULL
    AND adm_discharge - adm_date_time > (
        SELECT
            AVG(adm_discharge - adm_date_time)
        FROM
            admission
        WHERE
            adm_discharge IS NOT NULL
    )
ORDER BY
    adm_no;

    
/* (vii)*/

SELECT
    p.proc_code,
    proc_name,
    proc_description,
    proc_time,
    TO_CHAR((proc_std_cost - AVG(adprc_pat_cost)), '990.99') AS "Price Differential"
FROM
    adm_prc     a
    JOIN procedure   p
    ON a.proc_code = p.proc_code
GROUP BY
    p.proc_code,
    proc_name,
    proc_description,
    proc_time,
    proc_std_cost
ORDER BY
    p.proc_code;


    
/* (viii)*/

SELECT
    p.proc_code,
    proc_name,
    nvl(i.item_code, '---') AS item_code,
    nvl(item_description, '---') AS item_description,
    nvl(TO_CHAR(MAX(it_qty_used), '99'), '---') AS max_qty_used
FROM
    item   i
    JOIN item_treatment  it
    ON i.item_code = it.item_code
    JOIN adm_prc  a
    ON it.adprc_no = a.adprc_no
    RIGHT JOIN procedure  p
    ON a.proc_code = p.proc_code
GROUP BY
    p.proc_code,
    proc_name,
    i.item_code,
    item_description
ORDER BY
    proc_name;