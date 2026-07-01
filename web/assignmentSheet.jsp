<%--
  FILE:    assignmentSheet.jsp
  SERVLET: AssignmentServlet sets:
           courses (List<Course>), paper (Assessment or null),
           rubricRows (List<RubricRow>), presetType (String),
           readOnly (Boolean), action (String)
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, Model.Course, Model.Assessment, Model.RubricRow" %>
<%
    String fullName = (String) session.getAttribute("fullName");
    if (fullName == null) fullName = "Lecturer";
    String ctx      = request.getContextPath();

    Assessment      paper      = (Assessment)   request.getAttribute("paper");
    List<Course>    courses    = (List<Course>)  request.getAttribute("courses");
    List<RubricRow> rubricRows = (List<RubricRow>) request.getAttribute("rubricRows");
    boolean readOnly           = Boolean.TRUE.equals(request.getAttribute("readOnly"));
    String  presetType         = (String) request.getAttribute("presetType");

    boolean saved      = "true".equals(request.getParameter("saved"));
    String  errorParam = request.getParameter("error");

    // Pre-fill values
    String pCode    = paper != null ? paper.getCourseCode()       : "";
    String pTitle   = paper != null ? paper.getCourseTitle()      : "";
    String pType    = paper != null ? paper.getPaperType()
                                    : (presetType != null ? presetType : "Lab Report");
    String pSession = paper != null && paper.getAcademicSession() != null
                    ? paper.getAcademicSession() : "";
    String pSem     = paper != null ? String.valueOf(paper.getSemester()) : "1";
    String pDL      = paper != null && paper.getDeadline()      != null ? paper.getDeadline()      : "";
    String pInstr   = paper != null && paper.getInstructions()  != null ? paper.getInstructions()  : "";
    double pWeight  = paper != null ? paper.getWeightage()   : 0;
    String pSubMode = paper != null && paper.getSubmissionMode() != null
                    ? paper.getSubmissionMode() : "Individual";
    int    pMarks   = paper != null ? paper.getAssignMarks() : 100;
    int    paperId  = paper != null ? paper.getPaperId()     : 0;

    // Session options
    String[] SESSIONS = {"2023/2024","2024/2025","2025/2026","2026/2027","2027/2028"};

    // Continuous assessment types
    String[] contTypes = {
        "Lab Report","Lab Test","Group Assignment","Individual Assignment","Project","Practical Test"
    };

    // Bloom's taxonomy options
    String[][] BLOOMS = {
        {"C1","C1 — Remember"},{"C2","C2 — Understand"},{"C3","C3 — Apply"},
        {"C4","C4 — Analyze"}, {"C5","C5 — Evaluate"}, {"C6","C6 — Create"},
        {"A1","A1 — Receiving"},{"A2","A2 — Responding"},{"A3","A3 — Valuing"},
        {"P1","P1 — Imitation"},{"P2","P2 — Manipulation"},{"P3","P3 — Precision"}
    };
