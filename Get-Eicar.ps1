function Get-Eicar {

<#

.Synopsis

	Get-Eicar
	Author: Neil Hartsfield
            
.Description

	The EICAR test file is simply a 68 character long string used against AV products for testing purposes. 
	This is a function which drops an EICAR test file (.txt) on the local user's Desktop to test a system's On-Access Scanner. 
	A detection should be made immediately if the system's OAS is working properly. 
            
	We can obtain the correct path for OAS exclusions by dropping EICAR files in the directories we want to exclude. 
	Once the EICAR detection is made, we can look at the OAS logs and see exactly how the scan engine is seeing these directories. 
	By knowing how our engine scans the directory, we know how to configure the OAS exclusion.
            
	When executed, this PS script will prompt you with a target directory you would like to drop the EICAR test file in.
	Once the EICAR is dropped, PowerShell will wait and watch for a detection being made by your OAS.
	Upon detection, a log snippet will display, showing exactly how the AV scan engine is seeing the directory.

.Example

	PS C:> Get-Eicar
	Target directory to test EICAR detection (full path): C:\My
	Eicar dropped at C:\My\EicarTest.txt.
            
	<Log Snippet Here Showing Detection>

#>

#Base64 of Eicar string
$Base64Eicar = 'WDVPIVAlQEFQWzRcUFpYNTQoUF4pN0NDKTd9JEVJQ0FSLVNUQU5EQVJELUFOVElWSVJVUy1URVNULUZJTEUhJEgrSCo='

#Determine destination path for where you would like to drop the EICAR file.
$Path = Read-Host -Prompt 'Target directory to test EICAR detection (full path)'
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
    
    Get-Content "%LOGDIRECTORYHERE%" -tail 2 -wait | select-string 'EicarTest'
    
}
