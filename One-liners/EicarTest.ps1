<#
Generates an EICAR test file in current working directory. We need to escape (`) certain special characters (\, $).
Batch version found here: https://github.com/neilhartsfield/Batch/blob/main/EicarTest.bat

Actual : X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*
Escape : X5O!P%@AP[4`\PZX54(P^)7CC)7}`$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!`$H+H*
#>

Set-Content "X5O!P%@AP[4`\PZX54(P^)7CC)7}`$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!`$H+H*" -Path ./EicarTest.txt
