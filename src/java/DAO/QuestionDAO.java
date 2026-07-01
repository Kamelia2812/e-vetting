package DAO;

import Model.Question;
import Model.QuestionPart;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import util.DBConnection;

/**
 * QuestionDAO — all DB operations for the questions table. questions.paper_id →
 * exam_papers.paper_id (FK, CASCADE DELETE)
 *
 * question_type: OBJECTIVE | STRUCTURE | ESSAY (DB enum) taxonomy_level: C1–C6
 * (DB enum, Bloom's cognitive) status: DRAFT | APPROVED | NEEDS_REVISION |
 * REJECTED
 */
public class QuestionDAO {

    // ── Get all questions for one paper, ordered by question_no ─────────
    public List<Question> getQuestionsByPaperId(int paperId) throws Exception {
        List<Question> list = new ArrayList<>();
        String sql = "SELECT * FROM questions WHERE paper_id = ? ORDER BY question_no";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, paperId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Question q = mapRow(rs);
                q.setParts(getPartsForQuestion(con, q.getQuestionId()));
                list.add(q);
            }
        }
        return list;
    }

    // ── Get one question by ID ───────────────────────────────────────────
    public Question getQuestionById(int questionId) throws Exception {
        String sql = "SELECT * FROM questions WHERE question_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, questionId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Question q = mapRow(rs);
                q.setParts(getPartsForQuestion(con, q.getQuestionId()));
                return q;
            }
        }
        return null;
    }

    // ── Insert a new question, return generated question_id ─────────────
    public int addQuestion(Question q) throws Exception {
        String sql
                = "INSERT INTO questions "
                + "(paper_id, question_no, question_type, question_format, "
                + " question_text, question_text_ms, "
                + " statement_1, statement_2, statement_3, statement_4, "
                + " marks, chapter, taxonomy_level, clo_mapping, status, "
                + " choice_a, choice_b, choice_c, choice_d, correct_answer, "
                + " image_url, table_data, model_answer) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'DRAFT', ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, q.getPaperId());
            ps.setString(2, q.getQuestionNo());
            ps.setString(3, q.getQuestionType());
            ps.setString(4, q.getQuestionFormat() != null ? q.getQuestionFormat() : "SIMPLE");
            ps.setString(5, q.getQuestionText());
            ps.setString(6, q.getQuestionTextMs());
            ps.setString(7, q.getStatement1());
            ps.setString(8, q.getStatement2());
            ps.setString(9, q.getStatement3());
            ps.setString(10, q.getStatement4());
            ps.setInt(11, q.getMarks());
            ps.setString(12, q.getChapter());
            ps.setString(13, q.getTaxonomyLevel());
            ps.setString(14, q.getCloMapping() != null ? q.getCloMapping() : "CLO1");
            ps.setString(15, q.getChoiceA());
            ps.setString(16, q.getChoiceB());
            ps.setString(17, q.getChoiceC());
            ps.setString(18, q.getChoiceD());
            ps.setString(19, q.getCorrectAnswer());
            ps.setString(20, q.getImageUrl());
            ps.setString(21, q.getTableData());
            ps.setString(22, q.getModelAnswer());
            ps.executeUpdate();

            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) {
                int qId = keys.getInt(1);
                savePartsForQuestion(con, qId, q.getParts());
                return qId;
            }
        }
        throw new Exception("addQuestion failed — no generated key returned.");
    }

    private void savePartsForQuestion(Connection con, int questionId, List<QuestionPart> parts) throws SQLException {
        if (parts == null || parts.isEmpty()) return;
        String sql = "INSERT INTO question_parts (question_id, part_label, part_question_text, part_marks, part_model_answer) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (QuestionPart p : parts) {
                ps.setInt(1, questionId);
                ps.setString(2, p.getPartLabel());
                ps.setString(3, p.getPartQuestionText());
                ps.setInt(4, p.getPartMarks());
                ps.setString(5, p.getPartModelAnswer());
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    private List<QuestionPart> getPartsForQuestion(Connection con, int questionId) throws SQLException {
        List<QuestionPart> list = new ArrayList<>();
        String sql = "SELECT * FROM question_parts WHERE question_id = ? ORDER BY part_id";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, questionId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                QuestionPart p = new QuestionPart();
                p.setPartId(rs.getInt("part_id"));
                p.setQuestionId(rs.getInt("question_id"));
                p.setPartLabel(rs.getString("part_label"));
                p.setPartQuestionText(rs.getString("part_question_text"));
                p.setPartMarks(rs.getInt("part_marks"));
                p.setPartModelAnswer(rs.getString("part_model_answer"));
                list.add(p);
            }
        }
        return list;
    }

    // ── Update an existing question ──────────────────────────────────────
    public void updateQuestion(Question q) throws Exception {
        String sql
                = "UPDATE questions "
                + "SET question_no = ?, question_type = ?, question_format = ?, "
                + "    question_text = ?, question_text_ms = ?, "
                + "    statement_1 = ?, statement_2 = ?, statement_3 = ?, statement_4 = ?, "
                + "    marks = ?, chapter = ?, taxonomy_level = ?, clo_mapping = ?, "
                + "    choice_a = ?, choice_b = ?, choice_c = ?, choice_d = ?, correct_answer = ?, "
                + "    image_url = ?, table_data = ?, model_answer = ? "
                + "WHERE question_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, q.getQuestionNo());
            ps.setString(2, q.getQuestionType());
            ps.setString(3, q.getQuestionFormat() != null ? q.getQuestionFormat() : "SIMPLE");
            ps.setString(4, q.getQuestionText());
            ps.setString(5, q.getQuestionTextMs());
            ps.setString(6, q.getStatement1());
            ps.setString(7, q.getStatement2());
            ps.setString(8, q.getStatement3());
            ps.setString(9, q.getStatement4());
            ps.setInt(10, q.getMarks());
            ps.setString(11, q.getChapter());
            ps.setString(12, q.getTaxonomyLevel());
            ps.setString(13, q.getCloMapping() != null ? q.getCloMapping() : "CLO1");
            ps.setString(14, q.getChoiceA());
            ps.setString(15, q.getChoiceB());
            ps.setString(16, q.getChoiceC());
            ps.setString(17, q.getChoiceD());
            ps.setString(18, q.getCorrectAnswer());
            ps.setString(19, q.getImageUrl());
            ps.setString(20, q.getTableData());
            ps.setString(21, q.getModelAnswer());
            ps.setInt(22, q.getQuestionId());
            ps.executeUpdate();

            // Replace parts
            try (PreparedStatement delPs = con.prepareStatement("DELETE FROM question_parts WHERE question_id = ?")) {
                delPs.setInt(1, q.getQuestionId());
                delPs.executeUpdate();
            }
            savePartsForQuestion(con, q.getQuestionId(), q.getParts());
        }
    }

    // ── Delete one question by ID ────────────────────────────────────────
    public void deleteQuestion(int questionId) throws Exception {
        String sql = "DELETE FROM questions WHERE question_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, questionId);
            ps.executeUpdate();
        }
    }

    // ── Delete ALL questions for a paper (e.g. when discarding a draft) ─
    public void deleteAllByPaperId(int paperId) throws Exception {
        String sql = "DELETE FROM questions WHERE paper_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, paperId);
            ps.executeUpdate();
        }
    }

    // ── Sum of marks for a paper — used for the 100-mark validation ─────
    public int getTotalMarksByPaperId(int paperId) throws Exception {
        String sql = "SELECT COALESCE(SUM(marks), 0) FROM questions WHERE paper_id = ?";

        try (Connection con = DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, paperId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // ── Map ResultSet row → Question object ─────────────────────────────
    private Question mapRow(ResultSet rs) throws SQLException {
        Question q = new Question();
        q.setQuestionId(rs.getInt("question_id"));
        q.setPaperId(rs.getInt("paper_id"));
        q.setQuestionNo(rs.getString("question_no"));
        q.setQuestionType(rs.getString("question_type"));
        q.setQuestionText(rs.getString("question_text"));
        q.setQuestionTextMs(rs.getString("question_text_ms"));
        q.setMarks(rs.getInt("marks"));
        q.setChapter(rs.getString("chapter"));
        q.setTaxonomyLevel(rs.getString("taxonomy_level"));
        q.setCloMapping(rs.getString("clo_mapping"));
        q.setStatus(rs.getString("status"));
        q.setChoiceA(rs.getString("choice_a"));
        q.setChoiceB(rs.getString("choice_b"));
        q.setChoiceC(rs.getString("choice_c"));
        q.setChoiceD(rs.getString("choice_d"));
        q.setCorrectAnswer(rs.getString("correct_answer"));
        try {
            q.setModelAnswer(rs.getString("model_answer"));
        } catch (SQLException ignored) {}
        // New columns added by migration — graceful fallback if not yet run
        try {
            q.setQuestionFormat(rs.getString("question_format"));
            q.setStatement1(rs.getString("statement_1"));
            q.setStatement2(rs.getString("statement_2"));
            q.setStatement3(rs.getString("statement_3"));
            q.setStatement4(rs.getString("statement_4"));
            q.setImageUrl(rs.getString("image_url"));
            q.setTableData(rs.getString("table_data"));
        } catch (SQLException ignored) {}
        if (q.getQuestionFormat() == null) q.setQuestionFormat("SIMPLE");
        return q;
    }

    /** Updates question status (verdict) and optionally the taxonomy level. */
    public boolean updateQuestionVerdict(int questionId, String status, String taxonomyLevel) throws Exception {
        String sql = taxonomyLevel != null
            ? "UPDATE questions SET status = ?, taxonomy_level = ? WHERE question_id = ?"
            : "UPDATE questions SET status = ? WHERE question_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            if (taxonomyLevel != null) {
                ps.setString(2, taxonomyLevel);
                ps.setInt(3, questionId);
            } else {
                ps.setInt(2, questionId);
            }
            return ps.executeUpdate() > 0;
        }
    }
}
