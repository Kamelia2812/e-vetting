package Controller;

import util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.*;
import java.sql.*;
import java.util.*;

@WebServlet("/ReportSummaryServlet")
public class ReportSummaryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String role = (String) session.getAttribute("role");
        if (!"KP".equalsIgnoreCase(role) && !"KP_ADMIN".equalsIgnoreCase(role)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access restricted to KP only.");
            return;
        }

        try (Connection con = DBConnection.getConnection()) {

            // 1. All papers + lecturer name
            List<Map<String, Object>> papers = new ArrayList<>();
            String paperSql =
                "SELECT ep.paper_id, ep.course_code, ep.course_title, ep.faculty, " +
                "  ep.paper_type, ep.paper_variant, ep.academic_session, ep.semester, " +
                "  ep.total_questions, ep.assign_marks, ep.status, ep.submitted_date, " +
                "  ep.instructions, u.full_name AS lecturer_name " +
                "FROM exam_papers ep " +
                "JOIN users u ON ep.lecturer_id = u.user_id " +
                "ORDER BY ep.submitted_date DESC";
            try (PreparedStatement ps = con.prepareStatement(paperSql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> p = new LinkedHashMap<>();
                    p.put("paperId",       rs.getInt("paper_id"));
                    p.put("courseCode",    rs.getString("course_code"));
                    p.put("courseTitle",   rs.getString("course_title"));
                    p.put("faculty",       rs.getString("faculty"));
                    p.put("paperType",     rs.getString("paper_type"));
                    p.put("variant",       rs.getString("paper_variant"));
                    p.put("session",       rs.getString("academic_session"));
                    p.put("semester",      rs.getInt("semester"));
                    p.put("totalQ",        rs.getInt("total_questions"));
                    p.put("marks",         rs.getInt("assign_marks"));
                    p.put("status",        rs.getString("status"));
                    p.put("submittedDate", rs.getTimestamp("submitted_date"));
                    p.put("instructions",  rs.getString("instructions"));
                    p.put("lecturerName",  rs.getString("lecturer_name"));
                    papers.add(p);
                }
            }

            // 2. Vetters per paper (with names)
            String vetterSql =
                "SELECT u.full_name AS vetter_name, cv.is_leader " +
                "FROM course_vetters cv " +
                "JOIN users u ON cv.vetter_id = u.user_id " +
                "JOIN course c ON c.course_id = cv.course_id " +
                "WHERE c.course_code = ? " +
                "ORDER BY cv.is_leader DESC, u.full_name";

            for (Map<String, Object> p : papers) {
                List<Map<String, Object>> vetters = new ArrayList<>();
                try (PreparedStatement ps2 = con.prepareStatement(vetterSql)) {
                    ps2.setString(1, (String) p.get("courseCode"));
                    try (ResultSet rs2 = ps2.executeQuery()) {
                        while (rs2.next()) {
                            Map<String, Object> v = new LinkedHashMap<>();
                            v.put("name",     rs2.getString("vetter_name"));
                            v.put("isLeader", rs2.getInt("is_leader") == 1);
                            vetters.add(v);
                        }
                    }
                }
                p.put("vetters", vetters);
            }

            // 3. Per-criterion aggregated checklist results per paper
            // Aggregate across all vetters: isOk = false if ANY vetter marked it failing
            // Also collect all unique comments per criterion
            String clSql =
                "SELECT vc.criterion_key, " +
                "  MIN(vc.is_ok) AS is_ok, " +
                "  GROUP_CONCAT(DISTINCT CASE WHEN vc.comment != '' THEN " +
                "    CONCAT(u.full_name, ': ', vc.comment) END ORDER BY u.full_name SEPARATOR '\n') AS comments " +
                "FROM vetting_checklist vc " +
                "JOIN users u ON vc.vetter_id = u.user_id " +
                "WHERE vc.paper_id = ? " +
                "GROUP BY vc.criterion_key";

            for (Map<String, Object> p : papers) {
                Map<String, Object[]> criteria = new LinkedHashMap<>(); // key -> [isOk(bool), comments(String)]
                try (PreparedStatement ps3 = con.prepareStatement(clSql)) {
                    ps3.setInt(1, (int) p.get("paperId"));
                    try (ResultSet rs3 = ps3.executeQuery()) {
                        while (rs3.next()) {
                            String key      = rs3.getString("criterion_key");
                            boolean isOk    = rs3.getInt("is_ok") == 1;
                            String comments = rs3.getString("comments");
                            criteria.put(key, new Object[]{isOk, comments != null ? comments : ""});
                        }
                    }
                }
                p.put("criteria", criteria);
            }

            // 4. Vetter comments (from main question/jss/scheme comment fields, if any)
            // Pull aggregated vetter panel comment per paper from checklist comments
            for (Map<String, Object> p : papers) {
                @SuppressWarnings("unchecked")
                Map<String, Object[]> criteria = (Map<String, Object[]>) p.get("criteria");
                StringBuilder panelComment = new StringBuilder();
                if (criteria != null) {
                    for (Map.Entry<String, Object[]> e : criteria.entrySet()) {
                        String comment = (String) e.getValue()[1];
                        if (comment != null && !comment.isEmpty()) {
                            if (panelComment.length() > 0) panelComment.append("\n");
                            panelComment.append(comment);
                        }
                    }
                }
                p.put("panelComment", panelComment.toString());
            }

            // 5. Overall status summary
            Map<String, Integer> statusCounts = new LinkedHashMap<>();
            String cntSql = "SELECT status, COUNT(*) AS cnt FROM exam_papers GROUP BY status ORDER BY cnt DESC";
            try (PreparedStatement ps4 = con.prepareStatement(cntSql);
                 ResultSet rs4 = ps4.executeQuery()) {
                while (rs4.next()) {
                    statusCounts.put(rs4.getString("status"), rs4.getInt("cnt"));
                }
            }

            req.setAttribute("papers",       papers);
            req.setAttribute("statusCounts", statusCounts);
            req.setAttribute("total",        papers.size());
            req.setAttribute("generatedAt",  new java.util.Date());
            req.setAttribute("currentPage",  "reports");
            req.getRequestDispatcher("/reportSummary.jsp").forward(req, resp);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("ReportSummaryServlet: " + e.getMessage(), e);
        }
    }
}
