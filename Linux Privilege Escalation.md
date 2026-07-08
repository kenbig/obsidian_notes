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
%% If you discover and can mount an additional drive or unmounted file system, you may find sensitive files, passwords, or backups that can be leveraged to escalate privileges. %%

```
$ find / -path /proc -prune -o -type d -perm -o+w 2>/dev/null
```
%% discover which directories are writeable if you need to download tools to the system. You may discover a writeable directory where a cron job places files, which provides an idea of how often the cron job runs and could be used to elevate privileges if the script that the cron job runs is also writeable. %%

```
$ find / -path /proc -prune -o -type f -perm -o+w 2>/dev/null
```
%% Are any scripts or configuration files world-writable? While altering configuration files can be extremely destructive, there may be instances where a minor modification can open up further access. Also, any scripts that are run as root using cron jobs can be modified slightly to append a command. %%


### Environment enumeration
Commands to run when you encounter any linux distro:
- whoami - what user are we running as
- id - what groups does our user belong to?
- hostname - what is the server named, can we gather anything from the naming convention?
- ifconfig or ip a - what subnet did we land in, does the host have additional NICs in other subnets?
- sudo -l - can our user run anything with sudo (as another user as root) without needing a password? This can sometimes be the easiest win and we can do something like sudo su and drop right into a root shell.

```
$ cat /etc/os-release
```
%% check what operating system and version is running %%

```
$ echo $PATH
```
%% check out our current user's PATH. If PATH variable for a target user is misconfigured we may be able to leverage it to escalate privileges %%

```
$ env
```
%% check out environment variables %%

```
$ uname -a
$ lscpu
$ cat /etc/shells
$ cat /etc/fstab
```
%% check kernel version, CPU type/version, shells available to us. mounted drives  for creds%%

```
$ grep "sh$" /etc/passwd
```
%% check which users have login shells then check each version for vunlerabilities %%

```
$ cat /etc/group
```
%% check for available gorups in /etc/grouip file showing us both the group name and assigned user names %%

```
$ getent group sudo
```
%%  The /etc/group file lists all of the groups on the system. We can then use the getent command to list members of any interesting groups. %%

```
$ df -h
$ cat /etc/fstab | grep -v "#" | column -t
```
%% check for mounted file systems. A mounted file system is one that is attached to a particular directory on the system and accessed through that directory. Second command is for checking for unmounted file systes which are ones no longer accessible on the system %%

```
$ find / -type f -name ".*" -exec ls -l {} \; 2>/dev/null | grep htb-student
$ find / -type d -name ".*" -ls 2>/dev/null
```
%% find all hidden files and directories respectively %%
