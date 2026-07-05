# 🌦️ Weather Data Pipeline — DBT + PostgreSQL + AWS

> Pipeline ELT complet de collecte, transformation et stockage de données météorologiques multi-sources.

---

## 📈 Résultats

- ✅ Pipeline ELT automatisé multi-sources (Infoclimat + Weather Underground)
- ✅ Modélisation en étoile (Star Schema) avec DBT
- ✅ Contrôles qualité DBT (not_null, unique, relationships)
- ✅ Base de données PostgreSQL déployée sur AWS RDS
- ✅ Documentation et lineage DBT générés automatiquement
- ✅ Environnement local reproductible via Docker Compose

---

## 🏗️ Architecture du pipeline

```
  Infoclimat API          Weather Underground API
        │                          │
        └──────────┬───────────────┘
                   ▼
               Airbyte
          (Ingestion ELT)
                   │
                   ▼
     PostgreSQL RAW — AWS RDS
      (tables brutes sources)
                   │
                   ▼
                 DBT
    ┌─────────────────────────────┐
    │  staging  →  intermediate   │
    │          →  marts           │
    └─────────────────────────────┘
                   │
                   ▼
        Data Warehouse Analytics
        (schéma en étoile)
                   │
                   ▼
     AWS CloudWatch / AWS ECS
       (monitoring & déploiement)
```

---

## 📐 Modèle de données — Star Schema

```
fact_weather_observations
   ├── station_id         FK → dim_weather_stations
   ├── time_id            FK → dim_weather_time
   ├── temperature_c
   ├── humidity_pct
   ├── pressure_hpa
   ├── wind_speed_kmh
   └── precipitation_mm

dim_weather_stations
   ├── station_id         PK
   ├── station_name
   ├── city
   ├── latitude
   ├── longitude
   └── source             (infoclimat | weather_underground)

dim_weather_time
   ├── time_id            PK
   ├── datetime
   ├── hour
   ├── day
   ├── month
   └── year
```

---

## 🏗️ Structure du projet

```
weather-data-pipeline-dbt-postgres-aws/
├── aws/
│   └── rds/
│       ├── init_schema.sql       # Création des tables RAW
│       └── security_groups/      # Règles de sécurité AWS
├── data_sources/
│   ├── infoclimat/               # Scripts collecte Infoclimat
│   └── weather_underground/      # Scripts collecte Weather Underground
├── dbt/
│   └── weather_projet/
│       ├── models/
│       │   ├── staging/          # Nettoyage et typage des données brutes
│       │   ├── intermediate/     # Jointures et enrichissements
│       │   └── marts/            # Modèles finaux (fact + dims)
│       ├── macros/               # Macros DBT réutilisables
│       ├── seeds/                # Données de référence statiques
│       ├── snapshots/            # Gestion SCD (Slowly Changing Dimensions)
│       ├── tests/                # Tests de qualité des données
│       └── analyses/             # Analyses ad hoc SQL
├── docker/
│   └── docker-compose.yml        # PostgreSQL + pgAdmin + Airbyte local
├── requirements.txt
└── README.md
```

---

## 🛠️ Stack technique

| Outil | Usage |
|---|---|
| **DBT Core** | Transformation et modélisation (ELT) |
| **PostgreSQL** | Base de données relationnelle |
| **AWS RDS** | Hébergement cloud PostgreSQL |
| **Airbyte** | Ingestion des données sources |
| **Docker / Compose** | Environnement local de développement |
| **AWS ECS** | Architecture cible déploiement conteneurs |
| **AWS CloudWatch** | Architecture cible monitoring & alertes |
| **Python** | Scripts de collecte et utilitaires |

---

## 📦 Prérequis

- Python 3.12+
- Docker & Docker Compose
- Un compte AWS avec accès RDS
- DBT Core installé

---

## 🚀 Installation

### 1. Cloner le repo

```bash
git clone https://github.com/NizarTAHIRI11/weather-data-pipeline-dbt-postgres-aws.git
cd weather-data-pipeline-dbt-postgres-aws
```

### 2. Environnement virtuel et dépendances

```bash
python -m venv venv
# Windows
.\venv\Scripts\activate
# Linux/Mac
source venv/bin/activate

pip install -r requirements.txt
```

### 3. Variables d'environnement

Créer un fichier `.env` à la racine **(ne jamais committer)** :

```env
DB_HOST=your-rds-endpoint.amazonaws.com
DB_PORT=5432
DB_NAME=weather_db
DB_USER=your_user
DB_PASSWORD=your_password
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
AWS_REGION=eu-west-1
```

### 4. Lancer l'environnement local

```bash
cd docker
docker-compose up -d
# PostgreSQL → localhost:5432
# pgAdmin    → localhost:8080
# Airbyte    → localhost:8000
```

### 5. Configurer le profil DBT

Créer `~/.dbt/profiles.yml` **(ne jamais committer)** :

```yaml
weather_projet:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: your_user
      password: your_password
      dbname: weather_db
      schema: public
      threads: 4
    prod:
      type: postgres
      host: "{{ env_var('DB_HOST') }}"
      port: 5432
      user: "{{ env_var('DB_USER') }}"
      password: "{{ env_var('DB_PASSWORD') }}"
      dbname: weather_db
      schema: public
      threads: 4
```

---

## ▶️ Lancer le pipeline DBT

```bash
cd dbt/weather_projet

# Vérifier la connexion
dbt debug

# Compiler les modèles
dbt compile

# Exécuter tous les modèles
dbt run

# Exécuter les tests de qualité
dbt test

# Générer et servir la documentation
dbt docs generate
dbt docs serve
```

### Exécuter par couche

```bash
dbt run --select staging        # Nettoyage données brutes
dbt run --select intermediate   # Enrichissements
dbt run --select marts          # Modèles finaux (fact + dims)
```

---

## 🧪 Tests de qualité des données

| Test | Description |
|---|---|
| `not_null` | Champs obligatoires non vides |
| `unique` | Unicité des clés primaires |
| `accepted_values` | Validation des valeurs attendues |
| `relationships` | Intégrité référentielle fact ↔ dims |

```bash
# Tous les tests
dbt test

# Tests d'un modèle précis
dbt test --select marts.fact_weather_observations
```

---

## 📊 Sources de données

| Source | Description |
|---|---|
| **Infoclimat** | Réseau de stations météo françaises (température, humidité, pression) |
| **Weather Underground** | Stations personnelles et professionnelles mondiales |

---

## 🔐 Sécurité

- Credentials gérés via variables d'environnement (`.env`)
- `profiles.yml` DBT jamais versionné
- Réplication RDS activée pour la haute disponibilité
- Accès AWS via principe du moindre privilège (IAM)
- Security Groups RDS restreints aux IP autorisées

---

## 📁 Fichiers exclus du versioning

```
venv/                          # Environnement Python local
.env                           # Variables d'environnement sensibles
dbt/weather_projet/target/     # Fichiers compilés DBT (générés auto)
dbt/weather_projet/logs/       # Logs DBT runtime
~/.dbt/profiles.yml            # Credentials DBT
*.pem / *.key                  # Clés AWS
```

---

## 👤 Auteur

**Nizar Tahiri** — Data Engineer Trainee | Applied Mathematics Background
