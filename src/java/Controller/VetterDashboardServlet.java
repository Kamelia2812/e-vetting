package Controller;

import DAO.AssessmentDAO;
import DAO.CourseDAO;
import DAO.QuestionCommentDAO;
import DAO.QuestionDAO;
import DAO.RubricDAO;
import DAO.UserDAO;
import Model.Assessment;
import Model.Course;
import Model.Question;
import Model.QuestionComment;
import Model.User;
import Model.VetterCourseInfo;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Servlet for the Vetter Dashboard.
 *
 * GET pages (via ?page= param):
 *   dashboard — summary stat cards
 *   queue     — papers waiting for this vetter to review
 *   review    — per-question review for one specific paper
 *   reviewed  — papers this vetter has already actioned
 *
 * POST actions (via action param):
 *   saveComment        — AJAX: upsert a per-question comment
 *   deleteComment      — AJAX: remove a per-question comment
 *   approve            — set paper status to APPROVED
 *   requestImprovement — set paper status to NEEDS_IMPROVEMENT
 *   reject             — set paper status to REJECTED
 */
@WebServlet("/VetterDashboardServlet")
public class VetterDashboardServlet extends HttpServlet {

    private static final Logger LOG =
            Logger.getLogger(VetterDashboardServlet.class.getName());

    // DAOs are stateless — safe as instance fields
    private final AssessmentDAO         assessmentDAO    = new AssessmentDAO();
    private final QuestionDAO           questionDAO      = new QuestionDAO();
    private final QuestionCommentDAO    commentDAO       = new QuestionCommentDAO();
    private final CourseDAO             courseDAO        = new CourseDAO();
    private final UserDAO               userDAO          = new UserDAO();
    private final RubricDAO             rubricDAO        = new RubricDAO();
    private final DAO.VettingChecklistDAO checklistDAO   = new DAO.VettingChecklistDAO();

