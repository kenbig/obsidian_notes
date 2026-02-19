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