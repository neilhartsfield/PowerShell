#Base64 of uninstall password
$Base64PW = 'cGFzc3dvcmQ='

$PWString = [System.Convert]::FromBase64String($Base64PW)
$PW = [System.Text.Encoding]::UTF8.GetString($PWString)

# Set App variable to appropriate ENS module
$App = "C:\Program Files (x86)\McAfee\Endpoint Security\Web Control\RepairCache\setupWC.exe"

# Loop through and uninstall any matches
foreach ($a in $App) {
	$Params = @(
		"/x"
		"/PASSWORD=""$PW"""
	)
	Start-Process $App -ArgumentList $Params -Wait -NoNewWindow
}
