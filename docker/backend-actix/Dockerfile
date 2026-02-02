# =========================
# Stage 1: Builder
# =========================
FROM rust:1.76-slim AS builder

WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Cache dependencies
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

# Copy actual source
COPY src ./src

# Build production binary
RUN cargo build --release

# =========================
# Stage 2: Runtime
# =========================
FROM gcr.io/distroless/cc-debian12

WORKDIR /app

COPY --from=builder /app/target/release/app /app/app

ENV RUST_LOG=info
EXPOSE 8080

USER nonroot:nonroot

CMD ["/app/app"]
