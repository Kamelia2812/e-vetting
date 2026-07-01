package DAO;

import Model.User;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * UserDAO — all DB operations for the users table.
 *
 * getUserById() was added to support VetterDashboardServlet which needs
 * to fetch individual User objects by ID when building the assignedVetters
 * list for the multi-vetter review panel.
 */
public class UserDAO {

    // ── Authentication ────────────────────────────────────────────────────────

    public boolean emailExists(String email) throws Exception {
        String sql = "SELECT 1 FROM users WHERE email=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            return ps.executeQuery().next();
        }
    }

    public void register(User u) throws Exception {
        // Include phoneNo so the registration form value is persisted.
        String sql = "INSERT INTO users(full_name,email,password_hash,role,phoneNo) VALUES(?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, u.getFullName());
            ps.setString(2, u.getEmail());
            ps.setString(3, u.getPasswordHash());
            ps.setString(4, u.getRole());
            ps.setString(5, u.getPhoneNo() != null ? u.getPhoneNo() : "");
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) u.setUserId(rs.getInt(1));
            }
        }
    }

    public User login(String email, String passwordHash) throws Exception {
        String sql = "SELECT user_id, full_name, email, role FROM users " +
                     "WHERE email=? AND password_hash=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, passwordHash);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
                return null;
            }
        }
    }

    // ── Lookups ───────────────────────────────────────────────────────────────

    /**
     * Returns a single user by their primary key, or null if not found.
     *
     * Added to support VetterDashboardServlet.fetchUsers() which resolves
     * a list of vetter IDs (from course_vetters) into User objects for the
     * per-vetter review panel in vetterDashboard.jsp.
     *
     * @param userId the users.user_id primary key
     * @return the User, or null if the ID does not exist
     */
    public User getUserById(int userId) throws Exception {
        String sql = "SELECT user_id, full_name, email, role " +
                     "FROM users WHERE user_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
                return null;
            }
        }
    }

    public List<User> getAllLecturers() throws Exception {
        String sql = "SELECT user_id, full_name, email, role FROM users " +
                     "WHERE UPPER(role) = 'LECTURER' ORDER BY full_name";
        List<User> list = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    /**
     * Checks whether a lecturer is assigned as the vetter_id on any course.
     * Used by LoginServlet to set the isVetter session flag.
     */
    public boolean isAssignedAsVetter(int userId) throws Exception {
        String sql = "SELECT COUNT(*) FROM course WHERE vetter_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    /**
     * Returns all users whose role matches the given roleName (case-insensitive).
     * Used by KPDashboardServlet to populate the lecturer/vetter dropdowns.
     */
    public List<User> getUsersByRole(String roleName) throws Exception {
        String sql = "SELECT user_id, full_name, email, role FROM users " +
                     "WHERE UPPER(role) = UPPER(?) ORDER BY full_name";
        List<User> users = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) users.add(mapRow(rs));
            }
        }
        return users;
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    /** Maps a ResultSet row to a User. Shared by all query methods. */
    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId  (rs.getInt   ("user_id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail   (rs.getString("email"));
        u.setRole    (rs.getString("role"));
        return u;
    }
}