param(
    [string]$EnvironmentFile = (Join-Path $PSScriptRoot '.env'),
    [switch]$NoBuild,
    [switch]$UseExistingLocalBrokerCredential
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$environmentPath = (Resolve-Path -LiteralPath $EnvironmentFile).Path
$required = @('Contracts', 'Gateway', 'Delivery-Service', 'Storage-Service', 'Frontend', 'UserService')
foreach ($repository in $required) {
    if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot "../$repository"))) {
        throw "Missing sibling repository: $repository. Read DEMO.md first."
    }
}
# Optional compatibility for Siar's old .env, which does not contain RMQ_PASS.
# Read it only in memory; do not print/copy credentials or change the old broker.
$previousPassword = $env:RMQ_PASS
try {
    if ($UseExistingLocalBrokerCredential) {
        $oldBroker = (& docker inspect rabbitmq | ConvertFrom-Json)[0]
        if ($LASTEXITCODE -ne 0 -or $oldBroker.Config.Labels.'com.docker.compose.project' -ne 'docker') {
            throw 'The expected original local broker was not found.'
        }
        $entry = $oldBroker.Config.Env | Where-Object { $_.StartsWith('RABBITMQ_DEFAULT_PASS=') } | Select-Object -First 1
        if (-not $entry) { throw 'Original local broker has no configured password.' }
        $env:RMQ_PASS = $entry.Substring('RABBITMQ_DEFAULT_PASS='.Length)
    }
    $arguments = @('compose', '--project-name', 'eva-integration', '--project-directory', $PSScriptRoot,
        '--file', (Join-Path $PSScriptRoot 'docker-compose.integration.yaml'), '--env-file', $environmentPath, 'up', '-d')
    if ($NoBuild) { $arguments += '--no-build' } else { $arguments += '--build' }
    & docker @arguments
    if ($LASTEXITCODE -ne 0) { throw 'Demo startup failed; existing repositories/volumes were not reset.' }
    Write-Host 'Demo: http://localhost:18081  |  Gateway: http://localhost:18080'
    Write-Host 'Existing setup is unchanged. This command does not run database migrations.'
}
finally { $env:RMQ_PASS = $previousPassword }
