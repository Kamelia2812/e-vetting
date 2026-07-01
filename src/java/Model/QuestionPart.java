package Model;

public class QuestionPart {
    private int partId;
    private int questionId;
    private String partLabel;
    private String partQuestionText;
    private int partMarks;
    private String partModelAnswer;

    public int getPartId() {
        return partId;
    }

    public void setPartId(int partId) {
        this.partId = partId;
    }

    public int getQuestionId() {
        return questionId;
    }

    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }

    public String getPartLabel() {
        return partLabel;
    }

    public void setPartLabel(String partLabel) {
        this.partLabel = partLabel;
    }

    public String getPartQuestionText() {
        return partQuestionText;
    }

    public void setPartQuestionText(String partQuestionText) {
        this.partQuestionText = partQuestionText;
    }

    public int getPartMarks() {
        return partMarks;
    }

    public void setPartMarks(int partMarks) {
        this.partMarks = partMarks;
    }

    public String getPartModelAnswer() {
        return partModelAnswer;
    }

    public void setPartModelAnswer(String partModelAnswer) {
        this.partModelAnswer = partModelAnswer;
    }
}
