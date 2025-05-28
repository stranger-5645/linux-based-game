#!/bin/bash

USERNAME=$1
PASSWORD=$2

# Exit if user exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists."
    exit 0
fi

# Create user with home directory
useradd -m -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
chmod 700 /home/$USERNAME
deluser "$USERNAME" sudo &>/dev/null

# Create challenge directory
mkdir -p /home/$USERNAME/challenges
chmod 755 /home/$USERNAME/challenges

# Create fakebin directory
mkdir -p /home/$USERNAME/.fakebin

# Add fake commands to fakebin
echo -e '#!/bin/bash\necho "bash: sudo: command not found"' > /home/$USERNAME/.fakebin/sudo
echo -e '#!/bin/bash\necho "Permission denied."' > /home/$USERNAME/.fakebin/apt
echo -e '#!/bin/bash\necho "bash: su: command not found"' > /home/$USERNAME/.fakebin/su
chmod +x /home/$USERNAME/.fakebin/*

# Add fakebin to PATH
echo 'export PATH="$HOME/.fakebin:$PATH"' >> /home/$USERNAME/.bashrc

# Add cd protection logic inside .bashrc
cat << 'EOF' >> /home/$USERNAME/.bashrc

# Prevent users from accessing root-level directories
function cd() {
    if [[ "$1" == "/" || "$1" == "/root" || "$1" == "/etc" || "$1" == "/bin" || "$1" == "/usr" || "$1" == "/var" || "$1" == "/sbin" ]]; then
        echo "Permission denied: Access to system directories is restricted."
    else
        builtin cd "$@"
    fi
}
EOF

# Set ownership
chown -R "$USERNAME:$USERNAME" /home/$USERNAME
