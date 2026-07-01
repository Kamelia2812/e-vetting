<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List, DAO.CourseDAO, Model.Course" %>
<%
    if (session.getAttribute("userId") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String role = (String) session.getAttribute("role");
    boolean isKP = "kp".equalsIgnoreCase(role);
    
    String yy = request.getParameter("year");
    String mm = request.getParameter("month");
    String dd = request.getParameter("day");
    
    List<Course> courses = new java.util.ArrayList<>();
    try {
        courses = new CourseDAO().getAllCourses();
    } catch(Exception e) { e.printStackTrace(); }
    
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Calendar</title>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        body { margin: 0; font-family: 'Inter', sans-serif; background: #f8fafc; color: #1e293b; }
        .page-container { max-width: 1000px; margin: 0 auto; padding: 40px 20px; }
        h1 { font-family: 'Sora', sans-serif; font-size: 28px; margin-bottom: 20px; color: #0f172a; }
        
        .cal-box { background: #fff; border-radius: 12px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .cal-toolbar { display: flex; gap: 10px; margin-bottom: 20px; align-items: center; }
        .cal-toolbar select, .cal-toolbar input { padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; font-family: inherit; }
        .btn-new { background: #7f1d1d; color: #fff; border: none; padding: 10px 16px; border-radius: 6px; font-weight: 600; cursor: pointer; margin-left: auto; }
        
        .day-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .day-header button { background: none; border: none; font-size: 16px; color: #7f1d1d; cursor: pointer; font-weight: 600; }
        .day-title { text-align: center; }
        .day-title h2 { margin: 0; font-family: 'Sora', sans-serif; font-size: 24px; color: #0f172a; }
        .day-title .sub { font-size: 18px; color: #334155; font-weight: 700; }
        
        .event-card { border-radius: 8px; border: 1px solid #e2e8f0; overflow: hidden; margin-bottom: 15px; }
        .event-card-header { background: #fed7aa; padding: 15px 20px; display: flex; align-items: center; gap: 10px; font-family: 'Sora', sans-serif; font-weight: 700; font-size: 18px; color: #1e293b; }
        .event-card-body { padding: 15px 20px; background: #fff; font-size: 14px; color: #475569; }
        .event-card-body div { margin-bottom: 8px; display: flex; align-items: center; gap: 8px; }
        .event-card-footer { padding: 15px 20px; background: #f8fafc; border-top: 1px solid #e2e8f0; text-align: right; }
        .event-card-footer a { color: #7f1d1d; font-weight: 600; text-decoration: none; }
        
        /* Modal for new event */
        .modal { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); align-items: center; justify-content: center; z-index: 1000; }
        .modal.open { display: flex; }
        .modal-content { background: #fff; padding: 30px; border-radius: 12px; width: 400px; max-width: 90%; }
        .modal-content h3 { margin-top: 0; font-family: 'Sora', sans-serif; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 600; font-size: 14px; }
        .form-group input, .form-group select { width: 100%; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; box-sizing: border-box; }
        .modal-actions { text-align: right; margin-top: 20px; }
        .modal-actions button { padding: 8px 16px; border-radius: 6px; cursor: pointer; border: none; font-weight: 600; }
        .btn-cancel { background: #e2e8f0; color: #475569; margin-right: 10px; }
        
        .no-events { text-align: center; color: #64748b; padding: 40px 0; font-size: 15px; }
    </style>
</head>
<body>
<jsp:include page="topnav.jsp" />

<div class="page-container">
    <h1>Calendar</h1>
    
    <div class="cal-box">
        <div class="cal-toolbar">
            <div style="display:flex; gap:10px;">
                <select class="form-select">
                    <option>Day</option>
                    <option>Week</option>
                    <option>Month</option>
                </select>
                <select class="form-select">
                    <option>All courses</option>
                </select>
            </div>
            <% if (isKP) { %>
            <button class="btn-new" onclick="openEventModal()">New event</button>
            <% } %>
        </div>
        
        <div class="day-header">
            <button id="btnPrev" onclick="changeDay(-1)"></button>
            <div class="day-title" id="dayTitle">
                <!-- Rendered by JS -->
            </div>
            <button id="btnNext" onclick="changeDay(1)"></button>
        </div>
        
        <div id="eventList">
            <!-- Rendered by JS -->
        </div>
    </div>
</div>

<!-- Modal -->
<div class="modal" id="eventModal">
    <div class="modal-content">
        <h3>Create New Event</h3>
        <form method="post" action="<%= ctx %>/EventServlet">
            <div class="form-group">
                <label>Event Title</label>
                <input type="text" name="title" required placeholder="e.g. PPT SLIDES-EXERCISE is due">
            </div>
            <div class="form-group">
                <label>Date</label>
                <input type="date" name="date" id="modalDate" required>
            </div>
            <div class="form-group">
                <label>Time (optional)</label>
                <input type="time" name="time">
            </div>
            <div class="form-group">
                <label>Course Name</label>
                <select name="course" style="width: 100%; padding: 10px; border: 1px solid #cbd5e1; border-radius: 6px; font-family: inherit;">
                    <option value="">-- No specific course --</option>
                    <% for(Course c : courses) { %>
                        <option value="<%= c.getCourseName() %>"><%= c.getCourseCode() %> - <%= c.getCourseName() %></option>
                    <% } %>
                </select>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn-cancel" onclick="closeEventModal()">Cancel</button>
                <button type="submit" class="btn-new-event">Save Event</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="footer.jsp" />

<script>
    const isKP = <%= isKP %>;
    let currentDate = new Date();
    <% if (yy != null && mm != null && dd != null) { %>
        currentDate = new Date(<%= yy %>, <%= Integer.parseInt(mm) - 1 %>, <%= dd %>);
    <% } %>
    
    const dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    
    function renderDayView() {
        const y = currentDate.getFullYear();
        const m = currentDate.getMonth();
        const d = currentDate.getDate();
        
        const titleHtml = `
            <h2>\${dayNames[currentDate.getDay()]}, \${d} \${monthNames[m]} \${y}</h2>
        `;
        document.getElementById('dayTitle').innerHTML = titleHtml;
        
        // Update Prev/Next buttons
        const prevDate = new Date(currentDate);
        prevDate.setDate(currentDate.getDate() - 1);
        const nextDate = new Date(currentDate);
        nextDate.setDate(currentDate.getDate() + 1);
        
        document.getElementById('btnPrev').innerHTML = `&#9664; \${dayNames[prevDate.getDay()]}`;
        document.getElementById('btnNext').innerHTML = `\${dayNames[nextDate.getDay()]} &#9654;`;
        
        // Fetch events for this month, then filter by day
        fetch(`<%= ctx %>/EventServlet?action=list&year=\${y}&month=\${m+1}`)
            .then(res => res.json())
            .then(events => {
                const todaysEvents = events.filter(e => {
                    const ed = new Date(e.date);
                    return ed.getDate() === d && ed.getMonth() === m && ed.getFullYear() === y;
                });
                
                const listEl = document.getElementById('eventList');
                listEl.innerHTML = '';
                
                if (todaysEvents.length === 0) {
                    listEl.innerHTML = '<div class="no-events">No events for this day.</div>';
                    return;
                }
                
                todaysEvents.forEach(e => {
                    const eDate = new Date(e.date);
                    const timeStr = eDate.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
                    const fullStr = `\${dayNames[eDate.getDay()]}, \${eDate.getDate()} \${monthNames[eDate.getMonth()]}, \${timeStr}`;
                    
                    const card = document.createElement('div');
                    card.className = 'event-card';
                    card.innerHTML = `
                        <div class="event-card-header">
                            <i class="bi bi-file-earmark-text" style="opacity:0.8;"></i> \${e.title}
                        </div>
                        <div class="event-card-body">
                            <div><i class="bi bi-clock"></i> \${fullStr}</div>
                            <div><i class="bi bi-calendar2-event"></i> Course event</div>
                            \${e.course ? `<div style="color:#7f1d1d;font-weight:600"><i class="bi bi-mortarboard-fill"></i> \${e.course}</div>` : ''}
                        </div>
                        <div class="event-card-footer" style="display:flex; justify-content:space-between;">
                            <a href="#">Add submission</a>
                            \${isKP ? `<form method="post" action="<%= ctx %>/EventServlet" style="display:inline;" onsubmit="return confirm('Delete this event?');">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="\${e.id}">
                                <button type="submit" style="background:none; border:none; color:#dc2626; cursor:pointer; font-weight:600;"><i class="bi bi-trash3"></i> Delete</button>
                            </form>` : ''}
                        </div>
                    `;
                    listEl.appendChild(card);
                });
            });
    }
    
    function changeDay(offset) {
        currentDate.setDate(currentDate.getDate() + offset);
        renderDayView();
    }
    
    function openEventModal() {
        document.getElementById('eventModal').classList.add('open');
        const yy = currentDate.getFullYear();
        const mm = String(currentDate.getMonth()+1).padStart(2, '0');
        const dd = String(currentDate.getDate()).padStart(2, '0');
        document.getElementById('modalDate').value = `\${yy}-\${mm}-\${dd}`;
    }
    
    function closeEventModal() {
        document.getElementById('eventModal').classList.remove('open');
    }
    
    document.addEventListener('DOMContentLoaded', renderDayView);
</script>
</body>
</html>
