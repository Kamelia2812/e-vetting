package DAO;

import Model.JSS;
import Model.JSSRow;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import util.DBConnection;

/**
 * JSSDAO — all DB operations for jss and jss_rows tables.
 */
public class JSSDAO {

    public JSS getJSSByPaperId(int paperId) throws Exception {
        String sql = "SELECT * FROM jss WHERE paper_id = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                JSS jss = mapJSS(rs);
                jss.setRows(getRowsByJssId(jss.getJssId()));
                return jss;
            }
        }
        return null;
    }

    public JSS getJSSById(int jssId) throws Exception {
        String sql = "SELECT * FROM jss WHERE jss_id = ?";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, jssId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                JSS jss = mapJSS(rs);
                jss.setRows(getRowsByJssId(jssId));
                return jss;
            }
        }
        return null;
    }

    public List<JSSRow> getRowsByJssId(int jssId) throws Exception {
        List<JSSRow> list = new ArrayList<>();
        String sql = "SELECT * FROM jss_rows WHERE jss_id = ? ORDER BY row_order";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, jssId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public int createJSS(JSS jss) throws Exception {
        String sql = "INSERT INTO jss (paper_id, course_id, lecturer_id, faculty, "
                + "programme, academic_session, semester, assessment_type) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, jss.getPaperId());
            ps.setInt(2, jss.getCourseId());
            ps.setInt(3, jss.getLecturerId());
            ps.setString(4, jss.getFaculty() != null ? jss.getFaculty() : "FSKM");
            ps.setString(5, jss.getProgramme());
            ps.setString(6, jss.getAcademicSession());
            ps.setInt(7, jss.getSemester());
            ps.setString(8, jss.getAssessmentType());
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                return keys.getInt(1);
            }
        }
        throw new Exception("createJSS failed.");
    }

    // Delete all rows then re-insert — simpler than tracking individual updates
    public void saveRows(int jssId, List<JSSRow> rows) throws Exception {
        try (Connection con = DBConnection.getConnection()) {
            // Delete existing rows
            PreparedStatement del = con.prepareStatement("DELETE FROM jss_rows WHERE jss_id = ?");
            del.setInt(1, jssId);
            del.executeUpdate();

            if (rows == null || rows.isEmpty()) {
                return;
            }

            // Insert fresh rows in one batch
            String ins = "INSERT INTO jss_rows (jss_id, row_order, topic_name, lecture_hours, "
                    + "question_no, plo, clo, question_type, marks, taxonomy_level) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement ps = con.prepareStatement(ins);
            for (int i = 0; i < rows.size(); i++) {
                JSSRow r = rows.get(i);
                ps.setInt(1, jssId);
                ps.setInt(2, i);
                ps.setString(3, r.getTopicName());
                ps.setDouble(4, r.getLectureHours());
                ps.setString(5, r.getQuestionNo());
                ps.setString(6, r.getPlo());
                ps.setString(7, r.getClo());
                ps.setString(8, r.getQuestionType());
                ps.setInt(9, r.getMarks());
                ps.setString(10, r.getTaxonomyLevel());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private JSS mapJSS(ResultSet rs) throws SQLException {
        JSS j = new JSS();
        j.setJssId(rs.getInt("jss_id"));
        j.setPaperId(rs.getInt("paper_id"));
        j.setCourseId(rs.getInt("course_id"));
        j.setLecturerId(rs.getInt("lecturer_id"));
        j.setFaculty(rs.getString("faculty"));
        j.setProgramme(rs.getString("programme"));
        j.setAcademicSession(rs.getString("academic_session"));
        j.setSemester(rs.getInt("semester"));
        j.setAssessmentType(rs.getString("assessment_type"));
        j.setCreatedAt(rs.getTimestamp("created_at"));
        j.setUpdatedAt(rs.getTimestamp("updated_at"));
        return j;
    }

    private JSSRow mapRow(ResultSet rs) throws SQLException {
        JSSRow r = new JSSRow();
        r.setRowId(rs.getInt("row_id"));
        r.setJssId(rs.getInt("jss_id"));
        r.setRowOrder(rs.getInt("row_order"));
        r.setTopicName(rs.getString("topic_name"));
        r.setLectureHours(rs.getDouble("lecture_hours"));
        r.setQuestionNo(rs.getString("question_no"));
        r.setPlo(rs.getString("plo"));
        r.setClo(rs.getString("clo"));
        r.setQuestionType(rs.getString("question_type"));
        r.setMarks(rs.getInt("marks"));
        r.setTaxonomyLevel(rs.getString("taxonomy_level"));
        return r;
    }
}
