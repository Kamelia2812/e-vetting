package Controller;

import DAO.AssessmentDAO;
import DAO.JSSDAO;
import DAO.CourseDAO;
import DAO.QuestionDAO;
import Model.Assessment;
import Model.JSS;
import Model.JSSRow;
import Model.Course;
import Model.Question;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * JSSServlet — handles loading and saving the JSS form.
 *
 * URL: /JSSServlet
 *
 * GET ?paperId=X → load JSS for this paper (create empty if first time) POST
 * action=saveDraft → save all JSS rows as DRAFT POST action=submit → save and
 * mark as SUBMITTED
 */
@WebServlet("/JSSServlet")
public class JSSServlet extends HttpServlet {

    private final JSSDAO jssDAO = new JSSDAO();
    private final AssessmentDAO assessmentDAO = new AssessmentDAO();
    private final CourseDAO courseDAO = new CourseDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        if (!"LECTURER".equalsIgnoreCase((String) session.getAttribute("role"))) {
            res.sendRedirect(req.getContextPath() + "/unauthorized.jsp");
            return;
        }

        int lecturerId = (int) session.getAttribute("userId");

        try {
            String paperIdParam = req.getParameter("paperId");
            String courseIdParam = req.getParameter("courseId");

            int paperId = (paperIdParam != null && !paperIdParam.trim().isEmpty()) ? Integer.parseInt(paperIdParam.trim()) : 0;
            int courseId = (courseIdParam != null && !courseIdParam.trim().isEmpty()) ? Integer.parseInt(courseIdParam.trim()) : 0;

            Assessment paper = null;
            Course course = null;

            if (paperId > 0) {
                // Load by paperId — normal flow from exam paper builder
                paper = assessmentDAO.getAssessmentById(paperId);
                if (paper == null || paper.getLecturerId() != lecturerId) {
                    res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
                    return;
                }
                course = courseDAO.getCourseByCode(paper.getCourseCode());
            } else if (courseId > 0) {
                // Load by courseId — from dashboard JSS tab
                course = courseDAO.getCourseById(courseId);
                if (course == null) {
                    res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
                    return;
                }
                // Find the most recent final exam paper for this course by this lecturer
                List<Assessment> papers = assessmentDAO.getAssessmentsByLecturerId(lecturerId);
                for (Assessment a : papers) {
                    if (course.getCourseCode().equals(a.getCourseCode()) && a.isFinalAssessment()) {
                        paper = a;
                        paperId = a.getPaperId();
                        break;
                    }
                }
                // If no paper exists yet, still show empty JSS with course info
            } else {
                res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
                return;
            }

            // Load or initialise JSS
            JSS jss = paperId > 0 ? jssDAO.getJSSByPaperId(paperId) : null;

            // ── Auto-generate JSS rows from questions if JSS is empty ──
            List<JSSRow> autoRows = new java.util.ArrayList<>();
            if ((jss == null || jss.getRows() == null || jss.getRows().isEmpty()) && paperId > 0) {
                List<Question> questions = questionDAO.getQuestionsByPaperId(paperId);
                if (questions != null && !questions.isEmpty()) {
                    int qNum = 1;
                    for (Question q : questions) {
                        JSSRow row = new JSSRow();
                        row.setRowOrder(qNum);
                        row.setTopicName(q.getChapter() != null && !q.getChapter().isEmpty()
                                ? q.getChapter() : "Topic " + qNum);
                        row.setQuestionNo(String.valueOf(qNum));
                        // Map question type: OBJECTIVE→O, STRUCTURE→S, ESSAY→E
                        String qt = q.getQuestionType();
                        row.setQuestionType("OBJECTIVE".equals(qt) ? "O" : "STRUCTURE".equals(qt) ? "S" : "E");
                        row.setMarks(q.getMarks());
                        row.setClo(q.getCloMapping() != null ? q.getCloMapping() : "");
                        row.setTaxonomyLevel(q.getTaxonomyLevel() != null ? q.getTaxonomyLevel() : "");
                        row.setPlo(""); // lecturer fills PLO manually
                        autoRows.add(row);
                        qNum++;
                    }
                    req.setAttribute("autoGenerated", true);
                }
            }
            req.setAttribute("autoRows", autoRows);

            req.setAttribute("paper", paper);
            req.setAttribute("jss", jss);
            req.setAttribute("course", course);
            req.getRequestDispatcher("/JSS.jsp").forward(req, res);

        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error loading JSS", e);
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

        int lecturerId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        try {
            int paperId = Integer.parseInt(req.getParameter("paperId"));
            int courseId = Integer.parseInt(req.getParameter("courseId"));

            // Load or create the JSS header
            JSS jss = jssDAO.getJSSByPaperId(paperId);
            int jssId;

            if (jss == null) {
                // Create JSS header for the first time
                JSS newJss = new JSS();
                newJss.setPaperId(paperId);
                newJss.setCourseId(courseId);
                newJss.setLecturerId(lecturerId);
                newJss.setFaculty(req.getParameter("faculty"));
                newJss.setProgramme(req.getParameter("programme"));
                newJss.setAcademicSession(req.getParameter("academicSession"));
                newJss.setSemester(safeInt(req.getParameter("semester"), 1));
                newJss.setAssessmentType(req.getParameter("assessmentType"));
                jssId = jssDAO.createJSS(newJss);
            } else {
                jssId = jss.getJssId();
            }

            // Build rows from form arrays
            // Form sends: topicName[], lectureHours[], questionNo[], plo[], clo[],
            //             questionType[], marks[], taxonomyLevel[]
            List<JSSRow> rows = buildRowsFromRequest(req, jssId);
            jssDAO.saveRows(jssId, rows);

            // Redirect back with success message
            String redirect = req.getContextPath() + "/JSSServlet?paperId=" + paperId + "&saved=true";
            res.sendRedirect(redirect);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error saving JSS", e);
        }
    }

    // ── Build JSSRow list from submitted form arrays ─────────────────────
    private List<JSSRow> buildRowsFromRequest(HttpServletRequest req, int jssId) {
        List<JSSRow> rows = new ArrayList<>();

        String[] topics = req.getParameterValues("topicName");
        String[] hours = req.getParameterValues("lectureHours");
        String[] qNos = req.getParameterValues("questionNo");
        String[] plos = req.getParameterValues("plo");
        String[] clos = req.getParameterValues("clo");
        String[] types = req.getParameterValues("questionType");
        String[] marksArr = req.getParameterValues("marks");
        String[] blooms = req.getParameterValues("taxonomyLevel");

        if (topics == null) {
            return rows;
        }

        for (int i = 0; i < topics.length; i++) {
            JSSRow r = new JSSRow();
            r.setJssId(jssId);
            r.setRowOrder(i);
            r.setTopicName(get(topics, i));
            r.setLectureHours(safeDouble(get(hours, i)));
            r.setQuestionNo(get(qNos, i));
            r.setPlo(get(plos, i));
            r.setClo(get(clos, i));
            r.setQuestionType(get(types, i, "O"));
            r.setMarks(safeInt(get(marksArr, i), 0));
            r.setTaxonomyLevel(get(blooms, i, "C1"));
            rows.add(r);
        }
        return rows;
    }

    private String get(String[] arr, int i) {
        return get(arr, i, "");
    }

    private String get(String[] arr, int i, String def) {
        return (arr != null && i < arr.length && arr[i] != null) ? arr[i] : def;
    }

    private int safeInt(String s, int def) {
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return def;
        }
    }

    private double safeDouble(String s) {
        try {
            return Double.parseDouble(s.trim());
        } catch (Exception e) {
            return 0;
        }
    }
}
