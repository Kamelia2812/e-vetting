
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="Model.User" %>

<%
    String userFullName = (String) session.getAttribute("userFullName");
    String role = (String) session.getAttribute("role");
    String userInitial = (String) session.getAttribute("userInitial");

    if (userFullName == null) {
        userFullName = "Ketua Program";
    }
    if (role == null) {
        role = "KP";
    }
    if (userInitial == null || userInitial.trim().isEmpty()) {
        userInitial = "KProgram";
    }

    List<User> lecturers = (List<User>) request.getAttribute("lecturers");
%>

<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8"/>
        <title>Lecturers </title>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>

        <style>
            body{
                margin:0;
                font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial;
                background:#f6f7fb;
                color:#111827
            }
            header{
                background:#fff;
                border-bottom:1px solid #e5e7eb;
                position:sticky;
                top:0;
                z-index:10
            }
            .bar{
                max-width:1180px;
                margin:0 auto;
                padding:12px 16px;
                display:flex;
                align-items:center;
                gap:12px
            }
            .brand{
                display:flex;
                align-items:center;
                gap:10px;
                min-width:240px
            }
            .logo{
                width:38px;
                height:38px;
                border-radius:12px;
                display:grid;
                place-items:center;
                background:#eef2ff;
                border:1px solid #e0e7ff
            }
            nav{
                display:flex;
                gap:8px;
                flex:1
            }
            nav button{
                border:1px solid #e5e7eb;
                background:#fff;
                border-radius:12px;
                padding:9px 11px;
                font-weight:800;
                font-size:13px;
                cursor:pointer
            }
            nav button.active{
                background:#111827;
                color:#fff;
                border-color:#111827
            }
            .user{
                display:flex;
                align-items:center;
                gap:10px
            }
            .avatar{
                width:36px;
                height:36px;
                border-radius:50%;
                border:1px solid #e5e7eb;
                display:grid;
                place-items:center;
                background:#f3f4f6;
                font-weight:900
            }
            .logout{
                width:36px;
                height:36px;
                border-radius:50%;
                border:1px solid #e5e7eb;
                display:grid;
                place-items:center;
                text-decoration:none;
                background:#fff;
                font-weight:900
            }
            .logout:hover{
                background:#fee2e2;
                border-color:#fecaca;
                color:#991b1b
            }

            main{
                max-width:1180px;
                margin:0 auto;
                padding:18px 16px
            }
            h1{
                margin:0
            }
            .sub{
                color:#6b7280;
                margin-top:4px
            }

            .grid{
                margin-top:16px;
                display:grid;
                grid-template-columns:repeat(3,1fr);
                gap:14px
            }
            @media(max-width:900px){
                .grid{
                    grid-template-columns:1fr
                }
            }
            .card{
                background:#fff;
                border:1px solid #e5e7eb;
                border-radius:14px;
                padding:16px;
                box-shadow:0 10px 20px rgba(0,0,0,.06)
            }
            .name{
                font-weight:900
            }
            .email{
                color:#6b7280;
                font-size:13px;
                margin-top:4px
            }
            .actions{
                margin-top:12px
            }
            .btn{
                border:none;
                background:#111827;
                color:#fff;
                border-radius:12px;
                padding:9px 12px;
                font-weight:900;
                cursor:pointer;
                text-decoration:none;
                display:inline-block
            }
        </style>
    </head>

    <body>

        <header>
            <div class="bar">
                <div class="brand">
                    <div class="logo">🎓</div>
                    <div>
                        <b>E-Vetting System</b>
                        <div style="font-size:12px;color:#6b7280">Ketua Program</div>
                    </div>
                </div>

                <nav>
                    <button onclick="go('<%=request.getContextPath()%>/KP/dashboard')">Dashboard</button>
                    <button onclick="go('<%=request.getContextPath()%>/KP/courses')">All Courses</button>
                    <button class="nav" onclick="go('<%= request.getContextPath()%>/KP/vetting-queue')">Vetting Progress</button>
                    <button class="nav" onclick="go('<%= request.getContextPath()%>/KP/jss')">JSS</button>
                    <button class="nav" onclick="go('<%= request.getContextPath()%>/KP/checklist')">Checklist</button>
                    <button class="active">Lecturers</button>
                </nav>

                <div class="user">
                    <div style="text-align:right">
                        <b style="font-size:13px"><%=userFullName%></b><br/>
                        <span style="font-size:12px;color:#6b7280"><%=role%></span>
                    </div>
                    <div class="avatar"><%=userInitial%></div>
                    <a class="logout" href="<%=request.getContextPath()%>/logout" title="Logout">🚪</a>
                </div>
            </div>
        </header>

        <main>
            <h1>Lecturers</h1>
            <p class="sub">Assign courses to lecturers</p>

            <div class="grid">
                <%
                    if (lecturers == null || lecturers.isEmpty()) {
                %>
                <div class="card">
                    <b>No lecturers found</b>
                    <div class="email">Make sure users with role = Lecturer exist.</div>
                </div>
                <%
                } else {
                    for (User u : lecturers) {
                %>
                <div class="card">
                    <div class="name"><%= u.getFullName()%></div>
                    <div class="email"><%= u.getEmail()%></div>

                    <div class="actions">
                        <a class="btn"
                           href="<%=request.getContextPath()%>/KP/lecturers/assign?lecturerId=<%=u.getUserId()%>">
                            Assign Courses
                        </a>
                    </div>
                </div>
                <%
                        }
                    }
                %>
            </div>
        </main>

        <script>
            function go(url) {
                window.location.href = url;
            }
        </script>

    </body>
</html>

