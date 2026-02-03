use tracing_subscriber::{fmt, prelude::*, EnvFilter};
pub fn init_logger() {
    tracing_subscriber::registry()
        .with(fmt::layer().json())
        .with(EnvFilter::from_default_env())
        .init();
}
