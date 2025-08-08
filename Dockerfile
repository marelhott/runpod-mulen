FROM nvidia/cuda:12.1.1-runtime-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
WORKDIR /workspace

# Base tools and libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates build-essential \
    python3 python3-pip python3-venv python3-dev \
    libgl1 libglib2.0-0 libffi-dev libgit2-dev \
    nginx supervisor aria2 && \
    rm -rf /var/lib/apt/lists/*

# rclone (fast cloud transfers)
RUN curl -fsSL https://rclone.org/install.sh | bash

# FileBrowser (lightweight web file manager)
RUN curl -fsSL https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz \
    | tar -xz -C /usr/local/bin

# Persist structure
RUN mkdir -p /workspace/{apps,venvs,models,logs,bin} /etc/nginx/sites-enabled

# ---------- A1111 ----------
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui /workspace/apps/A1111
RUN python3 -m venv /workspace/venvs/a1111
ENV PATH="/workspace/venvs/a1111/bin:${PATH}"
RUN pip install -U pip wheel setuptools

# Start script (backend listens 3001; nginx exposes 3000)
COPY scripts/start_a1111.sh /workspace/bin/start_a1111.sh
RUN chmod +x /workspace/bin/start_a1111.sh

# ---------- Fooocus (aidreamer2030) ----------
RUN git clone https://github.com/aidreamer2030/Fooocus-ControlNet-SDXL /workspace/apps/Fooocus
RUN python3 -m venv /workspace/venvs/fooocus
ENV PATH="/workspace/venvs/a1111/bin:/workspace/venvs/fooocus/bin:${PATH}"
RUN pip install -U pip wheel setuptools pygit2 && \
    ( test -f /workspace/apps/Fooocus/requirements_versions.txt && \
      sed -i "s/torchsde==0.2.5/torchsde==0.2.6/" /workspace/apps/Fooocus/requirements_versions.txt || true ) && \
    ( test -f /workspace/apps/Fooocus/requirements_versions.txt && \
      pip install -r /workspace/apps/Fooocus/requirements_versions.txt || \
      ( test -f /workspace/apps/Fooocus/requirements.txt && pip install -r /workspace/apps/Fooocus/requirements.txt || true ) )
COPY scripts/start_fooocus.sh /workspace/bin/start_fooocus.sh
RUN chmod +x /workspace/bin/start_fooocus.sh

# ---------- ComfyUI ----------
RUN git clone https://github.com/comfyanonymous/ComfyUI /workspace/apps/ComfyUI
RUN python3 -m venv /workspace/venvs/comfy
ENV PATH="/workspace/venvs/a1111/bin:/workspace/venvs/fooocus/bin:/workspace/venvs/comfy/bin:${PATH}"
RUN pip install -U pip wheel setuptools && \
    pip install -r /workspace/apps/ComfyUI/requirements.txt
COPY scripts/start_comfy.sh /workspace/bin/start_comfy.sh
RUN chmod +x /workspace/bin/start_comfy.sh

# ---------- InvokeAI (minimal API/UI) ----------
RUN git clone https://github.com/invoke-ai/InvokeAI /workspace/apps/InvokeAI
RUN python3 -m venv /workspace/venvs/invoke
ENV PATH="/workspace/venvs/a1111/bin:/workspace/venvs/fooocus/bin:/workspace/venvs/comfy/bin:/workspace/venvs/invoke/bin:${PATH}"
RUN pip install -U pip wheel setuptools && \
    ( test -f /workspace/apps/InvokeAI/requirements.txt && pip install -r /workspace/apps/InvokeAI/requirements.txt || true )
COPY scripts/start_invoke.sh /workspace/bin/start_invoke.sh
RUN chmod +x /workspace/bin/start_invoke.sh

# ---------- JupyterLab ----------
RUN python3 -m venv /workspace/venvs/jlab
ENV PATH="/workspace/venvs/a1111/bin:/workspace/venvs/fooocus/bin:/workspace/venvs/comfy/bin:/workspace/venvs/invoke/bin:/workspace/venvs/jlab/bin:${PATH}"
RUN pip install -U pip wheel setuptools && pip install jupyterlab
COPY scripts/start_jlab.sh /workspace/bin/start_jlab.sh
RUN chmod +x /workspace/bin/start_jlab.sh

# ---------- FileBrowser ----------
COPY scripts/start_filebrowser.sh /workspace/bin/start_filebrowser.sh
RUN chmod +x /workspace/bin/start_filebrowser.sh

# ---------- Nginx reverse proxy for clickable ports ----------
COPY nginx/sites-enabled/a1111.conf /etc/nginx/sites-enabled/a1111.conf
COPY nginx/sites-enabled/invoke.conf /etc/nginx/sites-enabled/invoke.conf
COPY nginx/sites-enabled/comfy.conf /etc/nginx/sites-enabled/comfy.conf
COPY nginx/sites-enabled/fooocus.conf /etc/nginx/sites-enabled/fooocus.conf
COPY nginx/sites-enabled/jupyter.conf /etc/nginx/sites-enabled/jupyter.conf
COPY nginx/sites-enabled/filebrowser.conf /etc/nginx/sites-enabled/filebrowser.conf

# ---------- Supervisord ----------
COPY supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 3000 3010 3020 7640 8888 8080
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/supervisord.conf"]
