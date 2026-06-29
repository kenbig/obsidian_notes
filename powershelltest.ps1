$ptuser = 'INLANEFREIGHT\julio';
$ptpass = 'Password1';
$ptpassword =  ConvertTo-SecureString $ptpass -AsPlainText -Force;
$ptcredential = New-Object System.Management.Automation.PSCredential $ptuser, $ptpassword;