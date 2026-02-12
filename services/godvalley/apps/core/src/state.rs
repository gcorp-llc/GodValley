use scylla::client::session::Session;
use std::sync::Arc;

pub struct AppState {
    #[allow(dead_code)]
    pub scylla_session: Arc<Session>,
}
