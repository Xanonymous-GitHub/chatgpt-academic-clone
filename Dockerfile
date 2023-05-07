# Use an official Python runtime as a parent image
FROM python:slim AS base

# Set up a non-root user and working directory
RUN addgroup --system appgroup \
    && adduser --system --ingroup appgroup appuser

USER appuser
WORKDIR /app

# Copy only the necessary files for dependency installation
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt --no-cache-dir

# Use multistage build to create a separate build stage
FROM base AS builder

# Copy the rest of the application code
COPY --chown=appuser:appgroup . .

# Switch back to the base image
FROM base

# Copy the compiled application from the builder stage
COPY --from=builder --chown=appuser:appgroup /app /app

# Set the environment variables
ENV API_KEY=${API_KEY}
ENV LLM_MODEL=${LLM_MODEL}

# Make the container executable and run the application
ENTRYPOINT ["python3"]
CMD ["main.py"]
