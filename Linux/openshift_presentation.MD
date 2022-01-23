Red Hat OpenShift Container Platform installation in the restricted network environment

# preparatory part ( our internal process)
Create AAA request
Create A5 and Firewall
Request for capacity and vcentre details
Encure the given network is available in the provided vcentre


#Solution components overview
Installer machine/bastion host
Download necessay file from redhart site ( use proxy)
coreOS image, openshift installer, openshift client (oc). install-config.yaml, pull-secrets
Load balancer and Firewall
setup OpenShift Mirror registry
OpenShift cluster nodes
   Bootstrap node
   Master nodes
   Worker nodes

Create ignition config 
Put ignition file in http location 
Start httpd server
Start build
	create bootstrap node
	create master nodes
	create worker node
	aprove certificate for worker node

Setup router
Configure ldap bind 
Configure  rbac 

