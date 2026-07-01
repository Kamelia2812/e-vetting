<%-- 
    Document   : navbar
 
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>navbar</title>
    </head>
    <body>
<%
    // 1. Get user data from the session
    String userRole = (String) session.getAttribute("role");
    String name = (String) session.getAttribute("userFullName");
    String initial = (String) session.getAttribute("userInitial");
%>

<header>
    <div class="bar">
        <div class="brand">
            <div class="logo">🎓</div>
            <div>
                <b>E-Vetting System</b>
                <span><%= userRole %> Panel</span>
            </div>
        </div>

        <nav>
            <button class="nav-btn" onclick="location.href='dashboard.jsp'">Dashboard</button>

            <%-- --- KProgram (monitor entire things) --- --%>
            <% if ("KETUA_PROGRAM".equals(userRole)) { %>
                <button class="nav-btn" onclick="location.href='manageCourse?action=list'">Manage Courses</button>
                <button class="nav-btn" onclick="location.href='manageUsers'">Manage Staff</button>
                <button class="nav-btn" onclick="location.href='progressMonitor'">Vetting Progress</button>
                <button class="nav-btn" onclick="location.href='reports'">Reports</button>
            <% } %>

            <%-- --- LECTURER--- --%>
            <% if ("LECTURER".equals(userRole)) { %>
                <button class="nav-btn" onclick="location.href='manageCourse?action=list'">My Courses</button>
                <button class="nav-btn" onclick="location.href='assessment?action=create'">Create Assessment</button>  //(Final Exam)
                <button class="nav-btn" onclick="location.href='assessmentStatus'">Status</button>
            <% } %>

            <%-- --- VETTER (The Reviewer/leader) --- --%>
            <% if ("VETTER".equals(userRole)) { %>
                <button class="nav-btn" onclick="location.href='manageCourse?action=list'">Assigned Courses</button>
                <button class="nav-btn" onclick="location.href='vettingQueue'">Vetting Queue</button>
                <button class="nav-btn" onclick="location.href='lecturersUnderMe'">Lecturers List</button>
            <% } %>
            
            
            <button class="nav-btn" onclick="location.href='profile.jsp'">Profile</button>
        </nav>

        <div class="user">
            <div class="meta">
                <b><%= name %></b>
            </div>
            <div class="avatar"><%= initial %></div>
            <a class="logout" href="logout" title="Exit System">➜</a>
        </div>
    </div>
</header>
    </body>
</html>
