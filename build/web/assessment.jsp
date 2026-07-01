<%@ page import="Model.Course, Model.Assessment, java.util.List" %>
<%
    // Role Security Check
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equalsIgnoreCase("Lecturer")) {
        response.sendRedirect("unauthorized.jsp"); // Redirect unauthorized users
        return; 
    }

    // Data passed from LecturerDashboardServlet
    List<Course> myCourses = (List<Course>) request.getAttribute("courses");
    List<Assessment> existingAssessments = (List<Assessment>) request.getAttribute("assessments");
%>

<div class="assessment-container">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px;">
        <div>
            <h1 style="margin:0; font-size: 24px;">Assessments</h1>
            <p style="color: #64748b; margin: 5px 0 0;">Create and manage your final exam papers</p>
        </div>
        <button class="btn-primary" style="background: #2563eb; color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer;">
            + New Assessment
        </button>
    </div>

    <h3 style="font-size: 18px; margin-bottom: 8px;">Select a Course to Create Assessment</h3>
    <p style="color: #94a3b8; font-size: 14px; margin-bottom: 20px;">Click on a course card to open the assessment builder for that course.</p>
    
    <div class="course-list" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-bottom: 50px;">
        <% if (myCourses != null) { 
            for (Course c : myCourses) { %>
            <div class="card course-card" onclick="location.href='LecturerDashboardServlet?page=create&courseId=<%= c.getCourseId() %>'" 
                 style="background: white; border: 1px solid #e2e8f0; border-radius: 16px; padding: 20px; cursor: pointer; transition: 0.2s; position: relative;">
                
                <div style="color: #4f46e5; font-weight: 800; font-size: 12px; margin-bottom: 4px;"><%= c.getCourseCode() %></div>
                <div style="font-weight: 700; font-size: 18px; margin-bottom: 8px;"><%= c.getCourseName() %></div>
                <div style="color: #64748b; font-size: 13px; margin-bottom: 20px;">? <%= c.getOfferPeriod() %></div>
                
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span class="badge draft" style="background: #eff6ff; color: #2563eb; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 700;">? Draft</span>
                    <span style="color: #4f46e5; font-size: 14px; font-weight: 600;">? Open</span>
                </div>
            </div>
        <% } } %>
    </div>

    <div style="background: white; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);">
        <div style="padding: 20px; border-bottom: 1px solid #f1f5f9;">
            <h3 style="margin: 0; font-size: 16px;">Existing Assessments</h3>
        </div>
        <table style="width: 100%; border-collapse: collapse; text-align: left;">
            <thead style="background: #f8fafc; border-bottom: 1px solid #e2e8f0;">
                <tr>
                    <th style="padding: 15px 20px; color: #64748b; font-size: 12px; text-transform: uppercase;">Course</th>
                    <th style="padding: 15px 20px; color: #64748b; font-size: 12px; text-transform: uppercase;">Assessment</th>
                    <th style="padding: 15px 20px; color: #64748b; font-size: 12px; text-transform: uppercase;">Status</th>
                    <th style="padding: 15px 20px; color: #64748b; font-size: 12px; text-transform: uppercase;">Action</th>
                </tr>
            </thead>
            <tbody>
                <% if (existingAssessments != null && !existingAssessments.isEmpty()) {
                    for (Assessment a : existingAssessments) { 
                %>
                <tr style="border-bottom: 1px solid #f1f5f9;">
                    <td style="padding: 15px 20px;">
                        <div style="color: #94a3b8; font-size: 11px; font-weight: 700;"><%= a.getCourseCode() %></div>
                        <div style="font-weight: 600;"><%= a.getCourseName() %></div>
                    </td>
                    <td style="padding: 15px 20px; font-weight: 600;">Final Exam Paper</td>
                    <td style="padding: 15px 20px;">
                        <% String status = a.getStatus(); 
                           String badgeStyle = "background: #f1f5f9; color: #475569;"; 
                           if("DRAFT".equalsIgnoreCase(status)) badgeStyle = "background: #eff6ff; color: #2563eb;";
                           if("SUBMITTED".equalsIgnoreCase(status)) badgeStyle = "background: #fffbeb; color: #d97706;";
                           if("VETTED".equalsIgnoreCase(status)) badgeStyle = "background: #f0fdf4; color: #166534;";
                           if("REJECTED".equalsIgnoreCase(status)) badgeStyle = "background: #fef2f2; color: #991b1b;";
                        %>
                        <span style="<%= badgeStyle %> padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 700;">? <%= status %></span>
                    </td>
                    <td style="padding: 15px 20px;">
                        <% if("DRAFT".equalsIgnoreCase(status) || "REJECTED".equalsIgnoreCase(status)) { %>
                            <button class="btn-edit" style="background: #2563eb; color: white; border: none; padding: 8px 16px; border-radius: 6px; font-weight: 600; cursor: pointer;">? Edit</button>
                        <% } else { %>
                            <button style="background: white; border: 1px solid #e2e8f0; padding: 8px 16px; border-radius: 6px; font-weight: 600; cursor: pointer;">View</button>
                        <% } %>
                    </td>
                </tr>
                <% } } else { %>
                <tr>
                    <td colspan="4" style="padding: 40px; text-align: center; color: #94a3b8;">No assessments currently tracked.</td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<style>
    .course-card:hover { transform: translateY(-4px); box-shadow: 0 10px 15px -3px rgb(0 0 0 / 0.1); border-color: #2563eb; }
</style>