#!/bin/sh

### -------------------------------
### create supervisor config file

cat > /etc/supervisord.conf <<EOF
[supervisord]
 loglevel = INFO
 logfile  = /var/log/supervisord.log
 user     = root

[supervisorctl]
 serverurl = unix:///path/to/supervisord.sock
 username  = dummy
 password  = dummy

[program:opensmtpd]
 command=/usr/sbin/smtpd -d
 user=root
EOF


### ----------------------
### create certification

chmod 600 /etc/ssl/private/$domain.key
chmod 644 /etc/ssl/certs/$domain.crt


### ------------------------------
### create credential table file

smtp_password_encrypted=`smtpctl encrypt $smtp_password`

cat > /etc/smtpd/credentials <<EOF
$smtp_user $smtp_password_encrypted
EOF

chmod 640 /etc/smtpd/credentials

### ------------------------
### create smtpd.conf file

cat > /etc/smtpd/smtpd.conf <<EOF
# ----- pki for tls
pki $domain key  "/etc/ssl/private/$domain.key"
pki $domain cert "/etc/ssl/certs/$domain.crt"

# ----- tables setup
table creds "file:/etc/smtpd/credentials"

# ----- listeners
listen on eth0 port  25 hostname $domain tls         pki $domain
listen on eth0 port 587 hostname $domain tls-require pki $domain auth <creds>

# ----- rules
action "relay" relay host smtp+notls://$relay_target

match for any action "relay"
match from any for domain "$domain" action "relay"
EOF

### ---------------------
### execute supervisord
exec "$@"
