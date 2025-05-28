#!/bin/bash

# 1. Prepare directories
mkdir -p /etc/shellinabox/custom

# 2. Create Cyberpunk CSS
cat <<EOF > /etc/shellinabox/custom/cyber.css
@import url('https://fonts.googleapis.com/css2?family=Share+Tech+Mono&display=swap');

body, #shell {
    background-color: #0a0a0a !important;
    color: #39ff14 !important;
    font-family: 'Share Tech Mono', monospace !important;
    font-size: 16px;
    font-weight: 500;
}

#custom-banner {
    background-color: #111111;
    color: #00ffcc;
    font-family: 'Courier New', monospace;
    font-size: 16px;
    padding: 15px;
    text-align: center;
    border-bottom: 3px solid #00ffcc;
    white-space: pre;
}
EOF

# 3. Create Welcome Banner (NOT logo but alternative message)
cat <<'EOF' > /etc/shellinabox/custom/banner.html
<div id="custom-banner">
🧠 Welcome Operative...

📡 Connected to Amazon Linux Sector-7
🔍 Decrypting environment... Access Level: Analyst I

💻 SYSTEM READY. Engage your mission.
</div>
EOF

# 4. Shellinabox config update
sed -i '/^SHELLINABOX_ARGS=/d' /etc/default/shellinabox
echo 'SHELLINABOX_ARGS="--no-beep --disable-ssl --user-css /etc/shellinabox/custom/cyber.css --static-file=/custom-banner:/etc/shellinabox/custom/banner.html"' >> /etc/default/shellinabox

# 5. Restart service
service shellinabox restart
