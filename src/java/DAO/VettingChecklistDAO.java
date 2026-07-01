package DAO;

import util.DBConnection;
import java.sql.*;
import java.util.*;

public class VettingChecklistDAO {

    // ── Predefined criteria ──────────────────────────────────────────────────
    public static final String[][] QUESTION_CRITERIA = {
        {"q_content",  "Content is accurate and relevant to the course"},
        {"q_clarity",  "Question wording is clear and unambiguous"},
        {"q_marks",    "Marks allocation is appropriate for the difficulty"},
        {"q_taxonomy", "Bloom's taxonomy level is correctly classified"},
        {"q_answer",   "Expected answer is clear and definitive"}
    };

    public static final String[][] JSS_CRITERIA = {
        {"jss_coverage", "All syllabus topics are adequately covered"},
        {"jss_bloom",    "Bloom's taxonomy distribution is balanced (C1-C6)"},
        {"jss_weights",  "Mark weightage distribution is correct"},
        {"jss_format",   "Format follows the standard JSS template"},
        {"jss_clo",      "CLO mapping is correctly aligned to questions"},
        {"jss_marks",    "Total marks allocation matches the exam weightage"}
    };

    public static final String[][] SCHEME_CRITERIA = {
        {"sc_complete",  "Model answers are complete and accurate"},
        {"sc_marking",   "Marking scheme is clear for each question"},
        {"sc_partial",   "Partial marks allocation is clearly specified"},
        {"sc_consistent","Answer scheme is consistent with the questions"}
    };

    // ── Save / upsert one checklist item ────────────────────────────────────
    public void saveItem(int paperId, int vetterId, String section,
                         Integer refId, String criterionKey,
                         boolean isOk, String comment) throws Exception {
        if (refId != null && refId == 0) refId = null;
        String sql = "INSERT INTO vetting_checklist "
                   + "(paper_id, vetter_id, section, ref_id, criterion_key, is_ok, comment, updated_at) "
                   + "VALUES (?,?,?,?,?,?,?,NOW()) "
                   + "ON DUPLICATE KEY UPDATE is_ok=VALUES(is_ok), comment=VALUES(comment), updated_at=NOW()";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt   (1, paperId);
            ps.setInt   (2, vetterId);
            ps.setString(3, section);
            if (refId != null) ps.setInt(4, refId); else ps.setNull(4, Types.INTEGER);
            ps.setString(5, criterionKey);
            ps.setInt   (6, isOk ? 1 : 0);
            ps.setString(7, comment != null ? comment.trim() : "");
            ps.executeUpdate();
        }
    }

    // ── Delete one checklist item ───────────────────────────────────────────
    public void deleteItem(int paperId, int vetterId, String section,
                           Integer refId, String criterionKey) throws Exception {
        if (refId != null && refId == 0) refId = null;
        String sql = "DELETE FROM vetting_checklist WHERE paper_id=? AND vetter_id=? AND section=? "
                   + "AND (ref_id=? OR (ref_id IS NULL AND ? IS NULL)) AND criterion_key=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId);
            ps.setInt(2, vetterId);
            ps.setString(3, section);
            if (refId != null) {
                ps.setInt(4, refId);
                ps.setInt(5, refId);
            } else {
                ps.setNull(4, Types.INTEGER);
                ps.setNull(5, Types.INTEGER);
            }
            ps.setString(6, criterionKey);
            ps.executeUpdate();
        }
    }

    // ── Load this vetter's checklist for one paper ───────────────────────────
    // Returns map keyed "SECTION_refId_key" → {is_ok, comment}
    public Map<String, Map<String, Object>> loadForVetter(int paperId, int vetterId) throws Exception {
        String sql = "SELECT section, ref_id, criterion_key, is_ok, comment, updated_at "
                   + "FROM vetting_checklist WHERE paper_id=? AND vetter_id=?";
        Map<String, Map<String, Object>> map = new LinkedHashMap<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId); ps.setInt(2, vetterId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String key = buildKey(rs.getString("section"),
                                         (Integer) rs.getObject("ref_id"),
                                         rs.getString("criterion_key"));
                    Map<String, Object> entry = new LinkedHashMap<>();
                    entry.put("is_ok",      rs.getInt("is_ok") == 1);
                    entry.put("comment",    rs.getString("comment"));
                    entry.put("updated_at", rs.getTimestamp("updated_at"));
                    map.put(key, entry);
                }
            }
        }
        return map;
    }

    // ── Load all vetters' checklists for a paper (for lecturer/KP view) ──────
    // Returns list of rows: {vetter_name, section, ref_id, criterion_key, is_ok, comment, updated_at}
    public List<Map<String, Object>> loadAllForPaper(int paperId) throws Exception {
        String sql = "SELECT vc.*, u.full_name AS vetter_name "
                   + "FROM vetting_checklist vc "
                   + "LEFT JOIN users u ON u.user_id = vc.vetter_id "
                   + "WHERE vc.paper_id=? "
                   + "ORDER BY vc.vetter_id, vc.section, vc.ref_id, vc.criterion_key";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("vetter_id",   rs.getInt("vetter_id"));
                    row.put("vetter_name", rs.getString("vetter_name"));
                    row.put("section",     rs.getString("section"));
                    row.put("ref_id",      rs.getObject("ref_id"));
                    row.put("criterion_key", rs.getString("criterion_key"));
                    row.put("is_ok",       rs.getInt("is_ok") == 1);
                    row.put("comment",     rs.getString("comment"));
                    row.put("updated_at",  rs.getTimestamp("updated_at"));
                    list.add(row);
                }
            }
        }
        return list;
    }

    // ── Helper: build composite map key ─────────────────────────────────────
    public static String buildKey(String section, Integer refId, String criterionKey) {
        return section + "_" + (refId != null ? refId : "0") + "_" + criterionKey;
    }

    // ── Lookup label from criteria arrays ────────────────────────────────────
    public static String getLabel(String criterionKey) {
        for (String[] c : QUESTION_CRITERIA) if (c[0].equals(criterionKey)) return c[1];
        for (String[] c : JSS_CRITERIA)      if (c[0].equals(criterionKey)) return c[1];
        for (String[] c : SCHEME_CRITERIA)   if (c[0].equals(criterionKey)) return c[1];
        return criterionKey;
    }
}
