package DAO;

import Model.Assessment;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * AssessmentDAO — all database operations for 'exam_papers' table.
 *
 * Used by:
 *   LecturerDashboardServlet — to show the lecturer's paper list and status counts
 *   NewPaperServlet          — to create/save a new exam paper
 *   VetterDashboardServlet   — to fetch submitted papers for review
 */
public class AssessmentDAO {

    // ─────────────────────────────────────────────────────────────────
    // LECTURER — get all papers belonging to a specific lecturer
    // Used by lecturerDashboard to populate the assessment table
    // ─────────────────────────────────────────────────────────────────
    public List<Assessment> getAssessmentsByLecturerId(int lecturerId) throws Exception {
        String sql = "SELECT * FROM exam_papers "
                   + "WHERE lecturer_id = ? "
                   + "ORDER BY created_at DESC";

        List<Assessment> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, lecturerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAssessment(rs));
                }
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────
    // LECTURER — count papers by status (for dashboard stat cards)
    // Returns how many are DRAFT, SUBMITTED, APPROVED, REJECTED
    // ─────────────────────────────────────────────────────────────────
    public int countByLecturerAndStatus(int lecturerId, String status) throws Exception {
        String sql = "SELECT COUNT(*) FROM exam_papers "
                   + "WHERE lecturer_id = ? AND status = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, lecturerId);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    public int countByLecturerAndStatuses(int lecturerId, String... statuses) throws Exception {
        if (statuses == null || statuses.length == 0) return 0;
        StringBuilder placeholders = new StringBuilder("?");
        for (int i = 1; i < statuses.length; i++) placeholders.append(",?");
        String sql = "SELECT COUNT(*) FROM exam_papers WHERE lecturer_id = ? AND status IN (" + placeholders + ")";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, lecturerId);
            for (int i = 0; i < statuses.length; i++) ps.setString(i + 2, statuses[i]);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // SINGLE — get one paper by its ID
    // Used by examPaper.jsp to load an existing draft for editing
    // ─────────────────────────────────────────────────────────────────
    public Assessment getAssessmentById(int paperId) throws Exception {
        String sql = "SELECT * FROM exam_papers WHERE paper_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapAssessment(rs) : null;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // CREATE — insert a brand new exam paper (status = DRAFT)
    // Called when lecturer starts a new paper
    // ─────────────────────────────────────────────────────────────────
    public int createAssessment(Assessment a) throws Exception {
        // Only insert columns that actually exist in exam_papers.
        // instructions/weightage/submission_mode/assign_marks are for
        // continuous assessments and do not exist in the current schema.
        String sql = "INSERT INTO exam_papers "
                   + "(course_code, course_title, faculty, lecturer_id, paper_type, "
                   + " academic_session, semester, deadline, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'DRAFT')";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, a.getCourseCode());
            ps.setString(2, a.getCourseTitle() != null ? a.getCourseTitle() : "");
            ps.setString(3, a.getFaculty()     != null ? a.getFaculty()     : "FSKM");
            ps.setInt   (4, a.getLecturerId());
            ps.setString(5, a.getPaperType()   != null ? a.getPaperType()   : "Final Examination");
            ps.setString(6, a.getAcademicSession());
            ps.setInt   (7, a.getSemester());
            ps.setString(8, a.getDeadline());
            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // SUBMIT — change status from DRAFT/REJECTED/NEEDS_IMPROVEMENT to SUBMITTED
    // ─────────────────────────────────────────────────────────────────
    public boolean submitAssessment(int paperId, int lecturerId) throws Exception {
        String sql = "UPDATE exam_papers "
                   + "SET status = 'SUBMITTED', submitted_date = NOW(), updated_at = NOW() "
                   + "WHERE paper_id = ? AND lecturer_id = ? "
                   + "AND status IN ('DRAFT', 'REJECTED', 'NEEDS_IMPROVEMENT')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId);
            ps.setInt(2, lecturerId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // SUBMIT TO LEADER — change APPROVED to PENDING_LEADER_SIGN
    // ─────────────────────────────────────────────────────────────────
    public boolean submitToLeader(int paperId, int lecturerId) throws Exception {
        String sql = "UPDATE exam_papers SET status='PENDING_LEADER_SIGN', updated_at=NOW() "
                   + "WHERE paper_id=? AND lecturer_id=? AND status IN ('APPROVED','NEEDS_IMPROVEMENT')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId); ps.setInt(2, lecturerId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // VETTER — get all papers that need review (SUBMITTED or UNDER_REVIEW)
    // Used by vetterDashboard
    // ─────────────────────────────────────────────────────────────────
    public List<Assessment> getPendingForVetter() throws Exception {
        String sql = "SELECT ep.* FROM exam_papers ep "
                   + "INNER JOIN course c ON c.course_code COLLATE utf8mb4_unicode_ci = ep.course_code COLLATE utf8mb4_unicode_ci "
                   + "WHERE ep.status IN ('SUBMITTED','UNDER_REVIEW') "
                   + "ORDER BY ep.submitted_date ASC";
        List<Assessment> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapAssessment(rs));
        }
        return list;
    }

    // Filtered by specific vetter (uses course.vetter_id)
    public List<Assessment> getPendingForVetter(int vetterId) throws Exception {
        String sql = "SELECT ep.* FROM exam_papers ep "
                   + "INNER JOIN course c ON c.course_code COLLATE utf8mb4_unicode_ci = ep.course_code COLLATE utf8mb4_unicode_ci "
                   + "WHERE c.vetter_id = ? "
                   + "AND ep.status IN ('SUBMITTED','UNDER_REVIEW') "
                   + "ORDER BY ep.submitted_date ASC";
        List<Assessment> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, vetterId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapAssessment(rs));
            }
        }
        return list;
    }

    // Papers awaiting leader vetter's signature (for leader vetter queue)
    public List<Assessment> getPendingLeaderSign(int leaderId) throws Exception {
        // Primary: course_vetters.is_leader
        try {
            String sql = "SELECT ep.* FROM exam_papers ep "
                       + "INNER JOIN course c ON c.course_code COLLATE utf8mb4_unicode_ci = ep.course_code COLLATE utf8mb4_unicode_ci "
                       + "INNER JOIN course_vetters cv ON cv.course_id = c.course_id "
                       + "WHERE cv.vetter_id = ? AND cv.is_leader = 1 "
                       + "AND ep.status IN ('PENDING_LEADER_SIGN','LEADER_APPROVED') "
                       + "ORDER BY ep.updated_at ASC";
            List<Assessment> list = new ArrayList<>();
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, leaderId);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) list.add(mapAssessment(rs));
                }
            }
            if (!list.isEmpty()) return list;
        } catch (Exception ignored) {}
        // Fallback: any vetter assigned via course.vetter_id
        String sql2 = "SELECT ep.* FROM exam_papers ep "
                    + "INNER JOIN course c ON c.course_code COLLATE utf8mb4_unicode_ci = ep.course_code COLLATE utf8mb4_unicode_ci "
                    + "WHERE c.vetter_id = ? "
                    + "AND ep.status IN ('PENDING_LEADER_SIGN','LEADER_APPROVED') "
                    + "ORDER BY ep.updated_at ASC";
        List<Assessment> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql2)) {
            ps.setInt(1, leaderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapAssessment(rs));
            }
        }
        return list;
    }

    // Papers awaiting leader vetter's final submission to KP (LEADER_APPROVED)
    public List<Assessment> getLeaderApproved(int leaderId) throws Exception {
        String sql = "SELECT ep.* FROM exam_papers ep "
                   + "INNER JOIN course c ON c.course_code COLLATE utf8mb4_unicode_ci = ep.course_code COLLATE utf8mb4_unicode_ci "
                   + "INNER JOIN course_vetters cv ON cv.course_id = c.course_id "
                   + "WHERE cv.vetter_id = ? AND cv.is_leader = 1 "
                   + "AND ep.status = 'LEADER_APPROVED' "
                   + "ORDER BY ep.updated_at ASC";
        List<Assessment> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, leaderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapAssessment(rs));
            }
        }
        return list;
    }

    // Papers already reviewed by this vetter
    public List<Assessment> getReviewedByVetter(int vetterId) throws Exception {
        String sql = "SELECT ep.* FROM exam_papers ep "
                   + "INNER JOIN course c ON c.course_code COLLATE utf8mb4_unicode_ci = ep.course_code COLLATE utf8mb4_unicode_ci "
                   + "WHERE c.vetter_id = ? "
                   + "AND ep.status IN ('APPROVED','REJECTED','NEEDS_IMPROVEMENT','PENDING_LEADER_SIGN','LEADER_APPROVED','SENT_TO_FAKULTI') "
                   + "ORDER BY ep.updated_at DESC";
        List<Assessment> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, vetterId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapAssessment(rs));
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────
    // VETTER — approve or reject a paper
    // Called by VetterDashboardServlet
    // ─────────────────────────────────────────────────────────────────
    public boolean updateStatus(int paperId, String newStatus, String remarks) throws Exception {
        String sql = "UPDATE exam_papers "
                   + "SET status = ?, remarks = ?, updated_at = NOW() "
                   + "WHERE paper_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, newStatus);
            ps.setString(2, remarks);
            ps.setInt(3, paperId);
            return ps.executeUpdate() > 0;
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // MAPPER — converts a ResultSet row into an Assessment Java object
    // ─────────────────────────────────────────────────────────────────
    private Assessment mapAssessment(ResultSet rs) throws SQLException {
        Assessment a = new Assessment();
        a.setPaperId        (rs.getInt      ("paper_id"));
        a.setCourseCode     (rs.getString   ("course_code"));
        a.setCourseTitle    (rs.getString   ("course_title"));
        a.setFaculty        (rs.getString   ("faculty"));
        a.setLecturerId     (rs.getInt      ("lecturer_id"));
        a.setKetuaPanelId   ((Integer) rs.getObject("ketua_panel_id"));
        a.setKetuaProgramId ((Integer) rs.getObject("ketua_program_id"));
        a.setPaperType      (rs.getString   ("paper_type"));
        a.setAcademicSession(rs.getString   ("academic_session"));
        a.setSemester       (rs.getInt      ("semester"));
        a.setTotalQuestions (rs.getInt      ("total_questions"));
        a.setVettedQuestions(rs.getInt      ("vetted_questions"));
        a.setStatus         (rs.getString   ("status"));
        a.setSubmittedDate  (rs.getTimestamp("submitted_date"));
        a.setDeadline       (rs.getString   ("deadline"));
        a.setRemarks        (rs.getString   ("remarks"));
        a.setCreatedAt      (rs.getTimestamp("created_at"));
        a.setUpdatedAt      (rs.getTimestamp("updated_at"));
        // Assignment fields — safe read (null if column not present yet)
        try { a.setInstructions (rs.getString("instructions"));  } catch (SQLException ignored) {}
        try { a.setWeightage    (rs.getDouble("weightage"));     } catch (SQLException ignored) {}
        try { a.setSubmissionMode(rs.getString("submission_mode")); } catch (SQLException ignored) {}
        try { a.setAssignMarks  (rs.getInt   ("assign_marks")); } catch (SQLException ignored) {}
        return a;
    }

    // ── Count all papers with a specific status (for KP dashboard) ────
    public int countByStatus(String status) throws Exception {
        String sql = "SELECT COUNT(*) FROM exam_papers WHERE status = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // Get ALL non-DRAFT papers for KP oversight (with lecturer + vetter name)
    public List<Assessment> getAllPackagesForKP() throws Exception {
        String sql = "SELECT ep.*, "
                   + "  u.full_name  AS lecturer_name, "
                   + "  v.full_name  AS vetter_name "
                   + "FROM exam_papers ep "
                   + "LEFT JOIN users u ON u.user_id = ep.lecturer_id "
                   + "LEFT JOIN course c ON c.course_code COLLATE utf8mb4_unicode_ci = ep.course_code COLLATE utf8mb4_unicode_ci "
                   + "LEFT JOIN users v ON v.user_id = c.vetter_id "
                   + "WHERE ep.status <> 'DRAFT' "
                   + "ORDER BY ep.submitted_date DESC";
        List<Assessment> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Assessment a = mapAssessment(rs);
                try { a.setLecturerName(rs.getString("lecturer_name")); } catch (Exception ignored) {}
                try { a.setVetterName(rs.getString("vetter_name")); } catch (Exception ignored) {}
                list.add(a);
            }
        }
        return list;
    }

    // ── Get papers matching any of the given statuses ─────────────────────────
    public List<Assessment> getAssessmentsByStatuses(String[] statuses) throws Exception {
        if (statuses == null || statuses.length == 0) return new ArrayList<>();
        StringBuilder sb = new StringBuilder(
            "SELECT ep.*, u.full_name AS lecturer_name "
          + "FROM exam_papers ep LEFT JOIN users u ON u.user_id = ep.lecturer_id WHERE ep.status IN (");
        for (int i = 0; i < statuses.length; i++) { sb.append(i > 0 ? ",?" : "?"); }
        sb.append(") ORDER BY ep.updated_at DESC");
        List<Assessment> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sb.toString())) {
            for (int i = 0; i < statuses.length; i++) ps.setString(i + 1, statuses[i]);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Assessment a = mapAssessment(rs);
                    try { a.setLecturerName(rs.getString("lecturer_name")); } catch (Exception ignored) {}
                    list.add(a);
                }
            }
        }
        return list;
    }

    // ── Get all papers with a specific status (for KP dashboard, with names) ─────
    public List<Assessment> getAssessmentsByStatus(String status) throws Exception {
        String sql = "SELECT ep.*, u.full_name AS lecturer_name "
                   + "FROM exam_papers ep LEFT JOIN users u ON u.user_id = ep.lecturer_id "
                   + "WHERE ep.status = ? ORDER BY ep.updated_at DESC";
        List<Assessment> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Assessment a = mapAssessment(rs);
                    try { a.setLecturerName(rs.getString("lecturer_name")); } catch (Exception ignored) {}
                    list.add(a);
                }
            }
        }
        return list;
    }
}