%>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title><%= pType %> — E-Vetting</title>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet"/>
<style>
/* ── TOKENS — matching KP Dashboard ── */
:root{
  --navy:#2a1454;--teal:#6d28d9;--teal-soft:#f5f3ff;--teal-b:#ddd6fe;
  --cream:#f7f6fb;--surface:#fff;--border:#e4e9f0;--ink:#1e1133;--ink2:#364560;--muted:#7a8aab;
  --blue:#2563eb;--blue-soft:#eff4ff;--blue-b:#c7d9fd;
  --green:#15803d;--green-bg:#f0fdf4;--green-b:#86efac;
  --amber:#b45309;--amber-bg:#fffbeb;--amber-b:#fcd34d;
  --red:#be123c;--red-bg:#fff1f2;--red-b:#fda4af;
  --r:10px;--sh:0 1px 3px rgba(11,22,40,.06),0 4px 12px rgba(11,22,40,.06);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Sora',sans-serif;background:var(--cream);color:var(--ink);font-size:14px;min-height:100vh}

/* ── Topnav shared variables (topnav.jsp provides the HTML) ── */
.topnav{background:linear-gradient(135deg,#312e81 0%,#4c1d95 55%,#6d28d9 100%);position:sticky;top:0;z-index:100;border-bottom:2px solid #f59e0b}
.nav-inner{max-width:1200px;margin:0 auto;padding:0 24px;height:58px;display:flex;align-items:center}
.brand{display:flex;align-items:center;gap:9px;padding-right:22px;border-right:1px solid rgba(255,255,255,.1);flex-shrink:0;text-decoration:none}
.brand-logo{width:34px;height:34px;object-fit:contain;border-radius:6px}
.brand-name{font-size:13px;font-weight:800;color:#fff}
.brand-sub{font-size:10px;color:rgba(255,255,255,.4)}
.nav-tabs{display:flex;align-items:center;gap:2px;padding-left:16px;flex:1;overflow-x:auto}
.nav-tabs::-webkit-scrollbar{display:none}
.tab{display:flex;align-items:center;gap:6px;padding:7px 12px;border-radius:8px;border:1px solid transparent;background:none;color:rgba(255,255,255,.5);font-family:'Sora',sans-serif;font-size:13px;font-weight:600;cursor:pointer;white-space:nowrap;transition:.15s;text-decoration:none}
.tab:hover{background:rgba(255,255,255,.07);color:#fff}
.tab.active{background:rgba(245,158,11,.2);border-color:rgba(245,158,11,.45);color:#fbbf24}
.nav-right{margin-left:auto;display:flex;align-items:center;gap:10px;padding-left:16px;border-left:1px solid rgba(255,255,255,.1);flex-shrink:0}
.user-name{font-size:12px;font-weight:700;color:#fff}
.user-role{font-size:10px;color:rgba(255,255,255,.4)}
.avatar{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#f59e0b,#fcd34d);color:#2a1454;display:grid;place-items:center;font-weight:800;font-size:13px}
.nav-user-link{display:flex;align-items:center;gap:9px;text-decoration:none;border-radius:8px;padding:4px 8px;transition:.15s}
.nav-user-link:hover{background:rgba(255,255,255,.06)}
.logout-link{width:32px;height:32px;border-radius:50%;border:1px solid rgba(255,255,255,.15);background:none;color:rgba(255,255,255,.5);display:grid;place-items:center;text-decoration:none;transition:.15s}
.logout-link:hover{background:rgba(190,18,60,.25);color:#fda4af}

/* PAGE HEADER */
.page-header{background:var(--surface);border-bottom:1px solid var(--border);padding:14px 24px}
.page-header-inner{max-width:980px;margin:0 auto;display:flex;align-items:center;justify-content:space-between;gap:10px;flex-wrap:wrap}
.ph-title{font-size:17px;font-weight:800}
.ph-sub{font-size:12px;color:var(--muted);margin-top:2px}
.type-badge{font-family:'JetBrains Mono',monospace;font-size:11px;font-weight:700;background:var(--teal-soft);color:var(--teal);border:1px solid var(--teal-b);border-radius:6px;padding:3px 10px}

/* LAYOUT */
.content{max-width:980px;margin:0 auto;padding:22px 24px 100px}

/* CARDS */
.card{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);box-shadow:var(--sh);margin-bottom:16px;overflow:hidden}
.card-header{padding:12px 18px;border-bottom:1px solid var(--border);background:#f8f9fc;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.card-header h2{font-size:13px;font-weight:800}
.card-body{padding:18px}
.section-lbl{font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);margin-bottom:10px;padding-bottom:6px;border-bottom:1px solid var(--border)}

/* FORM */
.fg{margin-bottom:12px}
.fg label{display:block;font-size:11px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:5px}
input,select,textarea{width:100%;border:1px solid var(--border);border-radius:7px;padding:7px 10px;font-family:'Sora',sans-serif;font-size:13px;color:var(--ink);background:#fafbfc;outline:none;transition:.15s}
input:focus,select:focus,textarea:focus{border-color:var(--teal);background:#fff;box-shadow:0 0 0 3px var(--teal-soft)}
input:disabled,select:disabled,textarea:disabled{background:var(--cream);color:var(--muted);cursor:not-allowed}
textarea{resize:vertical}
.gr2{display:grid;grid-template-columns:1fr 1fr;gap:12px}
.gr3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px}
.gr4{display:grid;grid-template-columns:1fr 1fr 1fr 1fr;gap:12px}
@media(max-width:680px){.gr2,.gr3,.gr4{grid-template-columns:1fr}}

/* MARKS SUMMARY BAR */
.marks-bar{background:var(--navy);border-radius:8px;padding:12px 16px;margin-bottom:14px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px}
.marks-bar-left{display:flex;align-items:baseline;gap:4px}
.mb-num{font-size:30px;font-weight:800;font-family:'JetBrains Mono',monospace;color:#fff;letter-spacing:-1.5px}
.mb-den{font-size:15px;font-weight:700;color:rgba(255,255,255,.4);font-family:'JetBrains Mono',monospace}
.mb-lbl{font-size:10px;color:rgba(255,255,255,.4);font-weight:700;margin-left:8px}
.mb-status{font-size:11px;font-weight:800;color:rgba(255,255,255,.5)}
.mb-status.ok  {color:#86efac}
.mb-status.over{color:#fda4af}

/* RUBRIC TABLE */
.rubric-wrap{overflow-x:auto;border-radius:8px;border:1px solid var(--border)}
.rubric-table{width:100%;border-collapse:collapse;font-size:12px;min-width:700px}
.rubric-table th{padding:9px 12px;background:#f7f9fc;border-bottom:1px solid var(--border);text-align:left;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:var(--muted)}
.rubric-table td{padding:6px 8px;border-bottom:1px solid var(--border);vertical-align:top}
.rubric-table tr:last-child td{border-bottom:none}
.rubric-table td input,.rubric-table td select,.rubric-table td textarea{padding:5px 8px;font-size:12px;border-radius:6px}
.rubric-table td textarea{min-height:56px}
.del-btn{background:none;border:none;cursor:pointer;color:var(--muted);font-size:12px;padding:4px 7px;border-radius:5px;transition:.15s}
.del-btn:hover{background:var(--red-bg);color:var(--red)}
.add-row-btn{display:flex;align-items:center;gap:5px;border:2px dashed var(--border);background:transparent;border-radius:8px;padding:7px 14px;font-family:'Sora',sans-serif;font-size:12px;font-weight:700;color:var(--muted);cursor:pointer;transition:.15s;margin-top:10px}
.add-row-btn:hover{border-color:var(--teal);color:var(--teal);background:var(--teal-soft)}

/* JSS TABLE */
.jss-table{width:100%;border-collapse:collapse;font-size:12px}
.jss-table th{padding:8px 10px;background:#f7f9fc;border:1px solid var(--border);text-align:left;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:var(--muted)}
.jss-table td{padding:6px 10px;border:1px solid var(--border);font-size:12px;vertical-align:middle}
.jss-table tfoot td{background:#f7f9fc;font-weight:800}

/* BUTTONS */
.btn{display:inline-flex;align-items:center;gap:5px;border:none;border-radius:7px;padding:8px 14px;font-family:'Sora',sans-serif;font-size:12px;font-weight:700;cursor:pointer;text-decoration:none;transition:.15s}
.btn-teal {background:var(--teal);color:#fff}.btn-teal:hover{background:#4c1d95}
.btn-navy {background:var(--navy);color:#fff}.btn-navy:hover{background:#132240}
.btn-ghost{background:transparent;color:var(--ink2);border:1px solid var(--border)}.btn-ghost:hover{background:var(--cream)}
.btn-sm{padding:5px 10px;font-size:11px;border-radius:6px}

/* ALERTS */
.alert{border-radius:8px;padding:10px 14px;font-size:12px;font-weight:600;margin-bottom:14px;display:flex;gap:8px;align-items:center}
.alert-ok  {background:var(--green-bg);border:1px solid var(--green-b);color:var(--green)}
.alert-err {background:var(--red-bg);border:1px solid var(--red-b);color:var(--red)}
.alert-warn{background:var(--amber-bg);border:1px solid var(--amber-b);color:var(--amber)}

/* STICKY FOOTER */
.footer-bar{position:fixed;bottom:0;left:0;right:0;background:var(--surface);border-top:1px solid var(--border);padding:10px 24px;z-index:50}
.footer-inner{max-width:980px;margin:0 auto;display:flex;align-items:center;gap:10px;flex-wrap:wrap}
.wt-badge{display:inline-flex;align-items:center;gap:4px;border-radius:999px;padding:4px 12px;font-family:'JetBrains Mono',monospace;font-size:13px;font-weight:800;background:var(--teal-soft);color:var(--teal);border:1px solid var(--teal-b)}

/* PRINT STYLES */
@media print {
  body { background: #fff !important; }
  .topnav, .footer-bar, .page-header { display: none !important; }
  .content { padding: 0 !important; margin: 0 !important; box-shadow: none !important; border: none !important; }
  input, textarea, select { border: none !important; background: transparent !important; resize: none !important; }
  .add-row-btn, .del-btn { display: none !important; }
  .rubricBody td:last-child, .rubricBody th:last-child { display: none !important; }
}
</style>

</head>
<body>

<%-- TOPNAV --%>
<jsp:include page="topnav.jsp"/>

<%-- PAGE HEADER --%>
<div class="page-header">
  <div class="page-header-inner">
    <div>
      <div class="ph-title">
        <%= readOnly ? "View" : (paperId > 0 ? "Edit" : "New") %> Assignment Sheet
      </div>
      <div class="ph-sub">Continuous Assessment — instruction sheet and rubric</div>
    </div>
    <div style="display:flex;align-items:center;gap:10px">
      <span class="type-badge" id="typeBadge"><%= pType %></span>
      <button type="button" class="btn btn-navy btn-sm" onclick="window.print()" style="background:#2563eb;color:#fff;border:none;border-radius:6px;padding:5px 12px;font-size:11px;font-weight:700;cursor:pointer;">&#128424; Print / PDF</button>
    </div>
  </div>
</div>

<div class="content">

  <% if (saved) { %>
  <div class="alert alert-ok">Saved successfully.</div>
  <% } %>
  <% if ("submit".equals(errorParam)) { %>
  <div class="alert alert-err">Cannot submit — please check all required fields.</div>
  <% } %>
  <% if (readOnly) { %>
  <div class="alert alert-warn">
    Read-only — this assessment is <b><%= paper != null ? paper.getStatusLabel() : "" %></b>.
  </div>
  <% } %>

  <form method="post" action="<%= ctx %>/AssignmentServlet" id="assignForm">
  <input type="hidden" name="paperId" value="<%= paperId %>"/>

  <%-- ══════════════════════════════════════════════
       1. ASSESSMENT DETAILS
  ══════════════════════════════════════════════ --%>
  <div class="card">
    <div class="card-header"><h2>Assessment Details</h2></div>
    <div class="card-body">

      <div class="gr2" style="margin-bottom:12px">
        <div class="fg" style="margin-bottom:0">
          <label>Assessment Type *</label>
          <select name="paperType" id="paperTypeSel" required
                  <%= readOnly?"disabled":"" %>
                  onchange="updateTypeBadge(this.value)">
            <% for (String t : contTypes) { %>
            <option value="<%= t %>" <%= t.equals(pType) ? "selected" : "" %>><%= t %></option>
            <% } %>
          </select>
        </div>
        <div class="fg" style="margin-bottom:0">
          <label>Submission Mode *</label>
          <select name="submissionMode" <%= readOnly?"disabled":"" %>>
            <option value="Individual" <%= "Individual".equals(pSubMode) ? "selected" : "" %>>Individual</option>
            <option value="Group"      <%= "Group".equals(pSubMode)      ? "selected" : "" %>>Group</option>
          </select>
        </div>
      </div>

      <div class="fg">
        <label>Course *</label>
        <select name="courseCode" id="courseCodeSel" required
                <%= readOnly?"disabled":"" %>
                onchange="onCourseChange(this)">
          <option value="">— Select course —</option>
          <% if (courses != null) { for (Course c : courses) { %>
          <option value="<%= c.getCourseCode() %>"
                  data-title="<%= c.getCourseName() %>"
                  <%= c.getCourseCode().equals(pCode) ? "selected" : "" %>>
            <%= c.getCourseCode() %> — <%= c.getCourseName() %>
          </option>
          <% } } %>
        </select>
      </div>

      <div class="fg">
        <label>Course Title</label>
        <input type="text" name="courseTitle" id="courseTitleInp"
               value="<%= pTitle %>" <%= readOnly?"disabled":"" %>/>
      </div>

      <div class="gr4">
        <div class="fg" style="margin-bottom:0">
          <label>Session *</label>
          <select name="academicSession" <%= readOnly?"disabled":"" %>>
            <option value="">— Select —</option>
            <% for (String sv : SESSIONS) { %>
            <option value="<%= sv %>" <%= sv.equals(pSession) ? "selected" : "" %>><%= sv %></option>
            <% } %>
          </select>
        </div>
        <div class="fg" style="margin-bottom:0">
          <label>Semester *</label>
          <select name="semester" <%= readOnly?"disabled":"" %>>
            <option value="1" <%= "1".equals(pSem) ? "selected" : "" %>>Semester I</option>
            <option value="2" <%= "2".equals(pSem) ? "selected" : "" %>>Semester II</option>
          </select>
        </div>
        <div class="fg" style="margin-bottom:0">
          <label>Weightage (%)</label>
          <input type="number" name="weightage" id="weightageInp"
                 value="<%= pWeight > 0 ? (int)pWeight : "" %>"
                 min="1" max="100" placeholder="e.g. 20"
                 <%= readOnly?"disabled":"" %>
                 oninput="updateFooterWeight()"/>
        </div>
        <div class="fg" style="margin-bottom:0">
          <label>Total Marks</label>
          <input type="number" name="assignMarks" id="assignMarksInp"
                 value="<%= pMarks %>" min="1"
                 <%= readOnly?"disabled":"" %>
                 onchange="updateMarksSummary()"/>
        </div>
      </div>

      <div class="fg" style="margin-top:12px;margin-bottom:0">
        <label>Submission Deadline *</label>
        <input type="date" name="deadline" value="<%= pDL %>"
               required <%= readOnly?"disabled":"" %>
               style="max-width:220px"/>
      </div>

      <input type="hidden" name="faculty" value="FSKM"/>
    </div>
  </div>

  <%-- ══════════════════════════════════════════════
       2. TASK INSTRUCTIONS
  ══════════════════════════════════════════════ --%>
  <div class="card">
    <div class="card-header"><h2>Task Instructions</h2></div>
    <div class="card-body">
      <div class="section-lbl">Write the full assignment brief for students</div>
      <textarea name="instructions" rows="10" <%= readOnly?"disabled":"" %>
        placeholder="Example:&#10;1. Group size: 3-4 students per group.&#10;2. Submit a PDF report via LMS.&#10;3. No plagiarism — 0 marks if detected.&#10;4. Deadline: as stated above."
        style="min-height:180px"><%= pInstr %></textarea>
    </div>
  </div>

  <%-- ══════════════════════════════════════════════
       3. RUBRIC / MARKING SCHEME
  ══════════════════════════════════════════════ --%>
  <div class="card">
    <div class="card-header">
      <h2>Rubric / Marking Scheme</h2>
      <div class="marks-bar" style="border-radius:8px;padding:8px 14px;margin:0">
        <div class="marks-bar-left">
          <span class="mb-num" id="rubricTotal">0</span>
          <span class="mb-den">/ <span id="rubricMax"><%= pMarks %></span></span>
          <span class="mb-lbl">marks</span>
        </div>
        <span class="mb-status" id="rubricStatus">Add criteria</span>
      </div>
    </div>
    <div class="card-body" style="padding:0">
      <div class="rubric-wrap">
        <table class="rubric-table" id="rubricTable">
          <thead>
            <tr>
              <th style="width:22%">Criterion</th>
              <th style="width:8%">Marks</th>
              <th style="width:9%">CLO</th>
              <th style="width:12%">Bloom's</th>
              <th>Level Descriptors</th>
              <% if (!readOnly) { %><th style="width:36px"></th><% } %>
            </tr>
          </thead>
          <tbody id="rubricBody">

            <%-- Render saved rubric rows if they exist, else show defaults --%>
            <% if (rubricRows != null && !rubricRows.isEmpty()) {
                   for (RubricRow row : rubricRows) { %>
            <tr>
              <td><input type="text" name="rubricCriterion[]"
                         value="<%= row.getCriterion() %>" <%= readOnly?"disabled":"" %>/></td>
              <td><input type="number" name="rubricMarks[]"
                         value="<%= row.getMarks() %>" min="0"
                         class="rubric-marks" onchange="updateRubricTotal()"
                         <%= readOnly?"disabled":"" %>/></td>
              <td>
                <select name="rubricClo[]" <%= readOnly?"disabled":"" %>>
                  <option value="">—</option>
                  <% for (int ci = 1; ci <= 5; ci++) { %>
                  <option value="CLO<%= ci %>"
                          <%= ("CLO"+ci).equals(row.getClo()) ? "selected" : "" %>>CLO<%= ci %></option>
                  <% } %>
                </select>
              </td>
              <td>
                <select name="rubricBloom[]" <%= readOnly?"disabled":"" %>>
                  <% for (String[] bl : BLOOMS) { %>
                  <option value="<%= bl[0] %>"
                          <%= bl[0].equals(row.getBloom()) ? "selected" : "" %>><%= bl[1] %></option>
                  <% } %>
                </select>
              </td>
              <td><textarea name="rubricDesc[]" rows="2"
                            <%= readOnly?"disabled":"" %>><%= row.getDescription() != null ? row.getDescription() : "" %></textarea></td>
              <% if (!readOnly) { %>
              <td><button type="button" class="del-btn" onclick="delRow(this)">&#x2715;</button></td>
              <% } %>
            </tr>
            <% }
               } else {
                 // Default 3 rows for new assessment
                 String[][] defaults = {
                     {"Content","40"},{"Presentation","30"},{"Report Format","30"}
                 };
                 for (String[] d : defaults) { %>
            <tr>
              <td><input type="text"   name="rubricCriterion[]" value="<%= d[0] %>" <%= readOnly?"disabled":"" %>/></td>
              <td><input type="number" name="rubricMarks[]"     value="<%= d[1] %>" min="0" class="rubric-marks" onchange="updateRubricTotal()" <%= readOnly?"disabled":"" %>/></td>
              <td>
                <select name="rubricClo[]" <%= readOnly?"disabled":"" %>>
                  <option value="">—</option>
                  <% for (int ci = 1; ci <= 5; ci++) { %>
                  <option value="CLO<%= ci %>">CLO<%= ci %></option>
                  <% } %>
                </select>
              </td>
              <td>
                <select name="rubricBloom[]" <%= readOnly?"disabled":"" %>>
                  <% for (String[] bl : BLOOMS) { %>
                  <option value="<%= bl[0] %>"><%= bl[1] %></option>
                  <% } %>
                </select>
              </td>
              <td><textarea name="rubricDesc[]" rows="2" placeholder="Describe what is expected..." <%= readOnly?"disabled":"" %>></textarea></td>
              <% if (!readOnly) { %>
              <td><button type="button" class="del-btn" onclick="delRow(this)">&#x2715;</button></td>
              <% } %>
            </tr>
            <% } } %>

          </tbody>
        </table>
      </div>
      <% if (!readOnly) { %>
      <div style="padding:12px 18px">
        <button type="button" class="add-row-btn" onclick="addRubricRow()">
          + Add Criterion
        </button>
      </div>
      <% } %>
    </div>
  </div>

  <%-- ══════════════════════════════════════════════
       4. JSS SUMMARY (auto-generated from rubric)
  ══════════════════════════════════════════════ --%>
  <div class="card">
    <div class="card-header">
      <h2>JSS Summary</h2>
      <span style="font-size:11px;color:var(--muted)">Auto-generated from rubric above</span>
    </div>
    <div class="card-body">
      <div style="font-size:11px;color:var(--muted);margin-bottom:10px">
        Programme: <b style="color:var(--ink2)"><%= pCode.isEmpty() ? "—" : pCode %></b>
        &nbsp;|&nbsp; Session: <b id="jssSession" style="color:var(--ink2)"><%= pSession.isEmpty() ? "—" : pSession %></b>
        &nbsp;|&nbsp; Semester: <b id="jssSemester" style="color:var(--ink2)"><%= "1".equals(pSem) ? "I" : "II" %></b>
        &nbsp;|&nbsp; Weightage: <b id="jssWeightage" style="color:var(--ink2)"><%= pWeight > 0 ? (int)pWeight+"%" : "—" %></b>
      </div>
      <table class="jss-table" id="jssTable">
        <thead>
          <tr>
            <th>No.</th>
            <th>Criterion</th>
            <th>Marks</th>
            <th>CLO</th>
            <th>Bloom's</th>
            <th>%</th>
          </tr>
        </thead>
        <tbody id="jssBody">
          <%-- Filled dynamically by JS updateJSS() --%>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="2" style="text-align:right">TOTAL</td>
            <td id="jssTotalMarks">0</td>
            <td></td>
            <td></td>
            <td id="jssPercent">0%</td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>

  </form>

  <%-- DISCUSSION PANEL (only shown for saved papers, not brand new ones) --%>
  <% if (paperId > 0) {
       request.setAttribute("msgPaperId", paperId); %>
  <jsp:include page="messagePanel.jsp"/>
  <% } %>

</div>

<%-- STICKY FOOTER --%>
<% if (!readOnly) { %>
<div class="footer-bar">
  <div class="footer-inner">
    <span class="wt-badge" id="footerWeightage">
      <%= pWeight > 0 ? (int)pWeight : "?" %>% weightage
    </span>
    <button type="button" class="btn btn-navy" onclick="submitForm('saveDraft')">
      Save Draft
    </button>
    <button type="button" class="btn btn-teal" onclick="submitForm('submit')">
      Submit for Vetting
    </button>
    <a href="<%= ctx %>/LecturerDashboardServlet?page=assessments" class="btn btn-ghost">
      Cancel
    </a>
  </div>
</div>
<% } %>

<script>
/* ── Course auto-fill ─────────────────────────────────────────── */
function onCourseChange(sel) {
  var opt = sel.options[sel.selectedIndex];
  var ti  = document.getElementById('courseTitleInp');
  if (ti) ti.value = opt.dataset.title || '';
}

/* ── Type badge in header ─────────────────────────────────────── */
function updateTypeBadge(val) {
  var el = document.getElementById('typeBadge');
  if (el) el.textContent = val;
}

/* ── Rubric total marks ───────────────────────────────────────── */
function updateRubricTotal() {
  var inputs = document.querySelectorAll('.rubric-marks');
  var total  = 0;
  inputs.forEach(function(i) { total += parseInt(i.value) || 0; });
  var maxEl  = document.getElementById('assignMarksInp');
  var max    = maxEl ? (parseInt(maxEl.value) || 100) : 100;
  var numEl  = document.getElementById('rubricTotal');
  var stEl   = document.getElementById('rubricStatus');
  var maxDisp= document.getElementById('rubricMax');
  if (numEl)   numEl.textContent  = total;
  if (maxDisp) maxDisp.textContent = max;
  if (stEl) {
    if (total === max)  { stEl.textContent = 'Balanced';             stEl.className = 'mb-status ok';   }
    else if (total > max){ stEl.textContent = 'Over by '+(total-max);stEl.className = 'mb-status over'; }
    else                { stEl.textContent = (max-total)+' remaining'; stEl.className = 'mb-status'; }
  }
  updateJSS();
}

function updateMarksSummary() {
  updateRubricTotal();
}

/* ── JSS auto-generation from rubric rows ─────────────────────── */
function updateJSS() {
  var rows     = document.querySelectorAll('#rubricBody tr');
  var max      = parseInt((document.getElementById('assignMarksInp') || {}).value) || 100;
  var jssBody  = document.getElementById('jssBody');
  var totalEl  = document.getElementById('jssTotalMarks');
  var pctEl    = document.getElementById('jssPercent');
  if (!jssBody) return;

  jssBody.innerHTML = '';
  var total = 0;

  rows.forEach(function(row, idx) {
    var critEl  = row.querySelector('input[name="rubricCriterion[]"]');
    var marksEl = row.querySelector('input[name="rubricMarks[]"]');
    var cloEl   = row.querySelector('select[name="rubricClo[]"]');
    var bloomEl = row.querySelector('select[name="rubricBloom[]"]');
    if (!critEl) return;

    var crit  = critEl.value  || '';
    var marks = parseInt((marksEl || {}).value) || 0;
    var clo   = cloEl  ? cloEl.value   : '';
    var bloom = bloomEl? bloomEl.value  : '';
    var pct   = max > 0 ? ((marks / max) * 100).toFixed(1) : '0';
    total += marks;

    var tr = document.createElement('tr');
    tr.innerHTML =
      '<td>' + (idx+1) + '</td>' +
      '<td>' + escHtml(crit)  + '</td>' +
      '<td style="font-weight:700">' + marks + '</td>' +
      '<td>' + escHtml(clo)   + '</td>' +
      '<td>' + escHtml(bloom) + '</td>' +
      '<td>' + pct + '%</td>';
    jssBody.appendChild(tr);
  });

  if (totalEl) totalEl.textContent = total;
  if (pctEl)   pctEl.textContent   = max > 0 ? ((total/max)*100).toFixed(1)+'%' : '0%';
}

/* ── Add / delete rubric rows ─────────────────────────────────── */
function addRubricRow() {
  var tbody = document.getElementById('rubricBody');
  var bloomOpts = '';
  var BLOOMS = [
    ['C1','C1 — Remember'],['C2','C2 — Understand'],['C3','C3 — Apply'],
    ['C4','C4 — Analyze'], ['C5','C5 — Evaluate'], ['C6','C6 — Create'],
    ['A1','A1 — Receiving'],['A2','A2 — Responding'],['A3','A3 — Valuing'],
    ['P1','P1 — Imitation'],['P2','P2 — Manipulation'],['P3','P3 — Precision']
  ];
  BLOOMS.forEach(function(b) {
    bloomOpts += '<option value="' + b[0] + '">' + b[1] + '</option>';
  });
  var cloOpts = '<option value="">—</option>';
  for (var ci = 1; ci <= 5; ci++) {
    cloOpts += '<option value="CLO' + ci + '">CLO' + ci + '</option>';
  }
  var tr = document.createElement('tr');
  tr.innerHTML =
    '<td><input type="text" name="rubricCriterion[]" placeholder="Criterion"/></td>' +
    '<td><input type="number" name="rubricMarks[]" value="0" min="0" class="rubric-marks" onchange="updateRubricTotal()"/></td>' +
    '<td><select name="rubricClo[]">'   + cloOpts   + '</select></td>' +
    '<td><select name="rubricBloom[]">' + bloomOpts + '</select></td>' +
    '<td><textarea name="rubricDesc[]" rows="2" placeholder="Description..."></textarea></td>' +
    '<td><button type="button" class="del-btn" onclick="delRow(this)">&#x2715;</button></td>';
  tbody.appendChild(tr);
  updateRubricTotal();
}

function delRow(btn) {
  btn.closest('tr').remove();
  updateRubricTotal();
}

/* ── Submit form ──────────────────────────────────────────────── */
function submitForm(action) {
  if (action === 'submit') {
    var courseEl = document.getElementById('courseCodeSel');
    if (!courseEl || !courseEl.value) {
      alert('Please select a course before submitting.');
      courseEl.focus();
      return;
    }
    if (!confirm('Submit this assignment sheet for vetting? You cannot edit it after submission.')) return;
  }
  var form = document.getElementById('assignForm');
  var inp  = document.createElement('input');
  inp.type = 'hidden'; inp.name = 'action'; inp.value = action;
  form.appendChild(inp);
  form.submit();
}

/* ── Footer weightage live update ─────────────────────────────── */
function updateFooterWeight() {
  var val = document.getElementById('weightageInp').value;
  var el  = document.getElementById('footerWeightage');
  if (el) el.textContent = (val || '?') + '% weightage';

  /* Update JSS summary */
  var jssW = document.getElementById('jssWeightage');
  if (jssW) jssW.textContent = val ? val + '%' : '—';
}

/* ── Minimal HTML escape for dynamic DOM writes ───────────────── */
function escHtml(s) {
  return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

/* ── Init ─────────────────────────────────────────────────────── */
updateRubricTotal();
</script>
</body>
</html>
