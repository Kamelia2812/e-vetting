/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
/*package Controller;

import DAO.CourseDAO;
import DAO.LessonPlanDAO;
import Model.Course;
import Model.LessonPlanWeek;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;


@WebServlet("/lecturer/teaching-plan")
public class LessonPlanServlet extends HttpServlet {

    private final LessonPlanDAO planDAO = new LessonPlanDAO();
    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String courseIdStr = request.getParameter("courseId");
        if (courseIdStr == null || courseIdStr.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/courses?err=MissingCourseId");
            return;
        }

        try {
            int courseId = Integer.parseInt(courseIdStr);
            Course course = courseDAO.getCourseById(courseId);
            List<LessonPlanWeek> existingPlan = planDAO.getPlanByCourseId(courseId);

            request.setAttribute("course", course);
            request.setAttribute("existingPlan", existingPlan);
            request.getRequestDispatcher("/teachingPlan.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Error loading teaching plan", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // SECURITY CHECK: Only Lecturers can save!
        String role = (String) session.getAttribute("role");
        if (!"Lecturer".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
            return;
        }

        try {
            int courseId = Integer.parseInt(request.getParameter("courseId"));
            List<LessonPlanWeek> weeks = new ArrayList<>();

            for (int i = 1; i <= 14; i++) {
                LessonPlanWeek w = new LessonPlanWeek();
                w.setCourseId(courseId);
                w.setWeekNumber(i);
                w.setStartDate(request.getParameter("startDate_" + i));
                w.setEndDate(request.getParameter("endDate_" + i));
                w.setTopic(request.getParameter("topic_" + i));
                w.setCloMapping(request.getParameter("clo_" + i));
                w.setLearningActivities(request.getParameter("activities_" + i));
                w.setAssessmentType(request.getParameter("assessment_" + i));
                w.setRemarks(request.getParameter("remarks_" + i));
                weeks.add(w);
            }

            planDAO.saveTeachingPlan(courseId, weeks);
            response.sendRedirect(request.getContextPath() + "/lecturer/teaching-plan?courseId=" + courseId + "&success=1");

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error saving teaching plan", e);
        }
    }
}
*/