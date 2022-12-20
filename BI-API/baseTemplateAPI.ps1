#######################################################################
#                           API SETUP                                 #
#######################################################################

# Set the base URL for the BeyondInsight Password Safe API
$baseUrl = "https://<BISERVER>/BeyondTrust/api/public/v3/";

# Set the runAsUser
$runAsUser = "APIUSER";

# Set the target systemName and accountName
$systemName = "SERVERNAME";
$accountName = "DOMAIN\USER";

# Set the API key that will be used for authentication
$apiKey = "APIKEY";

# Set the headers for the request
$headers = @{ Authorization="PS-Auth key=${apiKey}; runas=${runAsUser}";};

# Verbose logging?
$verbose = $True;

<# NOTE: The Invoke-RestMethod CmdLet does not currently have an option for ignoring SSL warnings (i.e self-signed CA certificates).
This policy is a temporary workaround to allow that for development purposes.
Warning: If using this policy, be absolutely sure the host is secure. #>

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


#######################################################################
#                           SIGN IN                                   #
#######################################################################

try
{
     #Sign-In
     if ($verbose) { "Signing-in.."; }
     $signInResult = Invoke-RestMethod -Uri "${baseUrl}Auth/SignAppIn" -Method POST -Headers $headers -SessionVariable session;   
     if ($verbose) { "..Signed-in as {0}" -f $signInResult.UserName;  ""; }
}
catch
{    "";"Exception:";
    if ($verbose)
    {$_.Exception
        $_.Exception | Format-List -Force;
    }
    else
    {
        $_.Exception.GetType().FullName;
        $_.Exception.Message;
    }
}


#######################################################################
#               INSERT CODE FOR MAKING API CALLS HERE                 #
#######################################################################

# In this example we will pull the password from the target Managed Account & it's associated System Name and output the results into the console.
# After writing the password to the console, we check the request back in.

try
{

    $allma = Invoke-RestMethod -Uri "${baseUrl}ManagedAccounts" -Method GET -Headers $headers -WebSession $session;
    
    $ma = Invoke-RestMethod -Uri "${baseUrl}ManagedAccounts?systemName=${systemName}&accountName=${accountName}" -Method GET -Headers $headers -WebSession $session;
    
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
    $checkin = Invoke-RestMethod -Uri "${baseUrl}Requests/${rURL}/Checkin" -Method PUT -Headers $headers -ContentType "application/json"  -Body $json -WebSession $session ;
    
if ($verbose) { "Done!"; }
}
catch
{
     "Exception: {0}" -f $_.Exception.Message;
} 

#######################################################################
#                      END OF API CALL CODE                           #
#######################################################################


#######################################################################
#                           SIGN OUT                                  #
#######################################################################
if ($verbose) { "Signing-out.."; }
$signoutResult = Invoke-RestMethod -Uri "${baseUrl}Auth/Signout" -Method POST -Headers $headers -WebSession $session;   
if ($verbose) { "..Signed-out"}
