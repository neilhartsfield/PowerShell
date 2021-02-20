function Get-Eicar {

<#

.Synopsis

            Get-Eicar
            Author: Neil Hartsfield
            
.Description

            The EICAR test file is simply a 68 character long string used against AV products for testing purposes. 
            This is a function which drops an EICAR test file (.txt) on the local user's Desktop to test a system's On-Access Scanner. 
            A detection should be made immediately if the system's OAS is working properly. 

.Example

            PS C:> Get-Eicar
            Eicar dropped at ~\Desktop\EicarTest.txt.

#>


#Base64 of Eicar string
$Base64Eicar = 'WDVPIVAlQEFQWzRcUFpYNTQoUF4pN0NDKTd9JEVJQ0FSLVNUQU5EQVJELUFOVElWSVJVUy1URVNULUZJTEUhJEgrSCo='

$Path = '~/Desktop'
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

}
