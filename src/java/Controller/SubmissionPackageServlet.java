package Controller;

import DAO.AssessmentDAO;
import DAO.QuestionDAO;
import DAO.JSSDAO;
import DAO.RubricDAO;
import Model.Assessment;
import Model.Question;
import Model.JSSRow;
import Model.RubricRow;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.List;

/**
 * SubmissionPackageServlet
 *
 * Central hub for one assessment's complete submission package.
 * Loads all related documents so the JSP can render them in one place.
 *
 * GET  ?paperId=X            — show the package for this paper
 * POST action=submitPackage  — change status to SUBMITTED
 */
@WebServlet("/SubmissionPackageServlet")
public class SubmissionPackageServlet extends HttpServlet {

    private final AssessmentDAO assessmentDAO = new AssessmentDAO();
    private final QuestionDAO   questionDAO   = new QuestionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int    userId = (int)    session.getAttribute("userId");
        String role   = (String) session.getAttribute("role");
        boolean isVetter = Boolean.TRUE.equals(session.getAttribute("isVetter"));

        String paperIdStr = req.getParameter("paperId");
        if (paperIdStr == null || paperIdStr.trim().isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdStr.trim());
            Assessment paper = assessmentDAO.getAssessmentById(paperId);
            if (paper == null) {
                res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
                return;
            }

            // ── Main paper (the requested paperId) ───────────────────────
            List<Question> questions = questionDAO.getQuestionsByPaperId(paperId);
            int totalMarks = questionDAO.getTotalMarksByPaperId(paperId);

            // ── Reserve / alternative paper ──────────────────────────────
            Assessment reservePaper = findRelatedPaper(paper, paperId);
            List<Question> reserveQuestions = null;
            int reserveTotalMarks = 0;
            if (reservePaper != null) {
                reserveQuestions  = questionDAO.getQuestionsByPaperId(reservePaper.getPaperId());
                reserveTotalMarks = questionDAO.getTotalMarksByPaperId(reservePaper.getPaperId());
            }

            // ── JSS ──────────────────────────────────────────────────────
            PackageDoc jssDoc = getJssStatus(paperId);
            PackageDoc reserveJssDoc = reservePaper != null
                    ? getJssStatus(reservePaper.getPaperId()) : null;

            // ── Answer Scheme / Rubric ───────────────────────────────────
            PackageDoc schemeDoc = getSchemeStatus(paperId, questions);
            PackageDoc reserveSchemeDoc = reservePaper != null
                    ? getSchemeStatus(reservePaper.getPaperId(), reserveQuestions) : null;

            // ── Overall readiness ────────────────────────────────────────
            int questionCount = questions != null ? questions.size() : 0;
            boolean paperReady  = questionCount > 0;
            boolean jssReady    = jssDoc.exists;
            boolean schemeReady = schemeDoc.exists;

            boolean canSubmit    = paperReady && jssReady && totalMarks == 100;
            boolean isVetterView = isVetter || "Vetter".equalsIgnoreCase(role);

            // ── Set attributes ───────────────────────────────────────────
            req.setAttribute("paper",              paper);
            req.setAttribute("questions",          questions);
            req.setAttribute("totalMarks",         totalMarks);
            req.setAttribute("reservePaper",       reservePaper);
            req.setAttribute("reserveQuestions",   reserveQuestions);
            req.setAttribute("reserveTotalMarks",  reserveTotalMarks);
            req.setAttribute("jssDoc",             jssDoc);
            req.setAttribute("reserveJssDoc",      reserveJssDoc);
            req.setAttribute("schemeDoc",          schemeDoc);
            req.setAttribute("reserveSchemeDoc",   reserveSchemeDoc);
            req.setAttribute("paperReady",         paperReady);
            req.setAttribute("jssReady",           jssReady);
            req.setAttribute("schemeReady",        schemeReady);
            req.setAttribute("canSubmit",          canSubmit);
            req.setAttribute("isVetterView",       isVetterView);

            // Active tab from URL
            String tab = req.getParameter("tab");
            if (tab == null) tab = "overview";
            req.setAttribute("activeTab", tab);

