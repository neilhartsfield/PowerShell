#requires -version 3.0


####Powershell: Request and Create Session

####BeyondInsight and Password Safe API: 6.4.4+
####Workflow: Sign in, Find Account, Request Session, Create Session, Sign out
####Permissions: Requestor Role with valid Access Policy (RDP Session + Auto Approve)

#### Script Version: 1.1
#### Modified: 18-Nov-2016


cls;


#Secure Connection
$baseUrl = "https://<BI URL>/BeyondTrust/api/public/v3/";

#The Application API Key generated for this implementation
$apiKey = "<API KEY>";

#Username of BI user associated to the API Key
$runAsUser = "<APIUSER>";

$systemToFind = "<SYSTEM>";
$accountToFind = "<Domain\User>";
$requestDurationInMinutes = 5;

#Build the Authorization header
$headers = @{ Authorization="PS-Auth key=${apiKey}; runas=${runAsUser};"; };

#Verbose logging?
$verbose = $True;
#System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;
#region Trust All Certificates
#[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
<#
#The Invoke-RestMethod CmdLet does not currently have an option for ignoring SSL warnings (i.e self-signed CA certificates).
#This policy is a temporary workaround to allow that for development purposes.
#Warning: If using this policy, be absolutely sure the host is secure.
add-type "
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem)
    {
        return true;
    }
}
";
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy;
#>
#endregion



#PowerShell throws an exception for any API that does not return success
#In our case, assume any API exception should kick out
try
{
     #Sign-In
     if ($verbose) { "Signing-in.."; }
     $signInResult = Invoke-RestMethod -Uri "${baseUrl}Auth/SignAppIn" -Method POST -Headers $headers -SessionVariable session;   
     if ($verbose) { "..Signed-in as {0}" -f $signInResult.UserName;  ""; }

     #Fetch Accounts
     if ($verbose) { "Getting Managed Account..."; }
     $ma = Invoke-RestMethod -Uri "${baseUrl}ManagedAccounts?systemName=$(${systemToFind})&accountName=$(${accountToFind})" -Method GET -Headers $headers -WebSession $session;

    if ($ma -eq $null)
    {
        #Didn't find it
        "Did not find system | account: {0} | {1}" -f $systemToFind, $accountToFind;
        "";
    }
    else
    {
        #Found it
        if ($verbose) { "..Found {0} | {1}" -f $ma.SystemName, $ma.AccountNameFull; ""; }
        $systemId = $ma.SystemId;
        $accountId = $ma.AccountId;

        #Make Request
        if ($verbose) {	"Requesting.."; }
        $requestId = Invoke-RestMethod -Uri "${baseUrl}Requests" -Method POST -Headers $headers -WebSession $session -Body @{AccessType="app"; ApplicationID="3"; SystemId=$ma.SystemId; AccountId=$ma.AccountId; DurationMinutes=$requestDurationInMinutes;};
        if ($verbose) { "..Request complete: $requestId"; ""; }

        #Create Session
        if ($verbose) {	"Creating RDP Session.."; }
        $sessionValue = Invoke-RestMethod -Uri "${baseUrl}Requests/${requestId}/Sessions" -Method POST -Headers $headers -WebSession $session -Body @{SessionType="appfile";};
        if ($verbose) { "..Session created"; ""; }
		
        #Save File (Note: saving to temp directory)
        if ($verbose) {	"Saving RDP File.."; }
        $rdpFile = "$($env:temp)\test.rdp";
        $sessionValue | Out-File $rdpFile;
        if ($verbose) { "..File saved: ${rdpFile}"; ""; }

        #Execute the File
        if ($verbose) {	"Executing RDP File.."; }
        Invoke-Item $rdpFile;
        if ($verbose) { "..done"; ""; }
 
        #Sign-Out
        if ($verbose) { "Signing-out.."; }
	    $signOutResult = Invoke-RestMethod -Uri "${baseUrl}Auth/Signout" -Method POST -Headers $headers -WebSession $session;    
	    if ($verbose) { "..Signed-out"; ""; }
    }

     if ($verbose) { "Done!"; }
}
catch
{
     "Exception: {0}" -f $_.Exception.Message;
}
