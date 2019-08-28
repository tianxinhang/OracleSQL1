/* FIT9132 2019 S1 Assignment 2 Q3 ANSWERS
    Student Name:tianxin hang
    Student ID:26792923

   Comments to your marker:
   
*/
SET AUTOCOMMIT OFF;

/* (i)*/

CREATE OR REPLACE TRIGGER change_item_code AFTER
    UPDATE OF item_code ON item
    FOR EACH ROW
BEGIN
    IF updating THEN
        UPDATE item_treatment
        SET
            item_code = :new.item_code
        WHERE
            item_code = :old.item_code;

        dbms_output.put_line('ITEM_CODE '
                             || :old.item_code
                             || ' has changed to '
                             || :new.item_code);

    END IF;
END;
/

/* Test Harness*/

SET SERVEROUTPUT ON

SET ECHO ON
/* Prior state*/

SELECT
    *
FROM
    item;

SELECT
    *
FROM
    item_treatment;

/* Test trigger */

UPDATE item
SET
    item_code = 'KNR56'
WHERE
    item_code = 'KN056';

/* Post state*/

SELECT
    *
FROM
    item;
qqq1
SELECT
    *
FROM
    item_treatment;

/* Undo changes*/

ROLLBACK;

SET ECHO OFF;

/* (ii)*/

CREATE OR REPLACE TRIGGER check_patient_name BEFORE
    INSERT ON patient
    FOR EACH ROW
BEGIN
    IF :new.patient_fname IS NULL AND :new.patient_lname IS NULL THEN
        raise_application_error(-20000, 'fname and lname can not be both null');
    END IF;
END;
/
/* Test Harness */

SET ECHO ON
/* Test Trigger*/

INSERT INTO patient VALUES (
    '111111',
    '',
    '',
    '25 cambro rd clayton vic 3168',
    TO_DATE('11-12-1986', 'DD-MM-YYYY'),
    '0322739597'
);

/* although not stricly required, closes transaction*/

ROLLBACK;

SET ECHO OFF;


/* (iii)*/

CREATE OR REPLACE TRIGGER adjust_item_stock AFTER
    INSERT OR DELETE OR UPDATE ON item_treatment
    FOR EACH ROW
BEGIN
    IF inserting THEN
        UPDATE item
        SET
            item_stock = item_stock - :new.it_qty_used
        WHERE
            item_code = :new.item_code;

        dbms_output.put_line(:new.item_code
                             || ' HAS COMSUMED '
                             || :new.it_qty_used
                             || ' IN PROCEDURE '
                             || :new.adprc_no);

    END IF;

    IF deleting THEN
        raise_application_error(-20000, 'ITEM USED INFORMATION CAN NOT BE DELETED'
        );
    END IF;
    IF updating THEN
        raise_application_error(-20000, 'ITEM USED INFORMATION CAN NOT BE UPDATED'
        );
    END IF;
END;
/

/* Test Harness*/

SET ECHO ON
/* Prior state*/

SELECT
    *
FROM
    item;

SELECT
    *
FROM
    item_treatment;

/* Test trigger */
/* Test Insert*/

INSERT INTO item_treatment (
    adprc_no,
    item_code,
    it_qty_used,
    it_item_total_cost
) VALUES (
    0100312,
    'NE001',
    2,
    34.5
);

/* Post state*/

SELECT
    *
FROM
    item;

SELECT
    *
FROM
    item_treatment;

/* Test Delete*/

DELETE FROM item_treatment
WHERE
    adprc_no = 100312
    AND item_code = 'AN002';

/* Test Update*/

UPDATE item_treatment
SET
    it_qty_used = 2
WHERE
    adprc_no = 100312
    AND item_code = 'AN002';

/* Undo changes*/

ROLLBACK;

SET ECHO OFF;