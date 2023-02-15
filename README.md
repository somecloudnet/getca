# getca

getca sets up a TLS session to google.com and obtains the full certificate chain, then strips the server-certificate and makes the system "trust" the resulting CA-chain. 

Usage: getca [ubuntu,redhat,centos]

If getca is run w/o attributes it will read /etc/os-release and use 'ID'. 
Add the OS as attribute (currently supported: ubuntu, redhat, centos) to override this behavior. 
Reason for different OS options is that they have different ways to import the CA-chain

I'm interested in adding other OS-types and adding the CA-chain into specific applications, so if you see encounter a non-supported environment (of which there will be many), please feel free to provide me with its "/etc/os-release" and other relevant information


