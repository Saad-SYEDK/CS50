function updateDateTime() {
    const now = new Date();
    const date = now.toLocaleDateString();
    const time = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    document.getElementById('date').innerHTML = `${date}`;
    document.getElementById('time').innerHTML = `${time}`;
}

// Update date and time every second
setInterval(updateDateTime, 1000);
updateDateTime()
