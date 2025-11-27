FROM python:latest
WORKDIR /app
COPY script.py .
RUN pip install psycopg[binary]
CMD ["python", "script.py"]
