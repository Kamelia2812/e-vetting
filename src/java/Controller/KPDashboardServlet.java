package Controller;

import DAO.AssessmentDAO;
import DAO.CourseDAO;
import DAO.UserDAO;
import Model.Assessment;
import Model.Course;
import Model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * KPDashboardServlet — single servlet for the entire KP dashboard.
 *
 * GET  ?page=dashboard   → overview stats
 * GET  ?page=courses     → all courses (add/edit/delete)
 * GET  ?page=assignment  → assign lecturer + vetter per course
 * GET  ?page=vetting     → view submitted/approved papers, send to Fakulti
 *
 * POST action=assignStaff    → assign lecturer + vetter to course
 * POST action=addCourse      → create new course
 * POST action=deleteCourse   → delete a course
 * POST action=sendToFakulti  → change paper status to SENT_TO_FAKULTI
 */
@WebServlet("/KPDashboardServlet")
public class KPDashboardServlet extends HttpServlet {

    private final CourseDAO     courseDAO     = new CourseDAO();
    private final UserDAO       userDAO       = new UserDAO();
    private final AssessmentDAO assessmentDAO = new AssessmentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);

        // Security: KP only
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        if (!"KP".equalsIgnoreCase((String) session.getAttribute("role"))) {
            res.sendRedirect(req.getContextPath() + "/unauthorized.jsp");
            return;
        }

        String page = req.getParameter("page");
        if (page == null || page.trim().isEmpty()) page = "dashboard";

        try {
            // ── Always load these for the sidebar/stats ──
            List<User>   lecturers = userDAO.getUsersByRole("LECTURER");
            List<User>   vetters   = userDAO.getUsersByRole("VETTER");
            List<Course> courses   = courseDAO.getAllCourses();

            req.setAttribute("lecturers", lecturers);
            req.setAttribute("vetters",   vetters);
            req.setAttribute("courses",   courses);
            req.setAttribute("activePage", page);

            // Build vetterMap + leaderMap using course_vetters table
            java.util.Map<Integer, java.util.List<Integer>> vetterMap = new java.util.HashMap<>();
            java.util.Map<Integer, Integer> leaderMap = new java.util.HashMap<>();
            for (Course c : courses) {
                try {
                    vetterMap.put(c.getCourseId(), courseDAO.getVetterIdsByCourseId(c.getCourseId()));
                    leaderMap.put(c.getCourseId(), courseDAO.getLeaderIdByCourseId(c.getCourseId()));
                } catch (Exception ignored) {
                    java.util.List<Integer> fallback = new java.util.ArrayList<>();
                    if (c.getVetterId() > 0) fallback.add(c.getVetterId());
                    vetterMap.put(c.getCourseId(), fallback);
                    leaderMap.put(c.getCourseId(), c.getVetterId());
                }
            }
            req.setAttribute("vetterMap", vetterMap);
            req.setAttribute("leaderMap", leaderMap);

            // Course synopsis (short brief) from course_information
            try {
                req.setAttribute("synopsisMap", courseDAO.getSynopsisMap());
            } catch (Exception ignored) {
                req.setAttribute("synopsisMap", new java.util.HashMap());
            }

            // Always load all packages so KP can see full vetting status on any page
            List<Assessment> allPackages = assessmentDAO.getAllPackagesForKP();
            req.setAttribute("allPackages", allPackages);

            if ("dashboard".equals(page)) {
                req.setAttribute("totalLecturers",   lecturers.size());
                req.setAttribute("totalVetters",     vetters.size());
                req.setAttribute("totalCourses",     courses.size());
                req.setAttribute("pendingCount",     assessmentDAO.getPendingForVetter().size());
                req.setAttribute("approvedCount",    assessmentDAO.countByStatus("APPROVED"));
                req.setAttribute("submittedCount",   assessmentDAO.countByStatus("SUBMITTED"));

            } else if ("repository".equals(page)) {
                // Repository shows both SENT_TO_FAKULTI and KP-FINALIZED papers
                List<Assessment> repo = assessmentDAO.getAssessmentsByStatuses(
                    new String[]{"SENT_TO_FAKULTI", "FINALIZED"});
                req.setAttribute("repoPackages", repo);

            } else if ("report".equals(page)) {
                // Report: all papers with vetter names and status summary
                try (java.sql.Connection _rc = util.DBConnection.getConnection()) {
                    java.util.List<java.util.Map<String,Object>> rptPapers = new java.util.ArrayList<java.util.Map<String,Object>>();
                    String rptSql =
                        "SELECT ep.paper_id, ep.course_code, ep.course_title, ep.faculty, " +
                        "  ep.paper_type, ep.academic_session, ep.semester, " +
                        "  ep.assign_marks, ep.status, ep.submitted_date, ep.updated_at, " +
                        "  u.full_name AS lecturer_name " +
                        "FROM exam_papers ep " +
                        "JOIN users u ON ep.lecturer_id = u.user_id " +
                        "ORDER BY ep.submitted_date DESC";
                    try (java.sql.PreparedStatement _rps = _rc.prepareStatement(rptSql);
                         java.sql.ResultSet _rrs = _rps.executeQuery()) {
                        while (_rrs.next()) {
                            java.util.Map<String,Object> _rp = new java.util.LinkedHashMap<String,Object>();
                            _rp.put("paperId",       _rrs.getInt("paper_id"));
                            _rp.put("courseCode",    _rrs.getString("course_code"));
                            _rp.put("courseTitle",   _rrs.getString("course_title"));
                            _rp.put("faculty",       _rrs.getString("faculty"));
                            _rp.put("paperType",     _rrs.getString("paper_type"));
                            _rp.put("session",       _rrs.getString("academic_session"));
                            _rp.put("semester",      _rrs.getInt("semester"));
                            _rp.put("marks",         _rrs.getInt("assign_marks"));
                            _rp.put("status",        _rrs.getString("status"));
                            _rp.put("submittedDate", _rrs.getTimestamp("submitted_date"));
                            _rp.put("updatedAt",     _rrs.getTimestamp("updated_at"));
                            _rp.put("lecturerName",  _rrs.getString("lecturer_name"));
                            rptPapers.add(_rp);
                        }
                    }
                    // Vetters per paper
                    String _vSql =
                        "SELECT u.full_name, cv.is_leader " +
                        "FROM course_vetters cv " +
                        "JOIN users u ON cv.vetter_id = u.user_id " +
                        "JOIN course c ON c.course_id = cv.course_id " +
                        "WHERE c.course_code = ? ORDER BY cv.is_leader DESC, u.full_name";
                    for (java.util.Map<String,Object> _rp : rptPapers) {
                        java.util.List<String> _vnames = new java.util.ArrayList<String>();
                        try (java.sql.PreparedStatement _vps = _rc.prepareStatement(_vSql)) {
                            _vps.setString(1, (String) _rp.get("courseCode"));
                            try (java.sql.ResultSet _vrs = _vps.executeQuery()) {
                                while (_vrs.next()) {
                                    String _vn = _vrs.getString("full_name");
                                    if (_vrs.getInt("is_leader") == 1) _vn = _vn + " (Leader)";
                                    _vnames.add(_vn);
                                }
                            }
                        }
                        _rp.put("vetterNames", _vnames);
                    }
                    // Status counts
                    java.util.Map<String,Integer> _sc = new java.util.LinkedHashMap<String,Integer>();
                    String _cntSql = "SELECT status, COUNT(*) AS cnt FROM exam_papers GROUP BY status ORDER BY cnt DESC";
                    try (java.sql.PreparedStatement _cps = _rc.prepareStatement(_cntSql);
                         java.sql.ResultSet _crs = _cps.executeQuery()) {
                        while (_crs.next()) _sc.put(_crs.getString("status"), _crs.getInt("cnt"));
                    }
                    req.setAttribute("rptPapers",      rptPapers);
                    req.setAttribute("rptStatusCounts", _sc);
                    req.setAttribute("rptGeneratedAt",  new java.util.Date());
                } catch (Exception _re) {
                    _re.printStackTrace();
                }
            }

            req.getRequestDispatcher("/KPDashboard.jsp").forward(req, res);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("KPDashboardServlet error", e);
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
        if (!"KP".equalsIgnoreCase((String) session.getAttribute("role"))) {
            res.sendRedirect(req.getContextPath() + "/unauthorized.jsp");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "";

        try {
            if ("assignStaff".equals(action)) {
                int courseId   = safeInt(req.getParameter("courseId"), 0);
                if (courseId == 0) {
                    res.sendRedirect(req.getContextPath() + "/KPDashboardServlet?page=assignment&err=Missing+course");
                    return;
                }
                int lecturerId = safeInt(req.getParameter("lecturerId"), 0);

                // Flexible vetter list (distinct, > 0)
                java.util.List<Integer> vetterIds = new java.util.ArrayList<>();
                String[] vetterParams = req.getParameterValues("vetterIds");
                if (vetterParams != null) {
                    for (String v : vetterParams) {
                        int id = safeInt(v, 0);
                        if (id > 0 && !vetterIds.contains(id)) vetterIds.add(id);
                    }
                }

                // Vetters may not vet their own course
                if (lecturerId > 0 && vetterIds.contains(lecturerId)) {
                    res.sendRedirect(req.getContextPath()
                        + "/KPDashboardServlet?page=assignment&err=The+course+lecturer+cannot+be+a+vetter+of+their+own+course");
                    return;
                }

                // Minimum 2 vetters per assessment
                if (!vetterIds.isEmpty() && vetterIds.size() < 2) {
                    res.sendRedirect(req.getContextPath()
                        + "/KPDashboardServlet?page=assignment&err=Each+course+needs+a+minimum+of+2+vetters");
                    return;
                }

                // Leader must be one of the assigned vetters (fallback: first)
                int leaderId = safeInt(req.getParameter("leaderId"), 0);
                if (!vetterIds.contains(leaderId)) {
                    leaderId = vetterIds.isEmpty() ? 0 : vetterIds.get(0);
                }

                // Assign lecturer
                if (lecturerId > 0) courseDAO.assignLecturerToCourse(courseId, lecturerId);

                courseDAO.assignVettersToCourse(courseId, vetterIds, leaderId);
                res.sendRedirect(req.getContextPath() + "/KPDashboardServlet?page=assignment&saved=true");

            } else if ("addCourse".equals(action)) {
                try {
                    Course c = new Course();
                    c.setCourseCode (req.getParameter("courseCode").trim().toUpperCase());
                    c.setCourseName (req.getParameter("courseName").trim());
                    c.setCredit     (safeInt(req.getParameter("credit"), 3));
                    c.setExamHour   (safeInt(req.getParameter("examHour"), 2));
                    c.setCore       (req.getParameter("core"));
                    c.setCoCategory (req.getParameter("coCategory"));
                    c.setUniOffer   (req.getParameter("uniOffer"));
                    c.setOfferPeriod(req.getParameter("offerPeriod"));
                    c.setSenateRef  (req.getParameter("senateRef"));
                    c.setDepartment (req.getParameter("department"));
                    c.setFaculty    (req.getParameter("faculty") != null ? req.getParameter("faculty") : "FSKM");
                    int newCourseId = courseDAO.createCourse(c);
                    String syn = req.getParameter("synopsis");
                    if (newCourseId > 0 && syn != null && !syn.trim().isEmpty()) {
                        courseDAO.upsertSynopsis(newCourseId, syn.trim());
                    }
                    res.sendRedirect(req.getContextPath() + "/KPDashboardServlet?page=courses&saved=true");
                } catch (java.sql.SQLIntegrityConstraintViolationException e) {
                    // Duplicate course code — redirect back with error message
                    String code = req.getParameter("courseCode");
                    res.sendRedirect(req.getContextPath() +
                        "/KPDashboardServlet?page=courses&err=Course+code+" + code + "+already+exists");
                }

            } else if ("updateCourse".equals(action)) {
                Course c = new Course();
                c.setCourseId  (safeInt(req.getParameter("courseId"), 0));
                c.setCourseCode(req.getParameter("courseCode").trim().toUpperCase());
                c.setCourseName(req.getParameter("courseName").trim());
                c.setCredit    (safeInt(req.getParameter("credit"), 3));
                c.setExamHour  (safeInt(req.getParameter("examHour"), 2));
                c.setCore      (req.getParameter("core"));
                c.setCoCategory(req.getParameter("coCategory"));
                c.setUniOffer  (req.getParameter("uniOffer"));
                c.setOfferPeriod(req.getParameter("offerPeriod"));
                c.setSenateRef (req.getParameter("senateRef"));
                c.setDepartment(req.getParameter("department"));
                c.setFaculty   (req.getParameter("faculty") != null ? req.getParameter("faculty") : "FSKM");
                courseDAO.updateCourse(c);
                String updSyn = req.getParameter("synopsis");
                if (updSyn != null) {
                    courseDAO.upsertSynopsis(c.getCourseId(), updSyn.trim());
                }
                res.sendRedirect(req.getContextPath() + "/KPDashboardServlet?page=courses&saved=true");

            } else if ("deleteCourse".equals(action)) {
                int courseId = Integer.parseInt(req.getParameter("courseId"));
                courseDAO.deleteCourseCascade(courseId);
                res.sendRedirect(req.getContextPath() + "/KPDashboardServlet?page=courses&deleted=true");

            } else if ("sendToFakulti".equals(action)) {
                int paperId = Integer.parseInt(req.getParameter("paperId"));
                assessmentDAO.updateStatus(paperId, "SENT_TO_FAKULTI", "Approved and sent to Fakulti by KP.");
                res.sendRedirect(req.getContextPath() + "/KPDashboardServlet?page=vetting&sent=true");

            } else if ("finalizeAssessment".equals(action)) {
                int paperId = safeInt(req.getParameter("paperId"), 0);
                String remarks = req.getParameter("remarks");
                if (remarks == null || remarks.trim().isEmpty())
                    remarks = "Approved and finalized by Ketua Program.";
                assessmentDAO.updateStatus(paperId, "FINALIZED", remarks.trim());
                sendFinalizeNotification(paperId, req, session);
                res.sendRedirect(req.getContextPath() + "/KPDashboardServlet?page=submissions&finalized=true");

            } else {
                res.sendRedirect(req.getContextPath() + "/KPDashboardServlet");
            }

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("KPDashboardServlet POST error: " + action, e);
        }
    }

    private void sendFinalizeNotification(int paperId, HttpServletRequest req, HttpSession session) {
        String kpName = (String) session.getAttribute("fullName");
        if (kpName == null) kpName = "KP";
        try (java.sql.Connection con = util.DBConnection.getConnection()) {
            String infoSql = "SELECT ep.lecturer_id, ep.course_code, ep.course_title, "
                           + "ep.academic_session, ep.semester "
                           + "FROM exam_papers ep WHERE ep.paper_id = ? LIMIT 1";
            int lecturerId = 0; String courseCode = ""; String courseTitle = ""; String sess = ""; int sem = 0;
            try (java.sql.PreparedStatement ps = con.prepareStatement(infoSql)) {
                ps.setInt(1, paperId);
                java.sql.ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    lecturerId  = rs.getInt("lecturer_id");
                    courseCode  = rs.getString("course_code");
                    courseTitle = rs.getString("course_title");
                    sess        = rs.getString("academic_session");
                    sem         = rs.getInt("semester");
                }
            }
            String summary = courseCode + " (" + courseTitle + ") " + sess + " Sem " + sem
                           + " — Finalized and approved by " + kpName + " (KP). No further action needed.";
            String notifSql = "INSERT INTO notifications (user_id, assessment_id, summary, is_read, created_at) VALUES (?,?,?,0,NOW())";
            // Notify lecturer
            if (lecturerId > 0) {
                try (java.sql.PreparedStatement ps = con.prepareStatement(notifSql)) {
                    ps.setInt(1, lecturerId); ps.setInt(2, paperId); ps.setString(3, summary);
                    ps.executeUpdate();
                }
            }
            // Notify all assigned vetters
            String vetterSql = "SELECT cv.vetter_id FROM course_vetters cv "
                             + "JOIN exam_papers ep ON ep.course_code = cv.course_code "
                             + "WHERE ep.paper_id = ?";
            try (java.sql.PreparedStatement ps = con.prepareStatement(vetterSql)) {
                ps.setInt(1, paperId);
                java.sql.ResultSet vrs = ps.executeQuery();
                while (vrs.next()) {
                    int vid = vrs.getInt("vetter_id");
                    try (java.sql.PreparedStatement np = con.prepareStatement(notifSql)) {
                        np.setInt(1, vid); np.setInt(2, paperId); np.setString(3, "[Vetter] " + summary);
                        np.executeUpdate();
                    }
                }
            }
        } catch (Exception e) {
            java.util.logging.Logger.getLogger(KPDashboardServlet.class.getName())
                .log(java.util.logging.Level.WARNING, "sendFinalizeNotification failed paperId=" + paperId, e);
        }
    }

    private int safeInt(String s, int def) {
        try { return Integer.parseInt(s.trim()); }
        catch (Exception e) { return def; }
    }
}