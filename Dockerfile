# syntax = docker/dockerfile:1

# Adjust NODE_VERSION as desired
ARG NODE_VERSION=20.11.0
FROM node:${NODE_VERSION}-slim as base

LABEL fly_launch_runtime="Node.js"

# Node.js app lives here
WORKDIR /app

# Set production environment
ENV NODE_ENV="production"

# Install pnpm
ARG PNPM_VERSION=9.0.1
RUN npm install -g pnpm@$PNPM_VERSION


# Throw-away build stage to reduce size of final image
FROM base as build
ENV NODE_ENV="development"
# Install packages needed to build node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential node-gyp pkg-config python-is-python3

# Install node modules
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY ./buf.yaml ./buf.gen.yaml ./
COPY ./proto ./proto
RUN pnpm build:proto

# Build the project
COPY ./tsconfig.json ./
COPY ./src ./src
RUN pnpm build:ts

# Final stage for app image
FROM base

# Copy built application
COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/dist /app

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD [ "node", "src/index.js" ]
