#!/bin/bash
USERNAME=$1
CHALLENGE_BASE="/home/$USERNAME/challenges"
CHALLENGE1="$CHALLENGE_BASE/challenge1"
CHALLENGE2="$CHALLENGE_BASE/challenge2"
CHALLENGE3="$CHALLENGE_BASE/challenge3"
CHALLENGE4="$CHALLENGE_BASE/challenge4"
CHALLENGE5="$CHALLENGE_BASE/challenge5"
CHALLENGE6="$CHALLENGE_BASE/challenge6"


# Create base challenge directory
mkdir -p "$CHALLENGE_BASE"
chown "$USERNAME:$USERNAME" "$CHALLENGE_BASE"

# Create Challenge 1
mkdir -p "$CHALLENGE1"

# Create the README file with instructions
cat <<EOF > "$CHALLENGE1/README.txt"
MISSION BRIEFING:
================

A hacker left traces deep in your system. You must navigate 
and investigate the suspicious folder to uncover a hidden message.

Hint: Not all files are visible by default. Use 'ls -la' to see 
hidden files and 'cat' to read their contents.

Good luck, agent!
EOF

# Create the hidden victory message file with 3D ASCII art
cat <<'EOF' > "$CHALLENGE1/.secret_msg"

=================================================================

   /$$$$$$  /$$   /$$  /$$$$$$   /$$$$$$  /$$$$$$$$  /$$$$$$  
  /$$__  $$| $$  | $$ /$$__  $$ /$$__  $$| $$_____/ /$$__  $$ 
 | $$  \__/| $$  | $$| $$  \__/| $$  \__/| $$      | $$$$$$$$
 | $$      | $$  | $$| $$      | $$      | $$$$$   | $$_____/ 
 | $$      | $$  | $$| $$      | $$      | $$__/   | $$      
 | $$    $$| $$  | $$| $$    $$| $$    $$| $$      | $$      
 |  $$$$$$/|  $$$$$$/|  $$$$$$/|  $$$$$$/| $$$$$$$$| $$      
  \______/  \______/  \______/  \______/ |________/|__/      
                                                           

            CONGRATULATIONS, AGENT!

            You've successfully found the hidden message
            left by the hacker. Your cybersecurity
            skills are impressive!

            SECRET CODE: FORGOTTEN-123

            Ready for your next challenge?
            Type 'cd ../challenge2' to continue

=================================================================

EOF

# Set appropriate permissions
chmod 755 "$CHALLENGE1"
chmod 600 "$CHALLENGE1/.secret_msg"  # Make the secret file readable only by user
chmod 644 "$CHALLENGE1/README.txt"   # Make README readable by everyone
chown -R $USERNAME:$USERNAME "$CHALLENGE1"

# IMPORTANT: Clean up .bashrc to prevent multiple welcome messages
if grep -q "CYBER ADVENTURE" "/home/$USERNAME/.bashrc"; then
    # Remove existing welcome messages
    sed -i '/CYBER ADVENTURE/d' "/home/$USERNAME/.bashrc"
    sed -i '/cyber adventure/d' "/home/$USERNAME/.bashrc"
    sed -i '/Welcome to Cyber/d' "/home/$USERNAME/.bashrc"
fi

# Add the welcome script directly to .bashrc
# This will run automatically when user logs in
cat <<'EOF' >> "/home/$USERNAME/.bashrc"

# CYBER ADVENTURE WELCOME MESSAGE
clear
echo "╔═════════════════════════════════════════════════╗"
echo "║                                                 ║"
echo "║      WELCOME TO CYBER ADVENTURE                 ║"
echo "║                                                 ║"
echo "╚═════════════════════════════════════════════════╝"
echo ""
echo "Your mission begins in the challenges directory."
echo ""
echo "To start:"
echo "  1. Type: cd challenges/challenge1"
echo "  2. Type: ls to see available files"
echo "  3. Type: cat README.txt to read your mission"
echo ""
echo "Good luck, cyber explorer!"
echo ""
EOF



# Challenge 2 setup
CHALLENGE2="$CHALLENGE_BASE/challenge2"
mkdir -p "$CHALLENGE2"
echo "[*] Creating Game.txt in challenge2"

cat <<EOF > "$CHALLENGE2/Game.txt"
🛠️ Challenge 2: System Recovery

A system component was lost. Recreate the following structure to restore stability:

Required Structure:
📁 system/
   └── logs/
       └── recovery.log

Commands you might find useful: mkdir, touch, tree

Example:
    mkdir -p system/logs
    touch system/logs/recovery.log

📌 Once recreated correctly inside this directory, your next mission will unlock!
EOF
chmod 755 "$CHALLENGE2"
chmod 644 "$CHALLENGE2/Game.txt"
chown "$USERNAME:$USERNAME" "$CHALLENGE2/Game.txt"
# Permissions so user can see inside challenge2
chmod 555 "$CHALLENGE2"

#setup for challenge3
mkdir -p "$CHALLENGE3/original" "$CHALLENGE3/temp" "$CHALLENGE3/backup"
echo "[*] Setting up files in challenge3..."
# Create example files in temp
echo "Old config" > "$CHALLENGE3/temp/config.old"
echo "Log dump" > "$CHALLENGE3/temp/log.old"
echo "Important data" > "$CHALLENGE3/temp/data.bak"
# Instruction file
cat <<EOF > "$CHALLENGE3/ice.txt"
📄 Challenge 3: Backup Breakdown

