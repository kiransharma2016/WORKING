https://docs.oracle.com/cd/E53394_01/html/E77676/gqqvw.html#:~:text=Puppet%20discovers%20information%20about%20a,install%20the%20Puppet%20software%20package.&text=Puppet%20works%20by%20using%20a,specific%20and%20node%2Dspecific%20configurations.



#puppet command runnign the mdoule locally 
puppet apply --modulepath='/etc/puppetlabs/code/environments/production/modules/' -e 'include docker::package'


