package Controller;

import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import DAO.CourseDAO;
import DAO.UserDAO;
import Model.Course;
import Model.User;

@WebServlet("/KPAssignCoursesServlet")
public class KPAssignCoursesServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Security Check: Ensure only KP can access this
        HttpSession session = request.getSession();
        String role = (String) session.getAttribute("role");

        if (role == null || !role.equalsIgnoreCase("KP")) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            // FIX: Create an instance (object) of the DAO
            CourseDAO courseDAO = new CourseDAO();

            // FIX: Use the object name 'courseDAO' (lowercase) to call the method
            List<Course> courses = courseDAO.getAllCourses();

            request.setAttribute("courses", courses);
            request.getRequestDispatcher("/KPCourses.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Failed to load courses", e);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect POST requests to the same logic or a specific update handler
        doGet(request, response);
    }
}
