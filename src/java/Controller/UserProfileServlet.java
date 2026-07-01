package Controller;

import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

/**
 * UserProfileServlet
 *
 * GET  /UserProfileServlet   — display current user's profile
 * POST /UserProfileServlet   — save changes (phone, faculty, position_title)
 */
@WebServlet("/UserProfileServlet")
public class UserProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        loadProfile(userId, req);
        req.getRequestDispatcher("/userProfile.jsp").forward(req, res);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");

        String phone    = trim(req.getParameter("phone"));
        String faculty  = trim(req.getParameter("faculty"));
        String position = trim(req.getParameter("position"));

        String sql = "UPDATE users SET phoneNo = ?, faculty = ?, position_title = ? WHERE user_id = ?";
        boolean ok = false;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setString(2, faculty);
            ps.setString(3, position);
            ps.setInt(4, userId);
            ok = ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        res.sendRedirect(req.getContextPath() + "/UserProfileServlet?saved=" + (ok ? "true" : "false"));
    }

    // ── Load user row and set request attributes ──────────────────────────────
    private void loadProfile(int userId, HttpServletRequest req) {
        String sql = "SELECT full_name, email, phoneNo, faculty, position_title, role FROM users WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String role = rs.getString("role");
                    boolean isLeader = isVettingLeader(userId);
                    String displayRole = (isLeader && "Vetter".equalsIgnoreCase(role)) ? "Vetting Leader" : role;
                    String position = rs.getString("position_title");
                    if (isLeader && "Vetter".equalsIgnoreCase(role)) {
                        position = "Vetting Leader";
                    }

                    req.setAttribute("pFullName",  rs.getString("full_name"));
                    req.setAttribute("pEmail",     rs.getString("email"));
                    req.setAttribute("pPhone",     rs.getString("phoneNo"));
                    req.setAttribute("pFaculty",   rs.getString("faculty"));
                    req.setAttribute("pPosition",  position);
                    req.setAttribute("pRole",      displayRole);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private boolean isVettingLeader(int userId) {
        String sql = "SELECT COUNT(*) FROM course_vetters WHERE vetter_id = ? AND is_leader = 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            return false;
        }
    }

    private String trim(String s) {
        return s != null ? s.trim() : "";
    }
}
