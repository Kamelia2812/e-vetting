<%-- 
    Document   : adminAssignCourses
    Created on : 22 Jan 2026, 8:15:48 AM
    Author     : Azim Muhai
--%>

<%-- 
    Document   : AdminAssignCourses
    Created on : 22 Jan 2026, 7:47:58 AM
    Author     : Azim Muhai
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="Model.Course" %>

<%
    List<Course> courses = (List<Course>) request.getAttribute("courses");
    List<Integer> assignedIds = (List<Integer>) request.getAttribute("assignedIds");
    Integer lecturerId = (Integer) request.getAttribute("lecturerId");
    boolean ok = "1".equals(request.getParameter("success"));
    if (assignedIds == null)
        assignedIds = new ArrayList<Integer>();
%>

<!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <title>Assign Courses</title>
        <style>
            body{
                font-family:system-ui;
                margin:0;
                background:#f6f7fb
            }
            .wrap{
                max-width:900px;
                margin:0 auto;
                padding:18px
            }
            .card{
                background:#fff;
                border:1px solid #e5e7eb;
                border-radius:14px;
                padding:16px
            }
            .row{
                display:flex;
                justify-content:space-between;
                align-items:center;
                gap:12px
            }
            .list{
                margin-top:12px;
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:10px
            }
            .item{
                border:1px solid #e5e7eb;
                border-radius:12px;
                padding:12px;
                display:flex;
                gap:10px;
                align-items:flex-start
            }
            .code{
                font-weight:900;
                color:#6b7280;
                font-size:12px
            }
            .name{
                font-weight:900;
                margin-top:2px
            }
            .btn{
                border:none;
                background:#111827;
                color:#fff;
                border-radius:12px;
                padding:10px 14px;
                font-weight:900;
                cursor:pointer
            }
            .msg{
                margin-top:12px;
                border:1px solid #bbf7d0;
                background:#f0fdf4;
                color:#166534;
                border-radius:12px;
                padding:10px 12px;
                font-weight:900
            }
        </style>
    </head>
    <body>
        <div class="wrap">
            <div class="card">
                <div class="row">
                    <div>
                        <h2 style="margin:0">Assign Courses</h2>
                        <div style="color:#6b7280">Select courses for lecturer ID: <b><%= lecturerId%></b></div>
                    </div>
                    <button class="btn" type="button" onclick="window.location.href = '<%= request.getContextPath()%>/admin/lecturers'">Back</button>
                </div>

                <% if (ok) { %>
                <div class="msg">Saved successfully.</div>
                <% }%>

                <form method="post" action="<%= request.getContextPath()%>/admin/lecturers/assign">
                    <input type="hidden" name="lecturerId" value="<%= lecturerId%>"/>

                    <div class="list">
                        <%
                            if (courses != null) {
                                for (Course c : courses) {
                                    boolean checked = assignedIds.contains(c.getCourseId());
                        %>
                        <label class="item">
                            <input type="checkbox" name="courseId" value="<%= c.getCourseId()%>" <%= checked ? "checked" : ""%> />
                            <div>
                                <div class="code"><%= c.getCourseCode()%></div>
                                <div class="name"><%= c.getCourseName()%></div>
                            </div>
                        </label>
                        <%
                                }
                            }
                        %>
                    </div>

                    <div style="margin-top:12px">
                        <button class="btn" type="submit">Save</button>
                    </div>
                </form>
            </div>
        </div>
      <jsp:include page="footer.jsp"/>
</body>
</html>

