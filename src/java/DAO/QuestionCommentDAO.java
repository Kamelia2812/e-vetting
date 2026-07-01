package DAO;

import Model.QuestionComment;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * QuestionCommentDAO — all DB operations for the question_comments table.
 *
 * One active comment per (question_id, vetter_id) pair.
 * The DB UNIQUE KEY uq_question_vetter enforces this, so saveComment()
 * uses INSERT ... ON DUPLICATE KEY UPDATE — callers never need to check
 * whether the row already exists.
 *
 * All JOIN ON clauses use COLLATE utf8mb4_unicode_ci to avoid the
 * collation-mismatch errors documented in the project summary.
 */
public class QuestionCommentDAO {

    private static final Logger LOG =
            Logger.getLogger(QuestionCommentDAO.class.getName());

    // ── Read ──────────────────────────────────────────────────────────────────

    /**
     * Loads every comment for every question that belongs to the given paperId,
     * grouped by question_id so the JSP can look them up in O(1).
     *
     * Uses a single SQL round-trip — joins through the questions table to
     * filter by paperId without N+1 queries.
     *
     * @param paperId the exam paper being reviewed
     * @return LinkedHashMap of questionId -&gt; ordered list of comments (oldest first)
     */
    public Map<Integer, List<QuestionComment>> getCommentsByPaperId(int paperId) {
        String sql =
            "SELECT qc.comment_id, qc.question_id, qc.vetter_id, " +
            "       u.full_name AS vetter_name, " +
            "       qc.comment_text, qc.content_tag, qc.taxonomy_tag, " +
            "       qc.verdict, qc.suggested_taxonomy, " +
            "       qc.created_at, qc.updated_at " +
            "FROM   question_comments qc " +
            "JOIN   questions q ON q.question_id = qc.question_id " +
            "JOIN   users     u ON u.user_id      = qc.vetter_id " +
            "WHERE  q.paper_id = ? " +
            "ORDER  BY qc.question_id, qc.created_at ASC";

        Map<Integer, List<QuestionComment>> result = new LinkedHashMap<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, paperId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    QuestionComment c = mapRow(rs);
                    Integer key = c.getQuestionId();
                    if (!result.containsKey(key)) {
                        result.put(key, new ArrayList<>());
                    }
                    result.get(key).add(c);
                }
            }

        } catch (Exception e) {
            LOG.log(Level.SEVERE, "getCommentsByPaperId failed paperId=" + paperId, e);
        }

        return result;
    }

    /**
     * Returns the single comment left by a specific vetter on a specific question,
     * or null if that vetter has not commented yet.
     *
     * Used by VetterDashboardServlet after saving a comment to re-fetch the
     * vetterName and formatted timestamp for the AJAX JSON response.
     *
     * @param questionId target question
     * @param vetterId   target vetter
     * @return the comment, or null
     */
    public QuestionComment getComment(int questionId, int vetterId) {
        String sql =
            "SELECT qc.comment_id, qc.question_id, qc.vetter_id, " +
            "       u.full_name AS vetter_name, " +
            "       qc.comment_text, qc.content_tag, qc.taxonomy_tag, " +
            "       qc.verdict, qc.suggested_taxonomy, " +
            "       qc.created_at, qc.updated_at " +
            "FROM   question_comments qc " +
            "JOIN   users u ON u.user_id = qc.vetter_id " +
            "WHERE  qc.question_id = ? AND qc.vetter_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, questionId);
            ps.setInt(2, vetterId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }

        } catch (Exception e) {
            LOG.log(Level.SEVERE,
                    "getComment failed q=" + questionId + " v=" + vetterId, e);
        }

        return null;
    }

    // ── Write ─────────────────────────────────────────────────────────────────

    /**
     * Inserts a new comment or updates the existing one for the same
     * (question_id, vetter_id) pair.
     *
     * Requires the UNIQUE KEY uq_question_vetter on (question_id, vetter_id)
     * in the question_comments table — see question_comments.sql.
     *
     * @param comment fully populated comment (questionId and vetterId required)
     * @return true if the DB row was inserted or updated successfully
     */
    public boolean saveComment(QuestionComment comment) {
        String sql =
            "INSERT INTO question_comments " +
            "    (question_id, vetter_id, comment_text, content_tag, taxonomy_tag, " +
            "     verdict, suggested_taxonomy, created_at, updated_at) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW()) " +
            "ON DUPLICATE KEY UPDATE " +
            "    comment_text       = VALUES(comment_text), " +
            "    content_tag        = VALUES(content_tag), " +
            "    taxonomy_tag       = VALUES(taxonomy_tag), " +
            "    verdict            = VALUES(verdict), " +
            "    suggested_taxonomy = VALUES(suggested_taxonomy), " +
            "    updated_at         = NOW()";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt   (1, comment.getQuestionId());
            ps.setInt   (2, comment.getVetterId());
            ps.setString(3, comment.getCommentText());
            ps.setString(4, comment.getContentTag());
            ps.setString(5, comment.getTaxonomyTag());
            ps.setString(6, comment.getVerdict());
            ps.setString(7, comment.getSuggestedTaxonomy());

            // ON DUPLICATE KEY UPDATE returns 2 for updated rows, 1 for inserted
            return ps.executeUpdate() >= 1;

        } catch (Exception e) {
            LOG.log(Level.SEVERE,
                    "saveComment failed q=" + comment.getQuestionId() +
                    " v=" + comment.getVetterId(), e);
            return false;
        }
    }

    /**
     * Deletes a vetter's comment on a question.
     * Called when the vetter clicks "Clear" on their review panel.
     *
     * @param questionId target question
     * @param vetterId   the vetter who owns the comment
     * @return true if a row was deleted
     */
    public boolean deleteComment(int questionId, int vetterId) {
        String sql =
            "DELETE FROM question_comments " +
            "WHERE question_id = ? AND vetter_id = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, questionId);
            ps.setInt(2, vetterId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            LOG.log(Level.SEVERE,
                    "deleteComment failed q=" + questionId + " v=" + vetterId, e);
            return false;
        }
    }

    // ── Paper-section comments (JSS / SCHEME) ────────────────────────────────

    /** Loads all vetter comments for a given paper + section, newest first. */
    public List<Map<String,Object>> getSectionComments(int paperId, String section) {
        String sql =
            "SELECT psc.id, psc.vetter_id, " +
            "       COALESCE(u.full_name, psc.vetter_name) AS vetter_name, " +
            "       psc.comment_text, psc.verdict, " +
            "       psc.created_at " +
            "FROM paper_section_comments psc " +
            "LEFT JOIN users u ON u.user_id = psc.vetter_id " +
            "WHERE psc.paper_id = ? AND psc.section = ? " +
            "ORDER BY psc.created_at ASC";
        List<Map<String,Object>> result = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt   (1, paperId);
            ps.setString(2, section);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> row = new java.util.LinkedHashMap<>();
                    row.put("id",          rs.getInt("id"));
                    row.put("vetterId",    rs.getInt("vetter_id"));
                    row.put("vetterName",  rs.getString("vetter_name"));
                    row.put("commentText", rs.getString("comment_text"));
                    row.put("verdict",     rs.getString("verdict"));
                    row.put("createdAt",   rs.getTimestamp("created_at"));
                    result.add(row);
                }
            }
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "getSectionComments failed", e);
        }
        return result;
    }

    /** Inserts a new paper-section comment (JSS or SCHEME). */
    public boolean saveSectionComment(int paperId, String section,
                                      int vetterId, String vetterName,
                                      String commentText, String verdict) {
        String sql =
            "INSERT INTO paper_section_comments " +
            "  (paper_id, section, vetter_id, vetter_name, comment_text, verdict) " +
            "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt   (1, paperId);
            ps.setString(2, section);
            ps.setInt   (3, vetterId);
            ps.setString(4, vetterName);
            ps.setString(5, commentText);
            ps.setString(6, (verdict == null || verdict.trim().isEmpty()) ? null : verdict);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "saveSectionComment failed", e);
            return false;
        }
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    /**
     * Maps a single ResultSet row to a QuestionComment object.
     * Extracted to avoid duplication across all query methods.
     */
    private QuestionComment mapRow(ResultSet rs) throws SQLException {
        QuestionComment c = new QuestionComment();
        c.setCommentId  (rs.getInt   ("comment_id"));
        c.setQuestionId (rs.getInt   ("question_id"));
        c.setVetterId   (rs.getInt   ("vetter_id"));
        c.setVetterName (rs.getString("vetter_name"));
        c.setCommentText(rs.getString("comment_text"));
        c.setContentTag       (rs.getString("content_tag"));
        c.setTaxonomyTag      (rs.getString("taxonomy_tag"));
        c.setVerdict          (rs.getString("verdict"));
        c.setSuggestedTaxonomy(rs.getString("suggested_taxonomy"));

        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) c.setCreatedAt(created.toLocalDateTime());

        Timestamp updated = rs.getTimestamp("updated_at");
        if (updated != null) c.setUpdatedAt(updated.toLocalDateTime());

        return c;
    }
}
