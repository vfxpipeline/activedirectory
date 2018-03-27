ping HQVFX.com

# DISABLE AND STOP FIREWALL
systemctl disable firewalld && systemctl stop firewalld


# INSTALL REQUIRED PACKAGES
yum -y install realmd 
yum -y install samba samba-winbind samba-winbind-clients samba-winbind-krb5-locator 
yum -y install ntp ntpdate 
yum -y install sssd
yum -y install oddjob oddjob-mkhomedir 
yum -y install authconfig-tui
yum -y install krb5-workstation
yum -y install openldap openldap-clients
yum install -y adcli

# NTP services get proper time sync from a domain controller:
systemctl enable ntpd && systemctl stop ntpd && ntpdate HQVFX.com && systemctl start ntpd
systemctl enable winbind && systemctl start winbind

# JOIN ACTIVE DIRECTORY SERVER
authconfig-tui

# >>> Go with following options
use winbind, 
use shadow passwords
use winbind authentication
local authorization is sufficient 

(NEXT)
ads
/bin/bash
domain: HQVFX
domain controllers: ad.HQVFX.com
ADS realm: HQVFX.COM 
(JOIN DOMAIN)


#[root@centos202 admin]# authconfig-tui
#[/usr/bin/net join -w HQVFX -S HQVFXad.HQVFX.com -U Administrator]
#Enter Administrator's password:<...>

#Using short domain name -- HQVFX
#Joined 'CENTOS202' to dns domain 'HQVFX.com'
#No DNS domain configured for centos202. Unable to perform DNS Update.
#DNS update failed: NT_STATUS_INVALID_PARAMETER

[root@centos202 admin]# net ads testjoin
Join is OK

[admin@centos202 ~]$ realm list
HQVFX.com
  type: kerberos
  realm-name: HQVFX.COM
  domain-name: HQVFX.com
  configured: kerberos-member
  server-software: active-directory
  client-software: winbind
  required-package: oddjob-mkhomedir
  required-package: oddjob
  required-package: samba-winbind-clients
  required-package: samba-winbind
  required-package: samba-common-tools
  login-formats: HQVFX\%U
  login-policy: allow-any-login

# EDIT THESE FILES (find reference file in same folder)
gedit /etc/krb5.conf
gedit /etc/samba/smb.conf

# RESTART SAMBA AND WINBIND SERVICES
systemctl restart smb.service && systemctl restart nmb.service && systemctl restart winbind

# RESTART SERVER (VERY IMPORTANT)
reboot

# AFTER REBOOT CKECK ALL REQUIRED SERVICES RUNNING FINE
systemctl status smb.service && systemctl status nmb.service && systemctl status winbind

# TO SEE THE LIST OF ACTIVE DIRECTORY USERS AND GROUPS IN CENTOS
wbinfo -u
wbinfo -g
