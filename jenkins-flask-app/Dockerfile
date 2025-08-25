# Use lightweight Python image
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["python", "app.py"]
# Expose the port the app runs on
#EXPOSE 5000
# Note: Ensure the Flask app is set to run on host
