import os
import time

from flask import Flask, jsonify, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, generate_latest

app = Flask(__name__)

APP_ENV = os.getenv("APP_ENV", "local")
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
START_TIME = time.time()

REQUEST_COUNTER = Counter(
    "tfm_app_http_requests_total",
    "Total number of HTTP requests",
    ["endpoint"],
)


@app.get("/")
def index():
    REQUEST_COUNTER.labels(endpoint="/").inc()

    return jsonify(
        application="TFM DevOps Platform",
        environment=APP_ENV,
        version=APP_VERSION,
        status="running",
    )


@app.get("/health")
def health():
    REQUEST_COUNTER.labels(endpoint="/health").inc()

    return jsonify(
        status="healthy",
        environment=APP_ENV,
        version=APP_VERSION,
    )


@app.get("/ready")
def ready():
    REQUEST_COUNTER.labels(endpoint="/ready").inc()

    return jsonify(
        status="ready",
        uptime_seconds=round(time.time() - START_TIME, 2),
    )


@app.get("/metrics")
def metrics():
    REQUEST_COUNTER.labels(endpoint="/metrics").inc()

    return Response(
        generate_latest(),
        mimetype=CONTENT_TYPE_LATEST,
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
