/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

package Controller;

import DAO.CourseDAO;
import Model.Course;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/courses/add")
public class AddCourseServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // 1. Check login
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // 2. Role Restriction: Only KP can add courses
        String role = (String) session.getAttribute("role");
        if (role == null || !role.equalsIgnoreCase("KP")) {
            response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
            return;
        }

        // 3. Get Parameters from your JSP form
        String courseCode = request.getParameter("courseCode");
        String courseName = request.getParameter("courseName");
        String creditStr = request.getParameter("credit");      // Changed from credits
        String offerPeriod = request.getParameter("offerPeriod"); // Changed from semester
        
        // Add the other attributes your model requires
        String examHourStr = request.getParameter("examHour");
        String core = request.getParameter("core");
        String coCategory = request.getParameter("coCategory");
        String uniOffer = request.getParameter("uniOffer");
        String senateRef = request.getParameter("senateRef");

        try {
            // Basic validation for the main fields
            if (isBlank(courseCode) || isBlank(courseName) || isBlank(creditStr)) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?err=Please+fill+all+required+fields");
                return;
            }

            int credit = Integer.parseInt(creditStr.trim());
            int examHour = isBlank(examHourStr) ? 0 : Integer.parseInt(examHourStr.trim());

            // 4. Set Attributes using your specific Model methods
            Course c = new Course();
            c.setCourseCode(courseCode.trim().toUpperCase());
            c.setCourseName(courseName.trim());
            c.setCredit(credit);
            c.setExamHour(examHour);
            c.setCore(core);
            c.setCoCategory(coCategory);
            c.setUniOffer(uniOffer);
            c.setOfferPeriod(offerPeriod); // Uses your existing offerPeriod attribute
            c.setSenateRef(senateRef);

            // 5. Save the course
            int newCourseId = courseDAO.createCourse(c);

            if (newCourseId > 0) {
                // Redirect to syllabus info page
                response.sendRedirect(request.getContextPath() + "/admin/course-info?id=" + newCourseId);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/courses?err=Failed+to+create+course");
            }
        } catch (NumberFormatException nfe) {
            response.sendRedirect(request.getContextPath() + "/admin/courses?err=Numbers+required+for+Credit+and+Exam+Hours");
        } catch (Exception e) {
            throw new ServletException("Create course failed", e);
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}


/*
package Controller;

import DAO.CourseDAO;
import Model.Course;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/courses/add")
public class AddCourseServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (role == null || !role.equalsIgnoreCase("Admin")) {
            response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
            return;
        }

        String courseCode = request.getParameter("courseCode");
        String courseName = request.getParameter("courseName");
        String creditsStr = request.getParameter("credits");
        String semester = request.getParameter("semester");

        try {
            // Basic validation
            if (isBlank(courseCode) || isBlank(courseName) || isBlank(creditsStr) || isBlank(semester)) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?err=Please+fill+all+fields");
                return;
            }

            int credits = Integer.parseInt(creditsStr.trim());

            Course c = new Course();
            c.setCourseCode(courseCode.trim().toUpperCase());
            c.setCourseName(courseName.trim());
            c.setCredits(credits);
            c.setSemester(semester.trim());

            // 1. Save the course AND capture the generated ID
            int newCourseId = courseDAO.createCourse(c);

            // 2. Check if it was successful
            if (newCourseId > 0) {
                // Redirect them to the Syllabus Template page to fill in the details immediately
                response.sendRedirect(request.getContextPath() + "/admin/course-info?id=" + newCourseId);
            } else {
                response.sendRedirect(request.getContextPath() + "/admin/courses?err=Failed+to+create+course");
            }
        } catch (NumberFormatException nfe) {
            response.sendRedirect(request.getContextPath() + "/admin/courses?err=Level+and+Credits+must+be+numbers");
        } catch (Exception e) {
            throw new ServletException("Create course failed", e);
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
*/