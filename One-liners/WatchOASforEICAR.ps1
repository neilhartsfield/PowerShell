# Open a separate PowerShell Window and run this command. Drop an EICAR file wherever you'd like to test exclusions or to simply watch for real time OAS detections

Get-Content "$env:DEFLOGDIR\OnAccessScan_Activity.log" -tail 1 -wait | select-string 'Eicar'
