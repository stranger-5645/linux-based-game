from flask import Flask, render_template, request, redirect, url_for, session
from flask_pymongo import PyMongo
from flask_bcrypt import Bcrypt
import docker
import subprocess
import random
import smtplib
from email.message import EmailMessage
docker_client = docker.from_env()

app = Flask(__name__)
app.secret_key = "your_secret_key"

# MongoDB config
# MongoDB config
app.config["MONGO_URI"] = "mongodb://sakshi:12345@localhost:27017/user_data?authSource=admin"
mongo = PyMongo(app)
bcrypt = Bcrypt(app)
client = docker.from_env()
users = mongo.db.users 

# Name of the shared container
CONTAINER_NAME = "multi_user_system"

@app.route('/')
def index():
    return render_template('index.html')  

import smtplib
from email.message import EmailMessage

EMAIL_ADDRESS = "wysiwyg823@gmail.com"
EMAIL_PASSWORD = "gposgxkjrjzqsgtb"  

def send_otp_email(to_email, otp):
    msg = EmailMessage()
    msg['Subject'] = "🔐 Your OTP for Cyber Adventure Game"
    msg['From'] = EMAIL_ADDRESS
    msg['To'] = to_email
    msg.set_content(
        f"Hello Agent,\n\n"
        f"Your OTP is: {otp}\n\n"
        "Enter this in the verification screen to begin your mission.\n\n"
        "-- Cyber Adventure HQ"
    )

    print("Attempting to send email...")
    try:
        smtp = smtplib.SMTP('smtp.gmail.com', 587)
        print("Connected to SMTP server")
        smtp.starttls()
        print("TLS started")
        smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        print("Logged in successfully")
        smtp.send_message(msg)
        print(f" OTP email sent to {to_email}")
        smtp.quit()
    except Exception as e:
        print("Failed to send OTP email:", e)


@app.route("/signup", methods=["GET", "POST"])
def signup():
    if request.method == "POST":
        username = request.form.get("username")
        email = request.form.get("email")
        password = request.form.get("password")

        if not username or not email or not password:
            return "All fields are required."

        existing_user = users.find_one({"email": email})
        if existing_user:
            return "Email already registered!"

        hashed_password = bcrypt.generate_password_hash(password).decode("utf-8")
        otp = str(random.randint(100000, 999999))

        users.insert_one({
            "username": username,
            "email": email,
            "password": hashed_password,
            "otp": otp,
            "verified": False
        })

        send_otp_email(email, otp)
        session["email"] = email

        try:
            container = client.containers.get(CONTAINER_NAME)

            # Run user setup
            command = f"bash /setup_user.sh {username} {password}"
            exec_result = container.exec_run(command, user="root", privileged=True)
            print("User setup output:", exec_result.output.decode())

            # Setup all 6 challenges
            for i in range(1, 7):
                challenge_command = f"bash /setup_challenges.sh {username} {i}"
                challenge_result = container.exec_run(challenge_command, user="root", privileged=True)
                print(f"Challenge {i} setup for {username}: {challenge_result.output.decode()}")

        except Exception as e:
            print(" Error setting up container:", e)
            return "Something went wrong during setup."

        return redirect(url_for("verify_otp"))

    return render_template("signup.html")

@app.route("/verify_otp", methods=["GET", "POST"])
def verify_otp():
    email = session.get("email")
    if not email:
        return redirect(url_for("signup"))

    if request.method == "POST":
        input_otp = request.form.get("otp")
        user = users.find_one({"email": email})

        if user and user["otp"] == input_otp:
            users.update_one(
                {"email": email},
                {"$set": {"verified": True}, "$unset": {"otp": ""}}
            )
            # ✅ Store session username if needed
            session["username"] = user["username"]

            return redirect(url_for("dashboard"))  
        else:
            return " Incorrect OTP. Try again."

    return render_template("verify_otp.html")


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        user = users.find_one({'email': request.form['email']})

        if user and bcrypt.check_password_hash(user['password'], request.form['password']):
            if not user.get("verified", False):
                return "⚠️ Please verify your email before logging in."

            session['username'] = user['username']
            session['password'] = request.form['password']
            return redirect(url_for('dashboard'))

        return "Invalid credentials!"

    return render_template('login.html')

