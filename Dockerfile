# Use official lightweight Python image
FROM python:3.12-slim

# Set working directory in the container
WORKDIR /app

# Copy all files from current directory to the container
COPY . .

# Install Flask
RUN pip install flask

# Expose port 5000 for Flask
EXPOSE 5000

# run
CMD ["python", "app.py"]
