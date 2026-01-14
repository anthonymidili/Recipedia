# Stage 1: Builder
FROM ruby:4.0.0-slim AS builder

# Install build dependencies for gems and Node.js
RUN apt-get update && apt-get install -y \
    build-essential libvips-dev libssl-dev libyaml-dev \
    zlib1g-dev libffi-dev libreadline-dev ca-certificates gnupg libjemalloc2 curl \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && corepack enable \
    && corepack prepare yarn@1.22.22 --activate \
    && rm -rf /var/lib/apt/lists/*

# Set WORKDIR
WORKDIR /app

# Install Bundler and Ruby Gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:4.0.3 && bundle install --jobs 4 --retry 3

# Install JS Dependencies using corepack (built into Node.js)
COPY package.json yarn.lock ./
RUN corepack enable && yarn install --frozen-lockfile

# Copy app and precompile assets
COPY . .
RUN SECRET_KEY_BASE=dummy_for_build bundle exec rake assets:precompile


# Stage 2: Final Runtime Image
FROM ruby:4.0.0-slim

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu \
    LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

WORKDIR /app

# Install runtime libraries
RUN apt-get update && apt-get install -y \
    libvips42 libvips-tools libjemalloc2 curl ca-certificates gnupg procps \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && corepack enable \
    && corepack prepare yarn@1.22.22 --activate \
    && rm -rf /var/lib/apt/lists/*

# Copy bundler config and gems from builder
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Copy app from builder (includes node_modules and compiled assets)
COPY --from=builder /app /app

# Copy and set up entrypoint script
COPY docker-entrypoint.sh /app/docker-entrypoint.sh
RUN chmod +x /app/docker-entrypoint.sh

EXPOSE 3000
CMD ["/app/docker-entrypoint.sh"]
