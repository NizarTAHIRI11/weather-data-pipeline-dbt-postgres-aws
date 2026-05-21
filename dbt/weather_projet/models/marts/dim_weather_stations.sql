{{ 
    config(
        materialized='table',
        indexes=[
            {'columns': ['station_id'], 'unique': True}
        ]
    ) 
}}

WITH amateur_stations AS (

    SELECT DISTINCT
        station_id,
        source_network
    FROM {{ ref('stg_la_madeleine') }}

    UNION

    SELECT DISTINCT
        station_id,
        source_network
    FROM {{ ref('stg_ichtegem') }}
)

SELECT
    station_id,

    CASE
        WHEN station_id = 'ILAMAD25' THEN 'La Madeleine'
        WHEN station_id = 'IICHTE19' THEN 'WeerstationBS'
    END AS station_name,

    CASE
        WHEN station_id = 'ILAMAD25' THEN 'La Madeleine'
        WHEN station_id = 'IICHTE19' THEN 'Ichtegem'
    END AS city,

    '-/-' AS state,

    CASE
        WHEN station_id = 'ILAMAD25' THEN 'France'
        WHEN station_id = 'IICHTE19' THEN 'Belgique'
    END AS country,

    CASE
        WHEN station_id = 'ILAMAD25' THEN 50.659
        WHEN station_id = 'IICHTE19' THEN 51.092
    END AS latitude,

    CASE
        WHEN station_id = 'ILAMAD25' THEN 3.070
        WHEN station_id = 'IICHTE19' THEN 2.999
    END AS longitude,

    CASE
        WHEN station_id = 'ILAMAD25' THEN 23
        WHEN station_id = 'IICHTE19' THEN 15
    END AS elevation_m,

    source_network,

    'other' AS hardware,

    CASE
        WHEN station_id = 'ILAMAD25' THEN 'EasyWeatherPro_V5.1.6'
        WHEN station_id = 'IICHTE19' THEN 'EasyWeatherV1.6.6'
    END AS software

FROM amateur_stations
WHERE source_network = 'weather_underground'