CREATE TABLE public.employees
(
    id         UUID,
    name       TEXT,
    birth_date DATE,

    CONSTRAINT employees_pkey PRIMARY KEY (id)
);

SELECT pgtrail.enable_audit('public.employees');

-- Filling in test data
INSERT INTO employees (id, name, birth_date)
values ('eba95a16-265a-4d79-ac33-aa1ccc9322e4', 'Phillip J. Fry', '1971-05-01');
INSERT INTO employees (id, name, birth_date)
values ('22dd0bac-ada8-4a65-b2b8-bb0021dc2b1d', 'Turanga Leela', '2971-03-01');
INSERT INTO employees (id, name, birth_date)
values ('0312679b-c40b-4074-a79c-74d1d14dbf20', 'Bender Bending Rodriguez', '2995-04-01');

-- Manipulating test data, it should cause new records to appear in the "pgtrail.audit_changes" table
UPDATE employees
SET name = 'Amy Wong'
WHERE id = '22dd0bac-ada8-4a65-b2b8-bb0021dc2b1d';
UPDATE employees
SET birth_date = '2999-12-31'
WHERE id = 'eba95a16-265a-4d79-ac33-aa1ccc9322e4';
DELETE
FROM employees
WHERE id = '0312679b-c40b-4074-a79c-74d1d14dbf20';