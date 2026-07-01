package Controller;

import DAO.AssessmentDAO;
import DAO.QuestionDAO;
import Model.Assessment;
import Model.Question;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List;

/**
 * SchemaServlet — Skema Jawapan (Answer Schema) builder.
 *
 * GET ?paperId=X → loads the schema form showing all questions POST action=save
 * → saves model answers for Structure and Essay questions
 *
 * For OBJECTIVE questions: correct answer is already stored in
 * questions.correct_answer — displayed read-only, no input needed. For
 * STRUCTURE and ESSAY questions: lecturer fills in model answer text — saved to
 * questions.model_answer column.
 */
@WebServlet("/SchemaServlet")
public class SchemaServlet extends HttpServlet {

    private final AssessmentDAO assessmentDAO = new AssessmentDAO();
    private final QuestionDAO questionDAO = new QuestionDAO();

    // ── GET: show schema form ──────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String paperIdParam = req.getParameter("paperId");
        if (paperIdParam == null || paperIdParam.trim().isEmpty()) {
            res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
            return;
        }

        try {
            int paperId = Integer.parseInt(paperIdParam.trim());
            Assessment paper = assessmentDAO.getAssessmentById(paperId);

            if (paper == null) {
                res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
                return;
            }

            // Lecturers can only access their own papers
            String role = (String) session.getAttribute("role");
            int userId = (int) session.getAttribute("userId");
            if ("Lecturer".equalsIgnoreCase(role) && paper.getLecturerId() != userId) {
                res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
                return;
            }

            List<Question> questions = questionDAO.getQuestionsByPaperId(paperId);

            req.setAttribute("paper", paper);
            req.setAttribute("questions", questions);
            req.setAttribute("saved", "true".equals(req.getParameter("saved")));
            req.getRequestDispatcher("/schema.jsp").forward(req, res);

        } catch (NumberFormatException e) {
            res.sendRedirect(req.getContextPath() + "/LecturerDashboardServlet");
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error loading schema", e);
        }
    }

    // ── POST: save model answers ───────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        try {
            int paperId = Integer.parseInt(req.getParameter("paperId").trim());

            // Read all questionId[] and modelAnswer[] arrays from the form
            String[] qIds = req.getParameterValues("questionId");
            String[] answers = req.getParameterValues("modelAnswer");

            if (qIds != null && answers != null) {
                for (int i = 0; i < qIds.length; i++) {
                    int qid = Integer.parseInt(qIds[i].trim());
                    String answer = (i < answers.length && answers[i] != null)
                            ? answers[i].trim() : "";
                    saveModelAnswer(qid, answer);
                }
            }

            // Save parts model answers
            String[] pIds = req.getParameterValues("partId");
            String[] pAnswers = req.getParameterValues("partModelAnswer");
            if (pIds != null && pAnswers != null) {
                for (int i = 0; i < pIds.length; i++) {
                    int pid = Integer.parseInt(pIds[i].trim());
                    String answer = (i < pAnswers.length && pAnswers[i] != null) ? pAnswers[i].trim() : "";
                    savePartModelAnswer(pid, answer);
                }
            }

            res.sendRedirect(req.getContextPath()
                    + "/SchemaServlet?paperId=" + paperId + "&saved=true");

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error saving schema answers", e);
        }
    }

    /**
     * Updates the model_answer column for a single question. Uses a direct SQL
     * update so we don't need to reload the full question object.
     */
    private void saveModelAnswer(int questionId, String modelAnswer) throws Exception {
        String sql = "UPDATE questions SET model_answer = ? WHERE question_id = ?";
        try (Connection con = util.DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, modelAnswer.isEmpty() ? null : modelAnswer);
            ps.setInt(2, questionId);
            ps.executeUpdate();
        }
    }

    private void savePartModelAnswer(int partId, String modelAnswer) throws Exception {
        String sql = "UPDATE question_parts SET part_model_answer = ? WHERE part_id = ?";
        try (Connection con = util.DBConnection.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, modelAnswer.isEmpty() ? null : modelAnswer);
            ps.setInt(2, partId);
            ps.executeUpdate();
        }
    }
}
