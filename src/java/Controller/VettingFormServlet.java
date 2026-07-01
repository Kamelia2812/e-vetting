package Controller;

import Model.Assessment;
import DAO.AssessmentDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;

/**
 * VettingFormServlet — FAP/01(a) and FAP/01(b) digital vetting forms.
 *
 * GET  ?action=new&amp;paperId=X     — open blank form for the given paper
 * GET  ?action=edit&amp;formId=X     — reload a saved draft
 * GET  ?action=view&amp;formId=X     — read-only view
 *
 * POST action=saveDraft  — save/update as DRAFT
 * POST action=submit     — save/update then mark as SUBMITTED
 */
@WebServlet("/VettingFormServlet")
public class VettingFormServlet extends HttpServlet {

    private final AssessmentDAO assessmentDAO = new AssessmentDAO();

    // ── GET ──────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "new";

        try {
            if ("new".equals(action)) {
                int paperId = Integer.parseInt(req.getParameter("paperId"));
                Assessment paper = assessmentDAO.getAssessmentById(paperId);
                if (paper == null) {
                    res.sendRedirect(req.getContextPath() + "/VetterDashboardServlet");
                    return;
                }

                // Determine form type from paper type
                String formType = isFinalExam(paper.getPaperType()) ? "FAP01a" : "FAP01b";

                req.setAttribute("paper", paper);
                req.setAttribute("formType", formType);
                req.setAttribute("action", "new");
                req.setAttribute("form", null); // no existing form data
                req.getRequestDispatcher("/vetFAP01.jsp").forward(req, res);

            } else if ("edit".equals(action) || "view".equals(action)) {
                int formId = Integer.parseInt(req.getParameter("formId"));
                VettingFormBean form = loadForm(formId);
                if (form == null) {
                    res.sendRedirect(req.getContextPath() + "/VetterDashboardServlet");
                    return;
                }
                Assessment paper = assessmentDAO.getAssessmentById(form.paperId);

                req.setAttribute("paper", paper);
                req.setAttribute("formType", form.formType);
                req.setAttribute("form", form);
                req.setAttribute("action", action);
                req.setAttribute("readOnly", "view".equals(action));
                req.getRequestDispatcher("/vetFAP01.jsp").forward(req, res);

            } else {
                res.sendRedirect(req.getContextPath() + "/VetterDashboardServlet");
            }

        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/VetterDashboardServlet");
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error in VettingFormServlet GET", e);
        }
    }

    // ── POST ─────────────────────────────────────────────────────────────────
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
            if ("saveDraft".equals(action) || "submit".equals(action)) {
                int formId = saveForm(req, userId, "submit".equals(action));
                if ("submit".equals(action)) {
                    res.sendRedirect(req.getContextPath()
                            + "/VettingFormServlet?action=view&amp;formId=" + formId + "&submitted=true");
                } else {
                    res.sendRedirect(req.getContextPath()
                            + "/VettingFormServlet?action=edit&amp;formId=" + formId + "&saved=true");
                }
            } else {
                res.sendRedirect(req.getContextPath() + "/VetterDashboardServlet");
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error in VettingFormServlet POST: " + action, e);
        }
    }

    // ── Save form (insert or update) ─────────────────────────────────────────
    private int saveForm(HttpServletRequest req, int userId, boolean submit) throws Exception {
        String formIdStr = req.getParameter("formId");
        int    paperId   = Integer.parseInt(req.getParameter("paperId"));
        String formType  = req.getParameter("formType");

        // Section A
        String programme      = req.getParameter("programme");
        String eqCode1 = req.getParameter("eq_code1"); String eqName1 = req.getParameter("eq_name1");
        String eqCode2 = req.getParameter("eq_code2"); String eqName2 = req.getParameter("eq_name2");
        String eqCode3 = req.getParameter("eq_code3"); String eqName3 = req.getParameter("eq_name3");
        String creditHoursStr = req.getParameter("credit_hours");
        String totalStudentsStr = req.getParameter("total_students");

        // FAP01a specific
        String numObjStr  = req.getParameter("num_objective");
        String numStrStr  = req.getParameter("num_structure");
        String numEssStr  = req.getParameter("num_essay");
        String toAnswerStr = req.getParameter("total_to_answer");
        String examDur    = req.getParameter("exam_duration");

        // FAP01b specific
        String assessTypeDesc = req.getParameter("assessment_type_desc");
        String weightPctStr   = req.getParameter("weightage_percent");
        String taskDur        = req.getParameter("task_duration");

        // JSON blobs
        String cloData      = req.getParameter("clo_data");
        String sectionBData = req.getParameter("section_b_data");
        String sectionCData = req.getParameter("section_c_data");

        // Verification
        String overallRemarks = req.getParameter("overall_remarks");
        String vetterName     = req.getParameter("vetter_name");
        String vetterDate     = req.getParameter("vetter_date");
        String lecturerSignName = req.getParameter("lecturer_sign_name");
        String lecturerSignDate = req.getParameter("lecturer_sign_date");
        String headVetterName = req.getParameter("head_vetter_name");
        String headVetterDate = req.getParameter("head_vetter_date");
        String isImprovedStr  = req.getParameter("is_improved");
        String improvJustification = req.getParameter("improvement_justification");
        String improvElaboration   = req.getParameter("improvement_elaboration");

        String status = submit ? "SUBMITTED" : "DRAFT";

        try (Connection con = util.DBConnection.getConnection()) {
            if (formIdStr == null || formIdStr.trim().isEmpty() || "0".equals(formIdStr.trim())) {
                // INSERT
                String sql = "INSERT INTO vetting_forms (paper_id, form_type, created_by, "
                        + "programme, eq_code1, eq_name1, eq_code2, eq_name2, eq_code3, eq_name3, "
                        + "credit_hours, total_students, "
                        + "num_objective, num_structure, num_essay, total_to_answer, exam_duration, "
                        + "assessment_type_desc, weightage_percent, task_duration, "
                        + "clo_data, section_b_data, section_c_data, overall_remarks, "
                        + "vetter_name, vetter_date, lecturer_sign_name, lecturer_sign_date, "
                        + "head_vetter_name, head_vetter_date, "
                        + "is_improved, improvement_justification, improvement_elaboration, form_status) "
                        + "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
                try (PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                    setFormParams(ps, paperId, formType, userId,
                            programme, eqCode1, eqName1, eqCode2, eqName2, eqCode3, eqName3,
                            creditHoursStr, totalStudentsStr,
                            numObjStr, numStrStr, numEssStr, toAnswerStr, examDur,
                            assessTypeDesc, weightPctStr, taskDur,
                            cloData, sectionBData, sectionCData, overallRemarks,
                            vetterName, vetterDate, lecturerSignName, lecturerSignDate,
                            headVetterName, headVetterDate,
                            isImprovedStr, improvJustification, improvElaboration, status);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) return rs.getInt(1);
                    }
                }
            } else {
                // UPDATE
                int formId = Integer.parseInt(formIdStr.trim());
                String sql = "UPDATE vetting_forms SET "
                        + "form_type=?, programme=?, eq_code1=?, eq_name1=?, eq_code2=?, eq_name2=?, "
                        + "eq_code3=?, eq_name3=?, credit_hours=?, total_students=?, "
                        + "num_objective=?, num_structure=?, num_essay=?, total_to_answer=?, exam_duration=?, "
                        + "assessment_type_desc=?, weightage_percent=?, task_duration=?, "
                        + "clo_data=?, section_b_data=?, section_c_data=?, overall_remarks=?, "
                        + "vetter_name=?, vetter_date=?, lecturer_sign_name=?, lecturer_sign_date=?, "
                        + "head_vetter_name=?, head_vetter_date=?, "
                        + "is_improved=?, improvement_justification=?, improvement_elaboration=?, form_status=? "
                        + "WHERE form_id=?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    int i = 1;
                    ps.setString(i++, formType);
                    ps.setString(i++, programme);
                    ps.setString(i++, eqCode1);    ps.setString(i++, eqName1);
                    ps.setString(i++, eqCode2);    ps.setString(i++, eqName2);
                    ps.setString(i++, eqCode3);    ps.setString(i++, eqName3);
                    ps.setObject(i++, parseDecimal(creditHoursStr));
                    ps.setObject(i++, parseInt(totalStudentsStr));
                    ps.setObject(i++, parseInt(numObjStr));
                    ps.setObject(i++, parseInt(numStrStr));
                    ps.setObject(i++, parseInt(numEssStr));
                    ps.setObject(i++, parseInt(toAnswerStr));
                    ps.setString(i++, examDur);
                    ps.setString(i++, assessTypeDesc);
                    ps.setObject(i++, parseDecimal(weightPctStr));
                    ps.setString(i++, taskDur);
                    ps.setString(i++, cloData);
                    ps.setString(i++, sectionBData);
                    ps.setString(i++, sectionCData);
                    ps.setString(i++, overallRemarks);
                    ps.setString(i++, vetterName);     ps.setString(i++, vetterDate);
                    ps.setString(i++, lecturerSignName); ps.setString(i++, lecturerSignDate);
                    ps.setString(i++, headVetterName); ps.setString(i++, headVetterDate);
                    ps.setInt   (i++, "1".equals(isImprovedStr) || "true".equals(isImprovedStr) ? 1 : 0);
                    ps.setString(i++, improvJustification);
                    ps.setString(i++, improvElaboration);
                    ps.setString(i++, status);
                    ps.setInt   (i++, formId);
                    ps.executeUpdate();
                }
                return formId;
            }
        }
        return 0;
    }

    // ── Set all parameters for INSERT ─────────────────────────────────────────
    private void setFormParams(PreparedStatement ps,
            int paperId, String formType, int userId,
            String programme, String eq1c, String eq1n, String eq2c, String eq2n, String eq3c, String eq3n,
            String creditHours, String totalStudents,
            String numObj, String numStr, String numEss, String toAnswer, String examDur,
            String assessType, String weightPct, String taskDur,
            String cloData, String secB, String secC, String remarks,
            String vetterName, String vetterDate, String lecSign, String lecDate,
            String headName, String headDate,
            String isImproved, String justification, String elaboration, String status)
            throws SQLException {
        int i = 1;
        ps.setInt   (i++, paperId);
        ps.setString(i++, formType);
        ps.setInt   (i++, userId);
        ps.setString(i++, programme);
        ps.setString(i++, eq1c); ps.setString(i++, eq1n);
        ps.setString(i++, eq2c); ps.setString(i++, eq2n);
        ps.setString(i++, eq3c); ps.setString(i++, eq3n);
        ps.setObject(i++, parseDecimal(creditHours));
        ps.setObject(i++, parseInt(totalStudents));
        ps.setObject(i++, parseInt(numObj));
        ps.setObject(i++, parseInt(numStr));
        ps.setObject(i++, parseInt(numEss));
        ps.setObject(i++, parseInt(toAnswer));
        ps.setString(i++, examDur);
        ps.setString(i++, assessType);
        ps.setObject(i++, parseDecimal(weightPct));
        ps.setString(i++, taskDur);
        ps.setString(i++, cloData);
        ps.setString(i++, secB);
        ps.setString(i++, secC);
        ps.setString(i++, remarks);
        ps.setString(i++, vetterName);    ps.setString(i++, vetterDate);
        ps.setString(i++, lecSign);       ps.setString(i++, lecDate);
        ps.setString(i++, headName);      ps.setString(i++, headDate);
        ps.setInt   (i++, "1".equals(isImproved) || "true".equals(isImproved) ? 1 : 0);
        ps.setString(i++, justification);
        ps.setString(i++, elaboration);
        ps.setString(i++, status);
    }

    // ── Load form from DB ─────────────────────────────────────────────────────
    private VettingFormBean loadForm(int formId) throws Exception {
        String sql = "SELECT * FROM vetting_forms WHERE form_id = ?";
        try (Connection con = util.DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, formId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    VettingFormBean b = new VettingFormBean();
                    b.formId   = rs.getInt("form_id");
                    b.paperId  = rs.getInt("paper_id");
                    b.formType = rs.getString("form_type");
                    b.createdBy = rs.getInt("created_by");
                    b.programme = rs.getString("programme");
                    b.eqCode1 = rs.getString("eq_code1"); b.eqName1 = rs.getString("eq_name1");
                    b.eqCode2 = rs.getString("eq_code2"); b.eqName2 = rs.getString("eq_name2");
                    b.eqCode3 = rs.getString("eq_code3"); b.eqName3 = rs.getString("eq_name3");
                    b.creditHours   = rs.getString("credit_hours");
                    b.totalStudents = rs.getString("total_students");
                    b.numObjective  = rs.getString("num_objective");
                    b.numStructure  = rs.getString("num_structure");
                    b.numEssay      = rs.getString("num_essay");
                    b.totalToAnswer = rs.getString("total_to_answer");
                    b.examDuration  = rs.getString("exam_duration");
                    b.assessmentTypeDesc = rs.getString("assessment_type_desc");
                    b.weightagePercent   = rs.getString("weightage_percent");
                    b.taskDuration       = rs.getString("task_duration");
                    b.cloData      = rs.getString("clo_data");
                    b.sectionBData = rs.getString("section_b_data");
                    b.sectionCData = rs.getString("section_c_data");
                    b.overallRemarks     = rs.getString("overall_remarks");
                    b.vetterName         = rs.getString("vetter_name");
                    b.vetterDate         = rs.getString("vetter_date");
                    b.lecturerSignName   = rs.getString("lecturer_sign_name");
                    b.lecturerSignDate   = rs.getString("lecturer_sign_date");
                    b.headVetterName     = rs.getString("head_vetter_name");
                    b.headVetterDate     = rs.getString("head_vetter_date");
                    b.isImproved         = rs.getInt("is_improved");
                    b.improvementJustification = rs.getString("improvement_justification");
                    b.improvementElaboration   = rs.getString("improvement_elaboration");
                    b.formStatus = rs.getString("form_status");
                    return b;
                }
            }
        }
        return null;
    }

    /**
     * Find the most recent vetting form for a given paper, or null.
     * Used by vetterDashboard to link to an existing form.
     * (Called as a static helper from JSP via JSTL/scriptlet is awkward;
     *  instead the dashboard servlet should forward a "latestFormId" attribute.)
     */
    public static Integer getLatestFormId(int paperId) {
        String sql = "SELECT form_id FROM vetting_forms WHERE paper_id = ? "
                   + "ORDER BY updated_at DESC LIMIT 1";
        try (Connection con = util.DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private boolean isFinalExam(String paperType) {
        if (paperType == null) return true;
        String pt = paperType.toLowerCase();
        return pt.contains("final exam") || pt.contains("peperiksaan") || pt.contains("examination");
    }

    private Integer parseInt(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return null; }
    }

    private Double parseDecimal(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try { return Double.parseDouble(s.trim()); } catch (NumberFormatException e) { return null; }
    }

    // ── Inner data-transfer bean ──────────────────────────────────────────────
    public static class VettingFormBean {
        public int    formId, paperId, createdBy, isImproved;
        public String formType, formStatus;
        public String programme;
        public String eqCode1, eqName1, eqCode2, eqName2, eqCode3, eqName3;
        public String creditHours, totalStudents;
        public String numObjective, numStructure, numEssay, totalToAnswer, examDuration;
        public String assessmentTypeDesc, weightagePercent, taskDuration;
        public String cloData, sectionBData, sectionCData;
        public String overallRemarks;
        public String vetterName, vetterDate;
        public String lecturerSignName, lecturerSignDate;
        public String headVetterName, headVetterDate;
        public String improvementJustification, improvementElaboration;
        public String s(String v) { return v != null ? v : ""; }
    }
}
