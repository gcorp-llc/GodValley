# Bootstrap all local services

Write-Host "Building Docker images..."
docker-compose -f docker-compose.dev.yml build

Write-Host "Starting all services..."
docker-compose -f docker-compose.dev.yml up -d

Write-Host "All services are up:"
docker ps
Write-Host "Check hosts file for local domains: gcorp.local, journa.local, cardiani.local, zeteb.local"
