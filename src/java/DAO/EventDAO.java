package DAO;

import Model.Event;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class EventDAO {

    public void addEvent(Event event) throws Exception {
        String sql = "INSERT INTO events (title, event_date, course_name, created_by) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, event.getTitle());
            ps.setTimestamp(2, new Timestamp(event.getEventDate().getTime()));
            ps.setString(3, event.getCourseName());
            ps.setInt(4, event.getCreatedBy());
            ps.executeUpdate();
        }
    }

    public List<Event> getEventsByMonth(int year, int month) throws Exception {
        List<Event> events = new ArrayList<>();
        String sql = "SELECT * FROM events WHERE YEAR(event_date) = ? AND MONTH(event_date) = ? ORDER BY event_date ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, year);
            ps.setInt(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Event e = new Event();
                    e.setEventId(rs.getInt("event_id"));
                    e.setTitle(rs.getString("title"));
                    e.setEventDate(rs.getTimestamp("event_date"));
                    e.setCourseName(rs.getString("course_name"));
                    e.setCreatedBy(rs.getInt("created_by"));
                    events.add(e);
                }
            }
        }
        return events;
    }

    public void deleteEvent(int eventId) throws Exception {
        String sql = "DELETE FROM events WHERE event_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            ps.executeUpdate();
        }
    }
}
