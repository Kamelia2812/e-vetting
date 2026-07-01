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

@WebServlet("/admin/courses/update")
public class UpdateCourseServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // 1. UPDATED ROLE CHECK: Change "Admin" to "KP"
        String role = (String) session.getAttribute("role");
        if (role == null || !role.equalsIgnoreCase("KP")) {
            response.sendRedirect(request.getContextPath() + "/unauthorized.jsp");
            return;
        }

        // 2. GET PARAMETERS: Match your specific Course attributes
        String idStr = request.getParameter("courseId");
        String code = request.getParameter("courseCode");
        String name = request.getParameter("courseName");
        String creditStr = request.getParameter("credit"); // Match your model
        String examHourStr = request.getParameter("examHour");
        String core = request.getParameter("core");
        String coCategory = request.getParameter("coCategory");
        String uniOffer = request.getParameter("uniOffer");
        String offerPeriod = request.getParameter("offerPeriod");
        String senateRef = request.getParameter("senateRef");

        try {
            // Validation (simplified)
            if (isBlank(idStr) || isBlank(code) || isBlank(name)) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?err=Required+fields+missing");
                return;
            }

            int id = Integer.parseInt(idStr.trim());
            int credit = Integer.parseInt(creditStr.trim());
            int examHour = Integer.parseInt(examHourStr.trim());

            // 3. SET ATTRIBUTES: Using your exact attribute names
            Course c = new Course();
            c.setCourseId(id);
            c.setCourseCode(code.trim().toUpperCase());
            c.setCourseName(name.trim());
            c.setCredit(credit);
            c.setExamHour(examHour);
            c.setCore(core);
            c.setCoCategory(coCategory);
            c.setUniOffer(uniOffer);
            c.setOfferPeriod(offerPeriod);
            c.setSenateRef(senateRef);

            // semester is GONE because it isn't in your model
            
            courseDAO.updateCourse(c);

            response.sendRedirect(request.getContextPath() + "/admin/courses?success=updated");
        } catch (NumberFormatException nfe) {
            response.sendRedirect(request.getContextPath() + "/admin/courses?err=Invalid+number+format");
        } catch (Exception e) {
            throw new ServletException("Update course failed", e);
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}



/*package Controller;

import DAO.CourseDAO;
import Model.Course;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/courses/update")
public class UpdateCourseServlet extends HttpServlet {

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

        String idStr = request.getParameter("courseId");
        String code = request.getParameter("courseCode");
        String name = request.getParameter("courseName");
        String creditsStr = request.getParameter("credits");
        String semester = request.getParameter("semester");

        try {
            if (isBlank(idStr) || isBlank(code) || isBlank(name) || isBlank(creditsStr) || isBlank(semester)) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?err=Please+fill+all+fields");
                return;
            }

            int id = Integer.parseInt(idStr.trim());
            int credits = Integer.parseInt(creditsStr.trim());

            Course c = new Course();
            c.setCourseId(id);
            c.setCourseCode(code.trim().toUpperCase());
            c.setCourseName(name.trim());
            c.setCredits(credits);
            c.setSemester(semester.trim());

            courseDAO.updateCourse(c);

            response.sendRedirect(request.getContextPath() + "/admin/courses?success=updated");
        } catch (NumberFormatException nfe) {
            response.sendRedirect(request.getContextPath() + "/admin/courses?err=Credits+must+be+a+number");
        } catch (Exception e) {
            throw new ServletException("Update course failed", e);
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
*/
