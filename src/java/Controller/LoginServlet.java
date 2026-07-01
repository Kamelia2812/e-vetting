package Controller;

import DAO.UserDAO;
import Model.User;
import util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email    = request.getParameter("email");
        String password = request.getParameter("password");
        String role     = request.getParameter("role");

        try {
            // Basic validation
            if (email == null || password == null
                    || email.trim().isEmpty() || password.trim().isEmpty()) {
                request.setAttribute("error", "Please enter email and password.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            String hash = PasswordUtil.sha256(password);
            User u = userDAO.login(email.trim().toLowerCase(), hash);

            if (u == null) {
                request.setAttribute("error", "Invalid email or password.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // Optional: enforce role selected on login page
            if (role != null && !role.trim().isEmpty() && u.getRole() != null
                    && !u.getRole().equalsIgnoreCase(role.trim())) {
                request.setAttribute("error", "Role does not match this account.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            // ── Create session ────────────────────────────────────────
            HttpSession session = request.getSession(true);
            session.setAttribute("userId",       u.getUserId());
            session.setAttribute("fullName",      u.getFullName());   // used by all dashboards
            session.setAttribute("userFullName",  u.getFullName());   // kept for backward compat
            session.setAttribute("email",         u.getEmail());
            session.setAttribute("role",          u.getRole());

            // Avatar initial
            String initial = (u.getFullName() != null && !u.getFullName().trim().isEmpty())
                    ? String.valueOf(Character.toUpperCase(u.getFullName().trim().charAt(0)))
                    : "U";
            session.setAttribute("userInitial", initial);

            // ── Check if lecturer is also assigned as a vetter on any course ──
            String userRole = u.getRole() == null ? "" : u.getRole().trim();
            if (userRole.equalsIgnoreCase("vetter")) {
                session.setAttribute("isVetter", true);
            } else if (userRole.equalsIgnoreCase("lecturer")) {
                try {
                    boolean isVetter = userDAO.isAssignedAsVetter(u.getUserId());
                    session.setAttribute("isVetter", isVetter);
                } catch (Exception ex) {
                    session.setAttribute("isVetter", false);
                }
            }

            // ── Redirect by role ──────────────────────────────────────
            if (userRole.equalsIgnoreCase("lecturer")) {
                // If also a vetter, go to vetter dashboard
                Boolean isVetter = (Boolean) session.getAttribute("isVetter");
                if (Boolean.TRUE.equals(isVetter)) {
                    response.sendRedirect(request.getContextPath() + "/VetterDashboardServlet");
                } else {
                    response.sendRedirect(request.getContextPath() + "/LecturerDashboardServlet");
                }

            } else if (userRole.equalsIgnoreCase("vetter")) {
                response.sendRedirect(request.getContextPath() + "/VetterDashboardServlet");

            } else if (userRole.equalsIgnoreCase("kp")) {
                response.sendRedirect(request.getContextPath() + "/KPDashboardServlet");

            } else {
                request.setAttribute("error", "Unknown role: " + userRole + ". Contact admin.");
                request.getRequestDispatcher("/login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            throw new ServletException("Login failed", e);
        }
    }
}