```
$ whois megacorpone.com -h 192.168.50.251
```
%% whois queries public databases to retrieve domain regsitration records. In this case, we are doing a forward lookup which means qurying WHOIS with a domain name to discover who owns it , for reverse queries we begin with an IP address to learn more about the entity behind it. -h represent the host running WHOIS service in this case an internal server %%

```
$ whois 38.100.193.70 -h 192.168.50.251
```
%% same as above but assuming we have IP address of website %%

