FROM python:3.11-slim

RUN pip install dbt-postgres

WORKDIR /dbt

COPY . .

RUN mkdir -p /root/.dbt && echo "\
weather_projet:\n\
  outputs:\n\
    prod:\n\
      type: postgres\n\
      host: greencoop.ch04i4cyywpm.us-east-2.rds.amazonaws.com\n\
      port: 5432\n\
      dbname: greencoop\n\
      user: greencoop\n\
      pass: \${DBT_PASSWORD}\n\
      schema: dbt_prod\n\
      threads: 4\n\
  target: prod" > /root/.dbt/profiles.yml

ENV DBT_PASSWORD=""

CMD ["dbt", "run", "--target", "prod"]