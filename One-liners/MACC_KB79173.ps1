<# 
Here is a quick one liner to copy all XML files in current working directory for KB79173

1. Navigate to McAfee Agent AgentEvents directory (C:\ProgramData\McAfee\Agent\AgentEvents) in File Explorer
2. Type 'cmd' into File Explorer address bar to open a command prompt in current directory
3. Type PowerShell to start PS within CMD
4. mkdir c:\xml
#>

Get-Childitem .\*.xml | Where {$_.Length -gt 60kb} | Copy-Item -Destination c:\xml -Force

<#
After copying the relevant .xml files
1. cd c:\xml
2. findstr /C:TotalChunks *.*
3. Look for chunk size:
0140710143850792763600000DF4.txml:</Data><TotalChunks>2228</TotalChunks>

4. Navigate to https://<epo>:<port>/SOLIDCORE_META/updateInternalConfiguration.do
5. For Config Property Name:

chunksLimitPerTranxToProcessInventory for Solidcore extensions up to 6.1.1
chunksLimitPerTranxToProcessSCORInventory for Solidcore extension 6.1.2 or later

6. Change Config Property Value to a value greater than the maximum number of chunks per inventory you determined earlier and click Update Property Value.
NOTE: Increasing the property chunksLimitPerTranxToProcessInventory or chunksLimitPerTranxToProcessSCORInventory uses more memory. 
As a result, you might need to increase the JvmMX value (see KB71516) if ePO performance is degraded. 
If you are running ePO 5.x with sufficient RAM, you can configure a high value for JvmMx without a performance impact because it uses 64-bit JVM.
#>
