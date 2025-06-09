# Use uv-enabled Python image
FROM ghcr.io/astral-sh/uv:0.7.12-python3.12-bookworm AS python

# Python build stage
FROM python AS python-build-stage

ENV PYTHONDONTWRITEBYTECODE=1

RUN apt-get update && apt-get install --no-install-recommends -y \
  build-essential \
  libpq-dev \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*



# Python 'run' stage
FROM python AS python-run-stage

ARG BUILD_ENVIRONMENT
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

RUN apt-get update && apt-get install --no-install-recommends -y \
  make \
  libpq-dev \
  gettext \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*



# Copy docs start script
COPY ./compose/local/docs/start /start-docs
RUN sed -i 's/\r$//g' /start-docs && chmod +x /start-docs

WORKDIR /docs
