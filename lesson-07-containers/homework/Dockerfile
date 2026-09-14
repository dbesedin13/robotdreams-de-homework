FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1

RUN useradd --create-home --uid 1000 appuser \
    && mkdir /cache \
    && chown appuser:appuser /cache

WORKDIR /app

COPY app/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app/ .

USER appuser

ENTRYPOINT ["python", "gh_ingest.py"]
