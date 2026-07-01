<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Model.Assessment, Controller.VettingFormServlet.VettingFormBean" %>
<%
    /* ── Guards ───────────────────────────────────────────────────────── */
    javax.servlet.http.HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp"); return;
    }
    String fullName    = (String)  sess.getAttribute("fullName");
    String currentRole = (String)  sess.getAttribute("role");

    Assessment paper   = (Assessment) request.getAttribute("paper");
    String formType    = (String) request.getAttribute("formType");   // FAP01a / FAP01b
    VettingFormBean form = (VettingFormBean) request.getAttribute("form");
    String action      = (String) request.getAttribute("action");
    boolean readOnly   = Boolean.TRUE.equals(request.getAttribute("readOnly"));
    boolean isFAP01a   = "FAP01a".equals(formType);

    // Convenience helper – returns form field value or "" if form is null
    String f_programme      = form != null ? form.s(form.programme) : "";
    String f_eqCode1 = form != null ? form.s(form.eqCode1) : "";
    String f_eqName1 = form != null ? form.s(form.eqName1) : "";
    String f_eqCode2 = form != null ? form.s(form.eqCode2) : "";
    String f_eqName2 = form != null ? form.s(form.eqName2) : "";
    String f_eqCode3 = form != null ? form.s(form.eqCode3) : "";
    String f_eqName3 = form != null ? form.s(form.eqName3) : "";
    String f_creditHours   = form != null ? form.s(form.creditHours) : "";
    String f_totalStudents = form != null ? form.s(form.totalStudents) : "";
    String f_numObj  = form != null ? form.s(form.numObjective) : "0";
    String f_numStr  = form != null ? form.s(form.numStructure) : "0";
    String f_numEss  = form != null ? form.s(form.numEssay) : "0";
    String f_toAns   = form != null ? form.s(form.totalToAnswer) : "0";
    String f_examDur = form != null ? form.s(form.examDuration) : "";
    String f_assessType = form != null ? form.s(form.assessmentTypeDesc) : "";
    String f_weightPct  = form != null ? form.s(form.weightagePercent) : "";
    String f_taskDur    = form != null ? form.s(form.taskDuration) : "";
    String f_cloData    = form != null ? form.s(form.cloData) : "";
    String f_secBData   = form != null ? form.s(form.sectionBData) : "";
    String f_secCData   = form != null ? form.s(form.sectionCData) : "";
    String f_remarks    = form != null ? form.s(form.overallRemarks) : "";
    String f_vetterName = form != null ? form.s(form.vetterName) : fullName != null ? fullName : "";
    String f_vetterDate = form != null ? form.s(form.vetterDate) : "";
    String f_lecSignName = form != null ? form.s(form.lecturerSignName) : (paper != null ? "" : "");
    String f_lecSignDate = form != null ? form.s(form.lecturerSignDate) : "";
    String f_headName   = form != null ? form.s(form.headVetterName) : "";
    String f_headDate   = form != null ? form.s(form.headVetterDate) : "";
    int f_isImproved    = form != null ? form.isImproved : 0;
    String f_improvJust = form != null ? form.s(form.improvementJustification) : "";
    String f_improvElab = form != null ? form.s(form.improvementElaboration) : "";

    boolean saved     = "true".equals(request.getParameter("saved"));
    boolean submitted = "true".equals(request.getParameter("submitted"));

    String formTitle_ms = isFAP01a
        ? "BORANG SEMAKAN SOALAN PEPERIKSAAN AKHIR"
        : "BORANG SEMAKAN SOALAN PENILAIAN AKHIR";
    String formTitle_en = isFAP01a
        ? "FINAL EXAMINATION VETTING FORM"
        : "FINAL ASSESSMENT VETTING FORM";
    String formCode = isFAP01a ? "UMT/B/FAP/01(a)" : "UMT/B/FAP/01(b)";

    // Paper info fallbacks
    String p_courseCode   = paper != null ? paper.getCourseCode()  : "";
    String p_courseTitle  = paper != null ? paper.getCourseTitle() : "";
    String p_faculty      = paper != null ? paper.getFaculty()     : "";
    String p_session      = paper != null ? paper.getAcademicSession() : "";
    String p_semester     = paper != null ? String.valueOf(paper.getSemester()) : "";
    String p_paperType    = paper != null ? paper.getPaperType()   : "";
    int    p_paperId      = paper != null ? paper.getPaperId()     : 0;
    int    formId         = form  != null ? form.formId            : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title><%= formCode %> — E-Vetting System</title>
