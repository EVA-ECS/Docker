$ErrorActionPreference = 'Stop'
# Stop ONLY the isolated project, without deleting containers, queues, or volumes.
$containers = @(& docker ps -q --filter 'label=com.docker.compose.project=eva-integration')
if ($LASTEXITCODE -ne 0) { throw 'Docker is unavailable.' }
if ($containers.Count -gt 0) {
    & docker stop --timeout 45 @containers
    if ($LASTEXITCODE -ne 0) { throw 'One or more demo containers did not stop.' }
}
Write-Host 'Isolated demo stopped. All volumes and the original setup are preserved.'
