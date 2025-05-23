# -----------------------------------------------------
# Client build stage
# -----------------------------------------------------
FROM docker.io/node:22.14-bookworm-slim AS client-builder

ARG APP_HOME=/app
WORKDIR ${APP_HOME}

COPY ./package.json ${APP_HOME}
RUN npm install && npm cache clean --force

# Use bind mount to load source files at build time
RUN --mount=type=bind,target=${APP_HOME},source=. npm run build


# -----------------------------------------------------
# UV base stage - pulls uv binary into PATH
# -----------------------------------------------------
FROM python:3.12-slim AS builder

# Copy uv binary from official image
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set build args
ARG BUILD_ENVIRONMENT=production
ARG APP_HOME=/app
ARG PYTHON_HOME=/python

# Set environment variables
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV UV_PYTHON_INSTALL_DIR=${PYTHON_HOME}
ENV UV_PYTHON_PREFERENCE=only-managed
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV BUILD_ENV=${BUILD_ENVIRONMENT}

WORKDIR ${APP_HOME}

# Install dependencies from lock file only (no source project code yet)
COPY ./uv.lock ./pyproject.toml ${APP_HOME}/

# Install Python dependencies using uv and cache
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=/app/uv.lock \
    --mount=type=bind,source=pyproject.toml,target=/app/pyproject.toml \
    uv sync --locked --no-install-project --no-dev

# Copy the full app into the image (later copied to final stage)
COPY . ${APP_HOME}


# -----------------------------------------------------
# Final stage based on debian
# -----------------------------------------------------
FROM debian:bookworm-slim AS final-stage

ARG APP_HOME=/app
ARG PYTHON_HOME=/python

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PATH="${APP_HOME}/.venv/bin:$PATH"

# Create non-root user
RUN addgroup --system django && adduser --system --ingroup django django

# Install system packages
RUN apt-get update && apt-get install --no-install-recommends -y \
  libpq-dev \
  gettext \
  wait-for-it \
  pipx \
  sudo \
  git \
  nano \
  bash-completion \
  ssh \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*

# Install hatch
RUN pipx install hatch

# Copy Python-managed env
COPY --from=builder --chown=django:django ${PYTHON_HOME} ${PYTHON_HOME}

# Copy the full Django project app
COPY --from=builder --chown=django:django ${APP_HOME} ${APP_HOME}

# Copy built client static files
COPY --from=client-builder --chown=django:django ${APP_HOME}/static ${APP_HOME}/static

# Entrypoint and helper scripts
COPY --chown=django:django ./compose/production/django/entrypoint /entrypoint
RUN sed -i 's/\r$//g' /entrypoint && chmod +x /entrypoint

COPY --chown=django:django ./compose/production/django/start /start
RUN sed -i 's/\r$//g' /start && chmod +x /start

COPY --chown=django:django ./compose/production/django/celery/worker/start /start-celeryworker
RUN sed -i 's/\r$//g' /start-celeryworker && chmod +x /start-celeryworker

COPY --chown=django:django ./compose/production/django/celery/beat/start /start-celerybeat
RUN sed -i 's/\r$//g' /start-celerybeat && chmod +x /start-celerybeat

COPY --chown=django:django ./compose/production/django/celery/flower/start /start-flower
RUN sed -i 's/\r$//g' /start-flower && chmod +x /start-flower

# Set permissions
RUN chown -R django:django ${APP_HOME}

USER django

# Compile translation messages
RUN DATABASE_URL="" \
  DJANGO_SETTINGS_MODULE="config.settings.production" \
  uv run manage.py compilemessages

ENTRYPOINT ["/entrypoint"]
