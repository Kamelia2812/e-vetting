package Model;

import java.util.ArrayList;
import java.util.List;

public class VetterCourseInfo {
    public int courseId;
    public String courseCode;
    public String courseName;
    public boolean isLeader;
    public String lecturerName;
    public int credit;
    public int examHour;
    public String core;
    public String coCategory;
    public String department;
    public String faculty;
    public String senateRef;
    
    public List<String> coVetters = new ArrayList<>();
}
