$baseUrl = "https://<BI URL>/BeyondTrust/api/public/v3/";
$apiKey = "<API KEY>";
$runAsUser = "<APIUSER>";
$headers = @{ Authorization="PS-Auth key=${apiKey}; runas=${runAsUser};"; };
$verbose = $True;
$systemName = "<System Name>";
$accountName = "<Domain\User>";

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

try
{
    if ($verbose) { "Signing-in.."; }
    $signInResult = Invoke-RestMethod -Uri "${baseUrl}Auth/SignAppIn" -Method POST -Headers $headers -SessionVariable session;   
    if ($verbose) { "..Signed-in as {0}" -f $signInResult.UserName;  ""; }

    $allma = Invoke-RestMethod -Uri "${baseUrl}ManagedAccounts" -Method GET -Headers $headers -WebSession $session;
    
    $ma = Invoke-RestMethod -Uri "${baseUrl}ManagedAccounts?systemName=${systemName}&accountName=${accountName}" -Method GET -Headers $headers -WebSession $session;
    
    # Check out duration
    $durationInMins = 5;
    $data = @{SystemId=$ma.SystemId; AccountId=$ma.AccountId; DurationMinutes=$durationInMins;};
    $json = $data | ConvertTo-Json;
    Write-Host $json
	$rURL= Invoke-RestMethod -Uri "${baseUrl}Requests" -Method POST -ContentType "application/json"  -Body $json -WebSession $session;
    if ($verbose) { "Request ID = {0}" -f $rURL;  ""; } #outputs the request id
        
    $creds = Invoke-RestMethod -Uri "${baseUrl}Credentials/${rURL}" -Method GET -Headers $headers -WebSession $session;
    if ($verbose) { "Password = {0}" -f $creds;  ""; }

    $reason = @{Reason="${reason}"};
    $json = $reason | ConvertTo-Json;
    
    <# You can check this request back in & sign out with the following:
    $checkin = Invoke-RestMethod -Uri "${baseUrl}Requests/${rURL}/Checkin" -Method PUT -Headers $headers -ContentType "application/json"  -Body $json -WebSession $session ;
    
    if ($verbose) { "Signing-out.."; }
	  $signOutResult = Invoke-RestMethod -Uri "${baseUrl}Auth/Signout" -Method POST -Headers $headers -WebSession $session;    
	  if ($verbose) { "..Signed-out"; ""; }
  
  #>
    
if ($verbose) { "Done!"; }
}
catch
{
     "Exception: {0}" -f $_.Exception.Message;
} 
