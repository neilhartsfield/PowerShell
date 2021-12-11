# Look for a specific MSFT KB installed:
Get-HotFix –ID kb5006755
wmic qfe | findstr "5006755"

# list all
wmic qfe
wmic qfe get Hotfixid

# find KB on target system
Get-HotFix –ID kb5006755 –Computername WIN2016.NHH.LAB
