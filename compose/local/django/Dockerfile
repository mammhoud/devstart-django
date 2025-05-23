FROM python:3.12-slim AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ARG BUILD_ENVIRONMENT=local
ARG APP_HOME=/app
ARG PYTHON_HOME=/python
ARG SCRIPTS_HOME=/scripts


ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy
ENV UV_PYTHON_INSTALL_DIR=/python
ENV UV_PYTHON_PREFERENCE=only-managed


ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

ENV BUILD_ENV=${BUILD_ENVIRONMENT}


# ADD . ${APP_HOME}
# RUN uv python install


WORKDIR ${APP_HOME}


# Install dependencies
RUN --mount=type=cache,target=/root/.cache/uv \
  --mount=type=bind,source=uv.lock,target=/app/uv.lock \
  --mount=type=bind,source=pyproject.toml,target=/app/pyproject.toml \
  uv sync --locked --no-install-project --no-dev


# Entrypoints and scripts
COPY ./compose/production/django/entrypoint /scripts/entrypoint
RUN sed -i 's/\r$//g' /scripts/entrypoint && chmod +x /scripts/entrypoint

COPY ./compose/local/django/start /scripts/start
RUN sed -i 's/\r$//g' /scripts/start && chmod +x /scripts/start

COPY ./compose/local/django/celery/worker/start /scripts/start-celeryworker
RUN sed -i 's/\r$//g' /scripts/start-celeryworker && chmod +x /scripts/start-celeryworker

COPY ./compose/local/django/celery/beat/start /scripts/start-celerybeat
RUN sed -i 's/\r$//g' /scripts/start-celerybeat && chmod +x /scripts/start-celerybeat

COPY ./compose/local/django/celery/flower/start /scripts/start-flower
RUN sed -i 's/\r$//g' /scripts/start-flower && chmod +x /scripts/start-flower


# Then, use a final image without uv
FROM debian:bookworm-slim as final-stage
ARG APP_HOME=/app
ARG PYTHON_HOME=/python

# Copy the Python version
COPY --from=builder --chown=python:python ${PYTHON_HOME} ${PYTHON_HOME}

# Copy the application from the builder
COPY --from=builder --chown=app:app ${APP_HOME} ${APP_HOME}

COPY --from=builder --chown=app:app ${SCRIPTS_HOME} ${SCRIPTS_HOME}

WORKDIR ${APP_HOME}

# Place executables in the environment at the front of the path
ENV PATH="${APP_HOME}/.venv/bin:$PATH"

# Install apt packages
RUN apt-get update && apt-get install --no-install-recommends -y \
  build-essential \
  pipx \
  sudo \
  git \
  bash-completion \
  nano \
  ssh

# Create devcontainer user and add to sudoers
RUN groupadd --gid 1000 dev-user \
  && useradd --uid 1000 --gid dev-user --shell /bin/bash --create-home dev-user \
  && echo dev-user ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/dev-user \
  && chmod 0440 /etc/sudoers.d/dev-user

# Install system dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
  libpq-dev \
  wait-for-it \
  gettext \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*


RUN pipx install hatch
# RUN --mount=type=bind,source=.,target=/app

COPY . ${APP_HOME}
# # Sync the project
RUN --mount=type=cache,target=/root/.cache/uv \
  uv sync --locked --no-dev


ENTRYPOINT ["/scripts/entrypoint"]
