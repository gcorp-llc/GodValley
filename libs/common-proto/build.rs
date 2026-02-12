fn main() -> Result<(), Box<dyn std::error::Error>> {
    std::env::set_var("PROTOC", protobuf_src::protoc());
    tonic_prost_build::compile_protos("../../protos/core.proto")?;
    Ok(())
}
