package util;

import javax.mail.*;
import javax.mail.internet.*;
import java.io.InputStream;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * EmailService — sends HTML notification emails via SMTP.
 *
 * Configuration is read from WEB-INF/mail.properties so SMTP credentials
 * can be changed without recompiling. Set mail.enabled=false to suppress
 * all sending during development.
 */
public class EmailService {

    private static final Logger LOG = Logger.getLogger(EmailService.class.getName());

    // Loaded once on first use
    private static Properties mailProps = null;
    private static boolean     enabled  = false;
    private static String      fromAddr = "";
    private static String      fromName = "";
    private static String      username = "";
    private static String      password = "";

    static {
        try (InputStream is = EmailService.class.getClassLoader()
                .getResourceAsStream("mail.properties")) {
            if (is != null) {
                Properties p = new Properties();
                p.load(is);

                enabled  = "true".equalsIgnoreCase(p.getProperty("mail.enabled", "false").trim());
                fromAddr = p.getProperty("mail.from.address", "").trim();
                fromName = p.getProperty("mail.from.name",    "E-Vetting UMT").trim();
                username = p.getProperty("mail.username",     "").trim();
                password = p.getProperty("mail.password",     "").trim();

                mailProps = new Properties();
                mailProps.put("mail.smtp.host",            p.getProperty("mail.smtp.host",            "smtp.gmail.com"));
                mailProps.put("mail.smtp.port",            p.getProperty("mail.smtp.port",            "587"));
                mailProps.put("mail.smtp.auth",            p.getProperty("mail.smtp.auth",            "true"));
                mailProps.put("mail.smtp.starttls.enable", p.getProperty("mail.smtp.starttls.enable", "true"));
                mailProps.put("mail.smtp.connectiontimeout", "8000");
                mailProps.put("mail.smtp.timeout",           "8000");

                LOG.info("EmailService initialised — enabled=" + enabled + " from=" + fromAddr);
            } else {
                LOG.warning("EmailService: mail.properties not found on classpath — email disabled.");
            }
        } catch (Exception e) {
            LOG.log(Level.WARNING, "EmailService init failed — email disabled.", e);
        }
    }

    // ── Public API ────────────────────────────────────────────────────────────

    /**
     * Sends a vetting verdict notification to a lecturer.
     *
     * @param toEmail     recipient email address
     * @param toName      recipient display name
     * @param courseCode  e.g. "STF3043"
     * @param courseTitle e.g. "Software Engineering"
     * @param session     e.g. "2024/2025"
     * @param semester    e.g. 1
     * @param verdict     APPROVED | NEEDS_IMPROVEMENT | REJECTED
     * @param remarks     vetter's overall remarks (may be null/empty)
     * @param feedbackUrl full URL to the LecturerReviewServlet page
     */
    public static void sendVerdictEmail(String toEmail, String toName,
                                        String courseCode, String courseTitle,
                                        String session,   int semester,
                                        String verdict,   String remarks,
                                        String feedbackUrl) {
        if (!enabled || toEmail == null || toEmail.trim().isEmpty()) return;

        String verdictLabel = "APPROVED".equals(verdict)          ? "Approved"
                            : "NEEDS_IMPROVEMENT".equals(verdict) ? "Needs Improvement — Revision Required"
                            : "REJECTED".equals(verdict)          ? "Rejected"
                            : verdict;
        String accentColor  = "APPROVED".equals(verdict) ? "#15803d"
                            : "NEEDS_IMPROVEMENT".equals(verdict) ? "#b45309"
                            : "#be123c";
        String icon         = "APPROVED".equals(verdict) ? "&#10003;"
                            : "NEEDS_IMPROVEMENT".equals(verdict) ? "&#9998;"
                            : "&#10007;";

        String subject = "[E-Vetting] " + verdictLabel + " — " + courseCode + " " + session + " Sem " + semester;

        String remarksBlock = (remarks != null && !remarks.trim().isEmpty())
            ? "<div style='margin-top:14px;padding:12px 16px;background:#f8f9fa;border-left:3px solid "
              + accentColor + ";border-radius:4px;font-size:13px;color:#374151;line-height:1.6'>"
              + "<strong>Vetter Remarks:</strong><br/>"
              + escHtml(remarks)
              + "</div>"
            : "";

        String actionBtn = "APPROVED".equals(verdict) ? "" :
            "<div style='text-align:center;margin-top:22px'>"
            + "<a href='" + feedbackUrl + "' "
            + "style='background:" + accentColor + ";color:#fff;padding:10px 24px;"
            + "border-radius:6px;text-decoration:none;font-weight:700;font-size:13px;display:inline-block'>"
            + "View Vetter Feedback &amp; Revise</a></div>";

        String approvedNote = "APPROVED".equals(verdict)
            ? "<p style='color:#15803d;font-weight:600;font-size:13px;margin-top:14px'>"
              + "Your paper has been approved. No further action is required at this stage.</p>"
            : "<p style='font-size:13px;color:#374151;margin-top:14px'>"
              + "Please log in to E-Vetting, view the vetter's detailed comments for each question, "
              + "make the necessary corrections, and resubmit your paper.</p>";

        String html = buildHtmlEmail(
            toName, icon, verdictLabel, accentColor,
            courseCode, courseTitle, session, semester,
            remarksBlock, approvedNote, actionBtn
        );

        sendAsync(toEmail, toName, subject, html);
    }

