
FROM python:3.12-slim

ARG AIRFLOW_VERSION=3.4.0
ARG PYTHON_VERSION=3.12

ENV AIRFLOW_HOME=/opt/airflow
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PATH="/usr/local/bin:${PATH}"

# Installation des dépendances système
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        gcc \
        libpq-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Création de l'utilisateur Airflow
RUN groupadd --gid 0 airflow \
    && useradd --uid 50000 --gid 0 \
       --home-dir /opt/airflow \
       --create-home airflow \
    && mkdir -p /opt/airflow/dags \
                /opt/airflow/logs \
                /opt/airflow/plugins \
                /opt/airflow/config \
    && chown -R airflow:0 /opt/airflow

# Installation Airflow avec contraintes officielles
RUN pip install --no-cache-dir \
    "apache-airflow[postgres]==${AIRFLOW_VERSION}" \
    --constraint \
    "https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt"

# Installation des dépendances complémentaires
COPY requirements.txt /tmp/requirements.txt

RUN if [ -s /tmp/requirements.txt ]; then \
      pip install --no-cache-dir \
        "apache-airflow==${AIRFLOW_VERSION}" \
        -r /tmp/requirements.txt; \
    fi

USER airflow

WORKDIR /opt/airflow

EXPOSE 8080
