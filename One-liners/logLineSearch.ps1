# Filter a log file based on the -match criteria and output only matching lines to the console

Get-Content -Path "C:\ProgramData\McAfee\Endpoint Security\Logs\OnAccessScan_Activity.log" | Where-Object {$_ -match "eicar"} | ForEach-Object {Write-Output $_}
