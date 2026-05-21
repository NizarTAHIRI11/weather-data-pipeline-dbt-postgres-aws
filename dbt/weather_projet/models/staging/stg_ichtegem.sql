{{ config(materialized='view') }}

WITH source_data AS (
    SELECT *
    FROM {{ source('forecast2', 'ichtegem_weather') }}
),
cleaned AS (
    SELECT
        -- Station metadata
        'IICHTE19' AS station_id,
        -- Observation time
        "Time"::time AS observation_time,
        -- Temperature conversion : Fahrenheit -> Celsius
        ROUND(
            (
                regexp_replace("Temperature", '[^0-9.-]', '', 'g')::numeric
                - 32
            ) * 5 / 9,
            2
        ) AS temperature_c,
        ROUND(
            (
                regexp_replace("Dew_Point", '[^0-9.-]', '', 'g')::numeric
                - 32
            ) * 5 / 9,
            2
        ) AS dew_point_c,
        -- Humidity
        regexp_replace("Humidity", '[^0-9.-]', '', 'g')::numeric AS humidity_pct,
        -- Wind data
        "Wind" AS wind_direction,
        ROUND(
            regexp_replace("Speed", '[^0-9.-]', '', 'g')::numeric * 1.60934,
            2
        ) AS wind_speed_kmh,

        ROUND(
            regexp_replace("Gust", '[^0-9.-]', '', 'g')::numeric * 1.60934,
            2
        ) AS wind_gust_kmh,
        -- Atmospheric pressure : inHg -> hPa
        ROUND(
            regexp_replace("Pressure", '[^0-9.-]', '', 'g')::numeric * 33.8639,
            2
        ) AS pressure_hpa,
        -- Precipitation : inch -> mm
        ROUND(
            regexp_replace("Precip__Rate_", '[^0-9.-]', '', 'g')::numeric * 25.4,
            2
        ) AS precip_rate_mm,
        ROUND(
            regexp_replace("Precip__Accum_", '[^0-9.-]', '', 'g')::numeric * 25.4,
            2
        ) AS precip_accum_mm,
        -- UV index and solar radiation
        "UV"::numeric AS uv_index,
        regexp_replace("Solar", '[^0-9.-]', '', 'g')::numeric AS solar_wm2,
        -- Source metadata
        'weather_underground' AS source_network,
        -- Airbyte ingestion timestamp kept for pipeline traceability
        _airbyte_extracted_at AS ingestion_timestamp
    FROM source_data
)
SELECT *
FROM cleaned