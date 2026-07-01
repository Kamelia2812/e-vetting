package Controller;

import util.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.time.*;
import java.time.temporal.ChronoUnit;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * NotificationServlet
 *
 * GET  ?action=list         — HTML fragment: recent notifications for current user
 * GET  ?action=count        — plain text: unread count
 * POST ?action=markRead&amp;id= — mark one notification read, returns "ok"
 * POST ?action=markAllRead  — mark all read for current user, returns "ok"
 */
@WebServlet("/NotificationServlet")
public class NotificationServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(NotificationServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendError(HttpServletResponse.SC_UNAUTHORIZED); return;
        }
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        if ("count".equals(action)) {
            serveCount(res, userId);
        } else {
            serveList(res, userId);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendError(HttpServletResponse.SC_UNAUTHORIZED); return;
        }
        int userId = (int) session.getAttribute("userId");
        String action = req.getParameter("action");

        res.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = res.getWriter();

        try (Connection con = DBConnection.getConnection()) {
            if ("markAllRead".equals(action)) {
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE notifications SET is_read=1 WHERE user_id=?")) {
                    ps.setInt(1, userId);
                    ps.executeUpdate();
                }
            } else if ("markRead".equals(action)) {
                int id = 0;
                try { id = Integer.parseInt(req.getParameter("id")); } catch (Exception ignored) {}
                if (id > 0) {
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE notifications SET is_read=1 WHERE notification_id=? AND user_id=?")) {
                        ps.setInt(1, id); ps.setInt(2, userId);
                        ps.executeUpdate();
                    }
                }
            }
            out.print("ok");
        } catch (Exception e) {
            LOG.log(Level.WARNING, "NotificationServlet POST failed", e);
            out.print("error");
        }
    }

    // ── Serve plain-text unread count ─────────────────────────────────────────
    private void serveCount(HttpServletResponse res, int userId) throws IOException {
        res.setContentType("text/plain;charset=UTF-8");
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=0")) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            res.getWriter().print(rs.next() ? rs.getInt(1) : 0);
        } catch (Exception e) {
            LOG.log(Level.WARNING, "serveCount failed", e);
            res.getWriter().print(0);
        }
    }

    // ── Serve HTML fragment of recent notifications ───────────────────────────
    private void serveList(HttpServletResponse res, int userId) throws IOException {
        res.setContentType("text/html;charset=UTF-8");
        PrintWriter out = res.getWriter();

        String sql =
            "SELECT notification_id, assessment_id, summary, is_read, created_at " +
            "FROM notifications WHERE user_id=? " +
            "ORDER BY created_at DESC LIMIT 15";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            boolean any = false;
            StringBuilder sb = new StringBuilder();

            while (rs.next()) {
                any = true;
                int     nid       = rs.getInt("notification_id");
                int     paperId   = rs.getInt("assessment_id");
                String  summary   = rs.getString("summary");
                boolean isRead    = rs.getInt("is_read") == 1;
                Timestamp ts      = rs.getTimestamp("created_at");
                String  timeAgo   = ts != null ? timeAgo(ts.toLocalDateTime()) : "";

                // Truncate long summaries
                String display = summary != null && summary.length() > 90
                    ? summary.substring(0, 87) + "…" : (summary != null ? summary : "");

                sb.append("<div class='notif-item").append(isRead ? " notif-read" : "").append("' ")
                  .append("onclick=\"markRead(").append(nid).append(",").append(paperId).append(")\">");
                // Use a coloured circle dot instead of emoji
                String dotColor = isRead ? "#cbd5e1" : "#185FA5";
                sb.append("<div class='notif-icon'>")
                  .append("<svg width='10' height='10' viewBox='0 0 10 10'>")
                  .append("<circle cx='5' cy='5' r='5' fill='").append(dotColor).append("'/>")
                  .append("</svg>")
                  .append("</div>");
                sb.append("<div class='notif-content'>");
                sb.append("<div class='notif-text'>").append(escHtml(display)).append("</div>");
                sb.append("<div class='notif-time'>").append(timeAgo).append("</div>");
                sb.append("</div>");
                sb.append("</div>");
            }

            if (!any) {
                sb.append("<div class='notif-empty'>No notifications yet.</div>");
            }

            out.print(sb.toString());

        } catch (Exception e) {
            LOG.log(Level.WARNING, "serveList failed userId=" + userId, e);
            out.print("<div class='notif-empty'>Could not load notifications.</div>");
        }
    }

    // ── "2 days 3 hours ago" ─────────────────────────────────────────────────
    private static String timeAgo(LocalDateTime created) {
        LocalDateTime now = LocalDateTime.now();
        long mins  = ChronoUnit.MINUTES.between(created, now);
        if (mins <  1)  return "Just now";
        if (mins < 60)  return mins + " minute" + (mins==1?"":"s") + " ago";
        long hrs = ChronoUnit.HOURS.between(created, now);
        if (hrs  < 24) return hrs  + " hour"   + (hrs==1?"":"s")  + " ago";
        long days = ChronoUnit.DAYS.between(created, now);
        if (days <  7) {
            long remHrs = hrs - days * 24;
            return days + " day" + (days==1?"":"s")
                + (remHrs > 0 ? " " + remHrs + " hour" + (remHrs==1?"":"s") : "")
                + " ago";
        }
        long weeks = days / 7;
        if (weeks < 4) return weeks + " week" + (weeks==1?"":"s") + " ago";
        long months = ChronoUnit.MONTHS.between(created, now);
        return months < 1 ? "1 month ago" : months + " month" + (months==1?"":"s") + " ago";
    }

    private static String escHtml(String s) {
        if (s == null) return "";
        return s.replace("&","&").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");
    }
}
