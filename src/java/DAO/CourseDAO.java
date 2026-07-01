package DAO;

import Model.Course;
import Model.CourseInfo;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * CourseDAO — all DB operations for the course table.
 * Single clean class — no duplicates.
 */
public class CourseDAO {

    // ── Get courses assigned to a specific vetter ────────────────────
    public List<Course> getCoursesByVetterId(int vetterId) throws Exception {
        String sql = "SELECT c.*, l.full_name AS lecturer_name, v.full_name AS vetter_name " +
                     "FROM course c " +
                     "LEFT JOIN users l ON l.user_id = c.lecturer_id " +
                     "LEFT JOIN users v ON v.user_id = c.vetter_id " +
                     "WHERE c.vetter_id = ? ORDER BY c.course_code";
        List<Course> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, vetterId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapCourse(rs));
            }
        }
        return list;
    }

    // ── Get courses assigned to a specific lecturer ──────────────────
    public List<Course> getCoursesByLecturerId(int lecturerId) throws Exception {
        String sql = "SELECT c.*, l.full_name AS lecturer_name, v.full_name AS vetter_name " +
                     "FROM course c " +
                     "JOIN lecturer_courses lc ON lc.course_id = c.course_id " +
                     "LEFT JOIN users l ON l.user_id = c.lecturer_id " +
                     "LEFT JOIN users v ON v.user_id = c.vetter_id " +
                     "WHERE lc.lecturer_id = ? ORDER BY c.course_code";
        List<Course> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, lecturerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapCourse(rs));
            }
        }
        return list;
    }

    // ── Get all courses (for KP view) with lecturer/vetter names ────
    public List<Course> getAllCourses() throws Exception {
        String sql = "SELECT c.*, l.full_name AS lecturer_name, v.full_name AS vetter_name " +
                     "FROM course c " +
                     "LEFT JOIN users l ON l.user_id = c.lecturer_id " +
                     "LEFT JOIN users v ON v.user_id = c.vetter_id " +
                     "ORDER BY c.course_code";
        List<Course> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapCourse(rs));
        }
        return list;
    }

    // ── Get one course by course_code string (e.g. "CSM3401") ───────
    public Course getCourseByCode(String courseCode) throws Exception {
        String sql = "SELECT c.*, l.full_name AS lecturer_name, v.full_name AS vetter_name " +
                     "FROM course c " +
                     "LEFT JOIN users l ON l.user_id = c.lecturer_id " +
                     "LEFT JOIN users v ON v.user_id = c.vetter_id " +
                     "WHERE c.course_code = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, courseCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapCourse(rs);
            }
        }
        return null;
    }

    // ── Get one course by course_id integer ─────────────────────────
    public Course getCourseById(int courseId) throws Exception {
        String sql = "SELECT c.*, l.full_name AS lecturer_name, v.full_name AS vetter_name " +
                     "FROM course c " +
                     "LEFT JOIN users l ON l.user_id = c.lecturer_id " +
                     "LEFT JOIN users v ON v.user_id = c.vetter_id " +
                     "WHERE c.course_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapCourse(rs);
            }
        }
        return null;
    }

    // ── Count all courses ────────────────────────────────────────────
    public int countCourses() throws Exception {
        String sql = "SELECT COUNT(*) FROM course";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ── Create a new course ──────────────────────────────────────────
    public int createCourse(Course c) throws Exception {
        String sql = "INSERT INTO course(course_code, course_name, credit, examHour, " +
                     "core, coCategory, uniOffer, offerPeriod, senateRef, department, faculty) " +
                     "VALUES(?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1,  c.getCourseCode());
            ps.setString(2,  c.getCourseName());
            ps.setInt   (3,  c.getCredit());
            ps.setInt   (4,  c.getExamHour());
            ps.setString(5,  c.getCore());
            ps.setString(6,  c.getCoCategory());
            ps.setString(7,  c.getUniOffer());
            ps.setString(8,  c.getOfferPeriod());
            ps.setString(9,  c.getSenateRef());
            ps.setString(10, c.getDepartment());
            ps.setString(11, c.getFaculty() != null ? c.getFaculty() : "FSKM");
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    // ── Update course details ────────────────────────────────────────
    public void updateCourse(Course c) throws Exception {
        String sql = "UPDATE course SET course_code=?, course_name=?, credit=?, " +
                     "examHour=?, core=?, coCategory=?, uniOffer=?, offerPeriod=?, " +
                     "senateRef=?, department=?, faculty=? WHERE course_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1,  c.getCourseCode());
            ps.setString(2,  c.getCourseName());
            ps.setInt   (3,  c.getCredit());
            ps.setInt   (4,  c.getExamHour());
            ps.setString(5,  c.getCore());
            ps.setString(6,  c.getCoCategory());
            ps.setString(7,  c.getUniOffer());
            ps.setString(8,  c.getOfferPeriod());
            ps.setString(9,  c.getSenateRef());
            ps.setString(10, c.getDepartment());
            ps.setString(11, c.getFaculty() != null ? c.getFaculty() : "FSKM");
            ps.setInt   (12, c.getCourseId());
            ps.executeUpdate();
        }
    }

    // ── Delete course + all FK references ───────────────────────────
    public void deleteCourseCascade(int courseId) throws Exception {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                exec(con, "DELETE FROM lecturer_courses   WHERE course_id=?", courseId);
                exec(con, "DELETE FROM course_assignments WHERE course_id=?", courseId);
                exec(con, "DELETE FROM course             WHERE course_id=?", courseId);
                con.commit();
            } catch (Exception e) {
                con.rollback();
                throw e;
            }
        }
    }

    // ── Assign staff (both at once) ──────────────────────────────────
    public boolean assignStaff(int courseId, int lecturerId, int vetterId) throws Exception {
        String sql = "UPDATE course SET lecturer_id=?, vetter_id=? WHERE course_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (lecturerId > 0) ps.setInt(1, lecturerId); else ps.setNull(1, Types.INTEGER);
            if (vetterId   > 0) ps.setInt(2, vetterId);   else ps.setNull(2, Types.INTEGER);
            ps.setInt(3, courseId);
            return ps.executeUpdate() > 0;
        }
    }

    // ── Assign lecturer to course (updates course + lecturer_courses) ─
    public void assignLecturerToCourse(int courseId, int lecturerId) throws Exception {
        // Update course.lecturer_id
        String sql1 = "UPDATE course SET lecturer_id=? WHERE course_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql1)) {
            if (lecturerId > 0) ps.setInt(1, lecturerId); else ps.setNull(1, Types.INTEGER);
            ps.setInt(2, courseId);
            ps.executeUpdate();
        }
        // Keep lecturer_courses in sync
        if (lecturerId > 0) {
            String sql2 = "INSERT INTO lecturer_courses (lecturer_id, course_id) VALUES (?,?) " +
                          "ON DUPLICATE KEY UPDATE lecturer_id=lecturer_id";
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql2)) {
                ps.setInt(1, lecturerId);
                ps.setInt(2, courseId);
                ps.executeUpdate();
            }
        }
    }

    // ── Assign vetter to course (updates course.vetter_id) ──────────
    public void assignVetterToCourse(int courseId, int vetterId) throws Exception {
        // Update legacy course.vetter_id
        String sql = "UPDATE course SET vetter_id=? WHERE course_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (vetterId > 0) ps.setInt(1, vetterId); else ps.setNull(1, Types.INTEGER);
            ps.setInt(2, courseId);
            ps.executeUpdate();
        }
        // Also update course_vetters table
        List<Integer> ids = new java.util.ArrayList<>();
        if (vetterId > 0) ids.add(vetterId);
        assignVettersToCourse(courseId, ids);
    }

    // ── Assign multiple vetters to course_vetters table ──────────────
    // Backwards-compatible: first vetter in the list becomes the leader.
    public void assignVettersToCourse(int courseId, List<Integer> vetterIds) throws Exception {
        int leader = vetterIds.isEmpty() ? 0 : vetterIds.get(0);
        assignVettersToCourse(courseId, vetterIds, leader);
    }

    // ── Assign a flexible number of vetters; one of them is the leader ─
    public void assignVettersToCourse(int courseId, List<Integer> vetterIds, int leaderId) throws Exception {
        try (Connection con = DBConnection.getConnection()) {
            con.setAutoCommit(false);
            try {
                // Clear existing vetters
                try (PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM course_vetters WHERE course_id=?")) {
                    ps.setInt(1, courseId); ps.executeUpdate();
                }
                // Insert new vetters with leader flag
                if (!vetterIds.isEmpty()) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "INSERT IGNORE INTO course_vetters (vetter_id, course_id, is_leader) VALUES (?,?,?)")) {
                        for (int vId : vetterIds) {
                            if (vId > 0) {
                                ps.setInt(1, vId); ps.setInt(2, courseId);
                                ps.setInt(3, vId == leaderId ? 1 : 0);
                                ps.addBatch();
                            }
                        }
                        ps.executeBatch();
                    }
                    // Update user role to Vetter
                    try (PreparedStatement psRole = con.prepareStatement(
                            "UPDATE users SET role = 'Vetter' WHERE user_id = ? AND role != 'KP'")) {
                        for (int vId : vetterIds) {
                            if (vId > 0) {
                                psRole.setInt(1, vId);
                                psRole.addBatch();
                            }
                        }
                        psRole.executeBatch();
                    }
                }
                // Update legacy vetter_id with the leader (fallback: first vetter)
                int legacy = leaderId > 0 ? leaderId : (vetterIds.isEmpty() ? 0 : vetterIds.get(0));
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE course SET vetter_id=? WHERE course_id=?")) {
                    if (legacy > 0) ps.setInt(1, legacy); else ps.setNull(1, Types.INTEGER);
                    ps.setInt(2, courseId); ps.executeUpdate();
                }
                con.commit();
            } catch (Exception e) { con.rollback(); throw e; }
        }
    }

    // ── Get all vetter IDs assigned to a course (leader first) ───────
    public List<Integer> getVetterIdsByCourseId(int courseId) throws Exception {
        String sql = "SELECT vetter_id FROM course_vetters WHERE course_id=? ORDER BY is_leader DESC, id";
        List<Integer> ids = new java.util.ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) ids.add(rs.getInt("vetter_id"));
            }
        }
        return ids;
    }

    // ── Synopsis: save/update the short course brief ─────────────────
    public void upsertSynopsis(int courseId, String synopsis) throws Exception {
        String sql = "INSERT INTO course_information (course_id, synopsis) VALUES (?,?) "
                   + "ON DUPLICATE KEY UPDATE synopsis = VALUES(synopsis)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            ps.setString(2, synopsis);
            ps.executeUpdate();
        }
    }

    // ── Synopsis: courseId -> synopsis map for list views ────────────
    public java.util.Map<Integer,String> getSynopsisMap() throws Exception {
        java.util.Map<Integer,String> map = new java.util.HashMap<>();
        String sql = "SELECT course_id, synopsis FROM course_information WHERE synopsis IS NOT NULL AND synopsis <> ''";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) map.put(rs.getInt("course_id"), rs.getString("synopsis"));
        }
        return map;
    }

    // ── Get the leader vetter ID for a course (0 if none) ────────────
    public int getLeaderIdByCourseId(int courseId) throws Exception {
        String sql = "SELECT vetter_id FROM course_vetters WHERE course_id=? AND is_leader=1 LIMIT 1";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("vetter_id") : 0;
            }
        }
    }

    // ── Syllabus: get course info ────────────────────────────────────
    public CourseInfo getCourseInfo(int courseId) throws Exception {
        String sql = "SELECT * FROM course_information WHERE course_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                CourseInfo ci = new CourseInfo();
                ci.setCourseId          (rs.getInt   ("course_id"));
                ci.setAcademicStaff     (rs.getString("academic_staff"));
                ci.setClassification    (rs.getString("classification"));
                ci.setPreRequisites     (rs.getString("pre_requisites"));
                ci.setSynopsis          (rs.getString("synopsis"));
                ci.setTransferableSkills(rs.getString("transferable_skills"));
                ci.setSpecialRequirements(rs.getString("special_requirements"));
                ci.setCreditRemarks     (rs.getString("credit_remarks"));
                ci.setYearRemarks       (rs.getString("year_remarks"));
                ci.setSemesterRemarks   (rs.getString("semester_remarks"));
                ci.setCaF2f  (rs.getDouble("ca_f2f"));
                ci.setCaNf2f (rs.getDouble("ca_nf2f"));
                ci.setFaF2f  (rs.getDouble("fa_f2f"));
                ci.setFaNf2f (rs.getDouble("fa_nf2f"));
                return ci;
            }
        }
    }

    // ── Syllabus: save course info ───────────────────────────────────
    public boolean saveCourseInfo(CourseInfo info) throws Exception {
        String sql = "INSERT INTO course_information " +
                     "(course_id, academic_staff, classification, pre_requisites, synopsis, " +
                     "transferable_skills, special_requirements, credit_remarks, year_remarks, " +
                     "semester_remarks, ca_f2f, ca_nf2f, fa_f2f, fa_nf2f) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?) " +
                     "ON DUPLICATE KEY UPDATE " +
                     "academic_staff=VALUES(academic_staff), classification=VALUES(classification), " +
                     "pre_requisites=VALUES(pre_requisites), synopsis=VALUES(synopsis), " +
                     "transferable_skills=VALUES(transferable_skills), " +
                     "special_requirements=VALUES(special_requirements), " +
                     "credit_remarks=VALUES(credit_remarks), year_remarks=VALUES(year_remarks), " +
                     "semester_remarks=VALUES(semester_remarks), " +
                     "ca_f2f=VALUES(ca_f2f), ca_nf2f=VALUES(ca_nf2f), " +
                     "fa_f2f=VALUES(fa_f2f), fa_nf2f=VALUES(fa_nf2f)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt   (1,  info.getCourseId());
            ps.setString(2,  info.getAcademicStaff());
            ps.setString(3,  info.getClassification());
            ps.setString(4,  info.getPreRequisites());
            ps.setString(5,  info.getSynopsis());
            ps.setString(6,  info.getTransferableSkills());
            ps.setString(7,  info.getSpecialRequirements());
            ps.setString(8,  info.getCreditRemarks());
            ps.setString(9,  info.getYearRemarks());
            ps.setString(10, info.getSemesterRemarks());
            ps.setDouble(11, info.getCaF2f());
            ps.setDouble(12, info.getCaNf2f());
            ps.setDouble(13, info.getFaF2f());
            ps.setDouble(14, info.getFaNf2f());
            return ps.executeUpdate() > 0;
        }
    }

    // ── Syllabus: clear CLOs and SLTs before re-saving ──────────────
    public void clearDynamicData(int courseId) throws Exception {
        try (Connection con = DBConnection.getConnection()) {
            exec(con, "DELETE FROM course_clos WHERE course_id=?", courseId);
            exec(con, "DELETE FROM course_slt  WHERE course_id=?", courseId);
        }
    }

    // ── Syllabus: save one CLO row ───────────────────────────────────
    public void saveCLO(int courseId, String desc, int[] plos, String teaching, String assessment) throws Exception {
        String sql = "INSERT INTO course_clos " +
                     "(course_id, description, plo1,plo2,plo3,plo4,plo5,plo6,plo7,plo8,plo9,plo10,plo11, " +
                     "teaching_methods, assessment_methods) " +
                     "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt   (1,  courseId);
            ps.setString(2,  desc);
            for (int i = 0; i < 11; i++) ps.setInt(3 + i, plos.length > i ? plos[i] : 0);
            ps.setString(14, teaching);
            ps.setString(15, assessment);
            ps.executeUpdate();
        }
    }

    // ── Syllabus: save one SLT row ───────────────────────────────────
    public void saveSLT(int courseId, String topic, double l, double t, double p, double o, double nf2f)
            throws Exception {
        String sql = "INSERT INTO course_slt (course_id, topic_name, l, t, p, o, nf2f) VALUES (?,?,?,?,?,?,?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt   (1, courseId);
            ps.setString(2, topic);
            ps.setDouble(3, l);
            ps.setDouble(4, t);
            ps.setDouble(5, p);
            ps.setDouble(6, o);
            ps.setDouble(7, nf2f);
            ps.executeUpdate();
        }
    }

    // ── Map ResultSet row → Course object ────────────────────────────
    private Course mapCourse(ResultSet rs) throws SQLException {
        Course c = new Course();
        c.setCourseId  (rs.getInt   ("course_id"));
        c.setCourseCode(rs.getString("course_code"));
        c.setCourseName(rs.getString("course_name"));
        c.setCredit    (rs.getInt   ("credit"));
        c.setExamHour  (rs.getInt   ("examHour"));
        c.setCore      (rs.getString("core"));
        c.setCoCategory(rs.getString("coCategory"));
        c.setUniOffer  (rs.getString("uniOffer"));
        c.setOfferPeriod(rs.getString("offerPeriod"));
        c.setSenateRef (rs.getString("senateRef"));
        // New fields
        try { c.setDepartment(rs.getString("department")); } catch (SQLException ignored) {}
        try { c.setFaculty   (rs.getString("faculty"));    } catch (SQLException ignored) {}
        // lecturer_id and vetter_id — nullable
        int lid = rs.getInt("lecturer_id");
        if (!rs.wasNull()) c.setLecturerId(lid);
        int vid = rs.getInt("vetter_id");
        if (!rs.wasNull()) c.setVetterId(vid);
        // JOIN fields — may be null if not assigned
        try { c.setLecturerName(rs.getString("lecturer_name")); } catch (SQLException ignored) {}
        try { c.setVetterName  (rs.getString("vetter_name"));   } catch (SQLException ignored) {}
        return c;
    }

    // ── Helper: execute a simple int-param statement ─────────────────
    private void exec(Connection con, String sql, int param) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, param);
            ps.executeUpdate();
        }
    }
}