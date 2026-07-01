package Controller;

import DAO.EventDAO;
import Model.Event;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.*;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

@WebServlet("/EventServlet")
public class EventServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("list".equals(action)) {
            try {
                int year = Integer.parseInt(req.getParameter("year"));
                int month = Integer.parseInt(req.getParameter("month"));
                EventDAO dao = new EventDAO();
                List<Event> events = dao.getEventsByMonth(year, month);
                
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                PrintWriter out = resp.getWriter();
                
                out.print("[");
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
                for (int i = 0; i < events.size(); i++) {
                    Event e = events.get(i);
                    out.print("{");
                    out.print("\"id\":" + e.getEventId() + ",");
                    out.print("\"title\":\"" + escapeJson(e.getTitle()) + "\",");
                    out.print("\"date\":\"" + sdf.format(e.getEventDate()) + "\",");
                    out.print("\"course\":\"" + escapeJson(e.getCourseName() == null ? "" : e.getCourseName()) + "\"");
                    out.print("}");
                    if (i < events.size() - 1) out.print(",");
                }
                out.print("]");
            } catch (Exception ex) {
                resp.setStatus(500);
                resp.getWriter().write("[]");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendError(403);
            return;
        }
        
        try {
            String act = req.getParameter("action");
            if ("delete".equals(act)) {
                int eventId = Integer.parseInt(req.getParameter("id"));
                EventDAO dao = new EventDAO();
                dao.deleteEvent(eventId);
                resp.sendRedirect(req.getContextPath() + "/calendar.jsp");
                return;
            }
            
            if ("update".equals(act)) {
                int eventId = Integer.parseInt(req.getParameter("id"));
                String title = req.getParameter("title");
                String dateStr = req.getParameter("date");
                String timeStr = req.getParameter("time");
                String course = req.getParameter("course");
                
                Date eventDate = parseDateTime(dateStr, timeStr);
                
                Event e = new Event();
                e.setEventId(eventId);
                e.setTitle(title);
                e.setEventDate(eventDate);
                e.setCourseName(course);
                e.setCreatedBy((Integer) session.getAttribute("userId"));
                
                EventDAO dao = new EventDAO();
                dao.updateEvent(e);
                
                resp.sendRedirect(req.getContextPath() + "/calendar.jsp");
                return;
            }
            
            String title = req.getParameter("title");
            String dateStr = req.getParameter("date");
            String timeStr = req.getParameter("time");
            String course = req.getParameter("course");
            
            Date eventDate = parseDateTime(dateStr, timeStr);
            
            Event e = new Event();
            e.setTitle(title);
            e.setEventDate(eventDate);
            e.setCourseName(course);
            e.setCreatedBy((Integer) session.getAttribute("userId"));
            
            EventDAO dao = new EventDAO();
            dao.addEvent(e);
            
            resp.sendRedirect(req.getContextPath() + "/calendar.jsp");
        } catch (Exception ex) {
            ex.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/calendar.jsp?error=1");
        }
    }
    
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
    
    private Date parseDateTime(String dateStr, String timeStr) throws Exception {
        Date eventDate = null;
        String dateTimeStr = dateStr + " " + (timeStr != null && !timeStr.isEmpty() ? timeStr : "00:00");
        
        String[] formats = {
            "yyyy-MM-dd HH:mm",
            "yyyy-MM-dd hh:mm a",
            "dd/MM/yyyy HH:mm",
            "dd/MM/yyyy hh:mm a",
            "yyyy-MM-dd",
            "dd/MM/yyyy"
        };
        
        for (String format : formats) {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat(format);
                eventDate = sdf.parse(dateTimeStr);
                break;
            } catch (Exception parseEx) {
                // Try next format
            }
        }
        if (eventDate == null) {
            throw new Exception("Unparseable date: " + dateTimeStr);
        }
        return eventDate;
    }
}
