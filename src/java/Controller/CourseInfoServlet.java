/*package Controller;

import DAO.CourseDAO;
import Model.Course;
import Model.CourseInfo;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/course-info")
public class CourseInfoServlet extends HttpServlet {

    private final CourseDAO courseDAO = new CourseDAO();

    // 1. THIS RUNS WHEN YOU CLICK THE COURSE CARD TO VIEW THE PAGE
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/admin/courses?err=Invalid Course ID");
            return;
        }

        try {
            int courseId = Integer.parseInt(idParam);
            Course course = courseDAO.getCourseById(courseId);
            CourseInfo courseInfo = courseDAO.getCourseInfo(courseId);

            if (course == null) {
                response.sendRedirect(request.getContextPath() + "/admin/courses?err=Course Not Found");
                return;
            }

            request.setAttribute("course", course);
            request.setAttribute("courseInfo", courseInfo);
            request.getRequestDispatcher("/courseInformation.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Error loading course info", e);
        }
    }

    // 2. THIS RUNS WHEN VETTING PANEL CLICKS "SAVE SYLLABUS DETAILS"
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Security check
        String role = (String) session.getAttribute("role");
        boolean canEdit = "Ketua Panel".equalsIgnoreCase(role) || "Vetting Panel".equalsIgnoreCase(role) || "Admin".equalsIgnoreCase(role);
        if (!canEdit) {
            response.sendRedirect(request.getContextPath() + "/admin/courses?err=Unauthorized");
            return;
        }

        try {
            int courseId = Integer.parseInt(request.getParameter("courseId"));

            // --- A. SAVE MAIN COURSE INFO ---
            CourseInfo info = new CourseInfo();
            info.setCourseId(courseId);
            info.setAcademicStaff(request.getParameter("academicStaff"));
            info.setClassification(request.getParameter("classification"));
            info.setPreRequisites(request.getParameter("preRequisites"));
            info.setSynopsis(request.getParameter("synopsis"));
            info.setTransferableSkills(request.getParameter("transferableSkills"));
            info.setSpecialRequirements(request.getParameter("specialRequirements"));
            
            // Remarks
            info.setCreditRemarks(request.getParameter("creditRemarks"));
            info.setYearRemarks(request.getParameter("yearRemarks"));
            info.setSemesterRemarks(request.getParameter("semesterRemarks"));

            // Assessment Hours (Using safe parsing helper below)
            info.setCaF2f(parseDoubleSafely(request.getParameter("caF2f")));
            info.setCaNf2f(parseDoubleSafely(request.getParameter("caNf2f")));
            info.setFaF2f(parseDoubleSafely(request.getParameter("faF2f")));
            info.setFaNf2f(parseDoubleSafely(request.getParameter("faNf2f")));

            courseDAO.saveCourseInfo(info);

            // --- B. CLEAR OLD DYNAMIC DATA ---
            courseDAO.clearDynamicData(courseId);

            // --- C. SAVE DYNAMIC CLOs & PLO MAPPING ---
            String[] cloDescs = request.getParameterValues("cloDesc[]");
            String[] cloTeaching = request.getParameterValues("cloTeaching[]");
            String[] cloAssessment = request.getParameterValues("cloAssessment[]");

            if (cloDescs != null) {
                for (int i = 0; i < cloDescs.length; i++) {
                    if (!cloDescs[i].trim().isEmpty()) {
                        
                        // Grab all 11 checkboxes for this specific row
                        int[] plos = new int[11];
                        for (int p = 1; p <= 11; p++) {
                            String[] ploCol = request.getParameterValues("plo" + p + "[]");
                            plos[p - 1] = (ploCol != null && ploCol.length > i) ? Integer.parseInt(ploCol[i]) : 0;
                        }
                        
                        String teaching = (cloTeaching != null && cloTeaching.length > i) ? cloTeaching[i] : "";
                        String assessment = (cloAssessment != null && cloAssessment.length > i) ? cloAssessment[i] : "";

                        courseDAO.saveCLO(courseId, cloDescs[i], plos, teaching, assessment);
                    }
                }
            }

            // --- D. SAVE DYNAMIC SLT TOPICS ---
            String[] sltTopics = request.getParameterValues("sltTopic[]");
            String[] sltL = request.getParameterValues("sltL[]");
            String[] sltT = request.getParameterValues("sltT[]");
            String[] sltP = request.getParameterValues("sltP[]");
            String[] sltO = request.getParameterValues("sltO[]");
            String[] sltNf2f = request.getParameterValues("sltNf2f[]");

            if (sltTopics != null) {
                for (int i = 0; i < sltTopics.length; i++) {
                    if (!sltTopics[i].trim().isEmpty()) {
                        courseDAO.saveSLT(
                            courseId, 
                            sltTopics[i],
                            parseDoubleSafely(sltL != null && sltL.length > i ? sltL[i] : "0"),
                            parseDoubleSafely(sltT != null && sltT.length > i ? sltT[i] : "0"),
                            parseDoubleSafely(sltP != null && sltP.length > i ? sltP[i] : "0"),
                            parseDoubleSafely(sltO != null && sltO.length > i ? sltO[i] : "0"),
                            parseDoubleSafely(sltNf2f != null && sltNf2f.length > i ? sltNf2f[i] : "0")
                        );
                    }
                }
            }

            response.sendRedirect(request.getContextPath() + "/admin/course-info?id=" + courseId + "&success=1");

        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Error saving course info", e);
        }
    }

    // A helper method to prevent the server crashing if a user leaves a number box blank
    private double parseDoubleSafely(String val) {
        if (val == null || val.trim().isEmpty()) return 0.0;
        try {
            return Double.parseDouble(val);
        } catch (NumberFormatException e) {
            return 0.0;
        }
    }
}
*/