use tonic::{Request, Response, Status};
use common_proto::core::core_service_server::CoreService;
use common_proto::core::{HealthCheckRequest, HealthCheckResponse, GetDataRequest, GetDataResponse};

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
