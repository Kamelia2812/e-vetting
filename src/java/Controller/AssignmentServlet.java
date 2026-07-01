package Controller;

import DAO.AssessmentDAO;
import DAO.CourseDAO;
import DAO.RubricDAO;
import Model.Assessment;
import Model.Course;
import Model.RubricRow;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.List;

/**
 * AssignmentServlet — handles the continuous assessment instruction sheet builder.
 *
 * GET  ?action=new&amp;type=Lab Report  → blank sheet for this type
 * GET  ?action=edit&amp;paperId=X       → load existing draft for editing
 * GET  ?action=view&amp;paperId=X       → read-only view
 *
 * POST action=saveDraft  → save paper + rubric rows, stay on builder
 * POST action=submit     → save paper + rubric rows, submit for vetting
 */
@WebServlet("/AssignmentServlet")
public class AssignmentServlet extends HttpServlet {

    private final AssessmentDAO assessmentDAO = new AssessmentDAO();
    private final CourseDAO     courseDAO     = new CourseDAO();
    private final RubricDAO     rubricDAO     = new RubricDAO();

    // ─────────────────────────────────────────────────────────────────
    // GET
    // ─────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        if (!"LECTURER".equalsIgnoreCase((String) session.getAttribute("role"))) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int    lecturerId = (int) session.getAttribute("userId");
        String action     = req.getParameter("action");
        if (action == null) action = "new";

