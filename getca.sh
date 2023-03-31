#!/bin/bash

# First find out the Linux distribution (as command argument or from /etc/os-release. Using ID_LIKE to catch distribution variations)
if [ -z $1 ]; then
	ostype=`cat /etc/os-release | sed -n 's/^ID_LIKE=\(.*\)$/\1/p'`
else
	ostype=$1
fi

# Get certs from Google (make sure Google is inspected and permited; otherwise replace Google with another destination)
echo | openssl s_client -showcerts  -servername www.google.com -connect www.google.com:443 | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > collectcerts.catmp 

# Clean up 
awk 'BEGIN {c=0;} /BEGIN CERT/{c++} { print > "cert." c ".catmp" }' < collectcerts.catmp 

# Remove server-certificate so we only have the CA-chain
echo "" > zscaler-cacert.pem
n=1
certcount=`grep BEGIN\ CERTIFICATE collectcerts.catmp  | wc -l`
while [ $n -lt $certcount  ]; do
 	filename=$(echo "cert."$n".catmp")
	cat $filename >> zscaler-cacert.pem
	n=$(( $n + 1 ))
done

# Now "trust" the signing certificates
case $ostype in
	debian | ubuntu | suse*)
	  echo "Adding Certs to Ubuntu or SUSE"
	  sudo cp zscaler-cacert.pem  /usr/local/share/ca-certificates/zscaler-cacert.pem
	  sudo update-ca-certificates
	  ;;
	redhat | centos | rhel*)
	  echo "Adding Certs to Redhat or CentOS"
	  sudo cp zscaler-cacert.pem /etc/pki/ca-trust/source/anchors/
	  sudo update-ca-trust
	  ;;
	*)
	  echo "Sorry, I don't know your OS, try using getca {ubuntu, redhat, centos, suse}"
	  echo "Or add the certificate-chain in zscaler-cacert.pem manually"
	  echo "Also: please send feedback to Joost (over Slack) with information on the OS you're using this script on"
	  exit
	  ;;
esac

# Final test to see if it worked. Just human visible though, no error-checking
echo | openssl s_client  -servername www.google.com -connect www.google.com:443

# Keep the RA-file for other system apps
if [ -f "zscaler-cacert.pem" ]; then
    echo "The file 'zscaler-cacert.pem' contains the SSL inspection certificates used by your organization. See https://help.zscaler.com/zia/adding-custom-certificate-application-specific-trust-store for additional applications"
fi

# Cleanup 
rm *.catmp