<style>
  :root{
    --primary:#1e3a5f; --primary-light:#2563eb; --accent:#0891b2;
    --bg:#f0f4f8; --card:#fff; --border:#d1d5db; --muted:#6b7280;
    --red:#dc2626; --green:#16a34a; --yellow:#d97706;
  }
  *{box-sizing:border-box;margin:0;padding:0;}
  body{background:var(--bg);font-family:'Segoe UI',Arial,sans-serif;font-size:14px;color:#111;}
  /* ── Top nav ── */
  .topnav{background:var(--primary);color:#fff;display:flex;align-items:center;
          justify-content:space-between;padding:0 24px;height:56px;}
  .topnav a{color:#cbd5e1;text-decoration:none;font-size:13px;}
  .topnav a:hover{color:#fff;}
  .topnav .brand{font-size:17px;font-weight:700;color:#fff;}
  /* ── Page wrapper ── */
  .page{max-width:960px;margin:28px auto;padding:0 16px 60px;}
  /* ── Form header ── */
  .form-header{background:var(--primary);color:#fff;border-radius:10px 10px 0 0;
               padding:20px 28px;display:flex;align-items:center;gap:18px;}
  .form-header .logo-box{background:#fff;border-radius:6px;padding:6px 12px;
                         font-weight:900;color:var(--primary);font-size:18px;letter-spacing:1px;}
  .form-header .titles{flex:1;}
  .form-header .titles h2{font-size:15px;font-weight:700;letter-spacing:.5px;}
  .form-header .titles p{font-size:12px;opacity:.8;margin-top:2px;}
  .form-header .code-badge{background:rgba(255,255,255,.15);padding:4px 10px;
                           border-radius:6px;font-size:12px;font-weight:600;}
  /* ── Alert ── */
  .alert{padding:12px 18px;border-radius:8px;margin-bottom:16px;font-size:13px;}
  .alert-success{background:#dcfce7;color:#166534;border:1px solid #86efac;}
  .alert-info   {background:#dbeafe;color:#1e40af;border:1px solid #93c5fd;}
  /* ── Section card ── */
  .section-card{background:var(--card);border:1px solid var(--border);
                border-radius:0 0 10px 10px;margin-top:1px;padding:0;}
  .section-head{background:#1e3a5f;color:#fff;padding:10px 20px;
                font-size:13px;font-weight:600;border-top:2px solid #2563eb;}
  .section-head.alt{background:#0f4c81;}
  .section-body{padding:20px;}
  /* ── Form grid ── */
  .fg{display:grid;gap:14px;}
  .fg2{grid-template-columns:1fr 1fr;}
  .fg3{grid-template-columns:1fr 1fr 1fr;}
  .fgroup{display:flex;flex-direction:column;gap:4px;}
  .fgroup label{font-size:12px;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;}
  .fgroup label span{font-style:italic;font-weight:400;text-transform:none;}
  .fgroup input,.fgroup select,.fgroup textarea{
    width:100%;padding:8px 10px;border:1px solid var(--border);border-radius:6px;
    font-size:13px;background:#fff;transition:border-color .2s;}
  .fgroup input:focus,.fgroup select:focus,.fgroup textarea:focus{
    outline:none;border-color:var(--primary-light);}
  .fgroup input[readonly],.fgroup textarea[readonly]{background:#f9fafb;color:var(--muted);}
  /* ── Eq-course rows ── */
  .eq-row{display:grid;grid-template-columns:160px 1fr;gap:10px;align-items:end;}
  /* ── CLO table ── */
  .clo-table{width:100%;border-collapse:collapse;font-size:13px;}
  .clo-table th{background:#1e3a5f;color:#fff;padding:8px 10px;text-align:left;font-size:12px;}
  .clo-table td{padding:6px 8px;border:1px solid var(--border);}
  .clo-table input,.clo-table select{width:100%;border:none;background:transparent;
    font-size:13px;padding:2px 4px;}
  .clo-table input:focus,.clo-table select:focus{outline:1px solid var(--primary-light);}
  /* ── Checklist table ── */
  .chk-table{width:100%;border-collapse:collapse;font-size:13px;}
  .chk-table th{background:#0f4c81;color:#fff;padding:8px 10px;font-size:12px;text-align:left;}
  .chk-table td{padding:8px 10px;border:1px solid var(--border);vertical-align:top;}
  .chk-table tr:nth-child(even) td{background:#f8fafc;}
  .chk-table .num{width:42px;text-align:center;font-weight:700;}
  .chk-table .yn{width:110px;}
  .chk-table .notes{width:200px;}
  .chk-table select{width:100%;padding:4px 6px;border:1px solid var(--border);border-radius:4px;font-size:12px;}
  .chk-table textarea{width:100%;border:1px solid var(--border);border-radius:4px;
                       font-size:12px;padding:4px;resize:vertical;min-height:36px;}
  /* ── Signature grid ── */
  .sig-grid{display:grid;grid-template-columns:1fr 1fr 1fr;gap:16px;}
  .sig-box{border:1px solid var(--border);border-radius:8px;padding:14px;background:#fafafa;}
  .sig-box h4{font-size:12px;font-weight:700;color:var(--primary);margin-bottom:10px;
              padding-bottom:6px;border-bottom:1px solid var(--border);}
  /* ── Improvement radio ── */
  .improv-row{display:flex;gap:24px;align-items:center;margin-bottom:10px;}
  .improv-row label{display:flex;align-items:center;gap:6px;cursor:pointer;font-size:13px;}
  /* ── Buttons ── */
  .btn-row{display:flex;gap:12px;justify-content:flex-end;padding:16px 20px;
           background:#f8fafc;border-top:1px solid var(--border);}
  .btn{padding:9px 22px;border-radius:7px;font-size:13px;font-weight:600;cursor:pointer;border:none;}
  .btn-primary{background:var(--primary-light);color:#fff;}
  .btn-primary:hover{background:#1d4ed8;}
  .btn-success{background:var(--green);color:#fff;}
  .btn-success:hover{background:#15803d;}
  .btn-secondary{background:#e5e7eb;color:#374151;}
  .btn-secondary:hover{background:#d1d5db;}
  /* ── Read-only banner ── */
  .ro-banner{background:#fef3c7;color:#92400e;padding:10px 18px;border-radius:8px;
             font-size:13px;margin-bottom:14px;border:1px solid #fcd34d;}
  @media(max-width:700px){.fg2,.fg3,.sig-grid{grid-template-columns:1fr;}}
</style>
</head>
<body>

<!-- ── Top navigation ─────────────────────────────────────── -->
<nav class="topnav">
  <span class="brand">E-Vetting System</span>
  <div style="display:flex;gap:20px;align-items:center;">
    <a href="<%= request.getContextPath() %>/VetterDashboardServlet">← Dashboard</a>
    <span style="color:#94a3b8;">|</span>
    <span style="color:#e2e8f0;font-size:13px;"><%= fullName != null ? fullName : "" %></span>
  </div>
</nav>

<div class="page">

  <!-- ── Form header ───────────────────────────────────────── -->
  <div class="form-header">
    <div class="logo-box">UMT</div>
    <div class="titles">
      <h2><%= formTitle_ms %></h2>
      <p><%= formTitle_en %> &nbsp;|&nbsp; Universiti Malaysia Terengganu</p>
    </div>
    <div class="code-badge"><%= formCode %> (Pind.1/2023)</div>
  </div>

  <!-- ── Alerts ────────────────────────────────────────────── -->
  <% if (saved) { %>
  <div class="alert alert-success" style="margin-top:12px;">Form saved as draft successfully.</div>
  <% } else if (submitted) { %>
  <div class="alert alert-success" style="margin-top:12px;">Form submitted successfully.</div>
  <% } %>
  <% if (readOnly) { %>
  <div class="ro-banner" style="margin-top:12px;">This form is in read-only view.</div>
  <% } %>

  <!-- ── Instruction notice ────────────────────────────────── -->
  <div class="alert alert-info" style="margin-top:12px;">
    <strong>ARAHAN / INSTRUCTION:</strong>
    Borang ini hendaklah dihantar bersama Borang Jadual Spesifikasi Soalan (JSS) (UMT/B/FAP/02).<br/>
    Table For Question Specification (JSS) (UMT/B/FAP/02) must be submitted with this form.
  </div>

  <!-- ── Main form ─────────────────────────────────────────── -->
  <form id="fap01Form" method="post" action="<%= request.getContextPath() %>/VettingFormServlet">
    <input type="hidden" name="paperId"  value="<%= p_paperId %>"/>
    <input type="hidden" name="formId"   value="<%= formId %>"/>
    <input type="hidden" name="formType" value="<%= formType %>"/>
    <!-- JSON data fields (populated by JS before submit) -->
    <input type="hidden" name="clo_data"      id="clo_data_hidden"/>
    <input type="hidden" name="section_b_data" id="section_b_hidden"/>
    <input type="hidden" name="section_c_data" id="section_c_hidden"/>

    <div class="section-card">

      <!-- ══════════════════════════════════════════════════════
           BAHAGIAN A: MAKLUMAT KURSUS
           Section A: Course Information (filled by lecturer)
           ════════════════════════════════════════════════════ -->
      <div class="section-head">
        BAHAGIAN A: MAKLUMAT KURSUS &nbsp;|&nbsp;
        <span style="font-weight:400;font-style:italic;">Section A: Course Information</span>
        <span style="float:right;font-weight:400;font-size:11px;">(Diisi oleh Pensyarah / Filled by Lecturer)</span>
      </div>
      <div class="section-body">
        <div class="fg fg2" style="margin-bottom:14px;">
          <div class="fgroup">
            <label>Fakulti / <span>Faculty</span></label>
            <input type="text" name="faculty_display" value="<%= p_faculty %>" readonly/>
          </div>
          <div class="fgroup">
            <label>Program Akademik / <span>Academic Programme</span></label>
            <input type="text" name="programme" value="<%= f_programme %>" <%= readOnly?"readonly":"" %>/>
          </div>
        </div>

        <!-- Main course -->
        <div class="fg fg2" style="margin-bottom:10px;">
          <div class="fgroup">
            <label>Kod Kursus / <span>Course Code</span></label>
            <input type="text" name="course_code_display" value="<%= p_courseCode %>" readonly/>
          </div>
          <div class="fgroup">
            <label>Nama Kursus / <span>Course Name</span></label>
            <input type="text" name="course_title_display" value="<%= p_courseTitle %>" readonly/>
          </div>
        </div>

        <!-- Equivalent courses -->
        <div style="margin-bottom:6px;font-size:12px;font-weight:600;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;">
          Kursus Setara / <span style="font-style:italic;font-weight:400;text-transform:none;">Equivalent Courses</span>
        </div>
        <div style="display:flex;flex-direction:column;gap:8px;margin-bottom:14px;">
          <div class="eq-row">
            <input type="text" name="eq_code1" placeholder="Kod Setara 1" value="<%= f_eqCode1 %>" <%= readOnly?"readonly":"" %>/>
            <input type="text" name="eq_name1" placeholder="Nama Kursus Setara 1" value="<%= f_eqName1 %>" <%= readOnly?"readonly":"" %>/>
          </div>
          <div class="eq-row">
            <input type="text" name="eq_code2" placeholder="Kod Setara 2" value="<%= f_eqCode2 %>" <%= readOnly?"readonly":"" %>/>
            <input type="text" name="eq_name2" placeholder="Nama Kursus Setara 2" value="<%= f_eqName2 %>" <%= readOnly?"readonly":"" %>/>
          </div>
          <div class="eq-row">
            <input type="text" name="eq_code3" placeholder="Kod Setara 3" value="<%= f_eqCode3 %>" <%= readOnly?"readonly":"" %>/>
            <input type="text" name="eq_name3" placeholder="Nama Kursus Setara 3" value="<%= f_eqName3 %>" <%= readOnly?"readonly":"" %>/>
          </div>
        </div>

        <div class="fg fg3" style="margin-bottom:14px;">
          <div class="fgroup">
            <label>Semester</label>
            <input type="text" name="semester_display" value="<%= p_semester %>" readonly/>
          </div>
          <div class="fgroup">
            <label>Sesi / <span>Session</span></label>
            <input type="text" name="session_display" value="<%= p_session %>" readonly/>
          </div>
          <div class="fgroup">
            <label>Jam Kredit / <span>Credit Hours</span></label>
            <input type="number" name="credit_hours" step="0.5" min="0" max="6"
                   value="<%= f_creditHours %>" <%= readOnly?"readonly":"" %>/>
          </div>
        </div>

        <div class="fg fg2" style="margin-bottom:14px;">
          <div class="fgroup">
            <label>Nama Pensyarah / <span>Lecturer's Name</span></label>
            <input type="text" name="lecturer_name_display" value="" readonly
                   placeholder="(pulled from system)"/>
          </div>
          <div class="fgroup">
            <label>Jumlah Pelajar / <span>Total Students</span></label>
            <input type="number" name="total_students" min="0"
                   value="<%= f_totalStudents %>" <%= readOnly?"readonly":"" %>/>
          </div>
        </div>

        <!-- FAP01a: Question counts + duration -->
        <% if (isFAP01a) { %>
        <div style="overflow-x:auto;margin-bottom:4px;">
          <table class="chk-table" style="min-width:600px;">
            <thead>
              <tr>
                <th>Bilangan Soalan / <em>Number of Questions</em></th>
                <th style="width:130px;">Bentuk Soalan / <em>Type</em></th>
                <th style="width:110px;">Jumlah / <em>Total</em></th>
                <th style="width:140px;">Perlu Dijawab / <em>Must Answer</em></th>
                <th style="width:150px;">Tempoh (Jam) / <em>Duration (Hrs)</em></th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>—</td>
                <td>Objektif / <em>Objective</em></td>
                <td><input type="number" name="num_objective" min="0" value="<%= f_numObj %>" <%= readOnly?"readonly":"" %>/></td>
                <td rowspan="3"><input type="number" name="total_to_answer" min="0" value="<%= f_toAns %>" <%= readOnly?"readonly":"" %>/></td>
                <td rowspan="3"><input type="text" name="exam_duration" value="<%= f_examDur %>" placeholder="e.g. 2" <%= readOnly?"readonly":"" %>/></td>
              </tr>
              <tr>
                <td>—</td>
                <td>Struktur / <em>Structure</em></td>
                <td><input type="number" name="num_structure" min="0" value="<%= f_numStr %>" <%= readOnly?"readonly":"" %>/></td>
              </tr>
              <tr>
                <td>—</td>
                <td>Esei / <em>Essay</em></td>
                <td><input type="number" name="num_essay" min="0" value="<%= f_numEss %>" <%= readOnly?"readonly":"" %>/></td>
              </tr>
            </tbody>
          </table>
        </div>
        <% } else { %>
        <!-- FAP01b: Assessment type + weightage + duration -->
        <div class="fg fg3" style="margin-bottom:4px;">
          <div class="fgroup" style="grid-column:span 1;">
            <label>Bentuk Penilaian / <span>Type of Assessment</span></label>
            <input type="text" name="assessment_type_desc" value="<%= f_assessType %>"
                   placeholder="e.g. Final Presentation, Final Report" <%= readOnly?"readonly":"" %>/>
          </div>
          <div class="fgroup">
            <label>Wajaran (%) / <span>Weightage</span></label>
            <input type="number" name="weightage_percent" step="0.1" min="0" max="100"
                   value="<%= f_weightPct %>" <%= readOnly?"readonly":"" %>/>
          </div>
          <div class="fgroup">
            <label>Tempoh Tugasan / <span>Task Duration</span></label>
            <input type="text" name="task_duration" value="<%= f_taskDur %>"
                   placeholder="e.g. 2 weeks" <%= readOnly?"readonly":"" %>/>
          </div>
        </div>
        <% } %>

        <!-- CLO table -->
        <div style="margin-top:18px;">
          <div style="font-size:12px;font-weight:600;color:var(--muted);text-transform:uppercase;
                      letter-spacing:.4px;margin-bottom:8px;">
            CLO — Penyataan Hasil Pembelajaran / <span style="font-style:italic;font-weight:400;text-transform:none;">Course Learning Outcome</span>
          </div>
          <table class="clo-table" id="cloTable">
            <thead>
              <tr>
                <th style="width:60px;">CLO</th>
                <th>Penyataan / <em>Statement</em></th>
                <th style="width:120px;">Aras Taksonomi / <em>Taxonomy</em></th>
                <th style="width:100px;"><%= isFAP01a ? "% Peperiksaan" : "% Penilaian" %></th>
              </tr>
            </thead>
            <tbody id="cloBody">
              <!-- Rows injected by JS -->
            </tbody>
          </table>
        </div>
      </div><!-- /section-body A -->

      <!-- ══════════════════════════════════════════════════════
           BAHAGIAN B: FAP01(a) — Format Checklist
                       FAP01(b) — Vetting Checklist (only)
           ════════════════════════════════════════════════════ -->
      <div class="section-head alt">
        <% if (isFAP01a) { %>
        BAHAGIAN B: SENARAI SEMAK FORMAT KERTAS SOALAN &nbsp;|&nbsp;
        <span style="font-weight:400;font-style:italic;">Section B: Question Paper Format Checklist</span>
        <% } else { %>
        BAHAGIAN B: SEMAKAN KESESUAIAN SOALAN &nbsp;|&nbsp;
        <span style="font-weight:400;font-style:italic;">Section B: Vetting Question Suitability</span>
        <% } %>
        <span style="float:right;font-weight:400;font-size:11px;">(Diisi oleh Panel Penyemak / Filled by Vetting Panel)</span>
      </div>
      <div class="section-body">
        <table class="chk-table" id="sectionBTable">
          <thead>
            <tr>
              <th class="num">Bil.</th>
              <th>Perkara / <em>Item</em></th>
              <th class="yn">Ya/Tidak / <em>Yes/No</em></th>
              <th class="notes">Catatan / <em>Notes</em></th>
            </tr>
          </thead>
          <tbody id="sectionBBody">
            <!-- Injected by JS -->
          </tbody>
        </table>
      </div>

      <!-- ══════════════════════════════════════════════════════
           FAP01(a) only — BAHAGIAN C: SEMAKAN KESESUAIAN SOALAN
           ════════════════════════════════════════════════════ -->
      <% if (isFAP01a) { %>
      <div class="section-head alt">
        BAHAGIAN C: SEMAKAN KESESUAIAN SOALAN &nbsp;|&nbsp;
        <span style="font-weight:400;font-style:italic;">Section C: Vetting Question Suitability</span>
        <span style="float:right;font-weight:400;font-size:11px;">(Diisi oleh Panel Penyemak / Filled by Vetting Panel)</span>
      </div>
      <div class="section-body">
        <table class="chk-table" id="sectionCTable">
          <thead>
            <tr>
              <th class="num">Bil.</th>
              <th>Perkara / <em>Item</em></th>
              <th class="yn">Perlu Penambahbaikan / <em>Needs Improvement</em></th>
              <th class="notes">Catatan/Ulasan / <em>Notes/Review</em></th>
            </tr>
          </thead>
          <tbody id="sectionCBody">
            <!-- Injected by JS -->
          </tbody>
        </table>
      </div>
      <% } %>

      <!-- ══════════════════════════════════════════════════════
           BAHAGIAN D (a) / C (b): PENGESAHAN PANEL PENYEMAK
           ════════════════════════════════════════════════════ -->
      <div class="section-head">
        <%= isFAP01a ? "BAHAGIAN D" : "BAHAGIAN C" %>: PENGESAHAN PANEL PENYEMAK SOALAN &nbsp;|&nbsp;
        <span style="font-weight:400;font-style:italic;">Section <%= isFAP01a ? "D" : "C" %>: Verification by Vetting Panel</span>
      </div>
      <div class="section-body">

        <!-- Overall remarks -->
        <div class="fgroup" style="margin-bottom:18px;">
          <label>Ulasan Keseluruhan / <span>Overall Remarks</span></label>
          <textarea name="overall_remarks" rows="4" <%= readOnly?"readonly":"" %>><%= f_remarks %></textarea>
        </div>

        <!-- Improvement status -->
        <div style="border:1px solid var(--border);border-radius:8px;padding:14px;margin-bottom:18px;background:#fafafa;">
          <div style="font-size:12px;font-weight:700;color:var(--primary);margin-bottom:10px;">
            Status Penambahbaikan / <em>Improvement Status</em>
          </div>
          <div class="improv-row">
            <label>
              <input type="radio" name="is_improved" value="1" <%= f_isImproved==1?"checked":"" %> <%= readOnly?"disabled":"" %>/>
              Telah Ditambahbaik / <em>Improved</em>
            </label>
            <label>
              <input type="radio" name="is_improved" value="0" <%= f_isImproved==0?"checked":"" %> <%= readOnly?"disabled":"" %>/>
              Tidak Ditambahbaik dengan Justifikasi / <em>No Improvement with Justification</em>
            </label>
          </div>
          <div class="fg fg2">
            <div class="fgroup">
              <label>Justifikasi (Wajib) / <span>Justification (Compulsory)</span></label>
              <textarea name="improvement_justification" rows="3" <%= readOnly?"readonly":"" %>><%= f_improvJust %></textarea>
            </div>
            <div class="fgroup">
              <label>Huraian (Jika Ada) / <span>Elaboration (If Any)</span></label>
              <textarea name="improvement_elaboration" rows="3" <%= readOnly?"readonly":"" %>><%= f_improvElab %></textarea>
            </div>
          </div>
        </div>

        <!-- Three-party signatures -->
        <div class="sig-grid">
          <!-- Vetter signature -->
          <div class="sig-box">
            <h4>Penyemak (Vetter) / <em>Name &amp; Stamp</em></h4>
            <div class="fgroup" style="margin-bottom:10px;">
              <label>Nama / Name</label>
              <input type="text" name="vetter_name" value="<%= f_vetterName %>" <%= readOnly?"readonly":"" %>/>
            </div>
            <div class="fgroup">
              <label>Tarikh / Date</label>
              <input type="date" name="vetter_date" value="<%= f_vetterDate %>" <%= readOnly?"readonly":"" %>/>
            </div>
          </div>

          <!-- Lecturer signature (after improvements) -->
          <div class="sig-box">
            <h4>Pensyarah Kursus (Selepas Penambahbaikan) / <em>Course Lecturer (After Improvement)</em></h4>
            <div class="fgroup" style="margin-bottom:10px;">
              <label>Nama / Name</label>
              <input type="text" name="lecturer_sign_name" value="<%= f_lecSignName %>" <%= readOnly?"readonly":"" %>/>
            </div>
            <div class="fgroup">
              <label>Tarikh / Date</label>
              <input type="date" name="lecturer_sign_date" value="<%= f_lecSignDate %>" <%= readOnly?"readonly":"" %>/>
            </div>
          </div>

          <!-- Head of vetting panel re-verification -->
          <div class="sig-box">
            <h4>Ketua Panel Penyemak / <em>Head of Vetting Panel (Re-validation)</em></h4>
            <div style="font-size:11px;color:var(--muted);margin-bottom:8px;font-style:italic;">
              Nota: Ketua Panel mestilah salah seorang daripada Vetters.<br/>
              Note: Head must be one of the Vetters.
            </div>
            <div class="fgroup" style="margin-bottom:10px;">
              <label>Nama / Name</label>
              <input type="text" name="head_vetter_name" value="<%= f_headName %>" <%= readOnly?"readonly":"" %>/>
            </div>
            <div class="fgroup">
              <label>Tarikh / Date</label>
              <input type="date" name="head_vetter_date" value="<%= f_headDate %>" <%= readOnly?"readonly":"" %>/>
            </div>
          </div>
        </div><!-- /sig-grid -->
      </div><!-- /section-body D/C -->

      <!-- ── Action buttons ──────────────────────────────────── -->
      <% if (!readOnly) { %>
      <div class="btn-row">
        <a href="<%= request.getContextPath() %>/VetterDashboardServlet" class="btn btn-secondary">Cancel</a>
        <button type="submit" name="action" value="saveDraft" class="btn btn-primary" onclick="prepareJSON()">
          Save Draft
        </button>
        <button type="submit" name="action" value="submit" class="btn btn-success"
                onclick="return prepareJSON() && confirm('Submit this vetting form? This will be final.')">
          Submit Form
        </button>
      </div>
      <% } else { %>
      <div class="btn-row">
        <a href="<%= request.getContextPath() %>/VetterDashboardServlet" class="btn btn-secondary">← Back to Dashboard</a>
        <a href="<%= request.getContextPath() %>/VettingFormServlet?action=edit&formId=<%= formId %>"
           class="btn btn-primary">Edit Form</a>
      </div>
      <% } %>

    </div><!-- /section-card -->
  </form>
</div><!-- /page -->

<script>
/* ══════════════════════════════════════════════════════════════
   Configuration: checklist items per form type
   ══════════════════════════════════════════════════════════════ */
var IS_FAP01A = <%= isFAP01a ? "true" : "false" %>;
var READ_ONLY = <%= readOnly ? "true" : "false" %>;

// ── CLO rows ────────────────────────────────────────────────
var DEFAULT_CLO_ROWS = 5;
var CLO_TAXONOMY = ['C1','C2','C3','C4','C5','C6','A1','A2','A3','A4','A5','P1','P2','P3','P4','P5'];
var savedCloData = <%= f_cloData.isEmpty() ? "null" : f_cloData %>;

function buildCloTable() {
  var tbody = document.getElementById('cloBody');
  tbody.innerHTML = '';
  var rows = savedCloData || defaultCloRows();
  rows.forEach(function(row, i) {
    var tr = document.createElement('tr');
    tr.innerHTML =
      '<td style="text-align:center;"><input style="width:100%;text-align:center;" type="text" '
      + 'name="clo_id_'+i+'" value="'+(row.clo||('CLO'+(i+1)))+'" '+(READ_ONLY?'readonly':'')+'/></td>'
      + '<td><input type="text" name="clo_stmt_'+i+'" value="'+esc(row.statement||'')+'" '+(READ_ONLY?'readonly':'')+'/></td>'
      + '<td><select name="clo_tax_'+i+'" '+(READ_ONLY?'disabled':'')+'>'
      + CLO_TAXONOMY.map(function(t){return '<option'+(t===(row.taxonomy||'C1')?' selected':'')+'>'+t+'</option>';}).join('')
      + '</select></td>'
      + '<td><input type="number" step="0.1" min="0" max="100" name="clo_pct_'+i+'" value="'+(row.percentage||'')+'" '+(READ_ONLY?'readonly':'')+'/></td>';
    tbody.appendChild(tr);
  });
}
function defaultCloRows() {
  var out = [];
  for (var i=0;i<DEFAULT_CLO_ROWS;i++) out.push({clo:'CLO'+(i+1),statement:'',taxonomy:'C1',percentage:''});
  return out;
}
function collectCloData() {
  var rows = [];
  var n = document.querySelectorAll('[name^="clo_id_"]').length;
  for (var i=0;i<n;i++) {
    rows.push({
      clo:       (document.querySelector('[name="clo_id_'+i+'"]')||{}).value||'',
      statement: (document.querySelector('[name="clo_stmt_'+i+'"]')||{}).value||'',
      taxonomy:  (document.querySelector('[name="clo_tax_'+i+'"]')||{}).value||'',
      percentage:(document.querySelector('[name="clo_pct_'+i+'"]')||{}).value||''
    });
  }
  return rows;
}

// ── Section B checklist items ────────────────────────────────
var FAP01A_SECTION_B = [
  {id:'b1i',   label:'Format Muka Hadapan — Logo UMT\nFront Page Format — UMT Logo'},
  {id:'b1ii',  label:'Semester dan Sesi Pengajian\nSemester and Study Session'},
  {id:'b1iii', label:'Nama Kursus\nCourse Name'},
  {id:'b1iv',  label:'Kod Kursus\nCourse Code'},
  {id:'b1v',   label:'Tempoh Peperiksaan\nDuration of Examination'},
  {id:'b1vi',  label:'Maklumat Calon\nCandidate Information'},
  {id:'b1vii', label:'Arahan Kepada Calon\nInstruction to Candidate'},
  {id:'b1viii',label:'Header CONFIDENTIAL/SULIT pada atas kiri dan bawah kanan\nCONFIDENTIAL/SULIT header on top-left and bottom-right'},
  {id:'b1ix',  label:'Format Penulisan Dwibahasa\nTwo-Language Writing Format'},
  {id:'b1x',   label:'Format penulisan soalan (jenis/saiz tulisan, jarak dll)\nQuestion writing format (font type/size, spacing, etc)'},
  {id:'b2i',   label:'[Muka Surat 2+] Header kod kursus + SULIT sehingga muka akhir\n[Page 2+] Course code header + SULIT until last page'},
  {id:'b2ii',  label:'[Muka Surat 2+] Bilangan muka surat pada setiap helai\n[Page 2+] Page numbers on every page'},
  {id:'b2iii', label:'"Kertas Soalan Tamat" / "End of Question Paper" pada muka surat terakhir\n"End of Question Paper" on last page'},
  {id:'b2iv',  label:'Tiada ralat menaip\nNo typing errors'},
  {id:'b2v',   label:'Setiap lampiran (jika ada) dirujuk sewajarnya\nEach appendix (if any) is referenced accordingly'},
  {id:'b3i',   label:'[Skema Jawapan] Memberikan jawapan penuh kepada setiap soalan\n[Answer Scheme] Complete answers to each question'},
  {id:'b3ii',  label:'[Skema Jawapan] Menunjukkan pembahagian markah\n[Answer Scheme] Shows marking distribution'}
];

var FAP01B_SECTION_B = [
  {id:'b1', label:'Arahan tugasan adalah jelas\nTask instructions are clear'},
  {id:'b2', label:'Aras kesukaran adalah menepati CLO\nDifficulty level meets CLO'},
  {id:'b3', label:'Soalan berdasarkan kandungan silibus dan sejajar dengan CLO\nQuestions based on syllabus content and aligned with CLO'},
  {id:'b4', label:'Agihan dan Penetapan Markah\nDistribution and allocation of marks'},
  {id:'b5', label:'Tempoh masa tugasan yang bersesuaian\nTask period given is appropriate'},
  {id:'b6', label:'Skema Jawapan / Rubrik Penilaian\nAnswer Scheme / Assessment Rubric'}
];

// ── Section C vetting items (FAP01a only) ────────────────────
var FAP01A_SECTION_C = [
  {id:'c1', label:'Aras kesukaran adalah menepati CLO\nThe difficulty level meets CLO'},
  {id:'c2', label:'Soalan disediakan berdasarkan kandungan silibus dan sejajar dengan CLO\nQuestions are based on syllabus content and aligned with CLO'},
  {id:'c3a',label:'[Bilangan Soalan] Objektif / Objective'},
  {id:'c3b',label:'[Bilangan Soalan] Struktur / Structure'},
  {id:'c3c',label:'[Bilangan Soalan] Esei / Essay'},
  {id:'c4', label:'Agihan dan Penetapan Markah\nDistribution and allocation of marks'},
  {id:'c5', label:'Jumlah soalan bersesuaian dengan tempoh peperiksaan\nTotal number of questions is appropriate for the exam period'},
  {id:'c6', label:'Skema Jawapan\nAnswer Scheme'}
];

var savedSecBData = <%= f_secBData.isEmpty() ? "null" : f_secBData %>;
var savedSecCData = <%= f_secCData.isEmpty() ? "null" : f_secCData %>;

function buildChecklistTable(tbodyId, items, savedData, ynLabel) {
  var tbody = document.getElementById(tbodyId);
  if (!tbody) return;
  tbody.innerHTML = '';
  var dataMap = {};
  if (savedData) savedData.forEach(function(d){ dataMap[d.id] = d; });

  items.forEach(function(item, i) {
    var saved = dataMap[item.id] || {};
    var yn    = saved.value   || '';
    var notes = saved.notes   || '';
    var label = item.label.replace(/\n/g,'<br/><em style="color:#6b7280;">');
    if (item.label.indexOf('\n')>=0) label += '</em>';

    var ynOpts = ['','Ya / Yes','Tidak / No','T/A / N/A'].map(function(v){
      return '<option'+(v===yn?' selected':'')+'>'+v+'</option>';
    }).join('');

    var tr = document.createElement('tr');
    tr.innerHTML = '<td class="num">'+(i+1)+'</td>'
      + '<td>'+label+'</td>'
      + '<td class="yn"><select data-id="'+item.id+'" data-field="value" '+(READ_ONLY?'disabled':'')+'>'
      + ynOpts + '</select></td>'
      + '<td class="notes"><textarea data-id="'+item.id+'" data-field="notes" rows="2" '
      + (READ_ONLY?'readonly':'')+'>'+(notes)+'</textarea></td>';
    tbody.appendChild(tr);
  });
}

function collectChecklist(tbodyId, items) {
  var tbody = document.getElementById(tbodyId);
  if (!tbody) return [];
  var rows = [];
  items.forEach(function(item) {
    var sel = tbody.querySelector('[data-id="'+item.id+'"][data-field="value"]');
    var txt = tbody.querySelector('[data-id="'+item.id+'"][data-field="notes"]');
    rows.push({id:item.id, label:item.label, value:sel?sel.value:'', notes:txt?txt.value:''});
  });
  return rows;
}

// ── Prepare JSON before form submit ─────────────────────────
function prepareJSON() {
  document.getElementById('clo_data_hidden').value = JSON.stringify(collectCloData());
  var secBItems = IS_FAP01A ? FAP01A_SECTION_B : FAP01B_SECTION_B;
  document.getElementById('section_b_hidden').value = JSON.stringify(collectChecklist('sectionBBody', secBItems));
  if (IS_FAP01A) {
    document.getElementById('section_c_hidden').value = JSON.stringify(collectChecklist('sectionCBody', FAP01A_SECTION_C));
  }
  return true;
}

// ── Helper: escape HTML for attribute values ─────────────────
function esc(s) {
  return (s||'').replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

// ── Initialise on load ───────────────────────────────────────
document.addEventListener('DOMContentLoaded', function() {
  buildCloTable();
  var secBItems = IS_FAP01A ? FAP01A_SECTION_B : FAP01B_SECTION_B;
  buildChecklistTable('sectionBBody', secBItems, savedSecBData);
  if (IS_FAP01A) {
    buildChecklistTable('sectionCBody', FAP01A_SECTION_C, savedSecCData);
  }
});
</script>
</body>
</html>