            req.getRequestDispatcher("/submissionPackage.jsp").forward(req, res);

        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error loading submission package", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int    userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");
        if (action == null) action = "";

        try {
            int paperId = Integer.parseInt(req.getParameter("paperId"));

            if ("submitPackage".equals(action)) {
                boolean ok = assessmentDAO.submitAssessment(paperId, userId);
                if (ok) {
                    sendSubmitNotifications(paperId, userId);
                }
                String redir = req.getContextPath()
                        + "/SubmissionPackageServlet?paperId=" + paperId
                        + (ok ? "&submitted=true" : "&error=submit");
                res.sendRedirect(redir);
            } else {
                res.sendRedirect(req.getContextPath()
                        + "/SubmissionPackageServlet?paperId=" + req.getParameter("paperId"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error in SubmissionPackageServlet POST", e);
        }
    }

    // ── Check JSS exists for this paper ──────────────────────────────────────
    private PackageDoc getJssStatus(int paperId) {
        PackageDoc doc = new PackageDoc("JSS (FAP/02)", "JSS.jsp");
        String sql = "SELECT jss_id FROM jss WHERE paper_id = ?";
        try (Connection con = util.DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    doc.exists = true;
                    doc.docId  = rs.getInt("jss_id");
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return doc;
    }

    // ── Check answer scheme (model answers) or rubric depending on paper type ──
    private PackageDoc getSchemeStatus(int paperId, List<Question> questions) {
        PackageDoc doc = new PackageDoc("Answer Scheme / Rubric", "");
        // Check model answers on questions (final exam)
        if (questions != null) {
            int withAnswer = 0;
            for (Question q : questions) {
                if (q.getModelAnswer() != null && !q.getModelAnswer().trim().isEmpty()) withAnswer++;
            }
            if (withAnswer > 0) {
                doc.exists    = true;
                doc.extraInfo = withAnswer + " question(s) with model answer";
            }
        }
        // Check rubric rows (continuous assessment)
        String sql = "SELECT COUNT(*) FROM rubric_rows WHERE paper_id = ?";
        try (Connection con = util.DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    doc.exists = true;
                    doc.extraInfo = (doc.extraInfo != null ? doc.extraInfo + "; " : "")
                                  + rs.getInt(1) + " rubric row(s)";
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return doc;
    }

    // ── Find the paired paper (MAIN↔RESERVE) for same course/session ────────
    private Assessment findRelatedPaper(Assessment paper, int currentPaperId) {
        if (paper == null) return null;
        // We look for another paper with the same course_code + academic_session + semester
        // that belongs to the same lecturer and is NOT the current paper.
        String sql = "SELECT paper_id, course_code, course_title, faculty, lecturer_id, " +
                     "paper_type, academic_session, semester, status, total_questions, " +
                     "deadline, weightage, submission_mode, paper_variant " +
                     "FROM exam_papers " +
                     "WHERE course_code = ? AND academic_session = ? AND semester = ? " +
                     "  AND lecturer_id = ? AND paper_id <> ? " +
                     "ORDER BY paper_id ASC LIMIT 1";
        try (Connection con = util.DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, paper.getCourseCode());
            ps.setString(2, paper.getAcademicSession());
            ps.setInt(3, paper.getSemester());
            ps.setInt(4, paper.getLecturerId());
            ps.setInt(5, currentPaperId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Assessment a = new Assessment();
                    a.setPaperId(rs.getInt("paper_id"));
                    a.setCourseCode(rs.getString("course_code"));
                    a.setCourseTitle(rs.getString("course_title"));
                    a.setFaculty(rs.getString("faculty"));
                    a.setLecturerId(rs.getInt("lecturer_id"));
                    a.setPaperType(rs.getString("paper_type"));
                    a.setAcademicSession(rs.getString("academic_session"));
                    a.setSemester(rs.getInt("semester"));
                    a.setStatus(rs.getString("status"));
                    a.setTotalQuestions(rs.getInt("total_questions"));
                    a.setWeightage(rs.getDouble("weightage"));
                    // paper_variant (not yet in Assessment model — store in paperType label for display)
                    String variant = rs.getString("paper_variant");
                    if (variant == null) variant = "RESERVE";
                    a.setPaperType(a.getPaperType() + " (" + variant + ")");
                    return a;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    // ── Send notifications to vetter and other relevant parties ─────────
    private void sendSubmitNotifications(int paperId, int lecturerId) {
        String infoSql = "SELECT ep.course_code, ep.course_title, ep.academic_session, "
                + "       ep.semester, c.vetter_id, "
                + "       u.full_name AS lec_name, "
                + "       v.full_name AS vetter_name, v.email AS vetter_email "
                + "FROM exam_papers ep "
                + "LEFT JOIN course c ON c.course_code COLLATE utf8mb4_unicode_ci = ep.course_code COLLATE utf8mb4_unicode_ci "
                + "LEFT JOIN users u ON u.user_id = ep.lecturer_id "
                + "LEFT JOIN users v ON v.user_id = c.vetter_id "
                + "WHERE ep.paper_id = ? LIMIT 1";
        try (Connection con = util.DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(infoSql)) {
            ps.setInt(1, paperId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return;
                String courseCode   = rs.getString("course_code");
                String courseTitle  = rs.getString("course_title");
                String session      = rs.getString("academic_session");
                int    semester     = rs.getInt("semester");
                int    vetterId     = rs.getInt("vetter_id");
                String lecName      = rs.getString("lec_name");
                String vetterName   = rs.getString("vetter_name");
                String vetterEmail  = rs.getString("vetter_email");
                if (lecName == null) lecName = "A lecturer";

                String summary = lecName + " submitted " + courseCode
                        + " (" + courseTitle + ") for " + session
                        + " Sem " + semester + " — ready for vetting.";

                String baseUrl   = "http://localhost:8080/assessmentvetting";
                String reviewUrl = baseUrl + "/VetterDashboardServlet?page=review&paperId=" + paperId;

                String notifSql = "INSERT INTO notifications (user_id, assessment_id, summary) VALUES (?, ?, ?)";

                // ── Notify assigned vetter ──
                if (vetterId > 0) {
                    try (PreparedStatement np = con.prepareStatement(notifSql)) {
                        np.setInt(1, vetterId); np.setInt(2, paperId); np.setString(3, summary);
                        np.executeUpdate();
                    }
                    util.EmailService.sendSubmissionEmail(
                        vetterEmail, vetterName != null ? vetterName : "Vetter",
                        lecName, courseCode, courseTitle, session, semester, reviewUrl);
                }

                // ── Notify all Admin / KP ──
                String adminSql = "SELECT user_id, full_name, email FROM users "
                                + "WHERE role IN ('Admin','KP','ADMIN','KP_ADMIN') AND user_id != ?";
                try (PreparedStatement ap = con.prepareStatement(adminSql)) {
                    ap.setInt(1, lecturerId);
                    try (ResultSet ar = ap.executeQuery()) {
                        while (ar.next()) {
                            int    adminId    = ar.getInt("user_id");
                            String adminName  = ar.getString("full_name");
                            String adminEmail = ar.getString("email");
                            if (adminId == vetterId) continue;
                            try (PreparedStatement np2 = con.prepareStatement(notifSql)) {
                                np2.setInt(1, adminId); np2.setInt(2, paperId); np2.setString(3, summary);
                                np2.executeUpdate();
                            }
                            util.EmailService.sendSubmissionEmail(
                                adminEmail, adminName != null ? adminName : "Admin",
                                lecName, courseCode, courseTitle, session, semester, reviewUrl);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace(); // non-fatal — submission succeeded
        }
    }

    /** Simple status bean for each document in the package. */
    public static class PackageDoc {
        public String  name;
        public String  linkBase;
        public boolean exists    = false;
        public int     docId     = 0;
        public String  extraInfo = null;

        public PackageDoc(String name, String linkBase) {
            this.name = name;
            this.linkBase = linkBase;
        }
    }
}
