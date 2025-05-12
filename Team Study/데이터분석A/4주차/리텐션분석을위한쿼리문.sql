DROP TABLE IF EXISTS cohort_users;

CREATE TABLE cohort_users (
    user_id VARCHAR(20),
    signup_cohort VARCHAR(20),
    week VARCHAR(10)
);


COPY cohort_users(user_id, signup_cohort, week)
FROM 'C:\sql_data\Cohort_Users.csv'
DELIMITER ','
CSV HEADER;

SELECT
    signup_cohort,
    week,
    COUNT(DISTINCT user_id) AS retained_users
FROM
    cohort_users
GROUP BY
    signup_cohort,
    week
ORDER BY
    signup_cohort,
    week;

WITH base_counts AS (
    SELECT
        signup_cohort,
        COUNT(DISTINCT user_id) AS total_users
    FROM
        cohort_users
    WHERE
        week = 'Week 0'
    GROUP BY
        signup_cohort
),
retention_counts AS (
    SELECT
        signup_cohort,
        week,
        COUNT(DISTINCT user_id) AS retained_users
    FROM
        cohort_users
    GROUP BY
        signup_cohort,
        week
)
SELECT
    r.signup_cohort,
    r.week,
    r.retained_users,
    b.total_users,
    ROUND(r.retained_users * 100.0 / b.total_users, 1) AS retention_rate_percent
FROM
    retention_counts r
JOIN
    base_counts b
ON
    r.signup_cohort = b.signup_cohort
ORDER BY
    r.signup_cohort,
    r.week;


