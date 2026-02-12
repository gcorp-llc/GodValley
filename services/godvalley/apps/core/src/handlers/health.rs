use actix_web::{get, HttpResponse, Responder};
use common_utils::ApiResponse;
use serde_json::json;

#[get("/health")]
pub async fn health() -> impl Responder {
    HttpResponse::Ok().json(ApiResponse::success(json!({
        "status": "ok",
        "service": "godvalley-core"
    })))
}
