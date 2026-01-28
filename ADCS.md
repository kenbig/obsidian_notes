```
netexec ldap 10.129.205.199 -u "blwasp" -p "Password123!" -M adcs
```
%% use nxc to identify if there are any ADCS servers in the domain %%

```
certipy find -u 'BlWasp@lab.local' -p 'Password123!' -dc-ip 10.129.205.199 -stdout
```
%% use certipy to enumerate ADCS service %%