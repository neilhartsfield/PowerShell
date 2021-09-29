# Recursively search in current working directory for all .XML files for a specific string and output the File path of found results.
Get-ChildItem . -r *.xml | Select-String "Search for this text" -List | Format-Table Path
