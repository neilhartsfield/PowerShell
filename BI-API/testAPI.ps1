#Set Working Directory to current script path
Split-Path -parent $MyInvocation.MyCommand.Definition | Set-Location
#Force TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        #Specify URL
        $baseUrl = "https://<BI URL>/BeyondTrust/api/public/v3/";
        #The Application API Key generated for UVM
        $apiKey = "<API KEY>"; 
        #Username of BI user associated to the API Key
        $runAsUser = "<runAsUser>";
        #Password for api user.
        #$runAsPassword = "P@ssw0rd";

#Build the Authorization header
#$headers = @{ Authorization="PS-Auth key=${apiKey}; runas=${runAsUser};pwd={runAsPassword}"; };
$headers = @{ Authorization="PS-Auth key=${apiKey}; runas=${runAsUser}";};

#Used to bypass any cert errors.
#region Trust All Certificates
#Uncomment the following block if you want to trust an unsecure connection when pointing to local Password Cache.
#
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

#endregion

#Verbose logging?
$verbose = $True;

#Sign in API with error handling
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

<# Do your work here, for example:
  Invoke-RestMethod -Uri "${baseUrl}ManagedAccounts" -Method GET -Headers $Headers -WebSession $session -ContentType "application/json" -Verbose
#>

     #Sign-out of API
     if ($verbose) { "Signing-out.."; }
     $signoutResult = Invoke-RestMethod -Uri "${baseUrl}Auth/Signout" -Method POST -Headers $headers -SessionVariable $session;   
     if ($verbose) { "..Signed-out"}