        try {
            // Fetch this lecturer's courses for the dropdown
            List<Course> courses = courseDAO.getCoursesByLecturerId(lecturerId);
            req.setAttribute("courses", courses);

            if ("edit".equals(action) || "view".equals(action)) {
                int        paperId = Integer.parseInt(req.getParameter("paperId"));
                Assessment paper   = assessmentDAO.getAssessmentById(paperId);

                if (paper == null || paper.getLecturerId() != lecturerId) {
                    res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
                    return;
                }

                // Load saved rubric rows for this paper
                List<RubricRow> rubricRows = rubricDAO.getByPaperId(paperId);

                req.setAttribute("paper",      paper);
                req.setAttribute("rubricRows", rubricRows);
                req.setAttribute("readOnly",   "view".equals(action) || !paper.isEditable());

            } else {
                // New — pre-set the assessment type from URL param
                String type = req.getParameter("type");
                if (type == null || type.isEmpty()) type = "Lab Report";
                req.setAttribute("presetType", type);
                req.setAttribute("rubricRows", new ArrayList<RubricRow>());
                req.setAttribute("readOnly",   false);
            }

            req.setAttribute("action", action);
            req.setAttribute("currentPage", "assessments");
            req.getRequestDispatcher("/assignmentSheet.jsp").forward(req, res);

        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error loading assignment builder", e);
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // POST
    // ─────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int    lecturerId = (int) session.getAttribute("userId");
        String action     = req.getParameter("action");
        if (action == null) action = "";

        try {
            if ("saveDraft".equals(action)) {
                int paperId = saveAssignment(req, lecturerId);
                saveRubric(req, paperId);
                res.sendRedirect(req.getContextPath()
                        + "/AssignmentServlet?action=edit&amp;paperId=" + paperId + "&saved=true");

            } else if ("submit".equals(action)) {
                int paperId = saveAssignment(req, lecturerId);
                saveRubric(req, paperId);

                boolean ok = assessmentDAO.submitAssessment(paperId, lecturerId);
                if (!ok) {
                    res.sendRedirect(req.getContextPath()
                            + "/AssignmentServlet?action=edit&amp;paperId=" + paperId + "&error=submit");
                    return;
                }
                res.sendRedirect(req.getContextPath()
                        + "/LecturerDashboardServlet?page=assessments&submitted=true");

            } else {
                res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error saving assignment: " + action, e);
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // Private helpers
    // ─────────────────────────────────────────────────────────────────

    /**
     * Saves or updates the assessment header fields (exam_papers row).
     * Creates a new row if paperId == 0, otherwise updates the existing row.
     *
     * @return the paper_id of the saved/updated row
     */
    private int saveAssignment(HttpServletRequest req, int lecturerId) throws Exception {
        Assessment a = new Assessment();
        a.setLecturerId     (lecturerId);
        a.setCourseCode     (trimStr(req.getParameter("courseCode")));
        a.setCourseTitle    (trimStr(req.getParameter("courseTitle")));
        a.setFaculty        (trimStr(req.getParameter("faculty"), "FSKM"));
        a.setPaperType      (trimStr(req.getParameter("paperType"), "Lab Report"));
        a.setAcademicSession(trimStr(req.getParameter("academicSession")));
        a.setSemester       (safeInt(req.getParameter("semester"), 1));
        a.setDeadline       (trimStr(req.getParameter("deadline")));
        a.setInstructions   (trimStr(req.getParameter("instructions")));
        a.setWeightage      (safeDouble(req.getParameter("weightage")));
        a.setSubmissionMode (trimStr(req.getParameter("submissionMode"), "Individual"));
        a.setAssignMarks    (safeInt(req.getParameter("assignMarks"), 100));

        String paperIdParam = req.getParameter("paperId");
        boolean isNew = (paperIdParam == null
                         || paperIdParam.trim().isEmpty()
                         || "0".equals(paperIdParam.trim()));

        if (isNew) {
            return assessmentDAO.createAssessment(a);
        } else {
            int paperId = Integer.parseInt(paperIdParam.trim());
            a.setPaperId(paperId);
            updateAssignment(a);
            return paperId;
        }
    }

    /**
     * Updates the continuous-assessment-specific columns on an existing exam_papers row.
     * Only updates papers that are still editable (DRAFT / REJECTED / NEEDS_IMPROVEMENT).
     */
    private void updateAssignment(Assessment a) throws Exception {
        String sql =
            "UPDATE exam_papers " +
            "SET    course_code = ?, course_title = ?, paper_type = ?, " +
            "       academic_session = ?, semester = ?, deadline = ?, " +
            "       instructions = ?, weightage = ?, " +
            "       submission_mode = ?, assign_marks = ? " +
            "WHERE  paper_id = ? " +
            "AND    status IN ('DRAFT','REJECTED','NEEDS_IMPROVEMENT')";

        try (Connection con = util.DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1,  a.getCourseCode());
            ps.setString(2,  a.getCourseTitle());
            ps.setString(3,  a.getPaperType());
            ps.setString(4,  a.getAcademicSession());
            ps.setInt   (5,  a.getSemester());
            ps.setString(6,  a.getDeadline());
            ps.setString(7,  a.getInstructions());
            ps.setDouble(8,  a.getWeightage());
            ps.setString(9,  a.getSubmissionMode());
            ps.setInt   (10, a.getAssignMarks());
            ps.setInt   (11, a.getPaperId());
            ps.executeUpdate();
        }
    }

    /**
     * Reads rubric row arrays from the form POST and saves them via RubricDAO.
     * Uses delete-and-reinsert — replaces whatever was saved before.
     *
     * Form field names (all arrays):
     *   rubricCriterion[], rubricMarks[], rubricClo[], rubricBloom[], rubricDesc[]
     */
    private void saveRubric(HttpServletRequest req, int paperId) throws Exception {
        String[] criteria    = safeArray(req.getParameterValues("rubricCriterion[]"));
        String[] marksArr    = safeArray(req.getParameterValues("rubricMarks[]"));
        String[] clos        = safeArray(req.getParameterValues("rubricClo[]"));
        String[] blooms      = safeArray(req.getParameterValues("rubricBloom[]"));
        String[] descs       = safeArray(req.getParameterValues("rubricDesc[]"));

        int len = criteria.length;
        List<RubricRow> rows = new ArrayList<>();

        for (int i = 0; i < len; i++) {
            String crit = trimStr(safeGet(criteria, i));
            if (crit.isEmpty()) continue;  // skip empty rows

            RubricRow r = new RubricRow();
            r.setPaperId   (paperId);
            r.setRowOrder  (i + 1);
            r.setCriterion (crit);
            r.setMarks     (safeInt(safeGet(marksArr, i), 0));
            r.setClo       (blankToNull(safeGet(clos,    i)));
            r.setBloom     (blankToNull(safeGet(blooms,  i)));
            r.setDescription(trimStr(safeGet(descs, i)));
            rows.add(r);
        }

        rubricDAO.saveAll(paperId, rows);
    }

    // ── Utility ───────────────────────────────────────────────────────

    private int    safeInt   (String s, int def) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return def; }
    }
    private double safeDouble(String s) {
        try { return Double.parseDouble(s.trim()); } catch (Exception e) { return 0; }
    }
    private String trimStr(String s) {
        return s != null ? s.trim() : "";
    }
    private String trimStr(String s, String def) {
        String t = trimStr(s);
        return t.isEmpty() ? def : t;
    }
    private String blankToNull(String s) {
        String t = trimStr(s);
        return t.isEmpty() ? null : t;
    }
    private String[] safeArray(String[] arr) {
        return arr != null ? arr : new String[0];
    }
    private String safeGet(String[] arr, int i) {
        return (arr != null && i < arr.length && arr[i] != null) ? arr[i] : "";
    }
}
