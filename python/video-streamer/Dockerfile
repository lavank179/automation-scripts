FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt stream.py test.mp4  /app/

RUN apt-get update && \
    apt-get install -y ffmpeg libsm6 libxext6 && \
    pip install --no-cache-dir --trusted-host pypi.org --trusted-host files.pythonhosted.org opencv-python-headless flask && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 8000
CMD ["python3", "stream.py"]
