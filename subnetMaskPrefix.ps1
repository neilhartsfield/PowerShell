# Prompt the user for a subnet mask
$subnetMask = Read-Host "Please enter a subnet mask (e.g. 255.255.255.0)"

# Use a default value if the user did not enter a subnet mask
if ($subnetMask -eq "")
    {
        $subnetMask = "255.255.255.0"
    }

# Check if the subnet mask is in the correct format
if ($subnetMask -match "^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|0)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|0)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|0)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|0)$")
    {
        # Convert the subnet mask to an IPAddress object
        $ipAddress = [System.Net.IPAddress]::Parse($subnetMask)
        # Convert the subnet mask to a binary string
        $binaryString = [Convert]::ToString($ipAddress.Address, 2)
        # Split the binary string into an array of characters
        $characters = $binaryString -split ""
        # Count the number of 1s in the array of characters
        $prefixLength = ($characters | Where-Object {$_ -eq "1"}).Length
        # Output the prefix length to the user
        Write-Host "The prefix length (CIDR notation) for this subnet mask is $prefixLength" -ForegroundColor Yellow
    }
else
    {
        # The subnet mask is not in the correct format
        Write-Error "The subnet mask is not in the correct format. Please enter a subnet mask in the format 255.255.255.255"
    }
