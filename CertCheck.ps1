<#

.Synopsis
	Checks for missing root certs as per KB87096
	Author: Neil Hartsfield

.Description
	This simple script will check all 20 root certificate blobs found in the .BAT file at the bottom of KB87096.
	Note: this script will need to be periodically updated with the current set of certificate blobs as the .BAT file in KB87096 is updated.
	
.Example
	To use this script in order to check current system's missing certificates:
	01. Make sure the directory structure exists which the "Dir cert: -recurse >> " is pointing to.
	02. Open PowerShell and run: .\CertCheck

#>

$blobs = @('02FAF3E291435468607857694DF5E45B68851868', '2B8F1B57330DBBA2D07A6C51F70EE90DDAB9AD8E', '3679CA35668772304D30A5FB873B0FA77BB70D54', '4EB6D578499B1CCF5F581EAD56BE3D9B6744A5E5', '8FBE4D070EF8AB1BCCAF2A9D5CCAE7282A2C66B3', 'B1BC968BD4F49D622AA89A81F2150152A41D829C', 'D1EB23A46D17D68FD92564C2F1F1601764D8E349', 'D69B561148F01C77C54578C10926DF5B856976AD', 'E12DFB4B41D7D9C32B30514BAC1D81D8385E2D46', '090D03435EB2A8364F79B78CB173D35E8EB63558', '0BBFAB97059595E8D1EC48E89EB8657C0E5AAE71', '17661DFBA03E6AAA09142E012D216864F01D1F5E', '495847A93187CFB8C71F840CB7B41497AD95C64F', '9151B539751B891401C745A9DE301CBDBADF3FB6', 'A75AC657AA7A4CDFE5F9DE393E69EFCAB659D250', 'B69E752BBE88B4458200A7C0F4F5B3CCE6F35B47', 'CC1DEEBF6D55C2C9061BA16F10A0BFA6979A4A32', 'D89E3BD43D5D909B47A18977AA9D5CE36CEE184C', 'EAB040689A0D805B5D6FD654FC168CFF00B78BE3', 'F1E7B6C0C10DA9436ECC04FF5FC3B6916B46CF4C')
Dir cert: -recurse >> C:\My\sample.txt
$source = Get-Content "C:\My\sample.txt" 

ForEach ($blob in $blobs)
{
if ($source | Select-String -pattern $blob -SimpleMatch | Select-Object -Unique)
{
"Certificate found: $blob"
}
else
{
"*****MISSING*****: $blob"
}
}
