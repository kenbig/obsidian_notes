### SMB
```
$  smbclient -N -L //10.129.14.128
```
%% check for anonymous access to shares%%

```
$ smbclient //10.129.14.128/notes
```
%% connect to a specific share%%

```
$ sudo nmap 10.129.14.128 -sV -sC -p139,445
```
%%footprint the smb service%%

```
$ rpcclient -U "" 10.129.14.128
```
%% once you connect anonymously you can use commands such as srvinfo, enumdomains, querydominfo, netshareenumall%%

### DNS
```
$ dig soa www.inlanefreight.com
```
%% The SOA record is located in a domain's zone file and specifies who is responsible for the operation of the domain and how DNS information for the domain is managed. %%

```
$ dig ns inlanefreight.htb @10.129.14.128
```
%% footprinting DNS servers we use the NS record and specification of the DNS server we want to query using the @character %%

```
$ dig CH TXT version.bind 10.129.120.85
```
%%query a DNS server's version using a class CHAOS query and type TXT. However, this entry must exist on the DNS server %%

```
$ dig any inlanefreight.htb @10.129.14.128
```
%% We can use the option ANY to view all available records. This will cause the server to show us all available entries that it is willing to disclose. %%

```
$ dig axfr inlanefreight.htb @10.129.14.128
```
%% If the administrator used a subnet for the allow-transfer option for testing purposes or as a workaround solution or set it to any, everyone would query the entire zone file at the DNS server. In addition, other zones can be queried, which may even show internal IP addresses and hostnames. %%

```
$ dnsenum --dnsserver 10.129.42.195 --enum -p 0 -s 0 -o subdomains.txt -f /usr/share/seclists/Discovery/DNS/fierce-hostlist.txt dev.inlanefreight.htb --threads 200
```
%% brute force subdomain, have to be able to do a zone transfer of the domain for it to work %%
### SMTP

```
$ telnet 10.129.14.128 25
```
%% connect to the SMTP server when connected you can use vrfy command to enumerate users. other commands include MAIL FROM, RCPT TO, DATA %%

```
$ sudo nmap 10.129.14.128 -p25 --script smtp-open-relay -v
```
%% use nmap to identify target SMTP server as an open relay using 16 different tests %%

```
$ smtp-user-enum -M VRFY -U footprinting-wordlist.txt -t 10.129.42.195 -w 15 -v
```
%% for enumerating users if you have an open smtp port %%


### IMAP/POP3
```
$ sudo nmap 10.129.14.128 -sV -p110,143,993,995 -sC
```
%% footprinting the imap/pop3 service %%

```
$ curl -k 'imaps://10.129.14.128' --user user:p4ssw0rd
```
%% we can login directly to the mail server if you have username/password %%

```
$ openssl s_client -connect 10.129.14.128:pop3s
```
%% interact with POP3 server over SSL %%

```
$ openssl s_client -connect 10.129.14.128:imaps
```
%% interact with imaps server over SSL %%

### SNMP
```
$ snmpwalk -v2c -c public 10.129.14.128
```
%% footprint snmp service, note that version 1,2c does not require authentication -c represents community but at times can be unknown%%

```
$ sudo apt install onesixtyone
$ onesixtyone -c /opt/useful/seclists/Discovery/SNMP/snmp.txt 10.129.14.128
```
%%  If we do not know the community string, we can use onesixtyone and SecLists wordlists to identify these community strings. %%

```
$ sudo apt install braa
$ braa <community string>@<IP>:.1.3.6.*
$ braa public@10.129.14.128:.1.3.6.*
```
%% Once we know a community string, we can use it with braa to brute-force the individual OIDs and enumerate the information behind them. %%

### MySQL
```
$ sudo nmap 10.129.14.128 -sV -sC -p3306 --script mysql*
```
%% scanning MySQL server %%

```
$ mysql -u root -pP4SSw0rd -h 10.129.14.128
```
%% connect to mysql %%

### MSSQL
```
$ sudo nmap --script ms-sql-info,ms-sql-empty-password,ms-sql-xp-cmdshell,ms-sql-config,ms-sql-ntlm-info,ms-sql-tables,ms-sql-hasdbaccess,ms-sql-dac,ms-sql-dump-hashes --script-args mssql.instance-port=1433,mssql.username=sa,mssql.password=,mssql.instance-name=MSSQLSERVER -sV -p 1433 10.129.230.249
```
%% mssql script scan %%

```
$ msf6 auxiliary(scanner/mssql/mssql_ping) > set rhosts 10.129.201.248
```
%% mssql ping in metasploit %%

```
$ msf6 auxiliary(scanner/mssql/mssql_ping) > set rhosts 10.129.201.248
```
%% python3 mssqlclient.py Administrator@10.129.201.248 -windows-auth %%

### ORACLE
```
$ sudo nmap -p1521 -sV 10.129.204.235 --open --script oracle-sid-brute
```
%% nmap SID Bruteforcing %%

```
$ sqlplus scott/tiger@10.129.204.235/XE as sysdba
```
%% oracle RDBMS database enumeration and login as database administrator%%

```
SQL> select name, password from sys.user$;
```
%% extract password hashes %%

```
$ ./odat.py all -s 10.129.204.235
```
%% oracle database enumeration for vulnerabilities %%

### IPMI
```
$ sudo nmap -sU --script ipmi-version -p 623 ilo.inlanfreight.local
```
%% footprinting IPMI %%

```
msf6 > use auxiliary/scanner/ipmi/ipmi_version 
```
%% metasploit version IPMI version scan %%

```
msf6 > use auxiliary/scanner/ipmi/ipmi_dumphashes 
```
%% once you do a version scan there is an IPMI flaw that exist in IPMI version 2 where you can retrieve IPMI hashes which you can try to crack offline or do a pass the hash attack if allowed %%

### RDP
```
$ nmap -sV -sC 10.129.201.248 -p3389 --script rdp*
```
%% footprint rdp %%

```
$ nmap -sV -sC 10.129.201.248 -p3389 --packet-trace --disable-arp-ping -n
```
%% check packets sent  over rdp %%

```
$ git clone https://github.com/CiscoCXSecurity/rdp-sec-check.git && cd rdp-sec-check
$ ./rdp-sec-check.pl 10.129.201.248
```
%% rdp security check %%

### WINRM
```
$ nmap -sV -sC 10.129.201.248 -p5985,5986 --disable-arp-ping -n
```
%% footprint winrm %%