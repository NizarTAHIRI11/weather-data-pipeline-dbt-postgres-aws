{{ 
    config(
        materialized='table',
        indexes=[
            {'columns': ['observation_datetime'], 'unique': True},
            {'columns': ['year', 'month']},
            {'columns': ['observation_date']}
        ]
    ) 
}}

SELECT DISTINCT
    observation_datetime,
    DATE(observation_datetime) AS observation_date,
    EXTRACT(YEAR FROM observation_datetime) AS year,
    EXTRACT(MONTH FROM observation_datetime) AS month,
    EXTRACT(DAY FROM observation_datetime) AS day,
    EXTRACT(HOUR FROM observation_datetime) AS hour
FROM {{ ref('fact_weather_observations') }}
WHERE observation_datetime IS NOT NULL