# Set the directory to search
$directory = "C:\ProgramData\Example\Logs\Activity.log"
$searchString = "error"

# Use the Get-ChildItem cmdlet to recursively search the directory for log files
# Use the Select-String cmdlet to search the log files for the specified string
# Use the ForEach-Object cmdlet to process each match and output the file name and line number
Get-ChildItem -Path $directory -Recurse -Filter "*.log" | Select-String -Pattern $searchString | ForEach-Object {[PSCustomObject]@{Filename=$_.Filename;LineNumber=$_.LineNumber}} | Select-Object -Property Filename,LineNumber | Format-Table