    /**
     * Sends a notification to KP / Admin when a paper verdict is issued.
     */
    public static void sendKpVerdictEmail(String toEmail, String toName,
                                          String lecturerName,
                                          String courseCode,  String courseTitle,
                                          String session,     int semester,
                                          String verdict,     String remarks,
                                          String reviewUrl) {
        if (!enabled || toEmail == null || toEmail.trim().isEmpty()) return;

        String verdictLabel = "APPROVED".equals(verdict)          ? "Approved"
                            : "NEEDS_IMPROVEMENT".equals(verdict) ? "Needs Improvement"
                            : "REJECTED".equals(verdict)          ? "Rejected"
                            : verdict;
        String accentColor  = "APPROVED".equals(verdict) ? "#15803d"
                            : "NEEDS_IMPROVEMENT".equals(verdict) ? "#b45309"
                            : "#be123c";

        String subject = "[E-Vetting KP] Paper " + verdictLabel + " — " + courseCode + " " + session + " Sem " + semester;

        String remarksBlock = (remarks != null && !remarks.trim().isEmpty())
            ? "<div style='margin-top:14px;padding:12px 16px;background:#f8f9fa;border-left:3px solid "
              + accentColor + ";border-radius:4px;font-size:13px;color:#374151;line-height:1.6'>"
              + "<strong>Vetter Remarks:</strong><br/>" + escHtml(remarks) + "</div>"
            : "";

        String html =
            "<div style='font-family:Segoe UI,Arial,sans-serif;max-width:580px;margin:0 auto'>"
            + "<div style='background:#0b1628;padding:18px 24px;border-radius:8px 8px 0 0'>"
            + "  <span style='color:#fff;font-size:16px;font-weight:700'>E-Vetting System — UMT</span>"
            + "  <span style='display:block;color:rgba(255,255,255,.45);font-size:11px;margin-top:2px'>KP / Admin Notification</span>"
            + "</div>"
            + "<div style='background:#fff;border:1px solid #e2e8f0;border-top:none;padding:24px;border-radius:0 0 8px 8px'>"
            + "<p style='font-size:13px;color:#374151'>Dear <strong>" + escHtml(toName) + "</strong>,</p>"
            + "<p style='font-size:13px;color:#374151;margin-top:8px'>"
            + "A vetting verdict has been submitted for the following paper:</p>"
            + "<table style='width:100%;border-collapse:collapse;margin-top:12px;font-size:13px'>"
            + "<tr><td style='padding:6px 10px;background:#f8fafc;font-weight:600;width:35%'>Lecturer</td>"
            + "    <td style='padding:6px 10px'>" + escHtml(lecturerName) + "</td></tr>"
            + "<tr><td style='padding:6px 10px;background:#f8fafc;font-weight:600'>Course</td>"
            + "    <td style='padding:6px 10px'>" + escHtml(courseCode) + " — " + escHtml(courseTitle) + "</td></tr>"
            + "<tr><td style='padding:6px 10px;background:#f8fafc;font-weight:600'>Session / Sem</td>"
            + "    <td style='padding:6px 10px'>" + escHtml(session) + " Sem " + semester + "</td></tr>"
            + "<tr><td style='padding:6px 10px;background:#f8fafc;font-weight:600'>Verdict</td>"
            + "    <td style='padding:6px 10px'><strong style='color:" + accentColor + "'>" + verdictLabel + "</strong></td></tr>"
            + "</table>"
            + remarksBlock
            + "<div style='text-align:center;margin-top:22px'>"
            + "<a href='" + reviewUrl + "' style='background:#185FA5;color:#fff;padding:10px 24px;"
            + "border-radius:6px;text-decoration:none;font-weight:700;font-size:13px;display:inline-block'>"
            + "View Full Review</a></div>"
            + "<p style='font-size:11px;color:#9ca3af;margin-top:24px;text-align:center'>"
            + "E-Vetting System &nbsp;·&nbsp; Universiti Malaysia Terengganu</p>"
            + "</div></div>";

        sendAsync(toEmail, toName, subject, html);
    }

