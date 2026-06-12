FROM python:3.12-slim

# System deps for OCR (tesseract) and PDF rasterization (poppler)
RUN apt-get update && apt-get install -y --no-install-recommends \
        tesseract-ocr \
        poppler-utils \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY blip_task_ocr.py .

ENV PORT=5011 \
    USE_NGROK=false \
    PYTHONUNBUFFERED=1

EXPOSE 5011

# 2 workers, 4 threads, long timeout for big-PDF OCR at 400 DPI
CMD ["gunicorn", "--bind", "0.0.0.0:5011", "--workers", "2", "--threads", "4", "--timeout", "300", "blip_task_ocr:app"]