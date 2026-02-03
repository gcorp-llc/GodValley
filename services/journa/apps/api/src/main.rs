use actix_web::{App, HttpServer, middleware::Logger};
use actix_cors::Cors;
use actix_web_prometheus::PrometheusMetricsBuilder;
use common_utils::init_logger;
use std::env;

mod routes;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    init_logger();

    let prometheus = PrometheusMetricsBuilder::new("journa_api")
        .endpoint("/metrics")
        .build()
        .unwrap();

    let port = env::var("PORT").unwrap_or_else(|_| "8080".to_string());
    let addr = format!("0.0.0.0:{}", port);

    println!("Starting server at http://{}", addr);

    HttpServer::new(move || {
        let cors = Cors::default()
            .allow_any_origin()
            .allow_any_method()
            .allow_any_header()
            .max_age(3600);

        App::new()
            .wrap(cors)
            .wrap(prometheus.clone())
            .wrap(Logger::default())
            .configure(routes::config)
    })
    .bind(addr)?
    .run()
    .await
}
