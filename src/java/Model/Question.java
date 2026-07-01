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
public class Question {
    private List<QuestionPart> parts = new ArrayList<>();

    private int questionId;
    private int paperId;
    public int assessmentId;
    private String questionNo;
    private String questionType;
    private String questionFormat;  // "SIMPLE" or "COMPLEX" (Roman-numeral statement combos)
    private String questionText;
    private String questionTextMs;  // Malay translation
    private String statement1;      // Complex MCQ statement "I"
    private String statement2;      // Complex MCQ statement "II"
    private String statement3;      // Complex MCQ statement "III"
    private String statement4;      // Complex MCQ statement "IV"
    private String imageUrl;        // optional uploaded image shown above the choices
    private String tableData;       // optional HTML table markup shown above the choices
    private int marks;
    private String chapter;
    private String taxonomyLevel;
    private String cloMapping;      // e.g. "CLO1"
    private String choiceA;
    private String choiceB;
    private String choiceC;
    private String choiceD;
    private String correctAnswer;   // "A", "B", "C", or "D"
    private String modelAnswer;      // skema jawapan for Structure/Essay questions
    private String status;

    public int getQuestionId() {
        return questionId;
    }

    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }

    public int getPaperId() {
        return paperId;
    }

    public void setPaperId(int paperId) {
        this.paperId = paperId;
    }

    public int getAssessmentId() {
        return assessmentId;
    }

    public void setAssessmentId(int assessmentId) {
        this.assessmentId = assessmentId;
    }

    public String getQuestionNo() {
        return questionNo;
    }

    public void setQuestionNo(String questionNo) {
        this.questionNo = questionNo;
    }

    public String getQuestionType() {
        return questionType;
    }

    public void setQuestionType(String questionType) {
        this.questionType = questionType;
    }

    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public int getMarks() {
        return marks;
    }

    public void setMarks(int marks) {
        this.marks = marks;
    }

    public String getChapter() {
        return chapter;
    }

    public void setChapter(String chapter) {
        this.chapter = chapter;
    }

    public String getTaxonomyLevel() {
        return taxonomyLevel;
    }

    public void setTaxonomyLevel(String taxonomyLevel) {
        this.taxonomyLevel = taxonomyLevel;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getQuestionTextMs() {
        return questionTextMs;
    }

    public void setQuestionTextMs(String v) {
        this.questionTextMs = v;
    }

    public String getCloMapping() {
        return cloMapping;
    }

    public void setCloMapping(String v) {
        this.cloMapping = v;
    }

    public String getChoiceA() {
        return choiceA;
    }

    public void setChoiceA(String v) {
        this.choiceA = v;
    }

    public String getChoiceB() {
        return choiceB;
    }

    public void setChoiceB(String v) {
        this.choiceB = v;
    }

    public String getChoiceC() {
        return choiceC;
    }

    public void setChoiceC(String v) {
        this.choiceC = v;
    }

    public String getChoiceD() {
        return choiceD;
    }

    public void setChoiceD(String v) {
        this.choiceD = v;
    }

    public String getCorrectAnswer() {
        return correctAnswer;
    }

    public void setCorrectAnswer(String v) {
        this.correctAnswer = v;
    }

    public String getModelAnswer() {
        return modelAnswer;
    }

    public void setModelAnswer(String v) {
        this.modelAnswer = v;
    }

    public String getQuestionFormat() {
        return questionFormat;
    }

    public void setQuestionFormat(String v) {
        this.questionFormat = v;
    }

    public boolean isComplex() {
        return "COMPLEX".equalsIgnoreCase(questionFormat);
    }

    public String getStatement1() { return statement1; }
    public void setStatement1(String v) { this.statement1 = v; }

    public String getStatement2() { return statement2; }
    public void setStatement2(String v) { this.statement2 = v; }

    public String getStatement3() { return statement3; }
    public void setStatement3(String v) { this.statement3 = v; }

    public String getStatement4() { return statement4; }
    public void setStatement4(String v) { this.statement4 = v; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String v) { this.imageUrl = v; }

    public String getTableData() { return tableData; }
    public void setTableData(String v) { this.tableData = v; }

    public List<QuestionPart> getParts() { return parts; }
    public void setParts(List<QuestionPart> parts) { this.parts = parts; }
}
