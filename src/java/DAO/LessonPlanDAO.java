/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import Model.LessonPlanWeek;
import util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author User
 */
public class LessonPlanDAO {
 // Pulls the 14 weeks from the database
    public List<LessonPlanWeek> getPlanByCourseId(int courseId) throws Exception {
        List<LessonPlanWeek> weeks = new ArrayList<>();
        String sql = "SELECT * FROM teaching_plan_weeks WHERE course_id = ? ORDER BY week_number ASC";
        
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, courseId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LessonPlanWeek week = new LessonPlanWeek();
                    week.setCourseId(rs.getInt("course_id"));
                    week.setWeekNumber(rs.getInt("week_number"));
                    
                    Date sDate = rs.getDate("start_date");
                    Date eDate = rs.getDate("end_date");
                    week.setStartDate(sDate != null ? sDate.toString() : "");
                    week.setEndDate(eDate != null ? eDate.toString() : "");
                    
                    week.setTopic(rs.getString("topic"));
                    week.setCloMapping(rs.getString("clo_mapping"));
                    week.setLearningActivities(rs.getString("learning_activities"));
                    week.setAssessmentType(rs.getString("assessment_type"));
                    week.setRemarks(rs.getString("remarks"));
                    weeks.add(week);
                }
            }
        }
        return weeks;
    }

    // Deletes the old plan and saves the newly typed 14 weeks
    public void saveTeachingPlan(int courseId, List<LessonPlanWeek> weeks) throws Exception {
        try (Connection con = DBConnection.getConnection()) {
            try (PreparedStatement delPs = con.prepareStatement("DELETE FROM teaching_plan_weeks WHERE course_id = ?")) {
                delPs.setInt(1, courseId);
                delPs.executeUpdate();
            }

            String insertSql = "INSERT INTO teaching_plan_weeks (course_id, week_number, start_date, end_date, topic, clo_mapping, learning_activities, assessment_type, remarks) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement insPs = con.prepareStatement(insertSql)) {
                for (LessonPlanWeek w : weeks) {
                    insPs.setInt(1, courseId);
                    insPs.setInt(2, w.getWeekNumber());
                    
                    if (w.getStartDate() == null || w.getStartDate().isEmpty()) insPs.setNull(3, Types.DATE);
                    else insPs.setDate(3, Date.valueOf(w.getStartDate()));
                    
                    if (w.getEndDate() == null || w.getEndDate().isEmpty()) insPs.setNull(4, Types.DATE);
                    else insPs.setDate(4, Date.valueOf(w.getEndDate()));

                    insPs.setString(5, w.getTopic());
                    insPs.setString(6, w.getCloMapping());
                    insPs.setString(7, w.getLearningActivities());
                    insPs.setString(8, w.getAssessmentType());
                    insPs.setString(9, w.getRemarks());
                    
                    insPs.addBatch();
                }
                insPs.executeBatch(); 
            }
        }
    }
}