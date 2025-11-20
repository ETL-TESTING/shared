# Testing Outcome
Mismatch 1 : Missing in Target

Mismatch 2 : Extra in Target

Mismatch 3 : Email Mismatch

# Testing Strategy
Source:
- Counts
- Extracts

Target:
- Counts
- Extracts

# Source
Counts(Source):
```sql
-- Summary stats for CUSTOMER table
SELECT
    COUNT(*) AS total_customer_records,
    COUNT(DISTINCT id) AS distinct_customer_ids
FROM stagingrepdb.public.customer;
```

Extract(Source)
```sql
-- Extract CUSTOMER IDs and Emails
SELECT id, email_id
FROM stagingrepdb.public.customer
ORDER BY id;
```

> customer_extract.csv (Export it)


# Target
Counts(Target):
```sql
-- Summary stats for PERSON table
SELECT
    COUNT(*) AS total_person_records,
    COUNT(DISTINCT id) AS distinct_person_ids
FROM targetdb.public.persons;
```

Extract(Target):
```sql
-- Extract PERSON IDs and Emails
SELECT id, email_id
FROM targetdb.public.persons
ORDER BY id;
```

> person_extract.csv (Export this)

- - - - - - -

# Reconciliation Check

missing_in_target :
```sql

SELECT s.id, s.email_id
    FROM stagingrepdb.recon.source_customer s
    LEFT JOIN stagingrepdb.recon.target_persons t ON s.id = t.id
    WHERE t.id IS NULL

```


extra_in_target :

```sql
SELECT t.id, t.email_id
    FROM stagingrepdb.recon.target_persons t
    LEFT JOIN stagingrepdb.recon.source_customer s ON t.id = s.id
    WHERE s.id IS NULL;
```

Data(email mismatches) :

```sql

SELECT s.id, s.email_id AS source_email, t.email_id AS target_email
    FROM stagingrepdb.recon.source_customer s
    JOIN stagingrepdb.recon.target_persons t ON s.id = t.id
    WHERE s.email_id IS DISTINCT FROM t.email_id;
```

# Combine as Single SQL
```sql
/******************************************************************************************
 Reconciliation: CUSTOMER (source extract) vs PERSONS (target extract)
 -- SINGLE VIEW RECONCILIATION --
 -- USEFUL FOR REPORTING --
 -- CENTRAL VIEW FOR ANy MISMATCHES --
******************************************************************************************/

WITH
src AS (
    SELECT id, email_id FROM stagingrepdb.recon.source_customer
),
tgt AS (
    SELECT id, email_id FROM stagingrepdb.recon.target_persons
),

counts AS (
    SELECT
        (SELECT COUNT(*) FROM src) AS source_count,
        (SELECT COUNT(*) FROM tgt) AS target_count
),

missing_in_target AS (
    SELECT s.id, s.email_id
    FROM src s
    LEFT JOIN tgt t ON s.id = t.id
    WHERE t.id IS NULL
),

extra_in_target AS (
    SELECT t.id, t.email_id
    FROM tgt t
    LEFT JOIN src s ON t.id = s.id
    WHERE s.id IS NULL
),

email_mismatches AS (
    SELECT s.id, s.email_id AS source_email, t.email_id AS target_email
    FROM src s
    JOIN tgt t ON s.id = t.id
    WHERE s.email_id IS DISTINCT FROM t.email_id
)

SELECT
    'Record Count Check' AS check_type,
    (SELECT source_count FROM counts) AS source_count,
    (SELECT target_count FROM counts) AS target_count,
    CASE
        WHEN (SELECT source_count FROM counts) = (SELECT target_count FROM counts)
        THEN 'PASS' ELSE 'FAIL' END AS status
UNION ALL
SELECT
    'Missing in Target', (SELECT COUNT(*) FROM missing_in_target), 0,
    CASE WHEN (SELECT COUNT(*) FROM missing_in_target) = 0 THEN 'PASS' ELSE 'FAILED' END
UNION ALL
SELECT
    'Extra in Target', (SELECT COUNT(*) FROM extra_in_target), 0,
    CASE WHEN (SELECT COUNT(*) FROM extra_in_target) = 0 THEN 'PASS' ELSE 'FAILED' END
UNION ALL
SELECT
    'Email Mismatches', (SELECT COUNT(*) FROM email_mismatches), 0,
    CASE WHEN (SELECT COUNT(*) FROM email_mismatches) = 0 THEN 'PASS' ELSE 'FAILED' END
ORDER BY check_type;

```
