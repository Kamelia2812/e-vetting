package Model;

public class Vetting {
    
    private int vettingId;
    private int assessmentId;    // Links to the exact exam/JSS being reviewed
    private int vetterId;        // Links to the User doing the review
    private String status;       // e.g., "APPROVED", "REVISION_REQUIRED"
    private String comments;     // The feedback/corrections needed
    private String vettingDate;  // When the vetter submitted this review
    
    public Vetting() {
    }

    public Vetting(int vettingId, int assessmentId, int vetterId, String status, String comments, String vettingDate) {
        this.vettingId = vettingId;
        this.assessmentId = assessmentId;
        this.vetterId = vetterId;
        this.status = status;
        this.comments = comments;
        this.vettingDate = vettingDate;
    }

    public int getVettingId() {
        return vettingId;
    }

    public void setVettingId(int vettingId) {
        this.vettingId = vettingId;
    }

    public int getAssessmentId() {
        return assessmentId;
    }

    public void setAssessmentId(int assessmentId) {
        this.assessmentId = assessmentId;
    }

    public int getVetterId() {
        return vetterId;
    }

    public void setVetterId(int vetterId) {
        this.vetterId = vetterId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getComments() {
        return comments;
    }

    public void setComments(String comments) {
        this.comments = comments;
    }

    public String getVettingDate() {
        return vettingDate;
    }

    public void setVettingDate(String vettingDate) {
        this.vettingDate = vettingDate;
    }
}