FROM python:3.13-slim

LABEL org.opencontainers.image.title="TFM DevOps Application"
LABEL org.opencontainers.image.description="Demo application for the DevOps master's project"

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV APP_ENV=local
ENV APP_VERSION=1.1.0

WORKDIR /app

RUN groupadd --gid 10001 appgroup \
    && useradd \
       --uid 10001 \
       --gid appgroup \
       --no-create-home \
       --shell /usr/sbin/nologin \
       appuser

COPY requirements.txt .

RUN pip install \
    --no-cache-dir \
    --disable-pip-version-check \
    -r requirements.txt

COPY src/ ./src/

RUN chown -R appuser:appgroup /app

USER 10001:10001

EXPOSE 8080

HEALTHCHECK \
    --interval=30s \
    --timeout=5s \
    --start-period=10s \
    --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=3)"

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--threads", "2", "--access-logfile", "-", "src.app:app"]
