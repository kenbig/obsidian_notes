### John the ripper
```
$ john --single passwd
r0lf:$6$ues25dIanlctrWxg$nZHVz2z4kCy1760Ee28M1xtHdGoy0C2cYzZ8l2sVa1kIa8K9gAcdBP.GI6ng/qA4oaMrgElZ1Cb9OeXO4Fvy3/:0:0:Rolf Sebastian:/home/r0lf:/bin/bash
```
%% if we ran into a file that has saved the passwd with hashes (output shown below command), the command generates a list of hashes based on the info and runs them against the hash until it finds one that matches%%

```
$ john --wordlist=<wordlist_file> <hash_file>
```
%%  can use the --rule option at the end to add rules e.g numbers, capitalizing letters or adding special characters %%

```
$ john --incremental <hash_file>
$ grep '# Incremental modes' -A 100 /etc/john/john.conf
```
%% instead of using a wordlist, use incremental mode. This uses predefined incremental modes specified in its configuration file (john.conf), which define character sets and password lengths. You can customize these or define your own to target passwords that use special characters or specific patterns. %%

```
$ hashid -j 193069ceb0461e1d40d216e32c79c704
```
%% using hashid command to identify hash type %%

### Hashcat