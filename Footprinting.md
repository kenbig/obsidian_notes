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


