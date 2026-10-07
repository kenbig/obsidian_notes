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