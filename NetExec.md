```
$ crackmapexec smb 192.168.1.0/24 --gen-relay-list relaylistOutputFilename.txt
```
%% get all hosts with smb signing disabled %%

```
$ crackmapexec smb 10.129.203.121 -u '' -p '' --pass-pol --export $(pwd)/passpol.txt
```
%% enumerate password policy for hosts with null and export to current directory %%

```
$ sed -i "s/'/\"/g" users.txt
$ jq -r '.[]' users.txt > userslist.txt
$ cat userslist.txt
```
%% extract users list just replace --pass-pol  with --users or --shares %%