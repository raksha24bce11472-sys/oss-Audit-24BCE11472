
#!/bin/bash

STUDENT_NAME="Raksha Vindya A"
SOFTWARE_CHOICE="git"

KERNEL=$(uname -r)
USER_NAME=$(whoami)
HOME_DIR=$HOME
UPTIME=$(uptime -p)
CURRENT_DATE=$(date)
DISTRO=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
LICENSE_MSG="This operating system is primarily covered by the GNU GPL."

echo "================================"
echo "  Open Source Audit - $STUDENT_NAME"
echo "================================"
echo "Distro   : $DISTRO"
echo "Kernel   : $KERNEL"
echo "User     : $USER_NAME"
echo "Home Dir : $HOME_DIR"
echo "Uptime   : $UPTIME"
echo "Date     : $CURRENT_DATE"
echo "License  : $LICENSE_MSG"
echo "Chosen   : $SOFTWARE_CHOICE"
