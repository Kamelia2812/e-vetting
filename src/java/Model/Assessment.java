package Model;

import java.sql.Timestamp;

/**
 * Assessment model — maps to the 'exam_papers' table in the database.
 *
 * Why exam_papers and not assessment? The 'exam_papers' table is the more
 * complete one — it has lecturer_id, course_code, status with proper values,
 * submitted_date, etc. The 'assessment' table is an older/simpler version; we
 * use exam_papers.
 *
 * Status values (from DB enum): DRAFT → lecturer is still working on it
 * SUBMITTED → lecturer submitted, waiting for vetter UNDER_REVIEW → vetter is
 * reviewing APPROVED → vetter approved, sent to KP REJECTED → vetter rejected,
 * needs revision
 */
public class Assessment {

    // Maps to exam_papers columns
    private int paperId;
    private String courseCode;
    private String courseTitle;
    private String faculty;
    private int lecturerId;
    private Integer ketuaPanelId;      // nullable — vetter assigned by KP
    private Integer ketuaProgramId;    // nullable — KP who will sign off
    private String paperType;          // FINAL or SUPPLEMENTARY
    private String academicSession;    // e.g. "2024/2025"
    private int semester;
    private int totalQuestions;
    private int vettedQuestions;
    private String status;             // DRAFT, SUBMITTED, UNDER_REVIEW, APPROVED, REJECTED
    private Timestamp submittedDate;   // null if not yet submitted
    private String deadline;
    private String remarks;            // vetter's overall comment
    private String instructions;       // assignment task instructions
    private double weightage;          // % contribution to final grade
    private String submissionMode;     // Individual or Group
    private int assignMarks;        // total marks for assignment
    private Timestamp createdAt;
    private Timestamp updatedAt;
    // Transient — populated by JOIN queries, not stored in exam_papers
    private String lecturerName;
    private String vetterName;

    // ─── Getters ───────────────────────────────────────────────────────
    public int getPaperId() {
        return paperId;
    }

    public String getCourseCode() {
        return courseCode;
    }

    public String getCourseTitle() {
        return courseTitle;
    }

    public String getFaculty() {
        return faculty;
    }

    public int getLecturerId() {
        return lecturerId;
    }

    public Integer getKetuaPanelId() {
        return ketuaPanelId;
    }

    public Integer getKetuaProgramId() {
        return ketuaProgramId;
    }

    public String getPaperType() {
        return paperType;
    }

    public String getAcademicSession() {
        return academicSession;
    }

    public int getSemester() {
        return semester;
    }

    public int getTotalQuestions() {
        return totalQuestions;
    }

    public int getVettedQuestions() {
        return vettedQuestions;
    }

    public String getStatus() {
        return status;
    }

    public Timestamp getSubmittedDate() {
        return submittedDate;
    }

    public String getDeadline() {
        return deadline;
    }

    public String getRemarks() {
        return remarks;
    }

    public String getInstructions() {
        return instructions;
    }

    public double getWeightage() {
        return weightage;
    }

    public String getSubmissionMode() {
        return submissionMode;
    }

    public int getAssignMarks() {
        return assignMarks;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setDeadline(String deadline) {
        this.deadline = deadline;
    }

    // ─── Setters (main fields) ─────────────────────────────────────────
    public void setPaperId(int paperId) { this.paperId = paperId; }
    public void setCourseCode(String courseCode) { this.courseCode = courseCode; }
    public void setCourseTitle(String courseTitle) { this.courseTitle = courseTitle; }
    public void setFaculty(String faculty) { this.faculty = faculty; }
    public void setLecturerId(int lecturerId) { this.lecturerId = lecturerId; }
    public void setKetuaPanelId(Integer ketuaPanelId) { this.ketuaPanelId = ketuaPanelId; }
    public void setKetuaProgramId(Integer ketuaProgramId) { this.ketuaProgramId = ketuaProgramId; }
    public void setPaperType(String paperType) { this.paperType = paperType; }
    public void setAcademicSession(String academicSession) { this.academicSession = academicSession; }
    public void setSemester(int semester) { this.semester = semester; }
    public void setTotalQuestions(int totalQuestions) { this.totalQuestions = totalQuestions; }
    public void setVettedQuestions(int vettedQuestions) { this.vettedQuestions = vettedQuestions; }
    public void setStatus(String status) { this.status = status; }
    public void setSubmittedDate(Timestamp submittedDate) { this.submittedDate = submittedDate; }

    // ─── Setters (new assignment fields) ──────────────────────────────
    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }

