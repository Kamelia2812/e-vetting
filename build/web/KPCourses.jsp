<%-- 
    Document   : adminCourses
    Created on : 22 Jan 2026, 6:11:09 AM
    Author     : Azim Muhai
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="Model.Course" %>

<%
    String userFullName = (String) session.getAttribute("userFullName");
    String role = (String) session.getAttribute("role");
    String userInitial = (String) session.getAttribute("userInitial");

    if (userFullName == null) {
        userFullName = "Vetter";
    }
    if (role == null) {
        role = "Vetter";
    }
    if (userInitial == null || userInitial.trim().isEmpty()) {
        userInitial = "Vetter";
    }

    List<Course> courses = (List<Course>) request.getAttribute("courses");

    String success = request.getParameter("success");
    String err = request.getParameter("err");
%>

<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width,initial-scale=1"/>
        <title>All Courses - Admin</title>

        <style>
            :root{
                --bg:#f6f7fb;
                --card:#fff;
                --text:#111827;
                --muted:#6b7280;
                --border:#e5e7eb;
                --primary:#111827;
                --shadow:0 10px 20px rgba(0,0,0,.06);
                --r:14px;
            }
            *{
                box-sizing:border-box
            }
            body{
                margin:0;
                font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial;
                background:var(--bg);
                color:var(--text)
            }
            header{
                background:#fff;
                border-bottom:1px solid var(--border);
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
            .brand b{
                display:block;
                font-size:14px
            }
            .brand span{
                display:block;
                font-size:12px;
                color:var(--muted)
            }
            nav{
                display:flex;
                gap:8px;
                flex:1;
                overflow:auto
            }
            nav button{
                border:1px solid var(--border);
                background:#fff;
                border-radius:12px;
                padding:9px 11px;
                font-weight:800;
                font-size:13px;
                cursor:pointer;
                white-space:nowrap;
                display:flex;
                align-items:center;
                gap:8px
            }
            nav button.active{
                background:var(--primary);
                border-color:var(--primary);
                color:#fff
            }
            .user{
                min-width:260px;
                display:flex;
                justify-content:flex-end;
                align-items:center;
                gap:10px
            }
            .avatar{
                width:36px;
                height:36px;
                border-radius:50%;
                border:1px solid var(--border);
                display:grid;
                place-items:center;
                background:#f3f4f6;
                font-weight:900
            }
            .user .meta{
                line-height:1.1;
                text-align:right
            }
            .user .meta b{
                font-size:13px
            }
            .user .meta span{
                font-size:12px;
                color:var(--muted)
            }
            .logout{
                width:36px;
                height:36px;
                border-radius:50%;
                border:1px solid var(--border);
                display:grid;
                place-items:center;
                text-decoration:none;
                color:#374151;
                font-weight:900;
                background:#fff;
                transition: transform .15s ease, background .15s ease, border-color .15s ease, color .15s ease;
            }
            .logout:hover{
                transform: translateX(2px);
                background:#fee2e2;
                border-color:#fecaca;
                color:#991b1b;
            }

            main{
                max-width:1180px;
                margin:0 auto;
                padding:18px 16px 60px
            }
            .top{
                display:flex;
                gap:12px;
                align-items:flex-start;
                justify-content:space-between;
                flex-wrap:wrap
            }
            h1{
                margin:0;
                font-size:28px
            }
            .sub{
                margin:6px 0 0;
                color:var(--muted);
                font-size:14px
            }
            .rightActions{
                display:flex;
                gap:10px;
                align-items:center
            }
            .btn{
                border:none;
                background:var(--primary);
                color:#fff;
                border-radius:12px;
                padding:10px 14px;
                font-weight:900;
                cursor:pointer;
                display:flex;
                gap:8px;
                align-items:center
            }
            .search{
                margin-top:16px;
                display:flex;
                gap:10px;
                align-items:center
            }
            .search input{
                width:520px;
                max-width:100%;
                padding:12px 14px;
                border-radius:12px;
                border:1px solid var(--border);
                background:#fff;
                outline:none;
                font-weight:700
            }

            .grid{
                margin-top:16px;
                display:grid;
                grid-template-columns:repeat(3,1fr);
                gap:14px
            }
            @media (max-width:1000px){
                .grid{
                    grid-template-columns:repeat(2,1fr)
                }
            }
            @media (max-width:600px){
                .grid{
                    grid-template-columns:1fr
                }
            }
            .card{
                background:var(--card);
                border:1px solid var(--border);
                border-radius:var(--r);
                box-shadow:var(--shadow)
            }
            .courseCard{
                padding:16px;
                cursor:pointer;
                transition: transform 0.2s ease, box-shadow 0.2s ease;
            }
            .courseCard:hover{
                transform: translateY(-4px);
                box-shadow: 0 14px 28px rgba(0,0,0,.12);
                border-color: #d1d5db;
            }
            .iconBox{
                width:52px;
                height:52px;
                border-radius:16px;
                border:1px solid #e0e7ff;
                background:#eef2ff;
                display:grid;
                place-items:center;
                font-size:22px;
                color:#3730a3
            }
            .rowTop{
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                margin-bottom:12px
            }
            .levelTag{
                border:1px solid var(--border);
                background:#fff;
                border-radius:999px;
                padding:6px 10px;
                font-size:12px;
                font-weight:900;
                color:#374151
            }
            .code{
                font-weight:1000;
                margin-top:10px
            }
            .name{
                color:var(--muted);
                font-weight:800;
                margin-top:4px
            }
            .kv{
                margin-top:18px;
                display:grid;
                grid-template-columns:1fr auto;
                row-gap:10px
            }
            .kv .k{
                color:var(--muted);
                font-weight:800
            }
            .kv .v{
                font-weight:1000
            }
            .divider{
                margin:14px 0;
                border-top:1px solid var(--border)
            }
            .semester{
                color:var(--muted);
                font-weight:800;
                font-size:13px
            }

            /* modal */
            .overlay{
                position:fixed;
                inset:0;
                background:rgba(17,24,39,.55);
                display:none;
                align-items:center;
                justify-content:center;
                padding:18px;
                z-index:50
            }
            .overlay.show{
                display:flex
            }
            .modal{
                width:720px;
                max-width:100%;
                background:#fff;
                border-radius:16px;
                border:1px solid var(--border);
                box-shadow:var(--shadow);
                padding:18px 18px 16px;
            }
            .modalTop{
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                gap:12px
            }
            .modal h2{
                margin:0
            }
            .modal .hint{
                margin:6px 0 0;
                color:var(--muted);
                font-weight:700
            }
            .x{
                width:38px;
                height:38px;
                border-radius:12px;
                border:1px solid var(--border);
                background:#fff;
                cursor:pointer;
                font-size:18px
            }
            .formGrid{
                margin-top:14px;
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:12px
            }
            .field label{
                display:block;
                font-weight:900;
                margin:0 0 6px
            }
            .field input{
                width:100%;
                padding:12px 12px;
                border:1px solid var(--border);
                border-radius:12px;
                background:#f9fafb;
                outline:none;
                font-weight:800
            }
            .formRow3{
                display:grid;
                grid-template-columns:1fr 1fr 1fr;
                gap:12px;
                margin-top:12px
            }
            .submitBtn{
                margin-top:14px;
                width:100%;
                border:none;
                background:var(--primary);
                color:#fff;
                border-radius:12px;
                padding:12px 14px;
                font-weight:1000;
                cursor:pointer
            }

            .msg{
                margin-top:12px;
                padding:10px 12px;
                border-radius:12px;
                border:1px solid var(--border);
                font-weight:900
            }
            .msg.ok{
                background:#f0fdf4;
                border-color:#bbf7d0;
                color:#166534
            }
            .msg.err{
                background:#fef2f2;
                border-color:#fecaca;
                color:#991b1b
            }
            .actions{
                display:flex;
                gap:8px;
            }
            .iconBtn{
                width:34px;
                height:34px;
                border-radius:12px;
                border:1px solid var(--border);
                background:#fff;
                cursor:pointer;
                display:grid;
                place-items:center;
                font-size:14px;
                font-weight:900;
            }
            .iconBtn:hover{
                background:#f9fafb;
            }
            .iconBtn.danger:hover{
                background:#fee2e2;
                border-color:#fecaca;
                color:#991b1b;
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
                        <span>Assessment Management</span>
                    </div>
                </div>

                <!-- Lecturer-style navbar buttons -->
                <nav>
                    <button class="nav" onclick="go('<%= request.getContextPath()%>/vetter/dashboard')">Dashboard</button>
                    <button class="nav active">All Courses</button>
                    <button class="nav" onclick="go('<%= request.getContextPath()%>/vetter/vetting-queue')">Vetting Queue</button>
                    <button class="nav" onclick="go('<%= request.getContextPath()%>/vetter/jss')">JSS</button>
                    <button class="nav" onclick="go('<%= request.getContextPath()%>/vetter/checklist')">Checklist</button>
                    <button class="nav" onclick="go('<%= request.getContextPath()%>/vetter/lecturers')">Lecturers</button>
                </nav>

                <div class="user">
                    <div class="meta">
                        <b><%= userFullName%></b><br/>
                        <span><%= role%></span>
                    </div>
                    <div class="avatar"><%= userInitial%></div>
                    <a class="logout" href="<%= request.getContextPath()%>/logout" title="Logout">➜</a>
                </div>
            </div>
        </header>

        <main>
            <div class="top">
                <div>
                    <h1>All Courses</h1>
                    <p class="sub">Manage course information and CLOs</p>

                    <% if ("1".equals(success)) { %>
                    <div class="msg ok">Course created successfully.</div>
                    <% } %>

                    <% if (err != null && !err.trim().isEmpty()) {%>
                    <div class="msg err"><%= err%></div>
                    <% } %>
                </div>

                <div class="rightActions">
                    <button class="btn" id="openModal">＋ Add Course</button>
                </div>
            </div>

            <div class="search">
                <input id="q" type="text" placeholder="Search courses by name or code..." />
            </div>

            <div class="grid" id="grid">
                <%
                    if (courses == null || courses.isEmpty()) {
                %>
                <div class="card courseCard">
                    <b>No courses yet</b>
                    <div class="name">Click “Add Course” to create your first course.</div>
                </div>
                <%
                } else {
                    for (Course c : courses) {
                        String code = c.getCourseCode() == null ? "" : c.getCourseCode();
                        String name = c.getCourseName() == null ? "" : c.getCourseName();
                %>
                <div class="card courseCard courseItem" 
                     data-search="<%= (code + " " + name).toLowerCase()%>"
                     onclick="go('<%= request.getContextPath()%>/admin/course-info?id=<%= c.getCourseId()%>')">
                     
                    <div class="rowTop">
                        <div class="iconBox">📘</div>

                        <div class="actions">
                            <button type="button"
                                    class="iconBtn"
                                    title="Edit"
                                    onclick="event.stopPropagation(); openEdit(
                                                    '<%= c.getCourseId()%>',
                                                    '<%= code.replace("'", "\\'")%>',
                                                    '<%= name.replace("'", "\\'")%>',
                                                    '<%= c.getCredit()%>',
                                                    '<%= c.getOfferPeriod() != null ? c.getOfferPeriod().replace("'", "\\'") : "" %>'
                                                    )">✏️</button>

                            <form method="post" action="<%= request.getContextPath()%>/admin/courses/delete"
                                  onsubmit="return confirm('Delete this course?')"
                                  onclick="event.stopPropagation();"
                                  style="margin:0;">
                                <input type="hidden" name="courseId" value="<%= c.getCourseId()%>"/>
                                <button type="submit" class="iconBtn danger" title="Delete">🗑️</button>
                            </form>
                        </div>
                    </div>

                    <div class="code"><%= code%></div>
                    <div class="name"><%= name%></div>

                    <div class="kv">
                        <div class="k">Credits</div><div class="v"><%= c.getCredit()%></div>
                        <div class="k">CLOs</div><div class="v">—</div>
                        <div class="k">Lecturer</div><div class="v">—</div>
                    </div>

                    <div class="semester"><%= c.getOfferPeriod() %></div>
                </div>
                <%
                        }
                    }
                %>
            </div>

        </main>

        <!-- ADD Modal -->
        <div class="overlay" id="overlay" aria-hidden="true">
            <div class="modal">
                <div class="modalTop">
                    <div>
                        <h2>Add New Course</h2>
                        <div class="hint">Enter course details and define CLOs</div>
                    </div>
                    <button class="x" id="closeModal" type="button">×</button>
                </div>

                <form method="post" action="<%= request.getContextPath()%>/admin/courses/add">
                    <div class="formGrid">
                        <div class="field">
                            <label>Course Code</label>
                            <input name="courseCode" type="text" placeholder="CS101" required />
                        </div>
                        <div class="field">
                            <label>Course Name</label>
                            <input name="courseName" type="text" placeholder="Introduction to CS" required />
                        </div>
                    </div>

                    <div class="formRow3">

                        <div class="field">
                            <label>Credits</label>
                            <input name="credits" type="number" placeholder="3" min="1" required />
                        </div>
                        <div class="field">
                            <label>Semester</label>
                            <input name="semester" type="text" placeholder="2024/25 S1" required />
                        </div>
                    </div>

                    <button class="submitBtn" type="submit">Create Course</button>
                </form>
            </div>
        </div>

        <!-- EDIT MODAL -->
        <div class="overlay" id="editModal">
            <div class="modal">
                <div class="modalTop"><h3>Edit Course</h3><button class="x" onclick="closeEdit()">×</button></div>
                <form method="post" action="<%=request.getContextPath()%>/admin/courses/update">
                    <input type="hidden" name="courseId" id="eid"/>
                    <div class="field"><label>Code</label><input name="courseCode" id="ecode" required/></div>
                    <div class="field"><label>Name</label><input name="courseName" id="ename" required/></div>
                    <div class="field"><label>Credits</label><input name="credits" id="ecredits" type="number" required/></div>
                    <div class="field"><label>Semester</label><input name="semester" id="esem" required/></div>
                    <button class="submitBtn">Save</button>
                </form>
            </div>
        </div>

        <script>
            function go(u) {
                location.href = u; }

            const add = document.getElementById("overlay");   // ADD modal overlay
            const edit = document.getElementById("editModal"); // EDIT modal overlay

            const openModalBtn = document.getElementById("openModal");
            const closeModalBtn = document.getElementById("closeModal");

            function showAdd() {
                if (!add)
                    return;
                add.classList.add("show");
                add.setAttribute("aria-hidden", "false");
            }

            function closeAdd() {
                if (!add)
                    return;
                add.classList.remove("show");
                add.setAttribute("aria-hidden", "true");
            }

            function closeEdit() {
                if (!edit)
                    return;
                edit.classList.remove("show");
                edit.setAttribute("aria-hidden", "true");
            }

            // open/close Add modal
            openModalBtn && openModalBtn.addEventListener("click", showAdd);
            closeModalBtn && closeModalBtn.addEventListener("click", closeAdd);

            // click outside to close
            add && add.addEventListener("click", (e) => {
                if (e.target === add)
                    closeAdd();
            });
            edit && edit.addEventListener("click", (e) => {
                if (e.target === edit)
                    closeEdit();
            });

            // Edit modal opener (called from onclick in cards)
            function openEdit(id, c, n, cr, s) {
                document.getElementById("eid").value = id;
                document.getElementById("ecode").value = c;
                document.getElementById("ename").value = n;
                document.getElementById("ecredits").value = cr;
                document.getElementById("esem").value = s;
                edit.classList.add("show");
                edit.setAttribute("aria-hidden", "false");
            }
            window.openEdit = openEdit;
            window.closeEdit = closeEdit;

            // Search filter
            const q = document.getElementById("q");
            q && q.addEventListener("input", () => {
                const v = q.value.trim().toLowerCase();
                document.querySelectorAll(".courseItem").forEach(card => {
                    const s = card.getAttribute("data-search") || "";
                    card.style.display = s.includes(v) ? "" : "none";
                });
            });
        </script>
        

    </body>
</html>

