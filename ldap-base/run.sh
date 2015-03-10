#!/bin/bash

if [ ! -d /data/ldap ]; then
    mv /var/lib/ldap /data
else 
    rm -rf /var/lib/ldap
fi

ln -s /data/ldap /var/lib/ldap
mkdir /etc/ldap
openssl genrsa -out /etc/ldap/private.pem 2048
openssl req -new -x509 -key /etc/ldap/private.pem -out /etc/ldap/cert.pem -days 1095 \
  -subj '/CN=localhost/O=docker/C=US' \
  -config <( \
  cat <<-EOF \
  [v3_ca] \
  subjectAltName = IP:52.10.49.1 \
  EOF \
  )

echo -n "TLSCipherSuite HIGH:MEDIUM:+TLSv1:!SSLv2:+SSLv3 \
TLSCACertificateFile /etc/ldap/cert.pem \
TLSCertificateFile /etc/ldap/cert.pem \
TLSCertificateKeyFile /etc/ldap/private.pem \
TLSVerifyClient never" > /etc/ldap/slapd.conf

exec /usr/sbin/slapd -h 'ldap:// ldaps://' -u ldap -d 3
