use actix_web::web;

pub mod health;

pub fn config(cfg: &mut web::ServiceConfig) {
    cfg.service(
        web::scope("/api")
            .service(health::get_health)
    );
}
