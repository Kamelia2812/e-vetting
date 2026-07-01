/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Controller;

import DAO.CourseDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/courses/delete")
public class DeleteCourseServlet extends HttpServlet {

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

        try {
            if (idStr == null || idStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?err=Missing+course+id");
                return;
            }

            int id = Integer.parseInt(idStr.trim());

            courseDAO.deleteCourseCascade(id);

            response.sendRedirect(request.getContextPath() + "/admin/courses?success=deleted");
        } catch (Exception e) {
            throw new ServletException("Delete course failed", e);
        }
    }
}

