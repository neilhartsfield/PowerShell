#Base64 of Eicar string
$Base64Eicar = 'WDVPIVAlQEFQWzRcUFpYNTQoUF4pN0NDKTd9JEVJQ0FSLVNUQU5EQVJELUFOVElWSVJVUy1URVNULUZJTEUhJEgrSCo='

#Determine destination path for where you would like to drop the EICAR file.
$File = New-TemporaryFile
# Remove the temporary file
Remove-Item $File -Force
# Make a new folder based upon the old name
$Path = New-Item -Itemtype Directory -Path "$($ENV:Temp)\$($File.Name)" 
$FilePath = Join-Path $Path EicarTest.txt

    If (!(Test-Path -Path $FilePath)) {
    
            Try {
            $EicarString = [System.Convert]::FromBase64String($Base64Eicar)
            $Eicar = [System.Text.Encoding]::UTF8.GetString($EicarString)
            Set-Content -Value $Eicar -Encoding ASCII -Path $FilePath -Force
            Write-Output "Eicar dropped at $FilePath."
            }

            Catch {
            Write-Warning "Eicar file could not be created."
            }
}
    Else {
    Write-Warning "Eicar already exists at $FilePath."
    }
    
start-sleep -seconds 10

Remove-Item -Path $Path -Recurse -Force
