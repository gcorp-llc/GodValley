FROM rust:1.76-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*
COPY . .
RUN cargo build --release -p gcorp-api

FROM debian:bookworm-slim
WORKDIR /app
RUN apt-get update && apt-get install -y libssl3 ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/gcorp-api /app/gcorp-api
ENV RUST_LOG=info
EXPOSE 8080
CMD ["/app/gcorp-api"]
