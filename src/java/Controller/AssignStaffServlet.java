package Controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import DAO.CourseDAO;

/**
 * Servlet implementation for assigning Lecturers and Vetters to a specific
 * course. Triggered by the "Save" button in course.jsp.
 */
@WebServlet("/AssignStaffServlet")
public class AssignStaffServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Security Check: Strictly KP role only
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        if (role == null || !role.equalsIgnoreCase("KP")) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            // 2. Capture parameters from the row form in course.jsp
            // Ensure these names match the 'name' attribute in your <select> and <input> tags
            String courseIdStr = request.getParameter("courseId");
            String lecturerIdStr = request.getParameter("lecturerId");
            String vetterIdStr = request.getParameter("vetterId");

            // Validate that we actually got data
            if (courseIdStr == null || lecturerIdStr == null || vetterIdStr == null) {
                response.sendRedirect("KPCourseServlet?status=missing_data");
                return;
            }

            int courseId = Integer.parseInt(courseIdStr);
            int lecturerId = Integer.parseInt(lecturerIdStr);
            int vetterId = Integer.parseInt(vetterIdStr);

            // 3. Call DAO to execute the SQL UPDATE
            CourseDAO courseDAO = new CourseDAO();

            // This method should execute: 
            // UPDATE courses SET lecturer_id = ?, vetter_id = ? WHERE course_id = ?
            boolean isUpdated = courseDAO.assignStaff(courseId, lecturerId, vetterId);

            // 4. Redirect back to the list controller (KPCourseServlet)
            if (isUpdated) {
                // Refresh the list to show the newly assigned staff
                response.sendRedirect("KPCourseServlet?status=success");
            } else {
                response.sendRedirect("KPCourseServlet?status=error");
            }

        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendRedirect("KPCourseServlet?status=invalid_format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("KPCourseServlet?status=exception");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to the list if someone tries to access this URL via browser address bar
        response.sendRedirect("KPCourseServlet");
    }
}
