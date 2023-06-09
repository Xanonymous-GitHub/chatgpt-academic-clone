# Use an official Python runtime as a parent image
FROM python:slim AS base

# Set up a non-root user and working directory
RUN addgroup --system appgroup \
    && adduser --system --ingroup appgroup appuser

USER appuser
WORKDIR /app

# Copy only the necessary files for dependency installation
COPY requirements.txt .
COPY request_llm/requirements_newbing.txt ./request_llm
COPY request_llm/requirements_moss.txt ./request_llm
COPY request_llm/requirements_jittorllms.txt ./request_llm
COPY request_llm/requirements_chatglm.txt ./request_llm

# Install any needed packages specified in requirements.txt
RUN export PATH=$PATH:/home/appuser/.local/bin \
    && export PYTHONPATH=$PYTHONPATH:/app \
    && export PATH=$PATH:/app \
    && pip install --trusted-host pypi.python.org -r requirements.txt --no-cache-dir \
    && pip install --trusted-host pypi.python.org -r request_llm/requirements_newbing.txt --no-cache-dir \
    && pip install --trusted-host pypi.python.org -r request_llm/requirements_moss.txt --no-cache-dir \
    && pip install --trusted-host pypi.python.org -r request_llm/requirements_jittorllms.txt --no-cache-dir \
    && pip install --trusted-host pypi.python.org -r request_llm/requirements_chatglm.txt --no-cache-dir

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
ENV WEB_PORT=${WEB_PORT}

# Make the container executable and run the application
ENTRYPOINT ["python3"]
CMD ["main.py"]
