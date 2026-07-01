<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="Model.LessonPlanWeek" %>
<%@ page import="Model.Course" %>
<%
    String role = (String) session.getAttribute("role");
    // Only Lecturer can edit. Ketua Panel, Vetting Panel, Admin are Read-Only.
    boolean canEdit = "Lecturer".equalsIgnoreCase(role);
    String readonly = canEdit ? "" : "readonly";
    String disabled = canEdit ? "" : "disabled";

    Course course = (Course) request.getAttribute("course");
    List<LessonPlanWeek> existingPlan = (List<LessonPlanWeek>) request.getAttribute("existingPlan");
    String success = request.getParameter("success");

    int cId = course != null ? course.getCourseId() : Integer.parseInt(request.getParameter("courseId"));
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Teaching Plan - 14 Weeks</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                background: #f6f7fb;
                padding: 20px;
                color: #111827;
            }
            .container {
                background: white;
                padding: 30px;
                border-radius: 10px;
                max-width: 1200px;
                margin: auto;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            }
            .header-title {
                text-align: center;
                margin-bottom: 20px;
                color: #003366;
            }

            /* The Tabs */
            .course-tabs {
                display: flex;
                justify-content: center;
                gap: 15px;
                margin-bottom: 30px;
            }
            .course-tabs a {
                padding: 12px 24px;
                background: #fff;
                border: 1px solid #e5e7eb;
                border-radius: 8px;
                text-decoration: none;
                color: #6b7280;
                font-weight: bold;
                font-size: 14px;
            }
            .course-tabs a:hover {
                background: #f3f4f6;
            }
            .course-tabs a.active-tab {
                background: #003366;
                color: white;
                border-color: #003366;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
            }
            th, td {
                border: 1px solid #ccc;
                padding: 10px;
                text-align: left;
                vertical-align: top;
            }
            th {
                background: #d4edda;
                text-align: center;
                font-size: 13px;
                font-weight: bold;
                color: #155724;
            }
            input[type="text"], input[type="date"], textarea {
                width: 100%;
                box-sizing: border-box;
                padding: 6px;
                border: 1px solid #ccc;
                border-radius: 4px;
                font-family: inherit;
            }
            input[readonly], textarea[readonly], input[disabled] {
                background: #f3f4f6;
                color: #6b7280;
                cursor: not-allowed;
                border: none;
            }

            .btn {
                background: #003366;
                color: white;
                padding: 12px 24px;
                border-radius: 8px;
                cursor: pointer;
                border: none;
                font-weight: bold;
                font-size: 15px;
            }
            .msg {
                background: #d4edda;
                color: #155724;
                padding: 12px;
                border-radius: 8px;
                margin-bottom: 20px;
                font-weight: bold;
                text-align: center;
            }
        </style>
    </head>
    <body>

        <div class="container">

            <div class="course-tabs">
                <a href="<%= request.getContextPath()%>/admin/course-info?id=<%= cId%>">Course Syllabus</a>
                <a href="<%= request.getContextPath()%>/lecturer/teaching-plan?courseId=<%= cId%>" class="active-tab">Teaching Plan</a>
            </div>

            <h2 class="header-title">14-Week Teaching Plan <%= course != null ? " - " + course.getCourseCode() : ""%></h2>

            <% if ("1".equals(success)) { %>
            <div class="msg">Teaching Plan saved successfully!</div>
            <% } %>
            <% if (!canEdit) { %>
            <div style="text-align: center; color: #991b1b; margin-bottom: 10px; font-weight: bold;">
                Viewing Mode Only (Read-Only)
            </div>
            <% }%>

            <form action="<%= request.getContextPath()%>/lecturer/teaching-plan" method="POST">
                <input type="hidden" name="courseId" value="<%= cId%>">

                <table>
                    <thead>
                        <tr>
                            <th style="width: 5%;">Week</th>
                            <th style="width: 12%;">Dates</th>
                            <th style="width: 20%;">Topic</th>
                            <th style="width: 10%;">CLOs</th>
                            <th style="width: 20%;">Teaching & Learning Activities</th>
                            <th style="width: 18%;">Assessment Type</th>
                            <th style="width: 15%;"> Remarks</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (int i = 1; i <= 14; i++) {
                                LessonPlanWeek weekData = null;
                                if (existingPlan != null) {
                                    for (LessonPlanWeek w : existingPlan) {
                                        if (w.getWeekNumber() == i) {
                                            weekData = w;
                                            break;
                                        }
                                    }
                                }
                                String sDate = (weekData != null && weekData.getStartDate() != null) ? weekData.getStartDate() : "";
                                String eDate = (weekData != null && weekData.getEndDate() != null) ? weekData.getEndDate() : "";
                                String topic = (weekData != null && weekData.getTopic() != null) ? weekData.getTopic() : "";
                                String clo = (weekData != null && weekData.getCloMapping() != null) ? weekData.getCloMapping() : "";
                                String act = (weekData != null && weekData.getLearningActivities() != null) ? weekData.getLearningActivities() : "";
                                String asm = (weekData != null && weekData.getAssessmentType() != null) ? weekData.getAssessmentType() : "";
                                String rem = (weekData != null && weekData.getRemarks() != null) ? weekData.getRemarks() : "";
                        %>
                        <tr>
                            <td style="text-align: center; font-weight: bold;">W<%= i%></td>
                            <td>
                                <input type="date" name="startDate_<%= i%>" value="<%= sDate%>" <%= disabled%>><br><br>
                                <input type="date" name="endDate_<%= i%>" value="<%= eDate%>" <%= disabled%>>
                            </td>
                            <td><textarea name="topic_<%= i%>" rows="4" <%= readonly%>><%= topic%></textarea></td>
                            <td><input type="text" name="clo_<%= i%>" value="<%= clo%>" <%= readonly%>></td>
                            <td><textarea name="activities_<%= i%>" rows="4" <%= readonly%>><%= act%></textarea></td>
                            <td><textarea name="assessment_<%= i%>" rows="4" <%= readonly%>><%= asm%></textarea></td>
                            <td><textarea name="remarks_<%= i%>" rows="4" <%= readonly%>><%= rem%></textarea></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>

                <% if (canEdit) { %>
                <div style="text-align: right; margin-top: 20px;">
                    <button type="submit" class="btn">Save Teaching Plan</button>
                </div>
                <% }%>
            </form>
        </div>

    </body>
</html>
