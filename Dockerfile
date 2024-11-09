FROM mongo

# Instala Python, pip, y python3-venv para entornos virtuales
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv && \
    rm -rf /var/lib/apt/lists/*

# Crea un entorno virtual e instala pymongo en él
RUN python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir pymongo

# Establece el entorno virtual en el PATH
ENV PATH="/opt/venv/bin:$PATH"
