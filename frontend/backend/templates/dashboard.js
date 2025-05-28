document.addEventListener("DOMContentLoaded", function () {
    // Fetch user data from session storage
    let user = sessionStorage.getItem("user");
    if (!user) {
        window.location.href = "login.html"; // Redirect if not logged in
    }

    document.getElementById("username").innerText = user;

    function updateProgress() {
        document.getElementById("completed-challenges").innerText = localStorage.getItem("challenges") || 0;
        document.getElementById("current-level").innerText = localStorage.getItem("level") || "Easy";
    }
    updateProgress();
});

function startChallenge() {
    alert("Starting a new challenge...");
    let completed = parseInt(localStorage.getItem("challenges") || 0) + 1;
    localStorage.setItem("challenges", completed);
    updateProgress();
}

function startDailyChallenge() {
    alert("Today's challenge: Recover a lost file using Linux commands!");
}

function joinMultiplayer() {
    alert("Connecting to multiplayer mode...");
}

function viewLeaderboard() {
    alert("Leaderboard coming soon!");
}

function launchTerminal() {
    window.location.href = "terminal.html";
}

function logout() {
    sessionStorage.clear();
    window.location.href = "login.html";
}
