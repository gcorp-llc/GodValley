pub mod scylla {
    use scylla::{Session, SessionBuilder};
    use std::env;
    use tracing::info;

    pub async fn create_session() -> Result<Session, Box<dyn std::error::Error>> {
        let uri = env::var("SCYLLA_URI").unwrap_or_else(|_| "127.0.0.1:9042".to_string());
        info!("Connecting to ScyllaDB at {}", uri);
        let session = SessionBuilder::new()
            .known_node(uri)
            .build()
            .await?;
        Ok(session)
    }

    pub async fn setup_keyspace(session: &Session, keyspace: &str) -> Result<(), Box<dyn std::error::Error>> {
        let query = format!(
            "CREATE KEYSPACE IF NOT EXISTS {} WITH REPLICATION = {{ 'class' : 'SimpleStrategy', 'replication_factor' : 1 }}",
            keyspace
        );
        session.query(query, ()).await?;
        info!("Keyspace {} ensured", keyspace);
        Ok(())
    }
}

pub mod redis_db {
    use redis::Client;
    use std::env;
    use tracing::info;

    pub fn create_client() -> Result<Client, redis::RedisError> {
        let uri = env::var("REDIS_URI").unwrap_or_else(|_| "redis://127.0.0.1/".to_string());
        info!("Connecting to Redis at {}", uri);
        Client::open(uri)
    }
}
