package Model;

/**
 * RubricRow — one criterion row in a continuous assessment rubric.
 * Maps to the rubric_rows table.
 *
 * Each assignment paper has 1-N rubric rows.
 * The sum of all row marks should equal assignMarks on the parent Assessment.
 */
public class RubricRow {

    private int    rubricId;
    private int    paperId;
    private int    rowOrder;
    private String criterion;   // e.g. "Content", "Presentation"
    private int    marks;       // marks allocated to this criterion
    private String clo;         // e.g. "CLO1"
    private String bloom;       // e.g. "C3"
    private String description; // level descriptor / marking guide

    // ── Constructors ──────────────────────────────────────────────────

    public RubricRow() {}

    public RubricRow(int paperId, int rowOrder,
                     String criterion, int marks,
                     String clo, String bloom, String description) {
        this.paperId     = paperId;
        this.rowOrder    = rowOrder;
        this.criterion   = criterion;
        this.marks       = marks;
        this.clo         = clo;
        this.bloom       = bloom;
        this.description = description;
    }

    // ── Getters ───────────────────────────────────────────────────────

    public int    getRubricId()    { return rubricId;    }
    public int    getPaperId()     { return paperId;     }
    public int    getRowOrder()    { return rowOrder;    }
    public String getCriterion()   { return criterion;   }
    public int    getMarks()       { return marks;       }
    public String getClo()         { return clo;         }
    public String getBloom()       { return bloom;       }
    public String getDescription() { return description; }

    // ── Setters ───────────────────────────────────────────────────────

    public void setRubricId(int rubricId)        { this.rubricId    = rubricId;    }
    public void setPaperId(int paperId)          { this.paperId     = paperId;     }
    public void setRowOrder(int rowOrder)        { this.rowOrder    = rowOrder;    }
    public void setCriterion(String criterion)   { this.criterion   = criterion;   }
    public void setMarks(int marks)              { this.marks       = marks;       }
    public void setClo(String clo)               { this.clo         = clo;         }
    public void setBloom(String bloom)           { this.bloom       = bloom;       }
    public void setDescription(String desc)      { this.description = desc;        }

    @Override
    public String toString() {
        return "RubricRow{rubricId=" + rubricId
                + ", criterion='" + criterion + "'"
                + ", marks=" + marks + "}";
    }
}