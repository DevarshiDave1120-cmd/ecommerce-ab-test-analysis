-- Fails if any data-quality count differs from the expected values
-- (README, "Data quality findings"), or if a step is missing or unexpected.
WITH expected AS (
  SELECT * FROM UNNEST([
    STRUCT(1 AS step, 294478 AS value),  -- raw rows
    (2, 290584),                         -- raw unique users
    (3, 3893),                           -- rows with group/page mismatch
    (4, 0),                              -- every mismatched row belongs to a repeat user
    (5, 3894),                           -- repeat users
    (6, 3893),                           -- repeat users with a mismatched row
    (7, 286690),                         -- int_ab_users_clean
    (8, 290584)                          -- int_ab_users_sensitivity
  ])
)

SELECT
  step,
  e.value AS expected_value,
  a.value AS actual_value
FROM expected AS e
FULL OUTER JOIN {{ ref('fct_data_quality_summary') }} AS a USING (step)
WHERE e.value IS NULL OR a.value IS NULL OR e.value != a.value
