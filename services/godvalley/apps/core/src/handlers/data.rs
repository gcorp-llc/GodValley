use actix_web::{get, web, HttpResponse, Responder};
use crate::state::AppState;
use common_utils::ApiResponse;
use serde_json::json;

#[get("/data/{id}")]
pub async fn get_data_rest(
    path: web::Path<String>,
    _data: web::Data<AppState>,
) -> impl Responder {
    let id = path.into_inner();
    // In a real app, we would query ScyllaDB here using data.scylla_session
    HttpResponse::Ok().json(ApiResponse::success(json!({
        "id": id,
        "value": "Data retrieved via REST",
        "provider": "ScyllaDB (Mocked)"
    })))
}
