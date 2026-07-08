```
$ ps aux | grep root
```
%% command to check services running as root in case there is a flaw or misconfiguration %%

```
$ ps au
$ ls /home
```
%% check which users are logged into the system and current terminal-attached processes, also check for any interesting files on user home directory %%

```
$ls -l ~/.ssh
```
%% check ssh directory contents for e.g ssh keys and ARP cacheto see what other hosts are being accessed and cross-reference these against any useable SSH private keys%%

```
$ history
$ sudo -l
```
%% check bash history and list user's privileges %%

```
$ ls -la /etc/cron.daily/
```
%% check cron jobs similar to scheduled tasks in windows also search for .conf files, and try reading /etc/shadow if readable for any hashes %%

```
$lsblk
```


