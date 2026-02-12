use actix_web::{web, App, HttpServer};
use actix_cors::Cors;
use tonic::transport::Server;
use common_proto::core::core_service_server::CoreServiceServer;
use scylla::client::session_builder::SessionBuilder;
use scylla::client::session::Session;
use std::sync::Arc;
use std::env;
use common_utils::init_logger;

mod handlers;
mod grpc;
mod state;

use crate::state::AppState;
use crate::grpc::MyCoreService;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    init_logger();

    let scylla_uri = env::var("SCYLLA_URI").unwrap_or_else(|_| "scylla:9042".to_string());

    // Initialize ScyllaDB
    let session: Session = SessionBuilder::new()
        .known_node(scylla_uri)
        .build()
        .await
        .expect("Failed to connect to ScyllaDB");

    let scylla_session = Arc::new(session);
    let app_state = web::Data::new(AppState {
        scylla_session: scylla_session.clone(),
    });

    // Start gRPC server in a separate task
    let grpc_addr = "[::0]:50051".parse().unwrap();
    let core_service = MyCoreService::default();

    tokio::spawn(async move {
        println!("Starting gRPC server at {}", grpc_addr);
        Server::builder()
            .add_service(CoreServiceServer::new(core_service))
            .serve(grpc_addr)
            .await
            .expect("gRPC server failed");
    });

    // Start Actix-web server
    let rest_port = env::var("PORT").unwrap_or_else(|_| "8080".to_string());
    let rest_addr = format!("0.0.0.0:{}", rest_port);

    println!("Starting REST server at http://{}", rest_addr);

    HttpServer::new(move || {
        let cors = Cors::default()
            .allow_any_origin()
            .allow_any_method()
            .allow_any_header()
            .max_age(3600);

        App::new()
            .wrap(cors)
            .app_data(app_state.clone())
            .service(handlers::health::health)
            .service(handlers::data::get_data_rest)
    })
    .bind(rest_addr)?
    .run()
    .await
}
