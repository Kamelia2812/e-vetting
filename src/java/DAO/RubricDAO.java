package DAO;

import Model.RubricRow;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * RubricDAO — all DB operations for the rubric_rows table.
 *
 * Save strategy: delete-and-reinsert on every save.
 * This keeps the logic simple — no need to diff old vs new rows.
 * Since rubric_rows has ON DELETE CASCADE from exam_papers, orphaned
 * rows are automatically cleaned up when a paper is deleted.
 */
public class RubricDAO {

    private static final Logger LOG = Logger.getLogger(RubricDAO.class.getName());

    // ── Read ──────────────────────────────────────────────────────────

    /**
     * Returns all rubric rows for a paper, ordered by row_order.
     * Returns an empty list if none exist.
     *
     * @param paperId the exam_papers.paper_id
     * @return ordered list of rubric rows
     */
    public List<RubricRow> getByPaperId(int paperId) throws Exception {
        String sql =
            "SELECT rubric_id, paper_id, row_order, criterion, " +
            "       marks, clo, bloom, description " +
            "FROM   rubric_rows " +
            "WHERE  paper_id = ? " +
            "ORDER  BY row_order ASC";

        List<RubricRow> list = new ArrayList<>();

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, paperId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "getByPaperId failed paperId=" + paperId, e);
            throw e;
        }

        return list;
    }

    // ── Write ─────────────────────────────────────────────────────────

    /**
     * Replaces all rubric rows for a paper with the provided list.
     *
     * Runs as a single transaction:
     *   1. DELETE existing rows for this paperId
     *   2. INSERT all rows from the list
     *
     * If any insert fails the transaction rolls back, leaving the
     * previous rubric intact.
     *
     * @param paperId the parent paper
     * @param rows    the new rubric rows to save (may be empty)
     */
    public void saveAll(int paperId, List<RubricRow> rows) throws Exception {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            // Step 1 — delete existing rows
            try (PreparedStatement del =
                    con.prepareStatement("DELETE FROM rubric_rows WHERE paper_id = ?")) {
                del.setInt(1, paperId);
                del.executeUpdate();
            }

            // Step 2 — insert new rows
            String ins =
                "INSERT INTO rubric_rows " +
                "    (paper_id, row_order, criterion, marks, clo, bloom, description) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement ps = con.prepareStatement(ins)) {
                for (int i = 0; i < rows.size(); i++) {
                    RubricRow r = rows.get(i);
                    ps.setInt   (1, paperId);
                    ps.setInt   (2, i + 1);           // row_order starts at 1
                    ps.setString(3, r.getCriterion());
                    ps.setInt   (4, r.getMarks());
                    ps.setString(5, r.getClo());       // null is fine
                    ps.setString(6, r.getBloom());     // null is fine
                    ps.setString(7, r.getDescription());
                    ps.addBatch();
                }
                if (!rows.isEmpty()) ps.executeBatch();
            }

            con.commit();

        } catch (Exception e) {
            if (con != null) {
                try { con.rollback(); } catch (SQLException ignored) {}
            }
            LOG.log(Level.SEVERE, "saveAll failed paperId=" + paperId, e);
            throw e;
        } finally {
            if (con != null) {
                try { con.setAutoCommit(true); con.close(); } catch (SQLException ignored) {}
            }
        }
    }

    /**
     * Deletes all rubric rows for a paper.
     * Called when a paper is deleted (though the FK CASCADE also handles this).
     *
     * @param paperId the parent paper
     */
    public void deleteByPaperId(int paperId) throws Exception {
        String sql = "DELETE FROM rubric_rows WHERE paper_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId);
            ps.executeUpdate();
        } catch (SQLException e) {
            LOG.log(Level.SEVERE, "deleteByPaperId failed paperId=" + paperId, e);
            throw e;
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────

    /** Maps a ResultSet row to a RubricRow object. */
    private RubricRow mapRow(ResultSet rs) throws SQLException {
        RubricRow r = new RubricRow();
        r.setRubricId  (rs.getInt   ("rubric_id"));
        r.setPaperId   (rs.getInt   ("paper_id"));
        r.setRowOrder  (rs.getInt   ("row_order"));
        r.setCriterion (rs.getString("criterion"));
        r.setMarks     (rs.getInt   ("marks"));
        r.setClo       (rs.getString("clo"));
        r.setBloom     (rs.getString("bloom"));
        r.setDescription(rs.getString("description"));
        return r;
    }
}