    public void setInstructions(String instructions) {
        this.instructions = instructions;
    }

    public void setWeightage(double weightage) {
        this.weightage = weightage;
    }

    public void setSubmissionMode(String submissionMode) {
        this.submissionMode = submissionMode;
    }

    public void setAssignMarks(int assignMarks) {
        this.assignMarks = assignMarks;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getLecturerName() { return lecturerName; }
    public void setLecturerName(String lecturerName) { this.lecturerName = lecturerName; }
    public String getVetterName() { return vetterName; }
    public void setVetterName(String vetterName) { this.vetterName = vetterName; }

    // ─── Helpers used in JSP ───────────────────────────────────────────
    public boolean isEditable() {
        return "DRAFT".equals(status) || "REJECTED".equals(status) || "NEEDS_IMPROVEMENT".equals(status);
    }

    public boolean isSubmittableToLeader() {
        return "APPROVED".equals(status) || "NEEDS_IMPROVEMENT".equals(status);
    }

    public boolean isPendingLeaderSign() {
        return "PENDING_LEADER_SIGN".equals(status);
    }

    public boolean isLeaderApproved() {
        return "LEADER_APPROVED".equals(status);
    }

    public boolean isFinalAssessment() {
        if (paperType == null) {
            return true;
        }
        return paperType.startsWith("Final") || paperType.equals("FINAL") || paperType.equals("Supplementary Exam") || paperType.equals("SUPPLEMENTARY");
    }

    public boolean isContinuousAssessment() {
        return !isFinalAssessment();
    }

    public String getPaperTypeLabel() {
        if (paperType == null) {
            return "—";
        }
        switch (paperType) {
            case "FINAL":
                return "Final Exam";
            case "SUPPLEMENTARY":
                return "Supplementary Exam";
            default:
                return paperType;
        }
    }

    public String getStatusLabel() {
        if (status == null) {
            return "Draft";
        }
        switch (status) {
            case "DRAFT":
                return "Draft";
            case "SUBMITTED":
                return "Submitted";
            case "UNDER_REVIEW":
                return "Under Review";
            case "NEEDS_IMPROVEMENT":
                return "Needs Improvement";
            case "APPROVED":
                return "Approved";
            case "REJECTED":
                return "Rejected";
            case "PENDING_LEADER_SIGN":
                return "Awaiting Leader Signature";
            case "LEADER_APPROVED":
                return "Leader Approved";
            case "SENT_TO_FAKULTI":
                return "Sent to Fakulti";
            case "FINALIZED":
                return "Finalized by KP";
            default:
                return status;
        }
    }

    public String getStatusClass() {
        if (status == null) {
            return "badge-draft";
        }
        switch (status) {
            case "DRAFT":
                return "badge-draft";
            case "SUBMITTED":
                return "badge-submitted";
            case "UNDER_REVIEW":
                return "badge-review";
            case "NEEDS_IMPROVEMENT":
                return "badge-improve";
            case "APPROVED":
                return "badge-approved";
            case "REJECTED":
                return "badge-rejected";
            case "PENDING_LEADER_SIGN":
                return "badge-leader";
            case "LEADER_APPROVED":
                return "badge-leader";
            case "SENT_TO_FAKULTI":
                return "badge-sent";
            case "FINALIZED":
                return "badge-sent";
            default:
                return "badge-draft";
        }
    }
}