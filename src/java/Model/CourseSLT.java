/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Model;

/**
 *
 * @author User
 */

public class CourseSLT {
    private String topicName;
    private double l;
    private double t;
    private double p;
    private double o;
    private double nf2f;

    // Constructors
    public CourseSLT() {}
    public CourseSLT(String topicName, double l, double t, double p, double o, double nf2f) {
        this.topicName = topicName; this.l = l; this.t = t; this.p = p; this.o = o; this.nf2f = nf2f;
    }

    // Getters
    public String getTopicName() { return topicName; }
    public double getL() { return l; }
    public double getT() { return t; }
    public double getP() { return p; }
    public double getO() { return o; }
    public double getNf2f() { return nf2f; }
}