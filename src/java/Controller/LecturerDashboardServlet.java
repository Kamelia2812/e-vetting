package Controller;

import DAO.AssessmentDAO;
import DAO.CourseDAO;
import Model.Assessment;
import Model.Course;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * LecturerDashboardServlet
 *
 * Handles GET requests to /LecturerDashboardServlet.
 * Fetches the lecturer's courses and assessment papers from the DB,
 * then forwards everything to lecturerDashboard.jsp to be displayed.
 *
 * URL params accepted:
 *   ?page=dashboard|courses|assessments|jss  → which tab to show
 *
 * Session attributes expected (set by LoginServlet):
 *   userId   (int)    → lecturer's user_id from the users table
 *   role     (String) → must be "LECTURER" (uppercase, as stored in DB)
 *   fullName (String) → display name
 */
@WebServlet("/LecturerDashboardServlet")
public class LecturerDashboardServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();
    private final AssessmentDAO assessmentDAO = new AssessmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // ── 1. Security: must be logged in ────────────────────────────
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // ── 2. Security: must be a LECTURER ───────────────────────────
        // DB stores role as uppercase "LECTURER" — equalsIgnoreCase handles both
        String role = (String) session.getAttribute("role");
        if (role == null || !role.equalsIgnoreCase("LECTURER")) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int lecturerId = (int) session.getAttribute("userId");

        // ── 3. Which tab is active? (default: dashboard) ─────────────
        String page = request.getParameter("page");
        if (page == null || page.trim().isEmpty()) {
            page = "dashboard";
        }

        try {
            // ── 4. Fetch this lecturer's assigned courses ──────────────
            // Uses lecturer_courses join table — fixed in CourseDAO
            List<Course> courses = courseDAO.getCoursesByLecturerId(lecturerId);
            request.setAttribute("courses", courses);

            // ── 5. Fetch this lecturer's exam papers ───────────────────
            List<Assessment> assessments = assessmentDAO.getAssessmentsByLecturerId(lecturerId);
            // Log for debugging
            System.out.println("[LecturerDashboard] lecturerId=" + lecturerId + " assessments=" + assessments.size());
            for (Assessment a : assessments) {
                System.out.println("  paper_id=" + a.getPaperId() + " status=" + a.getStatus() + " course=" + a.getCourseCode());
            }
            request.setAttribute("assessments", assessments);

            // ── 6. Count papers per status (for dashboard stat cards) ──
            int draftCount            = assessmentDAO.countByLecturerAndStatus(lecturerId, "DRAFT");
            int submittedCount        = assessmentDAO.countByLecturerAndStatuses(lecturerId,
                                            "SUBMITTED", "UNDER_REVIEW",
                                            "PENDING_LEADER_SIGN", "LEADER_APPROVED", "SENT_TO_FAKULTI");
            int approvedCount         = assessmentDAO.countByLecturerAndStatuses(lecturerId, "APPROVED", "FINALIZED");
            int rejectedCount         = assessmentDAO.countByLecturerAndStatus(lecturerId, "REJECTED");
            int needsImprovementCount = assessmentDAO.countByLecturerAndStatus(lecturerId, "NEEDS_IMPROVEMENT");

            request.setAttribute("draftCount",            draftCount);
            request.setAttribute("submittedCount",        submittedCount);
            request.setAttribute("approvedCount",         approvedCount);
            request.setAttribute("rejectedCount",         rejectedCount);
            request.setAttribute("needsImprovementCount", needsImprovementCount);

            // ── 7. Pass the active tab to the JSP ─────────────────────
            request.setAttribute("activePage", page);

            // ── 8. Forward to JSP ──────────────────────────────────────
            request.getRequestDispatcher("/lecturerDashboard.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error loading lecturer dashboard: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
        }
        String role = (String) session.getAttribute("role");
        if (role == null || !role.equalsIgnoreCase("LECTURER")) {
            response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
        }

        int    lecturerId = (int)    session.getAttribute("userId");
        String fullName   = (String) session.getAttribute("fullName");
        String action     = request.getParameter("action");

        if ("submitToLeader".equals(action)) {
            int paperId = 0;
            try { paperId = Integer.parseInt(request.getParameter("paperId")); } catch (Exception ignored) {}
            if (paperId <= 0) {
                response.sendRedirect(request.getContextPath() + "/LecturerDashboardServlet?page=assessments&err=Invalid+paper");
                return;
            }
            try {
                boolean ok = assessmentDAO.submitToLeader(paperId, lecturerId);
                if (ok) {
                    notifyLeaderVetter(paperId, fullName != null ? fullName : "Lecturer");
                    response.sendRedirect(request.getContextPath() + "/LecturerDashboardServlet?page=assessments&leaderSubmitted=true");
                } else {
                    response.sendRedirect(request.getContextPath() + "/LecturerDashboardServlet?page=assessments&err=Paper+not+in+approved+state");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/LecturerDashboardServlet?page=assessments&err=Error+occurred");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/LecturerDashboardServlet");
        }
    }

    private void notifyLeaderVetter(int paperId, String lecturerName) {
        try (java.sql.Connection con = util.DBConnection.getConnection()) {
            // Fetch paper details
            String infoSql = "SELECT ep.course_code, ep.course_title, ep.academic_session, ep.semester "
                           + "FROM exam_papers ep WHERE ep.paper_id = ? LIMIT 1";
            String courseCode = "", courseTitle = "", session2 = "";
            int sem = 0;
            try (java.sql.PreparedStatement ps = con.prepareStatement(infoSql)) {
                ps.setInt(1, paperId);
                java.sql.ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    courseCode  = rs.getString("course_code");
                    courseTitle = rs.getString("course_title");
                    session2    = rs.getString("academic_session");
                    sem         = rs.getInt("semester");
                }
            }
            String summary = courseCode + " — " + courseTitle + " (" + session2 + " Sem " + sem
                           + "): Submitted by " + lecturerName + " for your signature and final approval.";

            // Find leader vetter(s) for this course
            String leaderSql = "SELECT cv.vetter_id FROM course_vetters cv "
                             + "WHERE cv.course_code = ? AND cv.is_leader = 1";
            try (java.sql.PreparedStatement ps = con.prepareStatement(leaderSql)) {
                ps.setString(1, courseCode);
                java.sql.ResultSet rs = ps.executeQuery();
                String notifSql = "INSERT INTO notifications (user_id, assessment_id, summary, is_read, created_at) VALUES (?,?,?,0,NOW())";
                while (rs.next()) {
                    int leaderId = rs.getInt("vetter_id");
                    try (java.sql.PreparedStatement np = con.prepareStatement(notifSql)) {
                        np.setInt(1, leaderId); np.setInt(2, paperId); np.setString(3, summary);
                        np.executeUpdate();
                    }
                }
            }
        } catch (Exception e) {
            // Non-fatal
        }
    }
}