{{ 
    config(
        materialized='table',
        indexes=[
            {'columns': ['station_id']},
            {'columns': ['observation_datetime']},
            {'columns': ['station_id', 'observation_datetime']}
        ]
    ) 
}}

WITH unified_observations AS (

    SELECT
        station_id,
        (CURRENT_DATE + observation_time)::timestamp AS observation_datetime,
        temperature_c,
        dew_point_c,
        humidity_pct,
        pressure_hpa,
        wind_direction,
        NULL::numeric AS wind_direction_deg,
        wind_speed_kmh,
        wind_gust_kmh,
        precip_rate_mm,
        precip_accum_mm,
        NULL::numeric AS precip_1h_mm,
        NULL::numeric AS precip_3h_mm,
        uv_index,
        solar_wm2,
        NULL::numeric AS visibility_m,
        NULL::numeric AS snow_depth_cm,
        NULL::numeric AS cloud_cover_octas,
        NULL::numeric AS weather_code,
        source_network,
        ingestion_timestamp
    FROM {{ ref('stg_la_madeleine') }}

    UNION ALL

    SELECT
        station_id,
        (CURRENT_DATE + observation_time)::timestamp AS observation_datetime,
        temperature_c,
        dew_point_c,
        humidity_pct,
        pressure_hpa,
        wind_direction,
        NULL::numeric AS wind_direction_deg,
        wind_speed_kmh,
        wind_gust_kmh,
        precip_rate_mm,
        precip_accum_mm,
        NULL::numeric AS precip_1h_mm,
        NULL::numeric AS precip_3h_mm,
        uv_index,
        solar_wm2,
        NULL::numeric AS visibility_m,
        NULL::numeric AS snow_depth_cm,
        NULL::numeric AS cloud_cover_octas,
        NULL::numeric AS weather_code,
        source_network,
        ingestion_timestamp
    FROM {{ ref('stg_ichtegem') }}

    UNION ALL

    SELECT
        station_id,
        observation_datetime,
        temperature_c,
        dew_point_c,
        humidity_pct,
        pressure_hpa,
        NULL::varchar AS wind_direction,
        wind_direction_deg,
        wind_speed_kmh,
        wind_gust_kmh,
        NULL::numeric AS precip_rate_mm,
        NULL::numeric AS precip_accum_mm,
        precip_1h_mm,
        precip_3h_mm,
        NULL::numeric AS uv_index,
        NULL::numeric AS solar_wm2,
        visibility_m,
        snow_depth_cm,
        cloud_cover_octas,
        weather_code,
        source_network,
        ingestion_timestamp
    FROM {{ ref('stg_infoclimat') }}
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY station_id, observation_datetime
    ) AS weather_observation_id,

    station_id,
    observation_datetime,
    temperature_c,
    dew_point_c,
    humidity_pct,
    pressure_hpa,
    wind_direction,
    wind_direction_deg,
    wind_speed_kmh,
    wind_gust_kmh,
    precip_rate_mm,
    precip_accum_mm,
    precip_1h_mm,
    precip_3h_mm,
    uv_index,
    solar_wm2,
    visibility_m,
    snow_depth_cm,
    cloud_cover_octas,
    weather_code,
    source_network,
    ingestion_timestamp

FROM unified_observations