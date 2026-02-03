use tracing_subscriber::{fmt, prelude::*, EnvFilter};

pub fn init_logger() {
    tracing_subscriber::registry()
        .with(fmt::layer().json())
        .with(EnvFilter::from_default_env())
        .init();
}

pub mod error {
    use thiserror::Error;
    use serde::Serialize;

    #[derive(Error, Debug, Serialize)]
    pub enum AppError {
        #[error("Database error: {0}")]
        DatabaseError(String),

        #[error("Internal server error")]
        Internal,

        #[error("Not found: {0}")]
        NotFound(String),

        #[error("Validation error: {0}")]
        Validation(String),
    }
}
