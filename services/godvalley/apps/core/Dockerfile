# =========================
# Stage 1: Builder
# =========================
FROM rust:1.76-slim AS builder

WORKDIR /app

# Install system deps including protoc
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    ca-certificates \
    protobuf-compiler \
 && rm -rf /var/lib/apt/lists/*

# Copy the entire workspace
COPY . .

# Build the specific service
RUN cargo build --release -p godvalley-core

# =========================
# Stage 2: Runtime
# =========================
FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update && apt-get install -y libssl3 ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/godvalley-core /app/godvalley-core

ENV RUST_LOG=info
EXPOSE 8080 50051

CMD ["/app/godvalley-core"]
