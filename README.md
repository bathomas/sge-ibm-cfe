# sge-ibm-cfe
Configuration for building a self-contained RHEL 8 SGE VM image on IBM Cloud for Education (CfE). 
A systemd service (`grid-engine.service`) will attempt to install and start `qmaster` and `execd` on a new VM deployment on boot. This gets around the fact that at the current time it is not possible to use VM customisation on CfE for new hostnames etc. .

## Usage
- Create a new RHEL 8 VM reservation
The following assumes you have `sudo` rights:

```bash
# Install grid engine RPMs.
tar xvzf rh8/sge-8.1.9-1_el8.tar.gz
cd sge-8.1.9-1_el8
dnf install -y jemalloc-devel
dnf localinstall -y gridengine-8.1.9-1.el8.x86_64.rpm  --nogpgcheck
dnf localinstall -y gridengine-execd-8.1.9-1.el8.x86_64.rpm \  
                gridengine-qmaster-8.1.9-1.el8.x86_64.rpm \
                gridengine-qmon-8.1.9-1.el8.x86_64.rpm --nogpgcheck
# Install script that will attempt in install SGE on boot.
cd ..
cp rh8/configure-sge.sh /usr/local/bin
chmod +x /usr/local/bin/configure-sge.sh
# Copy SGE config. file to install_modules.
cp rh8/inst_sge_ibm-cloud.conf /opt/sge/util/install_modules/
# Install systemd service and enable
cp rh8/grid-engine.service /etc/systemd/system
systemctl enable grid-engine.service
# Shutdown and image VM to create template.
```

## Clean-up
If you want to reinstall `qmaster` and `execd` on a VM:

```bash
rm -rf /etc/rc.d/init.d/sge*
rm -rf /opt/sge/default/
reboot
```