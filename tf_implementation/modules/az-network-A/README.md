# Building the plan
```
./terraform init
./terraform plan -var lukas_password= -var charlie_password=
./terraform apply -var lukas_password= -var charlie_password= -auto-approve
```

# Installing desktop CentOS
## Gnome
Works but crashes from Mac RDP.  See:
* https://www.techrepublic.com/article/how-to-install-a-gui-on-top-of-centos-7/
* https://blogs.msdn.microsoft.com/microsoft_azure_guide/2015/01/05/how-to-enable-desktop-experience-and-enable-rdp-for-a-centos-7-vm-on-microsoft-azure/
```
sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-1.el7.nux.noarch.rpm
sudo yum groupinstall "GNOME Desktop" "Graphical Administration Tools"
sudo ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target
sudo yum -y install xrdp tigervnc-server
systemctl start xrdp.service
sudo systemctl start xrdp.service
sudo systemctl enable xrdp.service
sudo systemctl set-default graphical.target
sudo systemctl set-default graphical.target
echo "exec gnome-session" >> ~/.xinitrc
```

Installing KDE:
```
sudo yum -y groups install "KDE Plasma Workspaces"
echo "exec startkde" >> ~/.xinitrc
```

Funny thing is I started KDE from Gnome and it worked from Mac RDP...  even when I exited KDE back to Gnome.  There is some weirdness on the initial login page...  After reboot, it started failing again.

# Installing desktop Ubuntu
https://docs.microsoft.com/en-us/azure/virtual-machines/linux/use-remote-desktop

```
apt-get update
apt-get install xfce4
apt-get install xrdp
echo xfce4-session >~/.xsession
service xrdp restart
```

This works from MacOS and Windows.

# Run ansible on local host
`ansible-playbook --connection=local gui-runbook.yml`

# Tie it all together
See: https://stackoverflow.com/questions/44436985/running-local-exec-provisioner-all-on-instances-after-creation
https://getintodevops.com/blog/using-ansible-with-terraform
