package Controller;

import DAO.CourseDAO;
import DAO.UserDAO;
import Model.Course;
import Model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/KPCourseServlet")
public class KPCourseServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        try {
            // 1. Initialize DAOs
            CourseDAO courseDao = new CourseDAO();
            UserDAO userDao = new UserDAO();

            // 2. Fetch data from Database
            List<Course> allCourses = courseDao.getAllCourses(); 
            List<User> lecturers = userDao.getUsersByRole("Lecturer");
            List<User> vetters = userDao.getUsersByRole("Vetter");

            // 3. Set attributes (Make sure names match course.jsp exactly)
            request.setAttribute("allCourses", allCourses);
            request.setAttribute("lecturers", lecturers);
            request.setAttribute("vetters", vetters);

            // 4. Forward to the JSP
            request.getRequestDispatcher("course.jsp").forward(request, response);
            
        } catch (Exception e) {
            // This will help you see the EXACT error in the browser if it fails
            throw new ServletException("Failed to load KP Course Dashboard data", e);
        }
    }
}