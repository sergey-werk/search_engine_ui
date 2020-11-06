# Two-stage build
FROM python:3.6-alpine as python-base

# Stage 1
FROM python-base as builder
LABEL app="search_engine_ui"

RUN mkdir /install
WORKDIR /install

COPY requirements.txt /requirements.txt

RUN apk --no-cache --update add build-base && \
    pip install --prefix=/install -r /requirements.txt && \
    apk del build-base

# Stage 2
FROM python-base
LABEL app="search_engine_ui"
LABEL version="2.1"

COPY --from=builder /install /usr/local
COPY . /app
WORKDIR /app

# MONGO - адрес mongodb-хоста
# MONGO_PORT - порт для подключения к mongodb-хосту

ENV MONGO mongodb
ENV MONGO_PORT 27017

ENTRYPOINT  cd ui && FLASK_APP=ui.py gunicorn ui:app -b 0.0.0.0
