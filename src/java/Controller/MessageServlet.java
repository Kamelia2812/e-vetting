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
 * MessageServlet — per-assessment discussion threads.
 *
 * GET  ?action=thread&amp;paperId=X        — HTML fragment: full message thread
 * GET  ?action=unread&amp;paperId=X        — JSON: {"count":N}
 * POST action=send,   paperId, body    — save message, return JSON {"ok":true}
 * POST action=markRead, paperId        — update last_read_at for this user+paper
 */
@WebServlet("/MessageServlet")
public class MessageServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(MessageServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendError(HttpServletResponse.SC_UNAUTHORIZED); return;
        }
        int    userId   = (int)    session.getAttribute("userId");
        String fullName = (String) session.getAttribute("fullName");
        String role     = (String) session.getAttribute("role");
        if (fullName == null) fullName = "User";
        if (role     == null) role     = "";

        String action  = req.getParameter("action");
        int    paperId = safeInt(req.getParameter("paperId"), 0);

        if ("unread".equals(action)) {
            serveUnread(res, userId, paperId);
        } else {
            // Default: load full thread and mark as read
            markRead(userId, paperId);
            serveThread(res, userId, fullName, role, paperId);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            res.sendError(HttpServletResponse.SC_UNAUTHORIZED); return;
        }
        int    userId   = (int)    session.getAttribute("userId");
        String fullName = (String) session.getAttribute("fullName");
        String role     = (String) session.getAttribute("role");
        if (fullName == null) fullName = "User";
        if (role     == null) role     = "";

        String action  = req.getParameter("action");
        int    paperId = safeInt(req.getParameter("paperId"), 0);

        res.setContentType("application/json;charset=UTF-8");
        PrintWriter out = res.getWriter();

        if ("send".equals(action)) {
            String body = req.getParameter("body");
            if (body == null || body.trim().isEmpty() || paperId <= 0) {
                out.print("{\"ok\":false,\"msg\":\"Missing body or paperId\"}"); return;
            }
            body = body.trim();
            try (Connection con = DBConnection.getConnection();
                 PreparedStatement ps = con.prepareStatement(
                     "INSERT INTO messages (paper_id, sender_id, sender_name, sender_role, body) "
                   + "VALUES (?,?,?,?,?)")) {
                ps.setInt(1, paperId);
                ps.setInt(2, userId);
                ps.setString(3, fullName);
                ps.setString(4, role);
                ps.setString(5, body);
                ps.executeUpdate();
                // Mark as read for sender
                markRead(userId, paperId);
                out.print("{\"ok\":true}");
            } catch (Exception e) {
                LOG.log(Level.WARNING, "send failed", e);
                out.print("{\"ok\":false,\"msg\":\"Database error\"}");
            }

        } else if ("markRead".equals(action)) {
            markRead(userId, paperId);
            out.print("{\"ok\":true}");
        } else {
            out.print("{\"ok\":false,\"msg\":\"Unknown action\"}");
        }
    }

    // ── Serve unread count JSON ───────────────────────────────────────────────

    private void serveUnread(HttpServletResponse res, int userId, int paperId) throws IOException {
        res.setContentType("application/json;charset=UTF-8");
        int count = unreadCount(userId, paperId);
        res.getWriter().print("{\"count\":" + count + "}");
    }

    private int unreadCount(int userId, int paperId) {
        if (paperId <= 0) return 0;
        String sql =
            "SELECT COUNT(*) FROM messages m "
          + "WHERE m.paper_id = ? AND m.sender_id <> ? "
          + "AND m.sent_at > COALESCE("
          + "  (SELECT last_read_at FROM message_reads WHERE user_id=? AND paper_id=?),"
          + "  '1970-01-01')";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId); ps.setInt(2, userId);
            ps.setInt(3, userId);  ps.setInt(4, paperId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (Exception e) {
            LOG.log(Level.WARNING, "unreadCount failed", e);
            return 0;
        }
    }

    // ── Mark read ────────────────────────────────────────────────────────────

    private void markRead(int userId, int paperId) {
        if (paperId <= 0) return;
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(
                 "INSERT INTO message_reads (user_id, paper_id, last_read_at) VALUES (?,?,NOW()) "
               + "ON DUPLICATE KEY UPDATE last_read_at=NOW()")) {
            ps.setInt(1, userId); ps.setInt(2, paperId);
            ps.executeUpdate();
        } catch (Exception e) {
            LOG.log(Level.WARNING, "markRead failed", e);
        }
    }

    // ── Serve thread HTML fragment ────────────────────────────────────────────

    private void serveThread(HttpServletResponse res,
                              int userId, String myName, String myRole,
                              int paperId) throws IOException {
        res.setContentType("text/html;charset=UTF-8");
        PrintWriter out = res.getWriter();

        if (paperId <= 0) {
            out.print("<div class='msg-empty'>No paper selected.</div>");
            return;
        }

        String sql =
            "SELECT message_id, sender_id, sender_name, sender_role, body, sent_at "
          + "FROM messages WHERE paper_id = ? ORDER BY sent_at ASC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, paperId);
            ResultSet rs = ps.executeQuery();

            StringBuilder sb = new StringBuilder();
            boolean any = false;

            while (rs.next()) {
                any = true;
                int       mid        = rs.getInt("message_id");
                int       senderId   = rs.getInt("sender_id");
                String    senderName = rs.getString("sender_name");
                String    senderRole = rs.getString("sender_role");
                String    body       = rs.getString("body");
                Timestamp ts         = rs.getTimestamp("sent_at");

                boolean isMine = (senderId == userId);
                String  initials = initials(senderName);
                String  timeStr  = ts != null ? timeAgo(ts.toLocalDateTime()) : "";
                String  roleDisp = friendlyRole(senderRole);

                sb.append("<div class='msg-row ").append(isMine ? "msg-mine" : "msg-theirs").append("'>");

                if (!isMine) {
                    sb.append("<div class='msg-avatar'>").append(escHtml(initials)).append("</div>");
                }

                sb.append("<div class='msg-bubble-wrap'>");
                if (!isMine) {
                    sb.append("<div class='msg-meta-top'>")
                      .append("<span class='msg-sender'>").append(escHtml(senderName)).append("</span>")
                      .append("<span class='msg-role-chip'>").append(escHtml(roleDisp)).append("</span>")
                      .append("</div>");
                }
                sb.append("<div class='msg-bubble'>").append(escHtml(body)).append("</div>");
                sb.append("<div class='msg-time'>").append(timeStr).append("</div>");
                sb.append("</div>");

                if (isMine) {
                    sb.append("<div class='msg-avatar msg-avatar-mine'>").append(escHtml(initials)).append("</div>");
                }

                sb.append("</div>");
            }

            if (!any) {
                sb.append("<div class='msg-empty'>No messages yet. Start the conversation below.</div>");
            }

            out.print(sb.toString());

        } catch (Exception e) {
            LOG.log(Level.WARNING, "serveThread failed paperId=" + paperId, e);
            out.print("<div class='msg-empty'>Could not load messages.</div>");
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private static String initials(String name) {
        if (name == null || name.trim().isEmpty()) return "?";
        String[] parts = name.trim().split("\\s+");
        int start = (parts.length > 1 && parts[0].endsWith(".")) ? 1 : 0;
        StringBuilder sb = new StringBuilder();
        for (int i = start; i < parts.length && sb.length() < 2; i++)
            sb.append(Character.toUpperCase(parts[i].charAt(0)));
        return sb.length() > 0 ? sb.toString() : "?";
    }

    private static String friendlyRole(String role) {
        if (role == null) return "";
        switch (role.toUpperCase()) {
            case "LECTURER": return "Lecturer";
            case "VETTER":   return "Vetter";
            case "KP":       return "KP";
            case "ADMIN":    return "Admin";
            default:         return role;
        }
    }

    private static String timeAgo(LocalDateTime created) {
        LocalDateTime now = LocalDateTime.now();
        long mins = ChronoUnit.MINUTES.between(created, now);
        if (mins < 1)  return "just now";
        if (mins < 60) return mins + "m ago";
        long hrs = ChronoUnit.HOURS.between(created, now);
        if (hrs < 24)  return hrs + "h ago";
        long days = ChronoUnit.DAYS.between(created, now);
        if (days < 7)  return days + "d ago";
        return new java.text.SimpleDateFormat("d MMM").format(
            java.sql.Timestamp.valueOf(created));
    }

    private static String escHtml(String s) {
        if (s == null) return "";
        return s.replace("&","&").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("\n","<br/>");
    }

    private int safeInt(String s, int def) {
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return def; }
    }
}
