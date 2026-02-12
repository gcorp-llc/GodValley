# =========================
# Stage 1: Builder
# =========================
FROM rust:1.93.1-slim AS builder

# These arguments are passed from the build command (Makefile or CI)
ARG APP_NAME
ARG APP_PATH

WORKDIR /app

# Install system deps
# We include cmake and build-essential because some crates (like common-proto via protobuf-src)
# may need to compile C/C++ components during the build.
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    ca-certificates \
    cmake \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# Copy the entire monorepo context
COPY . .

# Build production binary for the specific package
RUN cargo build --release -p ${APP_NAME}

# =========================
# Stage 2: Runtime
# =========================
FROM gcr.io/distroless/cc-debian12

ARG APP_NAME
WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/target/release/${APP_NAME} /app/app

ENV RUST_LOG=info
EXPOSE 8080

USER nonroot:nonroot

CMD ["/app/app"]
