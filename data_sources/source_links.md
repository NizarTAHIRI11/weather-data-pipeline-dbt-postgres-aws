# Sources de données – Forecast 2.0

## Contexte

Dans le cadre du projet Forecast 2.0 de GreenAndCoop, plusieurs sources de données météorologiques ont été identifiées afin d’améliorer les modèles de prévision énergétique développés par l’équipe Data Science.

Les données proviennent de différentes plateformes et stations météorologiques semi-professionnelles. Elles seront ingérées dans PostgreSQL via Airbyte avant transformation avec DBT.

---

# 1. Réseau InfoClimat

## Description
Données météorologiques provenant du réseau InfoClimat couvrant plusieurs stations situées dans les Hauts-de-France.

## Stations concernées
- Bergues
- Hazebrouck
- Armentières
- Lille-Lesquin

## Source
https://s3.eu-west-1.amazonaws.com/course.oc-static.com/projects/922_Data+Engineer/922_P8/Data_Source1_011024-071024.json

## Format
- JSON

## Fréquence des données
- Relevés toutes les 10 à 30 minutes selon les stations

## Utilisation
- Ingestion RAW dans PostgreSQL via Airbyte
- Harmonisation et transformation avec DBT
- Construction des tables analytiques finales

---

# 2. Weather Underground – Ichtegem (Belgique)

## Description
Station météorologique amateur localisée à Ichtegem en Belgique.

## Métadonnées station
- Weather Station ID : IICHTE19
- Station Name : WeerstationBS
- Latitude : 51.092° N
- Longitude : 2.999° E
- Elevation : 15
- City : Ichtegem
- Hardware : other
- Software : EasyWeatherV1.6.6

## Format
- JSON / API météo

## Utilisation
- Intégration dans la dimension dim_weather_stations
- Enrichissement des modèles de prévision

---

# 3. Weather Underground – La Madeleine (France)

## Description
Station météorologique amateur localisée à La Madeleine en France.

## Métadonnées station
- Weather Station ID : ILAMAD25
- Station Name : La Madeleine
- Latitude : 50.659° N
- Longitude : 3.07° E
- Elevation : 23
- City : La Madeleine
- Hardware : other
- Software : EasyWeatherPro_V5.1.6

## Format
- JSON / API météo

## Utilisation
- Intégration dans la dimension dim_weather_stations
- Enrichissement des modèles de prévision

---

# Architecture cible du flux de données

Sources météo
→ Airbyte
→ PostgreSQL RAW
→ DBT (staging → intermediate → marts)
→ Tables analytiques
→ Équipe Data Science / SageMaker

---

# Remarques importantes

- Les données RAW ne doivent jamais être modifiées directement.
- Toutes les transformations doivent être réalisées via DBT.
- Les sources doivent être documentées afin de garantir la traçabilité des données.
- Les fréquences de synchronisation doivent rester cohérentes avec les fréquences de relevés des stations.