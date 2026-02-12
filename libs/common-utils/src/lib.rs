use tracing_subscriber::{fmt, prelude::*, EnvFilter};
use serde::{Serialize, Deserialize};

pub fn init_logger() {
    tracing_subscriber::registry()
        .with(fmt::layer().json())
        .with(EnvFilter::from_default_env())
        .init();
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ApiResponse<T> {
    pub success: bool,
    pub data: Option<T>,
    pub error: Option<String>,
}

impl<T> ApiResponse<T> {
    pub fn success(data: T) -> Self {
        Self {
            success: true,
            data: Some(data),
            error: None,
        }
    }

    pub fn error(message: &str) -> Self {
        Self {
            success: false,
            data: None,
            error: Some(message.to_string()),
        }
    }
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
