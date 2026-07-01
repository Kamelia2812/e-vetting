package util;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import DAO.EventDAO;
import Model.Event;
import java.util.Date;
import java.util.Calendar;

public class InsertEvents {
    public static void main(String[] args) {
        try {
            int validUserId = -1;
            try (Connection conn = DBConnection.getConnection();
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery("SELECT user_id FROM users LIMIT 1")) {
                if (rs.next()) {
                    validUserId = rs.getInt("user_id");
                }
            }
            if (validUserId == -1) {
                System.out.println("No users found in database to associate events with.");
                return;
            }
            
            EventDAO dao = new EventDAO();
            
            // Event 1
            Event e1 = new Event();
            e1.setTitle("Continuous Assessment Due");
            Calendar c1 = Calendar.getInstance();
            c1.set(2026, 6, 15, 23, 59, 0);
            e1.setEventDate(c1.getTime());
            e1.setCourseName("BAHASA MANDARIN III");
            e1.setCreatedBy(validUserId);
            dao.addEvent(e1);
            
            // Event 2
            Event e2 = new Event();
            e2.setTitle("Final Exam Vetting Deadline");
            Calendar c2 = Calendar.getInstance();
            c2.set(2026, 6, 20, 12, 0, 0);
            e2.setEventDate(c2.getTime());
            e2.setCourseName("DATA STRUCTURES");
            e2.setCreatedBy(validUserId);
            dao.addEvent(e2);
            
            // Event 3
            Event e3 = new Event();
            e3.setTitle("JSS Submission Due");
            Calendar c3 = Calendar.getInstance();
            c3.set(2026, 6, 25, 17, 0, 0);
            e3.setEventDate(c3.getTime());
            e3.setCourseName("SOFTWARE ENGINEERING");
            e3.setCreatedBy(validUserId);
            dao.addEvent(e3);
            
            System.out.println("Events inserted successfully.");
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
