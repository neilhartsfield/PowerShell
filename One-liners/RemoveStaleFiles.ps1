Get-ChildItem .\*.log | Where-Object {$_CreationTime -lt (Get-Date).AddDays(-30)} | Remove-Item -Force

# Shorthand
ls .\*.log | ? creationtime -gt(date).adddays(-30)|rm
