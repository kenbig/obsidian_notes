#### WHOIS

```
$ whois megacorpone.com -h 192.168.50.251
```
%% whois queries public databases to retrieve domain regsitration records. In this case, we are doing a forward lookup which means qurying WHOIS with a domain name to discover who owns it , for reverse queries we begin with an IP address to learn more about the entity behind it. -h represent the host running WHOIS service in this case an internal server %%

```
$ whois 38.100.193.70 -h 192.168.50.251
```
%% same as above but assuming we have IP address of website %%

#### Google Hacking

```
$ site:megacorpone.com filetype:txt
```
%% include txt files for site %%

```
$ site:megacorpone.com -filetype:html
```
%% exclude html pages from search results %%

```
$ intitle:"index of" "parent directory" 
```
%% find pages that contain "index of" in the title and the words "parent directory" on the page %%

#### Github
```
$ owner:megacorpone path:users
```
%% search for repos belonging to megacorpone with "users" in filename %%

```
$ ./gitleaks-linux-amd64 -v -r=<github-link>
```
%% find any leaked secrets e.g password, keys, tokens etc %%

#### DNS Enumeration
Types of DNS records:
- NS: Nameserver records contain the name of the authoritative servers hosting the DNS records for a domain.
- A: Also known as a host record, the "a record" contains the IPv4 address of a hostname (such as www.megacorpone.com).
- AAAA: Also known as a quad A host record, the "aaaa record" contains the IPv6 address of a hostname (such as www.megacorpone.com).
- MX: Mail Exchange records contain the names of the servers responsible for handling email for the domain. A domain can contain multiple MX records.
- PTR: Pointer Records are used in reverse lookup zones and can find the records associated with an IP address.
- CNAME: Canonical Name Records are used to create aliases for other host records.
- TXT: Text records can contain any arbitrary data and be used for various purposes, such as domain ownership verification.

```
$ host www.megacorpone.com
$ host -t mx megacorpone.com
$ host -t txt megacorpone.com
```
%% getting dns info respectively as described in the bullet points above %%

```
$ for ip in $(cat list.txt); do host $ip.megacorpone.com; done
$ 
```