package Controller;

import DAO.UserDAO;
import Model.User;
import util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLIntegrityConstraintViolationException;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phoneNo = request.getParameter("phoneNo");
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");
        String role = request.getParameter("role");

        try {
            // ── Validation ───────────────────────────────────────────
            if (isBlank(fullName) || isBlank(email) || isBlank(password)
                    || isBlank(confirm) || isBlank(role)) {
                request.setAttribute("error", "Please fill in all fields.");
                request.getRequestDispatcher("/signup.jsp").forward(request, response);
                return;
            }

            if (!password.equals(confirm)) {
                request.setAttribute("error", "Password and Confirm Password do not match.");
                request.getRequestDispatcher("/signup.jsp").forward(request, response);
                return;
            }

            if (phoneNo != null && !phoneNo.trim().isEmpty()) {
                if (!phoneNo.matches("^\\+?[0-9]{10,15}$")) {
                    request.setAttribute("error", "Invalid phone number. Use 10-15 digits.");
                    request.getRequestDispatcher("/signup.jsp").forward(request, response);
                    return;
                }
            }

            // Check if email already exists
            if (userDAO.emailExists(email.trim().toLowerCase())) {
                request.setAttribute("error", "Email already registered. Please login.");
                request.getRequestDispatcher("/signup.jsp").forward(request, response);
                return;
            }

            // ── Build user and register ───────────────────────────────
            User u = new User();
            u.setFullName(fullName.trim());
            u.setEmail(email.trim().toLowerCase());
            u.setRole(role.trim());
            u.setPhoneNo(phoneNo != null ? phoneNo.trim() : "");
            u.setPasswordHash(PasswordUtil.sha256(password));

            userDAO.register(u);

            // ── Success: redirect to login ────────────────────────────
            response.sendRedirect(request.getContextPath() + "/login.jsp?registered=1");

        } catch (SQLIntegrityConstraintViolationException e) {
            // Catch duplicate email at DB level as a safety net
            request.setAttribute("error", "Email already registered. Please login.");
            request.getRequestDispatcher("/signup.jsp").forward(request, response);
        } catch (Exception e) {
            throw new ServletException("Registration failed", e);
        }
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}
