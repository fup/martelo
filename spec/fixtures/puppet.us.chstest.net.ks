# Install template
install
network --noipv6 --device eth0 --bootproto static --ip 10.5.176.158 --netmask 255.255.255.0 --gateway 10.5.176.1 --nameserver 10.4.50.200,10.4.50.201 --hostname=puppet.us.chstest.net
url --url http://repo.us.chstest.net/redhat/5.5/x86_64
text
reboot --eject
key --skip
lang en_US.UTF-8
keyboard us
rootpw --iscrypted $1$nnhEUVmq$WtM8cGmYKunxp3xRq/Dat.
firewall --disabled
authconfig --enableshadow --enablemd5
selinux --disabled
timezone --utc America/Chicago
bootloader --location=mbr
repo --name=chs-rhel-5-x86_64 --baseurl=http://repo.us.chstest.net/chs/redhat/5/x86_64/

# Disk configure template
# partitions
clearpart --linux --initlabel
part      /boot   --fstype=ext3  --size=100
part      pv.01                  --size=20000
part      pv.02                  --size=1       --grow
volgroup  vg_root --pesize=32768   pv.01
volgroup  vg_opt  --pesize=32768   pv.02
logvol    swap    --fstype swap  --name=lv_swap --vgname=vg_root --size=4096
logvol    /       --fstype=ext3  --name=lv_root --vgname=vg_root --size=12832
logvol    /home   --fstype=ext3  --name=lv_home --vgname=vg_root --size=2048
logvol    /opt    --fstype=ext3  --name=lv_opt  --vgname=vg_opt  --size=2048
logvol    /tmp    --fstype=ext3  --name=lv_tmp  --vgname=vg_opt  --size=2048
logvol    /usr    --fstype=ext3  --name=lv_usr  --vgname=vg_opt  --size=4096
logvol    /var    --fstype=ext3  --name=lv_var  --vgname=vg_opt  --size=2048

# Package configure template
%packages
@core
-aspell
-aspell-en
-bluez-gnome
-bluez-libs
-bluez-utils
-cups
-cups-libs
-dhcpv6-client
-dnsmasq
-gpm
-mesa-libGL
-NetworkManager
-NetworkManager-glib
-telnet
-tcpdump
-yp-tools
-rsh
pe-augeas
pe-augeas-libs
pe-facter
pe-puppet 
pe-puppet-enterprise-release 
pe-ruby 
pe-ruby-augeas 
pe-rubygem-puppet-module 
pe-rubygems 
pe-ruby-irb 
pe-ruby-ldap 
pe-ruby-libs 
pe-ruby-rdoc 
pe-ruby-ri 
pe-ruby-shadow

# Preinstall template
%pre --interpreter /usr/bin/python --log=/tmp/mckpre.log --erroronfail
# ---
# Set up kickstart options
#   These items are used throughout
#   the %pre script.
# ---
cmdline = open('/proc/cmdline', 'r').read().split()
bootoptions = {}
for item in cmdline:
    if '=' in item:
        key,value = item.split('=')
        bootoptions[key] = value



# Postinstall template
%post
###
### RHN registration
###
echo "Starting RHN registration..."
echo "RHN registration temporarily suspended..."
#(rhnreg_ks --username XXXXXX --password XXXXXX)
echo "RHN registration completed..."

### pe-puppet install
###
#echo "Starting puppet install..."
#(yum install -y pe-augeas pe-augeas-libs pe-facter pe-puppet pe-puppet-enterprise-release pe-ruby pe-ruby-augeas pe-rubygem-puppet-module pe-rubygems pe-ruby-irb pe-ruby-ldap pe-ruby-libs pe-ruby-rdoc pe-ruby-ri pe-ruby-shadow)
#echo "puppet install completed..."

PUPPET_UID=`id -u pe-puppet`
PUPPET_GID=`id -g pe-puppet`

groupmod -g 401 pe-puppet
usermod -u 401 -g 401 pe-puppet

for path in '/etc/puppetlabs/puppet' "/var/run/pe-puppet" "/var/log/pe-puppet" '/var/opt/lib/pe-puppet'; do
  find $path -user  $PUPPET_UID -exec chown pe-puppet {} \;
  find $path -group $PUPPET_GID -exec chgrp pe-puppet {} \;
done

echo "starting puppet config..."
PUPPET_CONFDIR='/etc/puppetlabs/puppet'
PUPPET_CONF="${PUPPET_CONFDIR}/puppet.conf"
PUPPET_VARDIR='/var/opt/lib/pe-puppet'
PUPPET_LOGDIR="/var/log/pe-puppet"
PUPPET_RUNDIR="/var/run/pe-puppet"

mkdir -p $PUPPET_CONFDIR $PUPPET_VARDIR $PUPPET

cat > $PUPPET_CONF <<EOF
[main]
    vardir = $PUPPET_VARDIR
    logdir = $PUPPET_LOGDIR
    rundir = $PUPPET_RUNDIR
    user = pe-puppet
    group = pe-puppet

[agent]
    certname = puppet.us.chstest.net
    server = puppetmaster.us.chs.net
    report = true
    classfile = \$vardir/classes.txt
    localconfig = \$vardir/localconfig
    graph = true
    pluginsync = true
EOF
echo "ending puppet config..."

### Service Management ###
# Start Puppet Agent #
(puppet agent)