Backups were placed incorrectly. Your job is to clean the temporary files and copy only the essential backup to the correct location.

✅ Goal:
- Copy only 'data.bak' from 'temp' to 'backup'
- Remove all other files in 'temp'

Commands you might find helpful: cp, rm, ls, cat

Example:
    cp temp/data.bak /backup
    rm temp/*.old

🎯 Once completed correctly, your next mission will unlock!
EOF
chmod 755 "$CHALLENGE3"   # To access the challenge3 folder
chmod 644 "$CHALLENGE3/ice.txt"                 
chmod 755 "$CHALLENGE3/temp"                 # User needs to list and remove files
chmod 755 "$CHALLENGE3/backup"               # User needs to copy into this
chmod 755 "$CHALLENGE3/original"             # Reserved for future, safe default
# Ownership
chown -R "$USERNAME:$USERNAME" "$CHALLENGE3"


#steup challenge 4
mkdir -p "$CHALLENGE4"

echo "[*] Setting up Challenge 4: The File Whisperer..."

# Create a file with a hidden message
echo "🔍 You've uncovered the whisper of the system... well done!" > "$CHALLENGE4/.hidden_message.txt"

# Create a decoy file
echo "This file is empty." > "$CHALLENGE4/readme.txt"

# Create the instruction file
cat <<EOF > "$CHALLENGE4/Game.txt"
📄 Challenge 4: The File Whisperer

Rumor has it that a secret lies within a simple text file. It's up to you to find and reveal its contents.

✅ Goal:
- Use 'ls' to list files in this folder.
- Use 'touch' to create any helper files if needed.
- Use 'cat' to reveal the hidden message.

Commands you might find helpful:  touch, cat, ls, -la

🎯 When you find and read the secret file, the system will congratulate you!
EOF

# Set permissions
chmod 755 "$CHALLENGE4"
chmod 644 "$CHALLENGE4/Game.txt"
chmod 644 "$CHALLENGE4/readme.txt"
chmod 600 "$CHALLENGE4/.hidden_message.txt"
chown -R "$USERNAME:$USERNAME" "$CHALLENGE4"


#challenge 5 setup
mkdir -p "$CHALLENGE5"

mkdir -p "$CHALLENGE5/maze/room1/room2/exit"
echo "You've found the exit! 🎉" > "$CHALLENGE5/maze/room1/room2/exit/exit.txt"

cat <<EOF > "$CHALLENGE5/Game.txt"
📄 Challenge 5: Mapping the Maze

You’ve entered a vast file maze. You must use your command skills to map the directories and escape.

✅ Goal:
- Use 'tree' to view the structure.
- Use 'cd' and 'pwd' to navigate and find the 'exit.txt' file.

Commands you might find helpful: tree, cd, pwd, ls

🎯 Once you find 'exit.txt', you’ve escaped the maze!
EOF

# Set proper permissions
chown -R "$USERNAME:$USERNAME" "$CHALLENGE5"
find "$CHALLENGE5" -type d -exec chmod 755 {} \;
find "$CHALLENGE5" -type f -exec chmod 644 {} \;

#ownership
chown -R "$USERNAME:$USERNAME" "$CHALLENGE5"

#challenge setup 6

mkdir -p "$CHALLENGE6"

# Create challenge6 directory structure
mkdir -p "$CHALLENGE6/scattered_logs/app"
mkdir -p "$CHALLENGE6/scattered_logs/system"
mkdir -p "$CHALLENGE6/scattered_logs/network"
mkdir -p "$CHALLENGE6/archive_zone"

# Create MISSION.txt
cat << 'EOF' > "$CHALLENGE6/MISSION.txt"
🔍 MISSION: Gather all the logs and secure them!

Some strange logs were scattered in different subdirectories. Your job is to:
1. Create a new folder called 'secured_logs' inside 'archive_zone'.
2. Copy all `.log` files from inside 'scattered_logs' (including subdirectories) into 'secured_logs'.
3. List the contents of 'secured_logs' to verify all logs are there.

Tools: mkdir, cp, ls, tree

Once you see all 3 log files inside 'secured_logs', the mission is complete.
challenge6/
├── archive_zone/
│   └── secured_logs/
│       ├── app.log
│       ├── sys.log
│       └── net.log

Use the command below to copy all `.log` files recursively from 'scattered_logs' into 'secured_logs':

```bash
cp scattered_logs/**/*.log archive_zone/secured_logs/
EOF

# Create sample .log files
echo "App initialized" > "$CHALLENGE6/scattered_logs/app/app.log"
echo "System check OK" > "$CHALLENGE6/scattered_logs/system/sys.log"
echo "Ping success" > "$CHALLENGE6/scattered_logs/network/net.log"

# Set ownership and permissions

chmod 755"$CHALLENGE6"
chmod 644 "$CHALLENGE6/MISSION.txt"
chmod 755 "$CHALLENGE6/scattered_logs/app"
chmod 755 "$CHALLENGE6/scattered_logs/system"
chmod 755 "$CHALLENGE6/scattered_logs/network"
chmod 755 "$CHALLENGE6/archive_zone"

#ownership
chown -R "$USERNAME:$USERNAME" "$CHALLENGE6"

