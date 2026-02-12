use actix_web::{get, HttpResponse, Responder};
use serde_json::json;

#[get("/health")]
pub async fn get_health() -> impl Responder {
    HttpResponse::Ok().json(json!({ "status": "ok", "service": "zeteb-api" }))
}
