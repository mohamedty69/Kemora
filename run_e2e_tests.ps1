$ErrorActionPreference = "Stop"

Write-Host "Starting Kemora Backend API..." -ForegroundColor Cyan
Set-Location "E:\Kemora\Kemora.Api"

# Start the API in the background
$apiProcess = Start-Process -FilePath "dotnet" -ArgumentList "run" -PassThru -NoNewWindow

Write-Host "Starting ChromeDriver..." -ForegroundColor Cyan
# Start ChromeDriver in the background
$chromeDriverProcess = Start-Process -FilePath "chromedriver.cmd" -ArgumentList "--port=4444" -PassThru -NoNewWindow

Write-Host "Waiting 10 seconds for the API and ChromeDriver to warm up..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host "Starting Flutter Integration Tests..." -ForegroundColor Cyan
Set-Location "E:\Kemora\kemora_app"

try {
    # Run the integration test on Chrome using flutter drive
    flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d chrome
    $testExitCode = $LASTEXITCODE
} finally {
    Write-Host "Shutting down background processes..." -ForegroundColor Yellow
    if ($null -ne $apiProcess) {
        Stop-Process -Id $apiProcess.Id -Force -ErrorAction SilentlyContinue
    }
    if ($null -ne $chromeDriverProcess) {
        Stop-Process -Id $chromeDriverProcess.Id -Force -ErrorAction SilentlyContinue
    }
    
    if ($testExitCode -eq 0) {
        Write-Host "All tests passed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Tests failed!" -ForegroundColor Red
    }
    
    exit $testExitCode
}
