package Model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Represents a vetter's comment on a specific exam question.
 *
 * <p>Each comment belongs to exactly one (question, vetter) pair — the DB
 * enforces this with a UNIQUE constraint so vetters can revise their comment
 * without creating duplicates.
 *
 * <p>A comment optionally carries two classification tags:
 * <ul>
 *   <li>{@code contentTag}  — flags the question's content quality
 *       (e.g. "Content: Needs refinement")</li>
 *   <li>{@code taxonomyTag} — suggests a Bloom's taxonomy correction
 *       (e.g. "Taxonomy: Suggest C4 Analyze")</li>
 * </ul>
 * 
 */
public class QuestionComment {

    // ── Display formatter used in JSP (e.g. "10 Apr 2025 · 14:32") ──────────
    private static final DateTimeFormatter DISPLAY_FMT =
            DateTimeFormatter.ofPattern("dd MMM yyyy · HH:mm");

    // ── Fields ────────────────────────────────────────────────────────────────
    private int           commentId;
    private int           questionId;
    private int           vetterId;
    private String        vetterName;   // denormalised — joined from users.full_name
    private String        commentText;
    private String        contentTag;
    private String        taxonomyTag;
    private String        verdict;            // APPROVED | NEEDS_REVISION | REJECTED
    private String        suggestedTaxonomy;  // e.g. "C4"
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // ── Constructors ──────────────────────────────────────────────────────────

    public QuestionComment() {}

    /**
     * Convenience constructor for creating a new comment before persisting.
     *
     * @param questionId  the question being commented on
     * @param vetterId    the vetter leaving the comment
     * @param commentText the review text body
     * @param contentTag  optional content quality label
     * @param taxonomyTag optional Bloom's taxonomy suggestion label
     */
    public QuestionComment(int questionId,
                           int vetterId,
                           String commentText,
                           String contentTag,
                           String taxonomyTag) {
        this.questionId  = questionId;
        this.vetterId    = vetterId;
        this.commentText = commentText;
        this.contentTag  = blankToNull(contentTag);
        this.taxonomyTag = blankToNull(taxonomyTag);
    }

    public QuestionComment(int questionId,
                           int vetterId,
                           String commentText,
                           String contentTag,
                           String taxonomyTag,
                           String verdict,
                           String suggestedTaxonomy) {
        this.questionId        = questionId;
        this.vetterId          = vetterId;
        this.commentText       = commentText;
        this.contentTag        = blankToNull(contentTag);
        this.taxonomyTag       = blankToNull(taxonomyTag);
        this.verdict           = blankToNull(verdict);
        this.suggestedTaxonomy = blankToNull(suggestedTaxonomy);
    }

    // ── Derived / display helpers ─────────────────────────────────────────────

    /**
     * Returns the comment timestamp formatted for JSP display.
     * Prefers {@code updatedAt} so edits show the latest time.
     */
    public String getFormattedDate() {
        LocalDateTime ts = (updatedAt != null) ? updatedAt : createdAt;
        return (ts != null) ? ts.format(DISPLAY_FMT) : "";
    }

    /**
     * Returns up to two uppercase initials derived from the vetter's full name,
     * skipping leading honorifics that end with a period (Dr., Prof., Ts., etc.).
     *
     * <pre>
     *   "Dr. Siti Rahayu"  → "SR"
     *   "Ahmad Farid"      → "AF"
     *   "Aminah"           → "AM"  (uses first two chars of single name)
     * </pre>
     */
    public String getInitials() {
        if (vetterName == null || vetterName.trim().isEmpty()) return "??";

        String[] parts = vetterName.trim().split("\\s+");
        int start = (parts.length > 1 && parts[0].endsWith(".")) ? 1 : 0;

        StringBuilder sb = new StringBuilder();
        for (int i = start; i < parts.length && sb.length() < 2; i++) {
            if (!parts[i].isEmpty()) {
                sb.append(Character.toUpperCase(parts[i].charAt(0)));
            }
        }
        // Single-word name fallback — use first two chars
        if (sb.length() == 1 && parts[start].length() > 1) {
            sb.append(Character.toUpperCase(parts[start].charAt(1)));
        }
        return sb.length() > 0 ? sb.toString() : "??";
    }

    /**
     * Returns true when at least one tag is present (non-blank).
     * Used by JSP to decide whether to render the tag pill row.
     */
    public boolean hasTags() {
        return isPresent(contentTag) || isPresent(taxonomyTag);
    }

    /**
     * Returns true if the content tag signals the question needs work.
     * Drives the automatic per-question "Needs Revision" status badge.
     */
    public boolean isContentFlagged() {
        return isPresent(contentTag)
               && contentTag.toLowerCase().contains("needs");
    }

    // ── Getters ───────────────────────────────────────────────────────────────

    public int           getCommentId()   { return commentId;   }
    public int           getQuestionId()  { return questionId;  }
    public int           getVetterId()    { return vetterId;    }
    public String        getVetterName()  { return vetterName;  }
    public String        getCommentText() { return commentText; }
    public String        getContentTag()        { return contentTag;        }
    public String        getTaxonomyTag()       { return taxonomyTag;       }
    public String        getVerdict()           { return verdict;           }
    public String        getSuggestedTaxonomy() { return suggestedTaxonomy; }
    public LocalDateTime getCreatedAt()         { return createdAt;         }
    public LocalDateTime getUpdatedAt()         { return updatedAt;         }

    // ── Setters ───────────────────────────────────────────────────────────────

    public void setCommentId(int id)                  { this.commentId   = id;               }
    public void setQuestionId(int id)                 { this.questionId  = id;               }
    public void setVetterId(int id)                   { this.vetterId    = id;               }
    public void setVetterName(String name)            { this.vetterName  = name;             }
    public void setCommentText(String text)           { this.commentText = text;             }
    public void setContentTag(String tag)             { this.contentTag        = blankToNull(tag);     }
    public void setTaxonomyTag(String tag)            { this.taxonomyTag       = blankToNull(tag);     }
    public void setVerdict(String v)                  { this.verdict           = blankToNull(v);       }
    public void setSuggestedTaxonomy(String t)        { this.suggestedTaxonomy = blankToNull(t);       }
    public void setCreatedAt(LocalDateTime ts)        { this.createdAt         = ts;                   }
    public void setUpdatedAt(LocalDateTime ts)        { this.updatedAt         = ts;                   }

    // ── Private helpers ───────────────────────────────────────────────────────

    /** Converts blank / whitespace-only strings to null for clean DB storage. */
    private static String blankToNull(String s) {
        return (s != null && !s.trim().isEmpty()) ? s.trim() : null;
    }

    /** Null-safe non-blank presence check. */
    private static boolean isPresent(String s) {
        return s != null && !s.trim().isEmpty();
    }

    @Override
    public String toString() {
        return "QuestionComment{commentId=" + commentId
                + ", questionId=" + questionId
                + ", vetterId=" + vetterId
                + ", vetterName='" + vetterName + "'}";
    }
}