@app.route('/dashboard')
def dashboard():
    if 'username' not in session:
        return redirect('/login')

    username = session['username']

    # Get the shared multi-user container
    try:
        container = docker_client.containers.get("multi_user_system")
    except docker.errors.NotFound:
        # If container not found, fall back to DB
        user = users.find_one({"username": username})
        completed = user.get("completed_challenges", {}).get("basic", []) if user else []
        return render_template('dashboard.html', username=username, completed=completed)

    completed_challenges = []

    # Run verification commands for each challenge
    for challenge, cmd_template in challenge_verification_commands.items():
        cmd = cmd_template.format(username=username)  # username-specific path
        exit_code, _ = container.exec_run(cmd)
        if exit_code == 0:
            completed_challenges.append(challenge)

    # Update DB with completed challenges
    users.update_one(
        {"username": username},
        {"$set": {"completed_challenges.basic": completed_challenges}},
        upsert=True
    )

    return render_template('dashboard.html', username=username, completed=completed_challenges)



@app.route('/start_challenge/<int:challenge_id>', methods=['POST'])
def start_challenge(challenge_id):
    if 'username' not in session or 'password' not in session:
        return redirect(url_for('login'))

    username = session['username']
    password = session['password']

    try:
        container = client.containers.get(CONTAINER_NAME)

        # Step 1: Create user (if not already created)
        user_creation = container.exec_run(
            f"bash /setup_user.sh {username} {password}",
            user="root", privileged=True
        )
        print("[USER SETUP OUTPUT]:", user_creation.output.decode())

        # Step 2: Setup the challenge environment
        challenge_setup = container.exec_run(
            f"bash /setup_challenges.sh {username} {challenge_id}",
            user="root", privileged=True
        )
        print("[CHALLENGE SETUP OUTPUT]:", challenge_setup.output.decode())

        # Step 3: Check if challenge files exist
        check_folder = container.exec_run(
            f"test -f /home/{username}/challenges/challenge{challenge_id}/README.txt && echo OK || echo FAIL",
            user="root"
        )
        result = check_folder.output.decode().strip()
        if result != "OK":
            return f"Challenge setup failed. Folder or files missing for user {username}"

        # ✅ Step 4: Setup progression logic
        progression = container.exec_run(
            f"bash /challenge_progression.sh {username} {challenge_id}",
            user="root", privileged=True
        )
        print("[PROGRESSION SCRIPT OUTPUT]:", progression.output.decode())

        # Step 5: Redirect to Shellinabox terminal
        return redirect("http://localhost:4200")

    except Exception as e:
        return f"Error setting up challenge: {e}"



@app.route('/basic_level')
def basic_level():
    return render_template('basic_level.html')        

@app.route('/medium_level')
def medium_level():
    return render_template('medium_level.html')        

@app.route('/terminal')
def terminal():
    if 'username' not in session:
        return redirect(url_for('login'))

    # Shellinabox running on port 4200
    return redirect("http://localhost:4200")

@app.route('/complete_challenge', methods=['POST'])
def complete_challenge():
    username = request.form['username']
    level = request.form['level']         # e.g., 'basic', 'medium'
    challenge = request.form['challenge'] # e.g., 'challenge1'

    user = users.find_one({"username": username})
    if not user:
        return "User not found"

    progress = user.get('completed_challenges', {})
    progress.setdefault(level, [])

    if challenge not in progress[level]:
        progress[level].append(challenge)

    users.update_one(
        {"username": username},
        {"$set": {"completed_challenges": progress}}
    )

    return "Challenge marked as complete"

challenge_verification_commands = {
    "challenge1": "test -f /home/{username}/challenges/challenge1/.secret_msg",
    "challenge2": "test -d /home/{username}/challenges/challenge2/system/logs && test -f /home/{username}/challenges/challenge2/system/logs/recovery.log",
    "challenge3": "test -f /home/{username}/challenges/challenge3/backup/data.bak && ! ls /home/{username}/challenges/challenge3/temp/*.old 2>/dev/null",
    "challenge4": "test -f /home/{username}/challenges/challenge4/.hidden_message.txt",
    "challenge5": "test -f /home/{username}/challenges/challenge5/maze/room1/room2/exit/exit.txt",
    "challenge6": "test -d /home/{username}/challenges/challenge6/archive_zone/secured_logs && ls /home/{username}/challenges/challenge6/archive_zone/secured_logs/*.log | wc -l | grep -q '^3$'"
}



@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