    // ─────────────────────────────────────────────────────────────────────────
    // GET
    // ─────────────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (!isVetter(session)) {
            response.sendRedirect("login.jsp");
            return;
        }

        String page = request.getParameter("page");
        if (page == null || page.trim().isEmpty()) page = "dashboard";

        if ("queue".equals(page)) {
            handleQueue(request, response, session);
        } else if ("review".equals(page)) {
            handleReview(request, response, session);
        } else if ("reviewed".equals(page)) {
            handleReviewed(request, response, session);
        } else if ("courses".equals(page) || "teams".equals(page)) {
            handleCoursesAndTeams(request, response, session, page);
        } else {
            handleDashboard(request, response, session);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST
    // ─────────────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String action = request.getParameter("action");
        boolean isAjax = "saveComment".equals(action)
                      || "saveSectionComment".equals(action)
                      || "deleteComment".equals(action)
                      || "saveChecklist".equals(action);

        if (!isAuthorised(session)) {
            if (isAjax) {
                writeJson(response, false, "Session expired — please log in again");
            } else {
                response.sendRedirect("login.jsp");
            }
            return;
        }

        if (action == null || action.trim().isEmpty()) {
            response.sendRedirect("VetterDashboardServlet?page=dashboard");
            return;
        }

        if ("saveChecklist".equals(action)) {
            handleSaveChecklist(request, response, session);
        } else if ("saveComment".equals(action)) {
            handleSaveComment(request, response, session);
        } else if ("saveSectionComment".equals(action)) {
            handleSaveSectionComment(request, response, session);
        } else if ("deleteComment".equals(action)) {
            handleDeleteComment(request, response, session);
        } else if ("approve".equals(action)) {
            handleVerdict(request, response, session, "APPROVED");
        } else if ("requestImprovement".equals(action)) {
            handleVerdict(request, response, session, "NEEDS_IMPROVEMENT");
        } else if ("reject".equals(action)) {
            handleVerdict(request, response, session, "REJECTED");
        } else if ("leaderApprove".equals(action)) {
            handleLeaderApprove(request, response, session);
        } else if ("signAndSend".equals(action)) {
            handleSignAndSend(request, response, session);
        } else {
            response.sendRedirect("VetterDashboardServlet?page=dashboard");
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GET handlers
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Dashboard tab — loads pending count, reviewed count, and course count.
     */
    private void handleDashboard(HttpServletRequest request,
                                  HttpServletResponse response,
                                  HttpSession session)
            throws ServletException, IOException {

        int vetterId = (Integer) session.getAttribute("userId");

        try {
            List<Assessment> pending  = assessmentDAO.getPendingForVetter(vetterId);
            List<Assessment> reviewed = assessmentDAO.getReviewedByVetter(vetterId);
            List<Course> courses  = courseDAO.getCoursesByVetterId(vetterId);

            // Lecturer assignment rows (course + lecturer + paper status summary)
            List<LecturerRow> lecturerRows = getLecturerAssignments(vetterId);

            // Count papers approved by this vetter (any time)
            int approvedByMe = countApprovedByVetter(vetterId);

            request.setAttribute("pendingCount",   pending.size());
            request.setAttribute("reviewedCount",  reviewed.size());
            request.setAttribute("courseCount",    courses.size());
            request.setAttribute("approvedCount",  approvedByMe);
            request.setAttribute("lecturerRows",   lecturerRows);
            // Pass recent pending items (up to 3) for the dashboard preview
            request.setAttribute("recentPending",
                    pending.size() > 3 ? pending.subList(0, 3) : pending);
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "handleDashboard failed", e);
            request.setAttribute("pendingCount",  0);
            request.setAttribute("reviewedCount", 0);
            request.setAttribute("courseCount",   0);
            request.setAttribute("approvedCount", 0);
            request.setAttribute("lecturerRows",  new ArrayList<>());
            request.setAttribute("recentPending", new ArrayList<>());
        }

        request.setAttribute("page", "dashboard");
        forward(request, response, "/vetterDashboard.jsp");
    }

    /**
     * Queue tab — papers awaiting review by this vetter.
     */
    private void handleQueue(HttpServletRequest request,
                              HttpServletResponse response,
                              HttpSession session)
            throws ServletException, IOException {

        int vetterId = (Integer) session.getAttribute("userId");

        try {
            List<Assessment> pending = assessmentDAO.getPendingForVetter(vetterId);
            java.util.Collections.sort(pending, new java.util.Comparator<Assessment>() {
                public int compare(Assessment a1, Assessment a2) {
                    java.util.Date d1 = a1.getSubmittedDate();
                    java.util.Date d2 = a2.getSubmittedDate();
                    if (d1 == null && d2 == null) return 0;
                    if (d1 == null) return 1;
                    if (d2 == null) return -1;
                    return d1.compareTo(d2); // Oldest first
                }
            });
            List<Assessment> leaderPending = assessmentDAO.getPendingLeaderSign(vetterId);
            List<Assessment> leaderApproved = assessmentDAO.getLeaderApproved(vetterId);
            request.setAttribute("pendingPapers",  pending);
            request.setAttribute("leaderPending",  leaderPending);
            request.setAttribute("leaderApproved", leaderApproved);
            request.setAttribute("lecturerNameMap", buildLecturerNameMap(pending));
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "handleQueue failed", e);
            request.setAttribute("pendingPapers",   new ArrayList());
            request.setAttribute("leaderPending",   new ArrayList());
            request.setAttribute("leaderApproved",  new ArrayList());
            request.setAttribute("lecturerNameMap", new HashMap<>());
        }

        request.setAttribute("page", "queue");
        forward(request, response, "/vetterDashboard.jsp");
    }

    /**
     * Review page — loads one paper with all its questions, all vetter comments
     * keyed by questionId, and the list of assigned vetters for panel rendering.
     *
     * Also computes per-question status counts (approved / needsWork / pending)
     * for the progress bars at the top of the review page.
     */
    private void handleReview(HttpServletRequest request,
                               HttpServletResponse response,
                               HttpSession session)
            throws ServletException, IOException {

        String paperIdStr = request.getParameter("paperId");
        if (paperIdStr == null || paperIdStr.trim().isEmpty()) {
            response.sendRedirect("VetterDashboardServlet?page=queue");
            return;
        }

        int paperId = 0;
        try {
            paperId = Integer.parseInt(paperIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect("VetterDashboardServlet?page=queue");
            return;
        }

        try {
            Assessment paper = assessmentDAO.getAssessmentById(paperId);
            if (paper == null) {
                response.sendRedirect("VetterDashboardServlet?page=queue");
                return;
            }

            // Continuous assessments use rubric-based review, not question review
            if (paper.isContinuousAssessment()) {
                handleContinuousReview(request, response, session, paper);
                return;
            }

            // All questions for this paper
            List<Question> questions = questionDAO.getQuestionsByPaperId(paperId);

            // All comments across all vetters, grouped by questionId
            Map<Integer, List<QuestionComment>> commentMap = commentDAO.getCommentsByPaperId(paperId);

            // Resolve courseId then fetch which vetters are assigned to it
            int courseId = 0;
            try {
                Course c = courseDAO.getCourseByCode(paper.getCourseCode());
                if (c != null) courseId = c.getCourseId();
            } catch (Exception e) {
                LOG.log(Level.WARNING, "Could not resolve course for paper " + paperId, e);
            }

            List<Integer> vetterIds = new ArrayList<>();
            try {
                vetterIds = courseDAO.getVetterIdsByCourseId(courseId);
            } catch (Exception e) {
                LOG.log(Level.WARNING, "Could not load vetterIds for courseId=" + courseId, e);
            }

            // Fetch User object for each vetter ID
            List<User> assignedVetters = new ArrayList<>();
            for (int i = 0; i < vetterIds.size(); i++) {
                int vid = (Integer) vetterIds.get(i);
                try {
                    User u = userDAO.getUserById(vid);
                    if (u != null) assignedVetters.add(u);
                } catch (Exception e) {
                    LOG.log(Level.WARNING, "Could not fetch user id=" + vid, e);
                }
            }

            // Count per-question status for the progress bars
            // Avoid stream() — iterate the raw list to stay compatible with all JDKs
            int approvedCount  = 0;
            int needsWorkCount = 0;
            int pendingCount   = 0;

            for (int i = 0; i < questions.size(); i++) {
                Question q = (Question) questions.get(i);
                List<QuestionComment> qComments = commentMap.get(q.getQuestionId());

                if (qComments == null || qComments.isEmpty()) {
                    pendingCount++;
                } else {
                    boolean flagged = false;
                    for (int j = 0; j < qComments.size(); j++) {
                        QuestionComment qc = (QuestionComment) qComments.get(j);
                        if (qc.isContentFlagged()) {
                            flagged = true;
                            break;
                        }
                    }
                    if (flagged) needsWorkCount++; else approvedCount++;
                }
            }

            // Per-question status counts from the questions table itself
            int approvedQs    = 0;
            int needsRevQs    = 0;
            int rejectedQs    = 0;
            int pendingQs     = 0;
            for (int i = 0; i < questions.size(); i++) {
                Question q = (Question) questions.get(i);
                String qs = q.getStatus();
                if      ("APPROVED".equals(qs))       approvedQs++;
                else if ("NEEDS_REVISION".equals(qs)) needsRevQs++;
                else if ("REJECTED".equals(qs))       rejectedQs++;
                else                                  pendingQs++;
            }

            // Section comments
            java.util.List<java.util.Map<String,Object>> jssComments    = commentDAO.getSectionComments(paperId, "JSS");
            java.util.List<java.util.Map<String,Object>> schemeComments = commentDAO.getSectionComments(paperId, "SCHEME");

            int currentVetterId = (Integer) session.getAttribute("userId");
            boolean isLeaderVetter = isLeaderVetterForPaper(currentVetterId, paperId);

            // Load this vetter's checklist entries
            java.util.Map myChecklist = new java.util.LinkedHashMap();
            try { myChecklist = checklistDAO.loadForVetter(paperId, currentVetterId); } catch (Exception ignored) {}
            // Load all vetters' checklist entries (for combined read-only view)
            java.util.List<java.util.Map<String, Object>> allChecklists = new java.util.ArrayList<>();
            try { allChecklists = checklistDAO.loadAllForPaper(paperId); } catch (Exception ignored) {}

            request.setAttribute("paper",            paper);
            request.setAttribute("questions",        questions);
            request.setAttribute("commentMap",       commentMap);
            request.setAttribute("assignedVetters",  assignedVetters);
            request.setAttribute("approvedCount",    approvedQs);
            request.setAttribute("needsRevCount",    needsRevQs);
            request.setAttribute("rejectedCount",    rejectedQs);
            request.setAttribute("pendingCount",     pendingQs);
            request.setAttribute("jssComments",      jssComments);
            request.setAttribute("schemeComments",   schemeComments);
            request.setAttribute("isLeaderVetter",   isLeaderVetter);
            request.setAttribute("myChecklist",      myChecklist);
            request.setAttribute("allChecklists",    allChecklists);

        } catch (Exception e) {
            LOG.log(Level.SEVERE, "handleReview failed paperId=" + paperId, e);
        }

        request.setAttribute("page", "review");
        forward(request, response, "/vetterReview.jsp");
    }

    /**
     * Continuous assessment review — shows rubric + verdict form.
     * Called from handleReview when the paper type is not a final exam.
     */
    private void handleContinuousReview(HttpServletRequest request,
                                         HttpServletResponse response,
                                         HttpSession session,
                                         Assessment paper)
            throws ServletException, IOException {

        int paperId = paper.getPaperId();

        try {
            java.util.List<Model.RubricRow> rubricRows = rubricDAO.getByPaperId(paperId);
            request.setAttribute("rubricRows", rubricRows);
        } catch (Exception e) {
            LOG.log(Level.WARNING, "Could not load rubric for paperId=" + paperId, e);
            request.setAttribute("rubricRows", new java.util.ArrayList<>());
        }

        // Assigned vetters for panel display
        int courseId = 0;
        try {
            Model.Course c = courseDAO.getCourseByCode(paper.getCourseCode());
            if (c != null) courseId = c.getCourseId();
        } catch (Exception ignored) {}

        java.util.List<User> assignedVetters = new java.util.ArrayList<>();
        try {
            java.util.List<Integer> vetterIds = courseDAO.getVetterIdsByCourseId(courseId);
            for (int i = 0; i < vetterIds.size(); i++) {
                int vid = (Integer) vetterIds.get(i);
                try {
                    Model.User u = userDAO.getUserById(vid);
                    if (u != null) assignedVetters.add(u);
                } catch (Exception ignored) {}
            }
        } catch (Exception ignored) {}

        request.setAttribute("paper",           paper);
        request.setAttribute("assignedVetters", assignedVetters);
        request.setAttribute("currentPage",     "queue");
        request.setAttribute("page",            "review");
        forward(request, response, "/vetterAssignmentReview.jsp");
    }

    /**
     * Reviewed tab — papers this vetter has already actioned.
     */
    private void handleReviewed(HttpServletRequest request,
                                 HttpServletResponse response,
                                 HttpSession session)
            throws ServletException, IOException {

        int vetterId = (Integer) session.getAttribute("userId");

        try {
            List<Assessment> reviewed = assessmentDAO.getReviewedByVetter(vetterId);
            java.util.Collections.sort(reviewed, new java.util.Comparator<Assessment>() {
                public int compare(Assessment a1, Assessment a2) {
                    java.util.Date d1 = a1.getUpdatedAt();
                    java.util.Date d2 = a2.getUpdatedAt();
                    if (d1 == null && d2 == null) return 0;
                    if (d1 == null) return 1;
                    if (d2 == null) return -1;
                    return d2.compareTo(d1); // Newest first
                }
            });
            request.setAttribute("reviewedPapers",  reviewed);
            request.setAttribute("lecturerNameMap", buildLecturerNameMap(reviewed));
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "handleReviewed failed", e);
            request.setAttribute("reviewedPapers",  new ArrayList());
            request.setAttribute("lecturerNameMap", new HashMap<>());
        }

        request.setAttribute("page", "reviewed");
        forward(request, response, "/vetterDashboard.jsp");
    }

    private void handleCoursesAndTeams(HttpServletRequest request, HttpServletResponse response, HttpSession session, String page)
            throws ServletException, IOException {
        int vetterId = (Integer) session.getAttribute("userId");
        java.util.List<VetterCourseInfo> coursesList = new java.util.ArrayList<>();

        String sql =
            "SELECT c.course_id, c.course_code, c.course_name, c.credit, c.examHour, c.core, c.coCategory, c.department, c.faculty, c.senateRef, cv.is_leader, " +
            "       u.full_name AS lecturer_name " +
            "FROM course c " +
            "INNER JOIN course_vetters cv ON cv.course_id = c.course_id AND cv.vetter_id = ? " +
            "LEFT JOIN users u ON u.user_id = c.lecturer_id " +
            "ORDER BY c.course_code";
            
        try (java.sql.Connection con = util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, vetterId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VetterCourseInfo ci = new VetterCourseInfo();
                    ci.courseId = rs.getInt("course_id");
                    ci.courseCode = rs.getString("course_code");
                    ci.courseName = rs.getString("course_name");
                    ci.isLeader = rs.getInt("is_leader") == 1;
                    ci.lecturerName = rs.getString("lecturer_name");
                    ci.credit = rs.getInt("credit");
                    ci.examHour = rs.getInt("examHour");
                    ci.core = rs.getString("core");
                    ci.coCategory = rs.getString("coCategory");
                    ci.department = rs.getString("department");
                    ci.faculty = rs.getString("faculty");
                    ci.senateRef = rs.getString("senateRef");
                    
                    String sqlCo = "SELECT u.full_name, cv.is_leader FROM course_vetters cv " +
                                   "JOIN users u ON u.user_id = cv.vetter_id " +
                                   "WHERE cv.course_id = ? AND cv.vetter_id != ?";
                    try (java.sql.PreparedStatement psCo = con.prepareStatement(sqlCo)) {
                        psCo.setInt(1, ci.courseId);
                        psCo.setInt(2, vetterId);
                        try (java.sql.ResultSet rsCo = psCo.executeQuery()) {
                            while (rsCo.next()) {
                                String name = rsCo.getString("full_name");
                                if (rsCo.getInt("is_leader") == 1) name += " (Leader)";
                                ci.coVetters.add(name);
                            }
                        }
                    }
                    coursesList.add(ci);
                }
            }
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "handleCoursesAndTeams failed", e);
        }

        request.setAttribute("assignedCoursesList", coursesList);
        request.setAttribute("page", page);
        forward(request, response, "/vetterDashboard.jsp");
    }

    // ─────────────────────────────────────────────────────────────────────────
    // POST handlers
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * AJAX — saves or updates a question comment.
     * Returns JSON: {"success":true,"date":"...","vetterName":"..."}
     *            or {"success":false,"message":"..."}
     */
    private void handleSaveComment(HttpServletRequest request,
                                    HttpServletResponse response,
                                    HttpSession session)
            throws IOException {

        int    vetterId          = (Integer) session.getAttribute("userId");
        int    questionId        = parseIntParam(request, "questionId");
        String commentText       = trimStr(request.getParameter("commentText"));
        String contentTag        = trimStr(request.getParameter("contentTag"));
        String taxonomyTag       = trimStr(request.getParameter("taxonomyTag"));
        String verdict           = trimStr(request.getParameter("verdict"));
        String suggestedTaxonomy = trimStr(request.getParameter("suggestedTaxonomy"));

        if (questionId <= 0 || commentText.isEmpty()) {
            writeJson(response, false, "questionId and commentText are required");
            return;
        }

        QuestionComment comment = new QuestionComment(
                questionId, vetterId, commentText,
                contentTag.isEmpty()  ? null : contentTag,
                taxonomyTag.isEmpty() ? null : taxonomyTag,
                verdict.isEmpty()     ? null : verdict,
                suggestedTaxonomy.isEmpty() ? null : suggestedTaxonomy);

        boolean ok = commentDAO.saveComment(comment);

        // Update question status and taxonomy if verdict provided
        if (ok && !verdict.isEmpty()) {
            try {
                String taxUpdate = suggestedTaxonomy.isEmpty() ? null : suggestedTaxonomy;
                questionDAO.updateQuestionVerdict(questionId, verdict, taxUpdate);
            } catch (Exception e) {
                LOG.log(Level.WARNING, "updateQuestionVerdict failed q=" + questionId, e);
            }
        }

        if (ok) {
            // Re-fetch so we can return the DB-generated timestamp and vetterName
            QuestionComment saved = commentDAO.getComment(questionId, vetterId);
            String extra = "";
            if (saved != null) {
                extra = ",\"date\":\"" + escapeJson(saved.getFormattedDate()) + "\""
                      + ",\"vetterName\":\"" + escapeJson(saved.getVetterName()) + "\"";
            }
            writeJsonRaw(response, "{\"success\":true" + extra + "}");
        } else {
            writeJson(response, false, "Database error — comment not saved");
        }
    }

    /**
     * AJAX — saves a comment on a paper section (JSS or SCHEME).
     */
    private void handleSaveSectionComment(HttpServletRequest request,
                                           HttpServletResponse response,
                                           HttpSession session)
            throws IOException {

        int    vetterId    = (Integer) session.getAttribute("userId");
        String vetterName  = (String)  session.getAttribute("fullName");
        int    paperId     = parseIntParam(request, "paperId");
        String section     = trimStr(request.getParameter("section"));   // JSS | SCHEME
        String commentText = trimStr(request.getParameter("commentText"));
        String verdict     = trimStr(request.getParameter("verdict"));

        if (paperId <= 0 || commentText.isEmpty()
                || (!section.equals("JSS") && !section.equals("SCHEME"))) {
            writeJson(response, false, "paperId, section, and commentText are required");
            return;
        }

        boolean ok = commentDAO.saveSectionComment(paperId, section, vetterId,
                vetterName, commentText, verdict.isEmpty() ? null : verdict);
        writeJson(response, ok, ok ? null : "Database error — comment not saved");
    }

    /**
     * AJAX — deletes the current vetter's comment on a question.
     * Returns JSON: {"success":true} or {"success":false,"message":"..."}
     */
    private void handleDeleteComment(HttpServletRequest request,
                                      HttpServletResponse response,
                                      HttpSession session)
            throws IOException {

        int vetterId  = (Integer) session.getAttribute("userId");
        int questionId = parseIntParam(request, "questionId");

        if (questionId <= 0) {
            writeJson(response, false, "questionId is required");
            return;
        }

        boolean ok = commentDAO.deleteComment(questionId, vetterId);
        writeJson(response, ok, ok ? null : "Delete failed");
    }

    /**
     * Paper-level verdict — updates exam_papers.status and redirects to queue.
     *
     * @param newStatus APPROVED | NEEDS_IMPROVEMENT | REJECTED
     */
    private void handleVerdict(HttpServletRequest request,
                                HttpServletResponse response,
                                HttpSession session,
                                String newStatus)
            throws IOException {

        int    paperId = parseIntParam(request, "paperId");
        String remarks = trimStr(request.getParameter("remarks"));

        if (paperId <= 0) {
            response.sendRedirect("VetterDashboardServlet?page=queue");
            return;
        }

        try {
            assessmentDAO.updateStatus(paperId, newStatus, remarks);
            sendVerdictNotifications(paperId, newStatus, remarks);
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "handleVerdict failed paperId=" + paperId, e);
        }

        response.sendRedirect("VetterDashboardServlet?page=queue&verdict=done");
    }

    /**
     * Leader vetter signs and sends to KP — sets SENT_TO_FAKULTI.
     */
    private void handleSaveChecklist(HttpServletRequest request,
                                     HttpServletResponse response,
                                     HttpSession session) throws IOException {
        response.setContentType("application/json");
        int vetterId = (int) session.getAttribute("userId");
        try {
            int     paperId      = Integer.parseInt(request.getParameter("paperId"));
            String  section      = request.getParameter("section");
            String  refIdStr     = request.getParameter("refId");
            String  criterionKey = request.getParameter("criterionKey");
            boolean isOk         = "1".equals(request.getParameter("isOk"));
            String  comment      = request.getParameter("comment");
            Integer refId        = (refIdStr != null && !refIdStr.isEmpty()) ? Integer.parseInt(refIdStr) : null;
            
            boolean isDelete     = "1".equals(request.getParameter("delete"));
            if (isDelete) {
                checklistDAO.deleteItem(paperId, vetterId, section, refId, criterionKey);
            } else {
                checklistDAO.saveItem(paperId, vetterId, section, refId, criterionKey, isOk, comment);
            }
            
            response.getWriter().write("{\"success\":true}");
        } catch (Exception e) {
            LOG.log(Level.WARNING, "saveChecklist failed", e);
            response.getWriter().write("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
        }
    }

    private void handleLeaderApprove(HttpServletRequest request,
                                     HttpServletResponse response,
                                     HttpSession session)
            throws IOException {

        int vetterId = (int) session.getAttribute("userId");
        int paperId  = parseIntParam(request, "paperId");

        if (paperId <= 0) {
            response.sendRedirect("VetterDashboardServlet?page=queue"); return;
        }

        try {
            boolean isLeader = isLeaderVetterForPaper(vetterId, paperId);
            if (!isLeader) {
                response.sendRedirect("VetterDashboardServlet?page=queue&err=Not+authorized"); return;
            }
            // Transition PENDING_LEADER_SIGN → LEADER_APPROVED
            String sql = "UPDATE exam_papers SET status='LEADER_APPROVED', updated_at=NOW() "
                       + "WHERE paper_id=? AND status='PENDING_LEADER_SIGN'";
            try (java.sql.Connection con = util.DBConnection.getConnection();
                 java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, paperId);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "handleLeaderApprove failed paperId=" + paperId, e);
        }
        response.sendRedirect("VetterDashboardServlet?page=queue&leaderApproved=true");
    }

    private void handleSignAndSend(HttpServletRequest request,
                                   HttpServletResponse response,
                                   HttpSession session)
            throws IOException {

        int    vetterId = (int) session.getAttribute("userId");
        int    paperId  = parseIntParam(request, "paperId");
        String remarks  = trimStr(request.getParameter("remarks"));

        if (paperId <= 0) {
            response.sendRedirect("VetterDashboardServlet?page=queue"); return;
        }

        try {
            boolean isLeader = isLeaderVetterForPaper(vetterId, paperId);
            if (!isLeader) {
                response.sendRedirect("VetterDashboardServlet?page=queue&err=Not+authorized"); return;
            }
            // Allow from PENDING_LEADER_SIGN or LEADER_APPROVED
            String sql = "UPDATE exam_papers SET status='SENT_TO_FAKULTI', updated_at=NOW(), remarks=? "
                       + "WHERE paper_id=? AND status IN ('PENDING_LEADER_SIGN','LEADER_APPROVED')";
            try (java.sql.Connection con = util.DBConnection.getConnection();
                 java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, remarks != null && !remarks.isEmpty() ? remarks : "Finalized and sent to KP by Leader Vetter.");
                ps.setInt(2, paperId);
                ps.executeUpdate();
            }
            sendFinalizedNotifications(paperId, session);
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "handleSignAndSend failed paperId=" + paperId, e);
        }
        response.sendRedirect("VetterDashboardServlet?page=queue&signed=true");
    }

    private boolean isLeaderVetterForPaper(int vetterId, int paperId) {
        // Primary: course_vetters.is_leader flag — join via course.course_id
        try (Connection con = util.DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT 1 FROM exam_papers ep "
              + "JOIN course c ON c.course_code = ep.course_code "
              + "JOIN course_vetters cv ON cv.course_id = c.course_id "
              + "WHERE ep.paper_id = ? AND cv.vetter_id = ? AND cv.is_leader = 1 LIMIT 1")) {
            ps.setInt(1, paperId); ps.setInt(2, vetterId);
            if (ps.executeQuery().next()) return true;
        } catch (Exception ignored) {}
        // Fallback: course.vetter_id column
        try (Connection con = util.DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                "SELECT 1 FROM exam_papers ep "
              + "JOIN course c ON c.course_code COLLATE utf8mb4_unicode_ci = ep.course_code COLLATE utf8mb4_unicode_ci "
              + "WHERE ep.paper_id = ? AND c.vetter_id = ? LIMIT 1")) {
            ps.setInt(1, paperId); ps.setInt(2, vetterId);
            return ps.executeQuery().next();
        } catch (Exception e) { return false; }
    }

    private void sendFinalizedNotifications(int paperId, HttpSession session) {
        String vetterName = (String) session.getAttribute("fullName");
        if (vetterName == null) vetterName = "Leader Vetter";
        try (Connection con = util.DBConnection.getConnection()) {
            String infoSql = "SELECT ep.lecturer_id, ep.course_code, ep.course_title, "
                           + "ep.academic_session, ep.semester "
                           + "FROM exam_papers ep WHERE ep.paper_id = ? LIMIT 1";
            int lecturerId = 0; String courseCode = ""; String courseTitle = ""; String sess = ""; int sem = 0;
            try (PreparedStatement ps = con.prepareStatement(infoSql)) {
                ps.setInt(1, paperId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    lecturerId  = rs.getInt("lecturer_id");
                    courseCode  = rs.getString("course_code");
                    courseTitle = rs.getString("course_title");
                    sess        = rs.getString("academic_session");
                    sem         = rs.getInt("semester");
                }
            }
            String summary = courseCode + " (" + courseTitle + ") " + sess + " Sem " + sem
                           + " — Finalized and sent to KP by " + vetterName + ".";
            String notifSql = "INSERT INTO notifications (user_id, assessment_id, summary, is_read, created_at) VALUES (?,?,?,0,NOW())";
            // Notify lecturer
            if (lecturerId > 0) {
                try (PreparedStatement ps = con.prepareStatement(notifSql)) {
                    ps.setInt(1, lecturerId); ps.setInt(2, paperId); ps.setString(3, summary);
                    ps.executeUpdate();
                }
            }
            // Notify KP / Admin
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT user_id FROM users WHERE role IN ('KP','Admin','ADMIN')");
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    try (PreparedStatement np = con.prepareStatement(notifSql)) {
                        np.setInt(1, rs.getInt("user_id")); np.setInt(2, paperId); np.setString(3, summary);
                        np.executeUpdate();
                    }
                }
            }
        } catch (Exception e) {
            LOG.log(Level.WARNING, "sendFinalizedNotifications failed", e);
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Private helpers
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * After a paper-level verdict, inserts a notification for:
     *  – the paper's lecturer
     *  – every user whose role is KP or Admin
     */
    private void sendVerdictNotifications(int paperId, String newStatus, String remarks) {
        String label = "APPROVED".equals(newStatus)          ? "Approved"
                     : "NEEDS_IMPROVEMENT".equals(newStatus) ? "Needs Improvement — sent back for revision"
                     : "Rejected";
        try (Connection con = util.DBConnection.getConnection()) {
            // Fetch paper + lecturer info
            String infoSql =
                "SELECT ep.lecturer_id, ep.course_code, ep.course_title, "
                + "       ep.academic_session, ep.semester, "
                + "       u.full_name AS lec_name, u.email AS lec_email "
                + "FROM exam_papers ep "
                + "JOIN users u ON u.user_id = ep.lecturer_id "
                + "WHERE ep.paper_id = ? LIMIT 1";

            int    lecturerId = 0;
            String courseCode = "", courseTitle = "", sessStr = "", lecName = "", lecEmail = "";
            int    sem = 0;
            String summary = "";

            try (PreparedStatement ps = con.prepareStatement(infoSql)) {
                ps.setInt(1, paperId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    lecturerId  = rs.getInt("lecturer_id");
                    courseCode  = rs.getString("course_code");
                    courseTitle = rs.getString("course_title");
                    sessStr     = rs.getString("academic_session");
                    sem         = rs.getInt("semester");
                    lecName     = rs.getString("lec_name");
                    lecEmail    = rs.getString("lec_email");
                    summary     = courseCode + " (" + courseTitle + ") — " + sessStr + " Sem " + sem
                                + " : Vetting verdict: " + label
                                + (remarks != null && !remarks.isEmpty() ? ". Remarks: " + remarks : "");
                }
            }
            if (lecturerId == 0) return;

            // App base URL for email links — adjust if your server differs
            String baseUrl   = "http://localhost:8080/assessmentvetting";
            String reviewUrl = baseUrl + "/LecturerReviewServlet?paperId=" + paperId;
            String queueUrl  = baseUrl + "/VetterDashboardServlet?page=queue";

            // ── In-app notification for lecturer ──
            String insertSql = "INSERT INTO notifications (user_id, assessment_id, summary, is_read, created_at) "
                             + "VALUES (?, ?, ?, 0, NOW())";
            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.setInt(1, lecturerId); ps.setInt(2, paperId); ps.setString(3, summary);
                ps.executeUpdate();
            }

            // ── Email to lecturer ──
            util.EmailService.sendVerdictEmail(
                lecEmail, lecName, courseCode, courseTitle,
                sessStr, sem, newStatus, remarks, reviewUrl);

            // ── Notify all KP / Admin users ──
            String kpSql = "SELECT user_id, full_name, email FROM users "
                         + "WHERE role IN ('KP','Admin','ADMIN','KP_ADMIN')";
            try (PreparedStatement kps = con.prepareStatement(kpSql);
                 ResultSet krs = kps.executeQuery()) {
                while (krs.next()) {
                    int    kpId    = krs.getInt("user_id");
                    String kpName  = krs.getString("full_name");
                    String kpEmail = krs.getString("email");
                    if (kpId == lecturerId) continue;

                    // In-app
                    try (PreparedStatement kpi = con.prepareStatement(insertSql)) {
                        kpi.setInt(1, kpId); kpi.setInt(2, paperId);
                        kpi.setString(3, "[KP] " + summary);
                        kpi.executeUpdate();
                    }
                    // Email
                    util.EmailService.sendKpVerdictEmail(
                        kpEmail, kpName, lecName,
                        courseCode, courseTitle,
                        sessStr, sem, newStatus, remarks, reviewUrl);
                }
            }
        } catch (Exception e) {
            LOG.log(Level.WARNING, "sendVerdictNotifications failed paperId=" + paperId, e);
        }
    }

    /**
     * Returns true if the session belongs to a user authorised to POST to this servlet.
     * Accepts: Vetter (all casing variants), KP, Admin — and any session with isVetter=true.
     */
    private boolean isAuthorised(HttpSession session) {
        if (session == null || session.getAttribute("userId") == null) return false;
        String  role     = (String)  session.getAttribute("role");
        Boolean isVetter = (Boolean) session.getAttribute("isVetter");
        if (Boolean.TRUE.equals(isVetter)) return true;
        if (role == null) return false;
        String r = role.trim().toLowerCase();
        return r.equals("vetter") || r.equals("kp") || r.equals("admin")
            || r.equals("kp_admin") || r.equals("lecturer");
    }

    /** Kept for backward compatibility with GET handler calls. */
    private boolean isVetter(HttpSession session) {
        return isAuthorised(session);
    }

    /** Forwards request to the given JSP path. */
    private void forward(HttpServletRequest req,
                         HttpServletResponse res,
                         String jspPath)
            throws ServletException, IOException {
        req.getRequestDispatcher(jspPath).forward(req, res);
    }

    /** Parses an int request parameter; returns 0 if missing or invalid. */
    private int parseIntParam(HttpServletRequest req, String name) {
        try {
            String val = req.getParameter(name);
            return (val != null && !val.trim().isEmpty())
                   ? Integer.parseInt(val.trim()) : 0;
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    /** Null-safe trim — returns empty string for null input. */
    private String trimStr(String s) {
        return (s != null) ? s.trim() : "";
    }

    /** Writes a simple JSON success/error response. */
    private void writeJson(HttpServletResponse response,
                            boolean success, String message)
            throws IOException {
        String json = "{\"success\":" + success
                + (message != null
                   ? ",\"message\":\"" + escapeJson(message) + "\""
                   : "")
                + "}";
        writeJsonRaw(response, json);
    }

    /** Writes a raw JSON string with the correct content-type header. */
    private void writeJsonRaw(HttpServletResponse response, String json)
            throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.write(json);
        }
    }

    /** Minimal JSON escaping for string values embedded in JSON literals. */
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }

    // ── Lecturer assignment summary for dashboard ─────────────────────────────
    /**
     * For each course assigned to this vetter, return a row showing the lecturer
     * and a summary of paper statuses across all their exam papers for that course.
     */
    private List<LecturerRow> getLecturerAssignments(int vetterId) {
        List<LecturerRow> rows = new ArrayList<>();
        String sql =
            "SELECT c.course_id, c.course_code, c.course_name, c.credit, " +
            "       u.full_name AS lecturer_name, u.email AS lecturer_email, " +
            "       u.phoneNo AS lecturer_phone, " +
            "       cv.is_leader, " +
            "       COUNT(ep.paper_id) AS total_papers, " +
            "       SUM(CASE WHEN ep.status IN ('SUBMITTED','UNDER_REVIEW') THEN 1 ELSE 0 END) AS pending_papers, " +
            "       SUM(CASE WHEN ep.status = 'APPROVED' THEN 1 ELSE 0 END) AS approved_papers, " +
            "       SUM(CASE WHEN ep.status IN ('NEEDS_IMPROVEMENT','REJECTED') THEN 1 ELSE 0 END) AS action_papers, " +
            "       SUM(CASE WHEN ep.status = 'DRAFT' THEN 1 ELSE 0 END) AS draft_papers " +
            "FROM course c " +
            "INNER JOIN course_vetters cv ON cv.course_id = c.course_id AND cv.vetter_id = ? " +
            "LEFT JOIN users u ON u.user_id = c.lecturer_id " +
            "LEFT JOIN exam_papers ep ON ep.course_code = c.course_code " +
            "                        AND ep.lecturer_id = c.lecturer_id " +
            "GROUP BY c.course_id, c.course_code, c.course_name, c.credit, " +
            "         u.full_name, u.email, u.phoneNo, cv.is_leader " +
            "ORDER BY pending_papers DESC, c.course_code";
        try (Connection con = util.DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, vetterId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LecturerRow r = new LecturerRow();
                    r.courseCode     = rs.getString("course_code");
                    r.courseName     = rs.getString("course_name");
                    r.credit         = rs.getInt("credit");
                    r.lecturerName   = rs.getString("lecturer_name");
                    r.lecturerEmail  = rs.getString("lecturer_email");
                    r.lecturerPhone  = rs.getString("lecturer_phone");
                    r.totalPapers    = rs.getInt("total_papers");
                    r.pendingPapers  = rs.getInt("pending_papers");
                    r.approvedPapers = rs.getInt("approved_papers");
                    r.actionPapers   = rs.getInt("action_papers");
                    r.draftPapers    = rs.getInt("draft_papers");
                    r.isLeader       = rs.getInt("is_leader") == 1;
                    r.coVetters      = getCoVetters(rs.getInt("course_id"), vetterId);
                    rows.add(r);
                }
            }
        } catch (Exception e) {
            LOG.log(Level.WARNING, "getLecturerAssignments failed vetterId=" + vetterId, e);
        }
        return rows;
    }

    /** Helper to load co-vetters for a course. */
    private List<String> getCoVetters(int courseId, int currentVetterId) {
        List<String> names = new ArrayList<>();
        String sql = "SELECT u.full_name, cv.is_leader FROM course_vetters cv " +
                     "JOIN users u ON u.user_id = cv.vetter_id " +
                     "WHERE cv.course_id = ? AND cv.vetter_id != ?";
        try (Connection con = util.DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            ps.setInt(2, currentVetterId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String name = rs.getString("full_name");
                    if (rs.getInt("is_leader") == 1) {
                        name += " (Leader)";
                    }
                    names.add(name);
                }
            }
        } catch (Exception e) {
            LOG.log(Level.WARNING, "getCoVetters failed for courseId=" + courseId, e);
        }
        return names;
    }

    /** Count papers ever approved by this vetter. */
    private int countApprovedByVetter(int vetterId) {
        // Papers that are now APPROVED and were in courses assigned to this vetter
        String sql = "SELECT COUNT(*) FROM exam_papers ep " +
                     "JOIN course c ON c.course_code = ep.course_code " +
                     "WHERE c.vetter_id = ? AND ep.status = 'APPROVED'";
        try (Connection con = util.DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, vetterId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (Exception e) {
            LOG.log(Level.WARNING, "countApprovedByVetter failed", e);
            return 0;
        }
    }

    /**
     * Build a map from lecturerId → lecturer full name for a list of papers.
     * Used to show "Submitted by: Dr. X" on queue/reviewed cards.
     */
    private Map<Integer, String> buildLecturerNameMap(List<Assessment> papers) {
        Map<Integer, String> map = new LinkedHashMap<>();
        for (int i = 0; i < papers.size(); i++) {
            Assessment a = (Assessment) papers.get(i);
            int lid = a.getLecturerId();
            if (lid > 0 && !map.containsKey(lid)) {
                try {
                    User u = userDAO.getUserById(lid);
                    map.put(lid, u != null ? u.getFullName() : "Unknown");
                } catch (Exception e) {
                    map.put(lid, "Unknown");
                }
            }
        }
        return map;
    }
}
