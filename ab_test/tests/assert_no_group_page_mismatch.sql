-- Fails if any mismatched assignment survives cleaning, in either intermediate model.
-- Re-checks the rule from the raw columns rather than trusting is_assignment_mismatch.
SELECT 'int_ab_users_clean' AS model, user_id, experiment_group, landing_page
FROM {{ ref('int_ab_users_clean') }}
WHERE (experiment_group = 'control'   AND landing_page != 'old_page')
   OR (experiment_group = 'treatment' AND landing_page != 'new_page')

UNION ALL

SELECT 'int_ab_users_sensitivity' AS model, user_id, experiment_group, landing_page
FROM {{ ref('int_ab_users_sensitivity') }}
WHERE (experiment_group = 'control'   AND landing_page != 'old_page')
   OR (experiment_group = 'treatment' AND landing_page != 'new_page')
