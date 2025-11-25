FROM python:3.12-slim

ENV PORT=499

# Logs non bufferisés
ENV PYTHONUNBUFFERED=1

# Dossier de travail
WORKDIR /app

# Dépendances système :
# - git : pour cloner le dépôt PyMusic
# - ffmpeg : requis par yt-dlp pour l’audio
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Clone du repo PyMusic directement dans l'image
RUN git clone https://github.com/nicobo-crl/PyMusic . 

# Installation des dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# PyMusic écoute en interne sur 499
EXPOSE ${PORT}

# Démarrage de l'application
CMD ["python", "app.py"]
