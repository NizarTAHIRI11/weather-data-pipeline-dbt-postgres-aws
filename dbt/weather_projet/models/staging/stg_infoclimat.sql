{{ config(materialized='view') }}

WITH source_data AS (
    SELECT
        hourly::jsonb AS hourly,
        _airbyte_extracted_at AS ingestion_timestamp
    FROM {{ source('forecast2', 'infoclimat_weather') }}
),
stations_expanded AS (
    SELECT
        station.key AS station_id,
        station.value AS observations,
        ingestion_timestamp
    FROM source_data,
    jsonb_each(hourly) AS station
    WHERE station.key <> '_params'
),
observations_expanded AS (
    SELECT
        station_id,
        jsonb_array_elements(observations) AS obs,
        ingestion_timestamp
    FROM stations_expanded
),
cleaned AS (
    SELECT
        obs ->> 'id_station' AS station_id,
        (obs ->> 'dh_utc')::timestamp AS observation_datetime,
        NULLIF(obs ->> 'temperature', '')::numeric AS temperature_c,
        NULLIF(obs ->> 'pression', '')::numeric AS pressure_hpa,
        NULLIF(obs ->> 'humidite', '')::numeric AS humidity_pct,
        NULLIF(obs ->> 'point_de_rosee', '')::numeric AS dew_point_c,
        NULLIF(obs ->> 'visibilite', '')::numeric AS visibility_m,
        NULLIF(obs ->> 'vent_moyen', '')::numeric AS wind_speed_kmh,
        NULLIF(obs ->> 'vent_rafales', '')::numeric AS wind_gust_kmh,
        NULLIF(obs ->> 'vent_direction', '')::numeric AS wind_direction_deg,
        NULLIF(obs ->> 'pluie_3h', '')::numeric AS precip_3h_mm,
        NULLIF(obs ->> 'pluie_1h', '')::numeric AS precip_1h_mm,
        NULLIF(obs ->> 'neige_au_sol', '')::numeric AS snow_depth_cm,
        NULLIF(obs ->> 'nebulosite', '')::numeric AS cloud_cover_octas,
        NULLIF(obs ->> 'temps_omm', '')::numeric AS weather_code,
        'infoclimat' AS source_network,
        ingestion_timestamp
    FROM observations_expanded
)
SELECT *
FROM cleaned