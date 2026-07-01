package Controller;

import DAO.AssessmentDAO;
import DAO.QuestionDAO;
import DAO.CourseDAO;
import Model.Assessment;
import Model.Course;
import Model.Question;
import util.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.FileOutputStream;
import java.util.List;

/**
 * NewPaperServlet — handles all exam paper builder actions.
 *
 * GET ?action=new  → blank paper builder
 * GET ?action=edit&amp;paperId=X → load existing DRAFT for editing
 * GET ?action=view&amp;paperId=X → read-only view of submitted paper
 *
 * POST action=saveDraft  → save paper + questions, stay on builder
 * POST action=submit     → save then change status to SUBMITTED
 * POST action=deleteQuestion → remove one question row
 *
 * NOTE: Uses if-else instead of switch for Java 8 compatibility (NetBeans)
 */
@WebServlet("/NewPaperServlet")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024) // 5 MB — question images
public class NewPaperServlet extends HttpServlet {

    private final AssessmentDAO assessmentDAO = new AssessmentDAO();
    private final QuestionDAO   questionDAO   = new QuestionDAO();
    private final CourseDAO     courseDAO     = new CourseDAO();

    // ── GET: load the builder page ───────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        String sessionRole = (String) session.getAttribute("role");
        boolean isVetter   = Boolean.TRUE.equals(session.getAttribute("isVetter"));

        if (sessionRole == null
                || (!sessionRole.equalsIgnoreCase("LECTURER") && !isVetter)) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        int    lecturerId = (int) session.getAttribute("userId");
        String action     = req.getParameter("action");
        if (action == null) { action = "new"; }

        // Route continuous assessments to AssignmentServlet
        String category = req.getParameter("category");
        if ("continuous".equals(category)) {
            String type = req.getParameter("type");
            res.sendRedirect(req.getContextPath() + "/AssignmentServlet?action=new"
                    + (type != null ? "&type=" + java.net.URLEncoder.encode(type, "UTF-8") : ""));
            return;
        }

