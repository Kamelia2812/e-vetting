/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Model;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author User
 */
public class CourseInfo {

    private int infoId;
    private int courseId;
    private String academicStaff;
    private String classification;
    private String creditRemarks;
    private String yearRemarks;
    private String semesterRemarks;
    private String synopsis;
    private String preRequisites;
    private String teachingMethods;
    private String assessmentMethods;
    private String transferableSkills;
    private String specialRequirements;
    private String referencesList;

    // Assessment SLT Hours
    private double caF2f, caNf2f, faF2f, faNf2f;

    // Dynamic Lists
    private List<String> clos = new ArrayList<>();
    private List<CourseSLT> sltTopics = new ArrayList<>();

    public int getInfoId() {
        return infoId;
    }

    public void setInfoId(int infoId) {
        this.infoId = infoId;
    }

    public int getCourseId() {
        return courseId;
    }

    public void setCourseId(int courseId) {
        this.courseId = courseId;
    }

    public String getAcademicStaff() {
        return academicStaff;
    }

    public void setAcademicStaff(String academicStaff) {
        this.academicStaff = academicStaff;
    }

    public String getClassification() {
        return classification;
    }

    public void setClassification(String classification) {
        this.classification = classification;
    }

    public String getCreditRemarks() {
        return creditRemarks;
    }

    public void setCreditRemarks(String creditRemarks) {
        this.creditRemarks = creditRemarks;
    }

    public String getYearRemarks() {
        return yearRemarks;
    }

    public void setYearRemarks(String yearRemarks) {
        this.yearRemarks = yearRemarks;
    }

    public String getSemesterRemarks() {
        return semesterRemarks;
    }

    public void setSemesterRemarks(String semesterRemarks) {
        this.semesterRemarks = semesterRemarks;
    }

    public String getSynopsis() {
        return synopsis;
    }

    public void setSynopsis(String synopsis) {
        this.synopsis = synopsis;
    }

    public String getPreRequisites() {
        return preRequisites;
    }

    public void setPreRequisites(String preRequisites) {
        this.preRequisites = preRequisites;
    }

    public String getTeachingMethods() {
        return teachingMethods;
    }

    public void setTeachingMethods(String teachingMethods) {
        this.teachingMethods = teachingMethods;
    }

    public String getAssessmentMethods() {
        return assessmentMethods;
    }

    public void setAssessmentMethods(String assessmentMethods) {
        this.assessmentMethods = assessmentMethods;
    }

    public String getTransferableSkills() {
        return transferableSkills;
    }

    public void setTransferableSkills(String transferableSkills) {
        this.transferableSkills = transferableSkills;
    }

    public String getSpecialRequirements() {
        return specialRequirements;
    }

    public void setSpecialRequirements(String specialRequirements) {
        this.specialRequirements = specialRequirements;
    }

    public String getReferencesList() {
        return referencesList;
    }

    public void setReferencesList(String referencesList) {
        this.referencesList = referencesList;
    }

    public double getCaF2f() {
        return caF2f;
    }

    public void setCaF2f(double caF2f) {
        this.caF2f = caF2f;
    }

    public double getCaNf2f() {
        return caNf2f;
    }

    public void setCaNf2f(double caNf2f) {
        this.caNf2f = caNf2f;
    }

    public double getFaF2f() {
        return faF2f;
    }

    public void setFaF2f(double faF2f) {
        this.faF2f = faF2f;
    }

    public double getFaNf2f() {
        return faNf2f;
    }

    public void setFaNf2f(double faNf2f) {
        this.faNf2f = faNf2f;
    }

    public List<String> getClos() {
        return clos;
    }

    public void setClos(List<String> clos) {
        this.clos = clos;
    }

    public List<CourseSLT> getSltTopics() {
        return sltTopics;
    }

    public void setSltTopics(List<CourseSLT> sltTopics) {
        this.sltTopics = sltTopics;
    }
}
