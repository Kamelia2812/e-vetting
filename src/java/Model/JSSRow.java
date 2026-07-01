package Model;

/**
 * JSSRow — one row in the JSS table. Maps to 'jss_rows'. Each row = one topic +
 * one question mapped to it.
 */
public class JSSRow {

    private int rowId;
    private int jssId;
    private int rowOrder;
    private String topicName;
    private double lectureHours;
    private String questionNo;
    private String plo;
    private String clo;
    private String questionType;  // "O", "S", "E"
    private int marks;
    private String taxonomyLevel; // C1–C6

    public int getRowId() {
        return rowId;
    }

    public int getJssId() {
        return jssId;
    }

    public int getRowOrder() {
        return rowOrder;
    }

    public String getTopicName() {
        return topicName;
    }

    public double getLectureHours() {
        return lectureHours;
    }

    public String getQuestionNo() {
        return questionNo;
    }

    public String getPlo() {
        return plo;
    }

    public String getClo() {
        return clo;
    }

    public String getQuestionType() {
        return questionType;
    }

    public int getMarks() {
        return marks;
    }

    public String getTaxonomyLevel() {
        return taxonomyLevel;
    }

    public void setRowId(int v) {
        this.rowId = v;
    }

    public void setJssId(int v) {
        this.jssId = v;
    }

    public void setRowOrder(int v) {
        this.rowOrder = v;
    }

    public void setTopicName(String v) {
        this.topicName = v;
    }

    public void setLectureHours(double v) {
        this.lectureHours = v;
    }

    public void setQuestionNo(String v) {
        this.questionNo = v;
    }

    public void setPlo(String v) {
        this.plo = v;
    }

    public void setClo(String v) {
        this.clo = v;
    }

    public void setQuestionType(String v) {
        this.questionType = v;
    }

    public void setMarks(int v) {
        this.marks = v;
    }

    public void setTaxonomyLevel(String v) {
        this.taxonomyLevel = v;
    }

    public String getQuestionTypeLabel() {
        if ("O".equals(questionType)) {
            return "Objective";
        }
        if ("S".equals(questionType)) {
            return "Structure";
        }
        if ("E".equals(questionType)) {
            return "Essay";
        }
        return questionType != null ? questionType : "—";
    }
}
