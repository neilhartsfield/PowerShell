Get-CimInstance -Namespace root\SecurityCenter2 -ClassName AntivirusProduct
Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct
wmic /namespace:\\root\SecurityCenter2 path AntiVirusProduct get * /value

# Get WinDefender status
Get-MPComputerStatus

<# 
Easy way to figure/translate product state:
1.) Install-Module wrt.helpers 
2.) Test-IsProductStateOn 393472

Windows Defender
393472 (060100) = disabled and up to date
397584 (061110) = enabled and out of date
397568 (061100) = enabled and up to date
#>

<# To remove stale AV products listed:
    ++ Via UI:
1. run C:\Windows\System32\wbem\wbemtest.exe as administrator
2. click on connect
3. write root\SecurityCenter2 in the Namespace field
4. click connect
5. click enum instances
6. in the field Enter superclass name enter AntivirusProduct and click OK
7. delete the instance where the GUID matches the one returned by Get-CimInstance

    ++ Via cmd (as admin)
wmic /namespace:\\root\SecurityCenter2 PATH AntiVirusProduct WHERE instanceGuid='Insert the GUID' DELETE
#>
