package Model;

import java.sql.Timestamp;
import java.util.List;

/**
 * JSS — Jadual Spesifikasi Soalan (Question Specification Table) Maps to the
 * 'jss' table. One JSS belongs to one exam paper.
 */
public class JSS {

    private int jssId;
    private int paperId;
    private int courseId;
    private int lecturerId;
    private String faculty;
    private String programme;
    private String academicSession;
    private int semester;
    private String assessmentType;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private List<JSSRow> rows;

    public int getJssId() {
        return jssId;
    }

    public int getPaperId() {
        return paperId;
    }

    public int getCourseId() {
        return courseId;
    }

    public int getLecturerId() {
        return lecturerId;
    }

    public String getFaculty() {
        return faculty;
    }

    public String getProgramme() {
        return programme;
    }

    public String getAcademicSession() {
        return academicSession;
    }

    public int getSemester() {
        return semester;
    }

    public String getAssessmentType() {
        return assessmentType;
    }

    public String getStatus() {
        return status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public List<JSSRow> getRows() {
        return rows;
    }

    public void setJssId(int v) {
        this.jssId = v;
    }

    public void setPaperId(int v) {
        this.paperId = v;
    }

    public void setCourseId(int v) {
        this.courseId = v;
    }

    public void setLecturerId(int v) {
        this.lecturerId = v;
    }

    public void setFaculty(String v) {
        this.faculty = v;
    }

    public void setProgramme(String v) {
        this.programme = v;
    }

    public void setAcademicSession(String v) {
        this.academicSession = v;
    }

    public void setSemester(int v) {
        this.semester = v;
    }

    public void setAssessmentType(String v) {
        this.assessmentType = v;
    }

    public void setStatus(String v) {
        this.status = v;
    }

    public void setCreatedAt(Timestamp v) {
        this.createdAt = v;
    }

    public void setUpdatedAt(Timestamp v) {
        this.updatedAt = v;
    }

    public void setRows(List<JSSRow> v) {
        this.rows = v;
    }

    public int getTotalMarks() {
        if (rows == null) {
            return 0;
        }
        int sum = 0;
        for (JSSRow row : rows) {
            sum += row.getMarks();
        }
        return sum;
    }

    public double getTotalLectureHours() {
        if (rows == null) {
            return 0;
        }
        double sum = 0;
        for (JSSRow row : rows) {
            sum += row.getLectureHours();
        }
        return sum;
    }

    public int getMarksForClo(String clo) {
        if (rows == null) {
            return 0;
        }
        int sum = 0;
        for (JSSRow r : rows) {
            if (clo.equals(r.getClo())) {
                sum += r.getMarks();
            }
        }
        return sum;
    }

    public int getMarksForTaxonomy(String level) {
        if (rows == null) {
            return 0;
        }
        int sum = 0;
        for (JSSRow r : rows) {
            if (level.equals(r.getTaxonomyLevel())) {
                sum += r.getMarks();
            }
        }
        return sum;
    }

    public boolean isDraft() {
        return "DRAFT".equals(status);
    }
}
