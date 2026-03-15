FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1

WORKDIR /app

# System deps for OpenCV/ultralytics
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    libgl1 \
    libglib2.0-0 \
  && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/
RUN pip install -r requirements.txt

# Install CPU-only torch + torchvision first, then ultralytics (keeps image smaller)
RUN pip install --index-url https://download.pytorch.org/whl/cpu torch==2.2.2 torchvision==0.17.2 \
  && pip install ultralytics==8.2.0

COPY . /app

ENV PORT=8000
EXPOSE 8000

CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT}"]
