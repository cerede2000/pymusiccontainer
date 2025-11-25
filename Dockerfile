# ====== STAGE 1 : build (venv + dépendances) ======
FROM python:3.12-slim AS builder

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# On a juste besoin de git pour cloner le dépôt
RUN apt-get update \
 && apt-get install -y --no-install-recommends git \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Clone léger du dépôt + suppression du .git pour ne pas gonfler l'image finale
RUN git clone --depth 1 https://github.com/nicobo-crl/PyMusic . \
 && rm -rf .git

# Crée un venv minimal
RUN python -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Installe les dépendances (dont gunicorn) dans le venv
RUN pip install --upgrade pip \
 && pip install --no-cache-dir -r requirements.txt gunicorn

# ====== STAGE 2 : image finale ======
FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PATH="/venv/bin:$PATH" \
    PYMUSIC_PORT=499

WORKDIR /app

# On récupère seulement le venv et le code depuis le builder
COPY --from=builder /venv /venv
COPY --from=builder /src /app

# Crée un user non-root
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# gunicorn en frontal (prod)
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:${PYMUSIC_PORT}", "app:app"]