        try {
            List<Course> courses = courseDAO.getCoursesByLecturerId(lecturerId);
            req.setAttribute("courses", courses);

            if ("edit".equals(action) || "view".equals(action)) {
                int paperId = Integer.parseInt(req.getParameter("paperId"));
                Assessment paper = assessmentDAO.getAssessmentById(paperId);

                if (paper == null || paper.getLecturerId() != lecturerId) {
                    res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
                    return;
                }

                List<Question> questions = questionDAO.getQuestionsByPaperId(paperId);
                int totalMarks = questionDAO.getTotalMarksByPaperId(paperId);

                req.setAttribute("paper",      paper);
                req.setAttribute("questions",  questions);
                req.setAttribute("totalMarks", totalMarks);
                req.setAttribute("readOnly",   "view".equals(action) || !paper.isEditable());
            }

            String presetType = req.getParameter("paperType");
            if (presetType != null && !presetType.isEmpty()) {
                req.setAttribute("presetPaperType", presetType);
            }
            req.setAttribute("action", action);
            req.getRequestDispatcher("/examPaper.jsp").forward(req, res);

        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error loading exam paper builder", e);
        }
    }

    // ── POST: handle form submissions ────────────────────────────────
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
        if (action == null) { action = ""; }

        try {
            if ("saveDraft".equals(action)) {
                int paperId = savePaperAndQuestions(req, lecturerId);
                res.sendRedirect(req.getContextPath()
                        + "/NewPaperServlet?action=edit&paperId=" + paperId + "&saved=true");

            } else if ("submit".equals(action)) {
                int paperId = savePaperAndQuestions(req, lecturerId);

                int totalMarks = questionDAO.getTotalMarksByPaperId(paperId);
                if (totalMarks != 100) {
                    res.sendRedirect(req.getContextPath()
                            + "/NewPaperServlet?action=edit&paperId=" + paperId
                            + "&error=marks&total=" + totalMarks);
                    return;
                }

                boolean ok = assessmentDAO.submitAssessment(paperId, lecturerId);
                if (!ok) {
                    res.sendRedirect(req.getContextPath()
                            + "/NewPaperServlet?action=edit&paperId=" + paperId
                            + "&error=submit");
                    return;
                }
                res.sendRedirect(req.getContextPath()
                        + "/LecturerDashboardServlet?page=assessments&submitted=true");

            } else if ("resubmit".equals(action)) {
                int paperId = savePaperAndQuestions(req, lecturerId);

                int totalMarks = questionDAO.getTotalMarksByPaperId(paperId);
                if (totalMarks != 100) {
                    res.sendRedirect(req.getContextPath()
                            + "/NewPaperServlet?action=edit&paperId=" + paperId
                            + "&error=marks&total=" + totalMarks);
                    return;
                }

                boolean ok = assessmentDAO.submitAssessment(paperId, lecturerId);
                if (!ok) {
                    res.sendRedirect(req.getContextPath()
                            + "/NewPaperServlet?action=edit&paperId=" + paperId
                            + "&error=resubmit");
                    return;
                }
                res.sendRedirect(req.getContextPath()
                        + "/LecturerDashboardServlet?page=assessments&submitted=true");

            } else if ("deleteQuestion".equals(action)) {
                int questionId = Integer.parseInt(req.getParameter("questionId"));
                int paperId    = Integer.parseInt(req.getParameter("paperId"));
                questionDAO.deleteQuestion(questionId);
                updateQuestionCount(paperId);
                res.sendRedirect(req.getContextPath()
                        + "/NewPaperServlet?action=edit&paperId=" + paperId);

            } else {
                res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error in NewPaperServlet POST: " + action, e);
        }
    }

    // ── Save/update paper header + all question rows from form ───────
    private int savePaperAndQuestions(HttpServletRequest req, int lecturerId)
            throws Exception {

        Assessment a = new Assessment();
        a.setLecturerId(lecturerId);
        a.setCourseCode(req.getParameter("courseCode"));
        a.setCourseTitle(req.getParameter("courseTitle"));
        a.setFaculty(req.getParameter("faculty") != null ? req.getParameter("faculty") : "FSKM");
        a.setPaperType(req.getParameter("paperType"));
        a.setAcademicSession(req.getParameter("academicSession"));
        a.setSemester(safeInt(req.getParameter("semester"), 1));
        a.setDeadline(req.getParameter("deadline"));

        if (a.getCourseCode() == null || a.getCourseCode().trim().isEmpty()) {
            throw new Exception("Course code is required. Please select a course.");
        }
        if (a.getPaperType() == null || a.getPaperType().trim().isEmpty()) {
            throw new Exception("Assessment type is required. Please select a type.");
        }

        String paperIdParam = req.getParameter("paperId");
        int paperId;

        if (paperIdParam == null || paperIdParam.trim().isEmpty() || "0".equals(paperIdParam.trim())) {
            paperId = assessmentDAO.createAssessment(a);
            if (paperId == 0) {
                throw new Exception("Failed to create paper. Check that course code and paper type are valid.");
            }
        } else {
            paperId = Integer.parseInt(paperIdParam.trim());
            a.setPaperId(paperId);
            updateAssessmentHeader(a);
        }

        // Read question arrays from form
        String[] questionIds      = req.getParameterValues("questionId");
        String[] questionNos      = req.getParameterValues("questionNo");
        String[] questionTypes    = req.getParameterValues("questionType");
        String[] questionFormats  = req.getParameterValues("questionFormat");
        String[] statement1s      = req.getParameterValues("statement1");
        String[] statement2s      = req.getParameterValues("statement2");
        String[] statement3s      = req.getParameterValues("statement3");
        String[] statement4s      = req.getParameterValues("statement4");
        String[] tableDatas       = req.getParameterValues("tableData");
        String[] existingImageUrls= req.getParameterValues("existingImageUrl");
        String[] imagePartNames   = req.getParameterValues("imagePartName");
        String[] questionTexts    = req.getParameterValues("questionText");
        String[] questionTextsMs  = req.getParameterValues("questionTextMs");
        String[] marksArr         = req.getParameterValues("marks");
        String[] chapters         = req.getParameterValues("chapter");
        String[] taxonomyLevels   = req.getParameterValues("taxonomyLevel");
        String[] cloMappings      = req.getParameterValues("cloMapping");
        String[] choiceAs         = req.getParameterValues("choiceA");
        String[] choiceBs         = req.getParameterValues("choiceB");
        String[] choiceCs         = req.getParameterValues("choiceC");
        String[] choiceDs         = req.getParameterValues("choiceD");
        String[] correctAnswerKeys= req.getParameterValues("correctAnswerKey");

        int newQIndex = 0;
        if (questionIds != null) {
            for (int i = 0; i < questionIds.length; i++) {
                Question q = new Question();
                q.setPaperId(paperId);
                q.setQuestionNo(get(questionNos, i, String.valueOf(i + 1)));
                q.setQuestionType(get(questionTypes, i, "OBJECTIVE"));
                q.setQuestionFormat(get(questionFormats, i, "SIMPLE"));
                q.setStatement1(get(statement1s, i, null));
                q.setStatement2(get(statement2s, i, null));
                q.setStatement3(get(statement3s, i, null));
                q.setStatement4(get(statement4s, i, null));
                q.setTableData(get(tableDatas, i, null));
                q.setQuestionText(get(questionTexts, i, ""));
                q.setQuestionTextMs(get(questionTextsMs, i, null));
                q.setMarks(safeInt(get(marksArr, i, "0"), 0));
                q.setChapter(get(chapters, i, ""));
                q.setTaxonomyLevel(get(taxonomyLevels, i, "C1"));
                q.setCloMapping(get(cloMappings, i, "CLO1"));
                q.setChoiceA(get(choiceAs, i, null));
                q.setChoiceB(get(choiceBs, i, null));
                q.setChoiceC(get(choiceCs, i, null));
                q.setChoiceD(get(choiceDs, i, null));

                // Process Parts
                String[] pLabels = req.getParameterValues("partLabel_" + i);
                String[] pTexts = req.getParameterValues("partText_" + i);
                String[] pMarks = req.getParameterValues("partMarks_" + i);
                String[] pAns = req.getParameterValues("partModelAnswer_" + i);

                if (pLabels != null) {
                    java.util.List<Model.QuestionPart> pList = new java.util.ArrayList<>();
                    for (int j = 0; j < pLabels.length; j++) {
                        Model.QuestionPart p = new Model.QuestionPart();
                        p.setPartLabel(pLabels[j]);
                        p.setPartQuestionText(get(pTexts, j, ""));
                        p.setPartMarks(safeInt(get(pMarks, j, "0"), 0));
                        p.setPartModelAnswer(get(pAns, j, ""));
                        pList.add(p);
                    }
                    q.setParts(pList);
                }

                // Image: try new upload first, fall back to existing URL
                String partNameForRow  = get(imagePartNames, i, null);
                String uploadedImage   = (partNameForRow != null) ? saveQuestionImage(req, partNameForRow) : null;
                if (uploadedImage != null) {
                    q.setImageUrl(uploadedImage);
                } else {
                    q.setImageUrl(get(existingImageUrls, i, null));
                }

                // Correct answer
                String qIdForAns = questionIds[i];
                String correctAns = null;
                if (qIdForAns != null && !qIdForAns.trim().isEmpty() && !"0".equals(qIdForAns.trim())) {
                    correctAns = req.getParameter("correctAnswer_" + qIdForAns.trim());
                } else {
                    String radioKey = (correctAnswerKeys != null && newQIndex < correctAnswerKeys.length)
                            ? correctAnswerKeys[newQIndex] : null;
                    if (radioKey != null && !radioKey.trim().isEmpty()) {
                        correctAns = req.getParameter(radioKey.trim());
                    }
                    newQIndex++;
                }
                q.setCorrectAnswer(correctAns != null ? correctAns.trim() : null);

                String qIdStr = questionIds[i];
                if (qIdStr == null || qIdStr.trim().isEmpty() || "0".equals(qIdStr.trim())) {
                    questionDAO.addQuestion(q);
                } else {
                    q.setQuestionId(Integer.parseInt(qIdStr.trim()));
                    questionDAO.updateQuestion(q);
                }
            }
        }

        updateQuestionCount(paperId);
        return paperId;
    }

    // ── Update just the header fields of an existing paper ──────────
    private void updateAssessmentHeader(Assessment a) throws Exception {
        String sql = "UPDATE exam_papers "
                + "SET course_code = ?, course_title = ?, paper_type = ?, "
                + "    academic_session = ?, semester = ?, deadline = ?, faculty = ? "
                + "WHERE paper_id = ? AND status IN ('DRAFT', 'REJECTED', 'NEEDS_IMPROVEMENT')";

        try (java.sql.Connection con = DBConnection.getConnection();
             java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, a.getCourseCode());
            ps.setString(2, a.getCourseTitle());
            ps.setString(3, a.getPaperType());
            ps.setString(4, a.getAcademicSession());
            ps.setInt   (5, a.getSemester());
            ps.setString(6, a.getDeadline());
            ps.setString(7, a.getFaculty());
            ps.setInt   (8, a.getPaperId());
            ps.executeUpdate();
        }
    }

    // ── Recalculate total_questions count in exam_papers ────────────
    private void updateQuestionCount(int paperId) throws Exception {
        String sql = "UPDATE exam_papers "
                + "SET total_questions = (SELECT COUNT(*) FROM questions WHERE paper_id = ?) "
                + "WHERE paper_id = ?";
        try (java.sql.Connection con = DBConnection.getConnection();
             java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId);
            ps.setInt(2, paperId);
            ps.executeUpdate();
        }
    }

    // ── Save an uploaded question image → web/images/questions/ ─────
    private String saveQuestionImage(HttpServletRequest req, String partName)
            throws IOException, ServletException {
        Part part = req.getPart(partName);
        if (part == null || part.getSize() <= 0) { return null; }
        
        // Extract filename manually for Servlet 3.0 compatibility
        String submitted = null;
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp != null) {
            for (String content : contentDisp.split(";")) {
                if (content.trim().startsWith("filename")) {
                    submitted = content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
                    break;
                }
            }
        }
        if (submitted == null || submitted.trim().isEmpty()) { return null; }

         
        String ext = "";
        int dot = submitted.lastIndexOf('.');
        if (dot >= 0) {
            ext = submitted.substring(dot).toLowerCase().replaceAll("[^a-z0-9.]", "");
        }
        String fileName = "q_" + System.currentTimeMillis()
                        + "_" + (int)(Math.random() * 10000) + ext;

        
        
        
        
        
        
        String uploadDir = getServletContext().getRealPath("/images/questions");
        File dir = new File(uploadDir);
        if (!dir.exists()) { dir.mkdirs(); }

        try (InputStream in  = part.getInputStream();
             FileOutputStream out = new FileOutputStream(new File(dir, fileName))) {
            byte[] buf = new byte[8192];
            int n;
            while ((n = in.read(buf)) != -1) { out.write(buf, 0, n); }
        }
        return req.getContextPath() + "/images/questions/" + fileName;
    }

    // ── Safe array get with fallback default ────────────────────────
    private String get(String[] arr, int i, String def) {
        return (arr != null && i < arr.length && arr[i] != null) ? arr[i] : def;
    }

    // ── Safe parseInt with fallback default ─────────────────────────
    private int safeInt(String s, int def) {
        if (s == null) { return def; }
        try { return Integer.parseInt(s.trim()); }
        catch (NumberFormatException e) { return def; }
    }
}
