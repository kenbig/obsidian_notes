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
```
%% brute forcing for common hostnames using a wordlist %%

```
$ for ip in $(seq 64 79); do host 167.114.21.$ip; done | grep -Ev "not found|timed out"
```
%% loop to scan IP addresses 167.114.21.64 through 167.114.21.79. We will filter out invalid results (using grep -Ev), showing only entries that do not contain "not found" or "timed out" %%

```
$ dnsrecon -d megacorpone.com -D ~/list.txt -t brt
```
%% use the -d option to specify a domain name, -D to specify a file name containing potential subdomain strings, and -t to specify the type of enumeration to perform, in this case brt for brute force %%

```
$ dnsenum megacorpone.com
```
%% dnsenum to automate DNS enumeration of megacorpone domain %%

```
$ nslookup -type=TXT info.megacorptwo.com 192.168.50.151
```
%%  querying the 192.168.50.151 DNS server for any TXT record related to the info.megacorptwo.com host %%

#### Netcat
```
$ nc -nvv -w 1 -z 192.168.50.152 3388-3390
$ nc -nv -u -z -w 1 192.168.50.149 120-123
```
%% using netcat to do TCP and UDP port scan respectively  -w  1 for timeout, -z to specify zero-I/O, -u to specify UDP scan%%

#### Nmap
```
$ sudo nmap -sU -sS 192.168.50.149
```
%% The UDP scan (-sU) can also be used in conjunction with a TCP SYN scan (-sS) to build a more complete picture of our target %%

```
$ nmap -sn 192.168.50.1-253
```
%% performing a network sweep with Nmap using the -sn option, the host discovery process consists of more than just sending an ICMP echo request. Nmap also sends a TCP SYN packet to port 443, a TCP ACK packet to port 80, and an ICMP timestamp request to verify whether a host is available. %%

```
$ nmap -v -sn 192.168.50.1-253 -oG ping-sweep.txt
$ grep Up ping-sweep.txt | cut -d " " -f 2
```
%% do a more general scan then narrow down with grep to get the alive hosts %%

```
$ nmap -sT -A --top-ports=20 192.168.50.1-253 -oG top-port-sweep.txt
```
%%  we can also scan multiple IPs, probing for a short list of common ports. For example, let's conduct a TCP connect scan for the top 20 TCP ports with the --top-ports option and enable OS version detection, script scanning, and traceroute with -A %%

```
$ sudo nmap -O 192.168.50.14 --osscan-guess
```
%% -O option for OS Fingerprinting and --osscan-guess option to force Nmap to print the guessed result, even if is not fully accurate. %%

```
PS Test-NetConnection -Port 445 192.168.50.151
```
%% in windows if we can't install nmap, we can use LOLBAS command above to check if port open on target host %%

```
PS 1..1024 | % {echo ((New-Object Net.Sockets.TcpClient).Connect("192.168.50.151", $_)) "TCP port $_ is open"} 2>$null
```
%% We start by piping the first 1024 integer into a for-loop, which assigns the incremental integer value to the $_ variable. Then, we create a Net.Sockets.TcpClient object and perform a TCP connection against the target IP on that specific port, and if the connection is successful, it prompts a log message that includes the open TCP port. %%