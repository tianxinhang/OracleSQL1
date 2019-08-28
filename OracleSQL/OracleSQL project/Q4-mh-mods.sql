/* FIT9132 2019 S1 Assignment 2 Q4 ANSWERS
   Student Name:tianxin hang
    Student ID:26792923

   Comments to your marker:
   
*/
/* (i)*/
SET AUTOCOMMIT OFF;

SET SERVEROUTPUT ON;

/* This solution based on what Lindsay Smith talking on forums.he said no trigger needed */
/* because a manual check by the procurement staff to see which items have current stock levels which have dropped below the reorder level */

DROP TABLE item_reorderlv PURGE;

CREATE TABLE item_reorderlv
    AS
        ( SELECT
            item_code,
            item_stock / 2 AS "reorder level"
        FROM
            item
        );

ALTER TABLE item_reorderlv ADD CONSTRAINT item_reorderlv_pk PRIMARY KEY ( item_code

);

ALTER TABLE item_reorderlv
    ADD CONSTRAINT item_reorderlv_fk FOREIGN KEY ( item_code )
        REFERENCES item ( item_code );

ALTER TABLE item_reorderlv MODIFY 
    "reorder level" NOT NULL
;

/* This extra solution based on my understanding about question.*/
/* in the question ,it clearly said that when stock item falls to this level it will be a warning */
/* to procudure staff that item need to be re-order. So a trigger may need to be applied here to in real life */

CREATE OR REPLACE TRIGGER new_item_inserting AFTER
    INSERT ON item
    FOR EACH ROW
BEGIN
    IF inserting THEN
        INSERT INTO item_reorderlv VALUES (
            :new.item_code,
            ( :new.item_stock ) / 2
        );

    END IF;
END;
/

CREATE OR REPLACE TRIGGER item_stock_warning BEFORE
    UPDATE OF item_stock ON item
    FOR EACH ROW
DECLARE
    item_stock_reorder item_reorderlv."reorder level"%TYPE;
BEGIN
    IF updating THEN
        SELECT
            "reorder level"
        INTO item_stock_reorder
        FROM
            item_reorderlv
        WHERE
            item_code = :new.item_code;

        IF :new.item_stock < item_stock_reorder THEN
            dbms_output.put_line('PLEASE REORDER ' || :new.item_code);
        END IF;

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
    15,
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

/* Undo changes*/

ROLLBACK;

SET ECHO OFF;



  
/* (ii)*/



DROP TABLE perform_doctor PURGE;

CREATE TABLE perform_doctor
    AS
        ( SELECT
            adprc_no,
            perform_dr_id AS doctor_id
        FROM
            adm_prc
        WHERE
            perform_dr_id IS NOT NULL
        );

ALTER TABLE perform_doctor ADD doctor_type VARCHAR(50);

UPDATE perform_doctor
SET
    doctor_type = 'L'
WHERE
    doctor_type IS NULL;

ALTER TABLE perform_doctor ADD CONSTRAINT perform_doctor_pk PRIMARY KEY ( adprc_no

,
                                                                          doctor_id
                                                                          );

ALTER TABLE perform_doctor
    ADD CONSTRAINT perform_doctor_fk1 FOREIGN KEY ( adprc_no )
        REFERENCES adm_prc ( adprc_no );

ALTER TABLE perform_doctor
    ADD CONSTRAINT perform_doctor_fk2 FOREIGN KEY ( doctor_id )
        REFERENCES doctor ( doctor_id );

ALTER TABLE perform_doctor MODIFY (
    adprc_no NUMBER(7, 0),
    doctor_id NUMBER(4, 0),
    doctor_type NOT NULL
);

ALTER TABLE perform_doctor
    ADD CONSTRAINT dt_check CHECK ( doctor_type IN (
        'L',
        'A'
    ) );

ALTER TABLE adm_prc DROP CONSTRAINT doctor_performadmprc;

ALTER TABLE adm_prc DROP COLUMN perform_dr_id;

/*test*/

INSERT INTO perform_doctor VALUES (
    102003,
    7890,
    'A'
);

COMMIT;




