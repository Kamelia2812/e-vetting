<%@ page import="Model.Course, Model.User, java.util.List" %>
<%
    // 1. Role Guard: Strictly KP only
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equalsIgnoreCase("KP")) {
        response.sendRedirect("unauthorized.jsp");
        return;
    }

    // 2. Data Check: Ensure lists are not null to prevent 500 errors
    List<Course> allCourses = (List<Course>) request.getAttribute("allCourses");
    List<User> lecturerList = (List<User>) request.getAttribute("lecturers");
    List<User> vetterList = (List<User>) request.getAttribute("vetters");
%>

<div class="kp-container">
    <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 25px;">
        <div>
            <h1 style="margin:0; font-size: 22px; color: #1e293b;">Staff Assignment</h1>
            <p style="color: #64748b; margin: 4px 0 0; font-size: 14px;">Map Lecturers (Creators) and Vetters (Reviewers) to courses.</p>
        </div>
        <div class="stats-mini" style="font-size: 12px; color: #94a3b8; font-weight: 600;">
            TOTAL COURSES: <%= (allCourses != null) ? allCourses.size() : 0 %>
        </div>
    </div>

    <div class="table-card">
        <table class="assignment-table">
            <thead>
                <tr>
                    <th>Code</th>
                    <th>Course Name</th>
                    <th>Lecturer (Creator)</th>
                    <th>Vetter (Leader/Reviewer)</th>
                    <th style="text-align: center;">Update</th>
                </tr>
            </thead>
            <tbody>
                <% if (allCourses != null && !allCourses.isEmpty()) {
                    for (Course c : allCourses) { 
                %>
                <tr>
                    <td class="col-code">
                        <span class="code-badge"><%= c.getCourseCode() %></span>
                    </td>
                    
                    <td class="col-name">
                        <strong><%= c.getCourseName() %></strong>
                    </td>
                    
                    <form action="AssignStaffServlet" method="POST">
                        <input type="hidden" name="courseId" value="<%= c.getCourseId() %>">
                        
                        <td class="col-select">
                            <select name="lecturerId" class="modern-select">
                                <option value="0" style="color: #94a3b8;">-- No Lecturer --</option>
                                <% if (lecturerList != null) {
                                    for (User u : lecturerList) { %>
                                    <option value="<%= u.getUserId() %>" <%= (u.getUserId() == c.getLecturerId()) ? "selected" : "" %>>
                                        <%= u.getFullName() %>
                                    </option>
                                <% } } %>
                            </select>
                        </td>

                        <td class="col-select">
                            <select name="vetterId" class="modern-select">
                                <option value="0" style="color: #94a3b8;">-- No Vetter --</option>
                                <% if (vetterList != null) {
                                    for (User v : vetterList) { %>
                                    <option value="<%= v.getUserId() %>" <%= (v.getUserId() == c.getVetterId()) ? "selected" : "" %>>
                                        <%= v.getFullName() %>
                                    </option>
                                <% } } %>
                            </select>
                        </td>

                        <td class="col-action">
                            <button type="submit" class="btn-save">Save</button>
                        </td>
                    </form>
                </tr>
                <% } } else { %>
                <tr>
                    <td colspan="5" style="padding: 50px; text-align: center; color: #94a3b8;">
                        No courses found in the system.
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<style>
    /* Container & Layout */
    .table-card {
        background: white;
        border: 1px solid #e2e8f0;
        border-radius: 12px;
        overflow: visible; /* Allows dropdowns to overlap if needed */
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }

    .assignment-table {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
    }

    /* Table Headers */
    .assignment-table th {
        background: #f8fafc;
        padding: 12px 20px;
        font-size: 11px;
        text-transform: uppercase;
        letter-spacing: 0.05em;
        color: #64748b;
        border-bottom: 1px solid #e2e8f0;
    }

    /* Table Rows */
    .assignment-table td {
        padding: 16px 20px;
        border-bottom: 1px solid #f1f5f9;
        font-size: 14px;
        vertical-align: middle;
    }

    /* Styling Course Code */
    .code-badge {
        font-family: 'Monaco', 'Consolas', monospace;
        background: #eef2ff;
        color: #4338ca;
        padding: 4px 8px;
        border-radius: 6px;
        font-weight: 700;
        font-size: 13px;
        border: 1px solid #c7d2fe;
    }

    /* Styling Select Menus */
    .modern-select {
        width: 100%;
        padding: 8px 12px;
        border: 1px solid #d1d5db;
        border-radius: 8px;
        background-color: #ffffff;
        color: #334155;
        font-size: 13px;
        cursor: pointer;
        transition: all 0.2s;
    }

    .modern-select:focus {
        outline: none;
        border-color: #2563eb;
        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
    }

    /* Save Button */
    .btn-save {
        background: #2563eb;
        color: white;
        border: none;
        padding: 8px 18px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 13px;
        cursor: pointer;
        transition: background 0.2s;
    }

    .btn-save:hover {
        background: #1d4ed8;
    }

    /* Column Widths */
    .col-code { width: 15%; }
    .col-name { width: 25%; }
    .col-select { width: 25%; }
    .col-action { width: 10%; text-align: center; }
</style>