$baseUrl = "https://<BI URL>/BeyondTrust/api/public/v3/";
$apiKey = "<APIKEY>";
$runAsUser = "<APIUSER>";
$systemToFind = "<SYSTEM>";
$accountToFind = "<Domain\User>";

$headers = @{ Authorization="PS-Auth key=${apiKey}; runas=${runAsUser};"; };

$verbose = $True;

#Sign-In
if ($verbose) { "Signing-in.."; }
$signInResult = Invoke-RestMethod -Uri "${baseUrl}Auth/SignAppIn" -Method POST -Headers $headers -SessionVariable session;   
if ($verbose) { "..Signed-in as: {0}" -f $signInResult.UserName;  ""; }

$ma = Invoke-RestMethod -Uri "${baseUrl}ManagedAccounts?systemName=$(${systemToFind})&accountName=$(${accountToFind})" -Method GET -Headers $headers -WebSession $session;

$sessionValues = Invoke-RestMethod -Uri "${baseUrl}Requests" -Method GET -Headers $headers -WebSession $session;
$targetSession = $sessionValues.RequestID


#Create Check-in BODY
$data = @{SystemId=$ma.SystemId; AccountId=$ma.AccountId;};
$json = $data | ConvertTo-Json;

#Check session back in
if ($verbose) { "Checking-in.."; }
$checkOutResult = Invoke-RestMethod -Uri "${baseUrl}Requests/${targetSession}/checkin" -Method PUT -Headers $headers -WebSession $session -ContentType "application/json" -Body $json;
if ($verbose) { "..Checked in RequestID: $targetSession"; ""; }

#Sign-Out
if ($verbose) { "Signing-out.."; }
$signOutResult = Invoke-RestMethod -Uri "${baseUrl}Auth/Signout" -Method POST -Headers $headers -WebSession $session;    
if ($verbose) { "..Signed-out"; ""; }
