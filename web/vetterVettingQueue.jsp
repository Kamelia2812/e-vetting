<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="Model.Course" %>
<%@ page import="Model.Course" %>

<%
    List<Assessment> assessments = (List<Assessment>) request.getAttribute("assessments");
    Assessment assessment = (Assessment) request.getAttribute("assessment");
    Course course = (Course) request.getAttribute("course");
%>

<!doctype html>
<html>
<head>
    <title>Vetting Queue</title>
    <style>
        body{font-family:system-ui;background:#f6f7fb;margin:0}
        .wrap{max-width:1100px;margin:0 auto;padding:20px}
        .card{background:#fff;border:1px solid #e5e7eb;border-radius:14px;padding:16px;margin-bottom:14px}
        .btn{padding:8px 12px;border-radius:10px;font-weight:800;border:none;cursor:pointer}
        .approve{background:#16a34a;color:#fff}
        .reject{background:#dc2626;color:#fff}
        .badge{font-size:12px;font-weight:900;padding:4px 8px;border-radius:999px}
        .pending{background:#ffedd5;color:#9a3412}
    </style>
</head>

<body>
<div class="wrap">

<%-- ================= QUEUE ================= --%>
<% if (assessment == null) { %>

<h2>Vetting Queue</h2>

<% if (assessments == null || assessments.isEmpty()) { %>
    <div class="card">No assessments pending vetting</div>
<% } else {
   for (Assessment a : assessments) { %>

    <div class="card">
        <h3><%= a.getTitle() %></h3>
        <span class="badge pending">PENDING REVIEW</span>
        <p><%= a.getCourseName() %></p>

        <p>
            Total: <b><%= a.getTotalMarks() %></b> |
            Weightage: <b><%= a.getWeightage() %>%</b>
        </p>

        <a class="btn" href="<%=request.getContextPath()%>/admin/vetting?assessmentId=<%=a.getAssessmentId()%>">
            Review
        </a>
    </div>

<% }} %>

<%-- ================= REVIEW ================= --%>
<% } else { %>

<a href="<%=request.getContextPath()%>/admin/vetting">← Back to Queue</a>

<div class="card">
    <h2><%= assessment.getTitle() %></h2>
    <p><b>Course:</b> <%= course.getCourseName() %></p>

    <h3>Questions</h3>
    
</div>

<div class="card">
    <h3>Vetting Decision</h3>

    <form method="post" action="<%=request.getContextPath()%>/admin/vetting">
        <input type="hidden" name="assessmentId" value="<%= assessment.getAssessmentId() %>"/>

        <textarea name="comments" rows="4" style="width:100%" placeholder="Vetting comments"></textarea>

        <br/><br/>
        <button class="btn approve" name="action" value="approve">Approve</button>
        <button class="btn reject" name="action" value="revise">Request Revision</button>
    </form>
</div>

<% } %>

</div>
</body>
</html>
