<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String ctx = request.getContextPath();
%>
<style>
.mini-calendar-card {
    background: #fff;
    border-radius: 12px;
    padding: 20px;
    box-shadow: 0 4px 15px rgba(0,0,0,0.05);
    font-family: 'Sora', sans-serif;
    margin-bottom: 20px;
}
.mini-calendar-title {
    font-size: 18px;
    font-weight: 800;
    color: #111827;
    margin-bottom: 15px;
}
.mc-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    font-weight: 700;
    font-size: 14px;
}
.mc-header button {
    background: none;
    border: none;
    cursor: pointer;
    color: #7f1d1d;
    font-size: 16px;
}
.mc-grid {
    display: grid;
    grid-template-columns: repeat(7, 1fr);
    text-align: center;
    gap: 5px;
}
.mc-day-name {
    font-size: 12px;
    font-weight: 700;
    color: #111827;
    margin-bottom: 8px;
}
.mc-day {
    width: 28px;
    height: 28px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    font-size: 13px;
    color: #4b5563;
    margin: 0 auto;
    cursor: pointer;
    position: relative;
    text-decoration: none;
}
.mc-day:hover {
    background: #f3f4f6;
}
.mc-day.has-event {
    color: #7f1d1d;
}
.mc-day.has-event::after {
    content: '';
    position: absolute;
    bottom: 2px;
    width: 4px;
    height: 4px;
    background: #7f1d1d;
    border-radius: 50%;
}
.mc-footer {
    margin-top: 15px;
    padding-top: 15px;
    border-top: 1px solid #e5e7eb;
    font-size: 13px;
}
.mc-footer a {
    color: #7f1d1d;
    text-decoration: none;
}
.mc-footer a:hover {
    text-decoration: underline;
}
</style>

<div class="mini-calendar-card">
    <div class="mini-calendar-title">Calendar</div>
    <div class="mc-header">
        <button onclick="mcPrevMonth()">&#9664;</button>
        <div id="mcMonthYear"></div>
        <button onclick="mcNextMonth()">&#9654;</button>
    </div>
    <div class="mc-grid" id="mcGrid">
        <!-- Days rendered via JS -->
    </div>
    <div class="mc-footer">
        <a href="<%= ctx %>/calendar.jsp">Full calendar</a> &bull; Import or export calendars
    </div>
</div>

<script>
let mcDate = new Date();
const mcMonthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
const mcDayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];

function renderMiniCalendar() {
    const year = mcDate.getFullYear();
    const month = mcDate.getMonth();
    document.getElementById('mcMonthYear').innerText = mcMonthNames[month] + " " + year;
    
    // Fetch events for this month
    fetch('<%= ctx %>/EventServlet?action=list&year=' + year + '&month=' + (month + 1))
        .then(res => res.json())
        .then(events => {
            const eventDays = new Set();
            events.forEach(e => {
                const d = new Date(e.date);
                if (d.getFullYear() === year && d.getMonth() === month) {
                    eventDays.add(d.getDate());
                }
            });
            drawGrid(year, month, eventDays);
        }).catch(err => {
            console.error(err);
            drawGrid(year, month, new Set());
        });
}

function drawGrid(year, month, eventDays) {
    const grid = document.getElementById('mcGrid');
    grid.innerHTML = '';
    
    // Header row
    mcDayNames.forEach(d => {
        const el = document.createElement('div');
        el.className = 'mc-day-name';
        el.innerText = d;
        grid.appendChild(el);
    });
    
    const firstDay = new Date(year, month, 1).getDay();
    const daysInMonth = new Date(year, month + 1, 0).getDate();
    
    for (let i = 0; i < firstDay; i++) {
        const el = document.createElement('div');
        grid.appendChild(el);
    }
    
    for (let d = 1; d <= daysInMonth; d++) {
        const el = document.createElement('a');
        el.className = 'mc-day';
        if (eventDays.has(d)) el.classList.add('has-event');
        el.innerText = d;
        // Link to full calendar with specific date
        el.href = '<%= ctx %>/calendar.jsp?year=' + year + '&month=' + (month+1) + '&day=' + d;
        grid.appendChild(el);
    }
}

function mcPrevMonth() {
    mcDate.setMonth(mcDate.getMonth() - 1);
    renderMiniCalendar();
}
function mcNextMonth() {
    mcDate.setMonth(mcDate.getMonth() + 1);
    renderMiniCalendar();
}

document.addEventListener('DOMContentLoaded', renderMiniCalendar);
</script>