    /**
     * Sends a submission notification to the assigned vetter when a lecturer
     * submits a package.
     */
    public static void sendSubmissionEmail(String toEmail, String toName,
                                           String lecturerName,
                                           String courseCode,  String courseTitle,
                                           String session,     int semester,
                                           String reviewUrl) {
        if (!enabled || toEmail == null || toEmail.trim().isEmpty()) return;

        String subject = "[E-Vetting] New Submission — " + courseCode + " " + session + " Sem " + semester;

        String html =
            "<div style='font-family:Segoe UI,Arial,sans-serif;max-width:580px;margin:0 auto'>"
            + "<div style='background:#0b1628;padding:18px 24px;border-radius:8px 8px 0 0'>"
            + "  <span style='color:#fff;font-size:16px;font-weight:700'>E-Vetting System — UMT</span>"
            + "  <span style='display:block;color:rgba(255,255,255,.45);font-size:11px;margin-top:2px'>Vetter Notification</span>"
            + "</div>"
            + "<div style='background:#fff;border:1px solid #e2e8f0;border-top:none;padding:24px;border-radius:0 0 8px 8px'>"
            + "<p style='font-size:13px;color:#374151'>Dear <strong>" + escHtml(toName) + "</strong>,</p>"
            + "<p style='font-size:13px;color:#374151;margin-top:8px'>"
            + "A new exam paper has been submitted and is awaiting your vetting review.</p>"
            + "<table style='width:100%;border-collapse:collapse;margin-top:12px;font-size:13px'>"
            + "<tr><td style='padding:6px 10px;background:#f8fafc;font-weight:600;width:35%'>Submitted by</td>"
            + "    <td style='padding:6px 10px'>" + escHtml(lecturerName) + "</td></tr>"
            + "<tr><td style='padding:6px 10px;background:#f8fafc;font-weight:600'>Course</td>"
            + "    <td style='padding:6px 10px'>" + escHtml(courseCode) + " — " + escHtml(courseTitle) + "</td></tr>"
            + "<tr><td style='padding:6px 10px;background:#f8fafc;font-weight:600'>Session / Sem</td>"
            + "    <td style='padding:6px 10px'>" + escHtml(session) + " Sem " + semester + "</td></tr>"
            + "</table>"
            + "<div style='text-align:center;margin-top:22px'>"
            + "<a href='" + reviewUrl + "' style='background:#185FA5;color:#fff;padding:10px 24px;"
            + "border-radius:6px;text-decoration:none;font-weight:700;font-size:13px;display:inline-block'>"
            + "Review Paper</a></div>"
            + "<p style='font-size:11px;color:#9ca3af;margin-top:24px;text-align:center'>"
            + "E-Vetting System &nbsp;·&nbsp; Universiti Malaysia Terengganu</p>"
            + "</div></div>";

        sendAsync(toEmail, toName, subject, html);
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private static String buildHtmlEmail(String toName, String icon,
                                         String verdictLabel, String accentColor,
                                         String courseCode, String courseTitle,
                                         String session, int semester,
                                         String remarksBlock, String approvedNote,
                                         String actionBtn) {
        return
            "<div style='font-family:Segoe UI,Arial,sans-serif;max-width:580px;margin:0 auto'>"
            + "<div style='background:#0b1628;padding:18px 24px;border-radius:8px 8px 0 0'>"
            + "  <span style='color:#fff;font-size:16px;font-weight:700'>E-Vetting System — UMT</span>"
            + "  <span style='display:block;color:rgba(255,255,255,.45);font-size:11px;margin-top:2px'>Vetting Verdict Notification</span>"
            + "</div>"
            + "<div style='background:#fff;border:1px solid #e2e8f0;border-top:none;padding:24px;border-radius:0 0 8px 8px'>"
            + "<p style='font-size:13px;color:#374151'>Dear <strong>" + escHtml(toName) + "</strong>,</p>"
            + "<p style='font-size:13px;color:#374151;margin-top:8px'>"
            + "The vetting review for your exam paper has been completed.</p>"
            // Verdict badge
            + "<div style='margin-top:16px;padding:14px 18px;background:" + accentColor + "18;"
            + "border:1px solid " + accentColor + "40;border-radius:8px;display:flex;align-items:center;gap:10px'>"
            + "  <span style='font-size:22px;color:" + accentColor + "'>" + icon + "</span>"
            + "  <div><div style='font-size:15px;font-weight:700;color:" + accentColor + "'>" + escHtml(verdictLabel) + "</div>"
            + "       <div style='font-size:12px;color:#6b7280;margin-top:2px'>" + escHtml(courseCode) + " — " + escHtml(courseTitle)
            + " &nbsp;|&nbsp; " + escHtml(session) + " Sem " + semester + "</div>"
            + "  </div>"
            + "</div>"
            + remarksBlock
            + approvedNote
            + actionBtn
            + "<p style='font-size:11px;color:#9ca3af;margin-top:24px;text-align:center'>"
            + "E-Vetting System &nbsp;·&nbsp; Universiti Malaysia Terengganu</p>"
            + "</div></div>";
    }

    /** Sends the email on a daemon thread so it never blocks the HTTP request. */
    private static void sendAsync(String toEmail, String toName,
                                   String subject, String htmlBody) {
        Thread t = new Thread(() -> {
            try {
                Session mailSession = Session.getInstance(mailProps, new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(username, password);
                    }
                });

                MimeMessage msg = new MimeMessage(mailSession);
                msg.setFrom(new InternetAddress(fromAddr, fromName, "UTF-8"));
                msg.setRecipient(Message.RecipientType.TO,
                        new InternetAddress(toEmail, toName, "UTF-8"));
                msg.setSubject(subject, "UTF-8");
                msg.setContent(htmlBody, "text/html; charset=UTF-8");
                Transport.send(msg);
                LOG.info("Email sent to " + toEmail + " — " + subject);
            } catch (Exception e) {
                LOG.log(Level.WARNING, "Email send failed to " + toEmail, e);
            }
        });
        t.setDaemon(true);
        t.start();
    }

    /** Minimal HTML escaping for user-supplied strings. */
    private static String escHtml(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");
    }
}
