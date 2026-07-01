package Controller;

import DAO.AssessmentDAO;
import DAO.QuestionCommentDAO;
import DAO.QuestionDAO;
import Model.Assessment;
import Model.Question;
import Model.QuestionComment;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Serves the read-only "Vetter Feedback" page for a lecturer (or KP/Admin).
 *
 * Accessible by:
 *   – the lecturer who owns the paper
 *   – any user with role KP, Admin, or Vetter (read-only oversight)
 *
 * GET /LecturerReviewServlet?paperId=123
 */
@WebServlet("/LecturerReviewServlet")
public class LecturerReviewServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(LecturerReviewServlet.class.getName());

    private final AssessmentDAO      assessmentDAO = new AssessmentDAO();
    private final QuestionDAO        questionDAO   = new QuestionDAO();
    private final QuestionCommentDAO commentDAO    = new QuestionCommentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int    userId = (int)    session.getAttribute("userId");
        String role   = (String) session.getAttribute("role");

        int paperId = 0;
        try { paperId = Integer.parseInt(request.getParameter("paperId")); }
        catch (Exception ignored) {}

        if (paperId <= 0) {
            response.sendRedirect(request.getContextPath() + "/LecturerDashboardServlet");
            return;
        }

        try {
            Assessment paper = assessmentDAO.getAssessmentById(paperId);
            if (paper == null) {
                response.sendRedirect(request.getContextPath() + "/LecturerDashboardServlet");
                return;
            }

            // Access control: lecturer must own the paper; KP/Admin/Vetter may view any
            boolean isOwner  = paper.getLecturerId() == userId;
            boolean isKpOrAdmin = role != null && (
                    role.equalsIgnoreCase("KP")      ||
                    role.equalsIgnoreCase("Admin")   ||
                    role.equalsIgnoreCase("ADMIN")   ||
                    role.equalsIgnoreCase("Vetter"));
            if (!isOwner && !isKpOrAdmin) {
                response.sendRedirect(request.getContextPath() + "/LecturerDashboardServlet");
                return;
            }

            List<Question>  questions  = questionDAO.getQuestionsByPaperId(paperId);
            Map<Integer, List<QuestionComment>> commentMap = commentDAO.getCommentsByPaperId(paperId);
            List<Map<String,Object>> jssComments    = commentDAO.getSectionComments(paperId, "JSS");
            List<Map<String,Object>> schemeComments = commentDAO.getSectionComments(paperId, "SCHEME");

            java.util.List<java.util.Map<String, Object>> allChecklists = new java.util.ArrayList<>();
            try {
                DAO.VettingChecklistDAO clDAO = new DAO.VettingChecklistDAO();
                allChecklists = clDAO.loadAllForPaper(paperId);
            } catch (Exception ignored) {}

            request.setAttribute("paper",          paper);
            request.setAttribute("questions",      questions);
            request.setAttribute("commentMap",     commentMap);
            request.setAttribute("jssComments",    jssComments);
            request.setAttribute("schemeComments", schemeComments);
            request.setAttribute("isOwner",        isOwner);
            request.setAttribute("viewerRole",     role);
            request.setAttribute("allChecklists",  allChecklists);

            request.getRequestDispatcher("/lecturerReview.jsp").forward(request, response);

        } catch (Exception e) {
            LOG.log(Level.SEVERE, "LecturerReviewServlet failed paperId=" + paperId, e);
            throw new ServletException(e);
        }
    }
}
