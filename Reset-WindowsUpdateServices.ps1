function Reset-WindowsUpdateServices {
    <#
    .SYNOPSIS
        Resets Windows Update by stopping services, clearing cache, and generating a fresh log.
    .NOTES
        Must be run as Administrator.
    #>

    Stop-Service wuauserv -Force -Verbose -ErrorAction SilentlyContinue
    Stop-Service bits -Force -Verbose -ErrorAction SilentlyContinue

      Remove-Item -Recurse -Force -Verbose "C:\Windows\SoftwareDistribution\*" -ErrorAction SilentlyContinue

    Start-Service wuauserv -Verbose
    Start-Service bits -Verbose

    # Generate WindowsUpdate.log
    $logPath = "$env:USERPROFILE\Desktop\WindowsUpdate.log"
    Get-WindowsUpdateLog -LogPath $logPath

    $htmlFolder = "C:\Logs"
    $htmlPath = Join-Path $htmlFolder "WindowsUpdate_Logs.html"

    if (-not (Test-Path $htmlFolder)) {
        New-Item -Path $htmlFolder -ItemType Directory | Out-Null
    }
    $logLines = Get-Content $logPath
    $logLines | ConvertTo-Html -Title "Windows Update Logs" -PreContent "<h2>Windows Update Logs</h2>" |
        Out-File -FilePath $htmlPath -Encoding UTF8

    # Open HTML log
    Start-Process $htmlPath

    Write-Host "`n[DONE] You can now check for updates again." -ForegroundColor Green
}

Reset-WindowsUpdateServices
