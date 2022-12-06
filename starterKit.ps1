<#
.Synopsis
	A script to run when first spinning up a VM to modify system settings
	Author: Neil Hartsfield (nhartsfield@beyondtrust.com)
	
.Description
	This script will enable you to change your System Name, IP address (including gateway & subnet), DNS settings, and Domain settings
#>

# Check if PowerShell is running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # PowerShell is not running as administrator
    # Display a warning message in green text to the user
    Write-Host "Please run this script as an administrator" -ForegroundColor Green
    # Exit the script
    exit
}

# Take a snapshot of current system settings
$previousSystemName = Get-WmiObject Win32_ComputerSystem -Property Name
$previousValues = [PSCustomObject]@{
    SystemName = $previousSystemName.Name
    IP = (Get-NetIPConfiguration).IPv4Address.IPAddress
    DNS = (Get-NetIPConfiguration).DNSServer.ServerAddresses
    Domain = (Get-WmiObject Win32_ComputerSystem).Domain
}

# Prompt the user for a new system name
$systemName = Read-Host -Prompt "Enter the new system name (press enter to skip)" 

# Set the system name if the user entered a new name
if ($systemName -ne "") {
    Rename-Computer -NewName $systemName
}

# Retrieve a list of available network adapters
$adapters = Get-NetAdapter
Write-Host "`n"
Write-Host "Available network adapters to select:" -ForegroundColor Yellow -NoNewline
$adapters | Format-Table -Property Name

# Prompt the user to choose an adapter
Write-Host "NOTE: If you skip this step, you will not be prompted to change IP & DNS settings" -ForegroundColor Cyan
$adapter = Read-Host -Prompt "Enter the network adapter name to modify (press enter to skip)"

# If an adapter was chosen, proceed. If not, skip to domain settings.
if ($adapter -ne "") {

# Prompt the user for a static IP address
$ip = Read-Host -Prompt "Enter the new static IP address (press enter to skip)"

# If an IP address was entered, proceed. If not, skip to DNS settings.
if ($ip -ne "") {
    # Prompt the user for a default gateway
    $gateway = Read-Host -Prompt "Enter the new default gateway (press enter to skip)"

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
}

# Check if the user provided an IP address
New-NetIPAddress -IPAddress "$ip" -DefaultGateway "$gateway" -InterfaceAlias "$adapter" -PrefixLength "$prefixLength"

# Prompt the user for the DNS settings
$dns = Read-Host -Prompt "Enter the DNS server IP addresses, separated by a comma (press enter to skip)"

# Set the DNS settings for the selected network adapter
if ($dns -ne "") {
    # Split the DNS input into two values
    $dns1,$dns2 = $dns.Split(",")

# Set the DNS settings for the selected adapter using the specified credentials
Set-DnsClientServerAddress "$adapter" -ServerAddresses $dns1,$dns2
}

# Set a variable to keep track of whether any changes were made
$changesMade = ($ip -ne "") -or ($dns -ne "")

# Restart the network adapter if any changes were made
if ($changesMade) {
    Try {
        Write-Host "Restarting network adapter..." -ForegroundColor Yellow
        Restart-NetAdapter -Name $adapter
        Write-Host "Network adapter restarted successfully" -ForegroundColor Yellow
    }
    Catch {
        # Display an error message
        Write-Host "An error occurred while restarting the network adapter." -ForegroundColor Yellow
    }
}
}

# Prompt the user for the domain to join
$domain = Read-Host -Prompt "Enter the domain to join (press enter to skip)"

# Join the domain if the user entered a new value
if ($domain -ne "") {
    Add-Computer -DomainName $domain
}

# Spacing
Write-Host -Separator "`n"

# Retrieve updated (current) values
$updatedSystemName = Get-WmiObject Win32_ComputerSystem -Property Name
$currentValues = [PSCustomObject]@{
    SystemName = $updatedSystemName.Name
    IP = (Get-NetIPConfiguration).IPv4Address.IPAddress
    DNS = (Get-NetIPConfiguration).DNSServer.ServerAddresses
    Domain = (Get-WmiObject Win32_ComputerSystem).Domain
}

# Add titles to the tables and display only the IP addresses of the DNS servers
Write-Host "++ Updated Configuration:" -ForegroundColor Green -NoNewline
$currentValues | Format-Table -Property SystemName,IP,DNS,Domain
Write-Host "++ Previous Configuration:" -ForegroundColor Green -NoNewline
$previousValues | Format-Table -Property SystemName,IP,DNS,Domain
