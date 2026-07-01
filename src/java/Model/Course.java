package Model;

public class Course {

    private int courseId;
    private String courseCode;
    private String courseName;
    private int credit;
    private int examHour;
    private String core;
    private String coCategory; // course category
    private String uniOffer;   // university offer
    private String offerPeriod; // offer period (e.g. session 1 2024/25)
    private String senateRef;  // senate reference
    private int lecturerId;
    private int vetterId;       //leader
    private String lecturerName;   // fetched via JOIN in CourseDAO.getAllCourses()
    private String vetterName;     // fetched via JOIN in CourseDAO.getAllCourses()
    private String department;
    private String faculty;

    public Course() {
    }

    public Course(int courseId, String courseCode, String courseName, int credit, int examHour, String core, String coCategory, String uniOffer, String offerPeriod, String senateRef, int lecturerId, int vetterId) {
        this.courseId = courseId;
        this.courseCode = courseCode;
        this.courseName = courseName;
        this.credit = credit;
        this.examHour = examHour;
        this.core = core;
        this.coCategory = coCategory;
        this.uniOffer = uniOffer;
        this.offerPeriod = offerPeriod;
        this.senateRef = senateRef;
        this.lecturerId = lecturerId;
        this.vetterId = vetterId;
    }

    public int getCourseId() {
        return courseId;
    }

    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }

    public String getCourseCode() {
        return courseCode;
    }

    public void setCourseCode(String courseCode) {
        this.courseCode = courseCode;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public int getCredit() {
        return credit;
    }

    public void setCredit(int credit) {
        this.credit = credit;
    }

    public int getExamHour() {
        return examHour;
    }

    public void setExamHour(int examHour) {
        this.examHour = examHour;
    }

    public String getCore() {
        return core;
    }

    public void setCore(String core) {
        this.core = core;
    }

    public String getCoCategory() {
        return coCategory;
    }

    public void setCoCategory(String coCategory) {
        this.coCategory = coCategory;
    }

    public String getUniOffer() {
        return uniOffer;
    }

    public void setUniOffer(String uniOffer) {
        this.uniOffer = uniOffer;
    }

    public String getOfferPeriod() {
        return offerPeriod;
    }

    public void setOfferPeriod(String offerPeriod) {
        this.offerPeriod = offerPeriod;
    }

    public String getSenateRef() {
        return senateRef;
    }

    public void setSenateRef(String senateRef) {
        this.senateRef = senateRef;
    }

    public int getLecturerId() {
        return lecturerId;
    }

    public void setLecturerId(int lecturerId) {
        this.lecturerId = lecturerId;
    }

    public int getVetterId() {
        return vetterId;
    }

    public void setVetterId(int vetterId) {
        this.vetterId = vetterId;
    }

    public String getLecturerName() {
        return lecturerName;
    }

    public void setLecturerName(String lecturerName) {
        this.lecturerName = lecturerName;
    }

    public String getVetterName() {
        return vetterName;
    }

    public void setVetterName(String vetterName) {
        this.vetterName = vetterName;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getFaculty() {
        return faculty;
    }

    public void setFaculty(String faculty) {
        this.faculty = faculty;
    }

}
