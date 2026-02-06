use actix_web::{get, web, App, HttpServer, Responder, HttpResponse};
use actix_cors::Cors;
use tonic::{transport::Server, Request, Response, Status};
use common_proto::core::core_service_server::{CoreService, CoreServiceServer};
use common_proto::core::{HealthCheckRequest, HealthCheckResponse, GetDataRequest, GetDataResponse};
use scylla::{Session, SessionBuilder};
use std::sync::Arc;
use std::env;
use common_utils::init_logger;

// ScyllaDB state
struct AppState {
    #[allow(dead_code)]
    scylla_session: Arc<Session>,
}

// gRPC implementation
#[derive(Debug, Default)]
pub struct MyCoreService {}

#[tonic::async_trait]
impl CoreService for MyCoreService {
    async fn health_check(
        &self,
        _request: Request<HealthCheckRequest>,
    ) -> Result<Response<HealthCheckResponse>, Status> {
        Ok(Response::new(HealthCheckResponse {
            healthy: true,
            message: "GodValley Core is running".into(),
        }))
    }

    async fn get_data(
        &self,
        request: Request<GetDataRequest>,
    ) -> Result<Response<GetDataResponse>, Status> {
        let req = request.into_inner();
        Ok(Response::new(GetDataResponse {
            id: req.id,
            value: "Sample Data from GodValley".into(),
        }))
    }
}

// REST Handlers
#[get("/health")]
async fn health() -> impl Responder {
    HttpResponse::Ok().json(serde_json::json!({"status": "ok", "service": "godvalley-core"}))
}

#[get("/data/{id}")]
async fn get_data_rest(
    path: web::Path<String>,
    _data: web::Data<AppState>,
) -> impl Responder {
    let id = path.into_inner();
    // In a real app, we would query ScyllaDB here using data.scylla_session
    HttpResponse::Ok().json(serde_json::json!({
        "id": id,
        "value": "Data retrieved via REST",
        "provider": "ScyllaDB (Mocked)"
    }))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    init_logger();

    let scylla_uri = env::var("SCYLLA_URI").unwrap_or_else(|_| "scylla:9042".to_string());

    // Initialize ScyllaDB (lazy for demo purposes, so it doesn't crash if not available)
    let session = SessionBuilder::new()
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
            .service(health)
            .service(get_data_rest)
    })
    .bind(rest_addr)?
    .run()
    .await
}
