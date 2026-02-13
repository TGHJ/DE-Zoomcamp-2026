# 1) Base image: small Python runtime
FROM python:3.13-slim

# 2) Bring in the uv binary (fast dependency resolver/installer)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# 3) Work inside /app
WORKDIR /app

# 4) Put the virtual environment in /app/.venv and ensure it's used
ENV UV_PROJECT_ENVIRONMENT=/app/.venv
ENV PATH="/app/.venv/bin:$PATH"

# 5) Copy only dependency files first (enables Docker layer caching)
COPY pyproject.toml uv.lock .python-version ./

# 6) Install deps exactly as locked (reproducible)
RUN uv sync --locked --no-dev

# 7) Copy your app code last (so code changes don’t invalidate deps layer)
COPY pipeline.py ./pipeline.py

# 8) Default command to run your script
CMD ["python", "pipeline.py"]
