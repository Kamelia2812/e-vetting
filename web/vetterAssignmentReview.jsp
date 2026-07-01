<%--
  FILE:    vetterAssignmentReview.jsp
  SERVLET: VetterDashboardServlet (handleContinuousReview) sets:
           paper (Assessment), rubricRows (List<RubricRow>),
           assignedVetters (List<User>), currentPage="queue"
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, Model.Assessment, Model.RubricRow, Model.User" %>
<%
    Assessment      paper      = (Assessment)   request.getAttribute("paper");
    List<RubricRow> rubricRows = (List<RubricRow>) request.getAttribute("rubricRows");
    List<User>      vetterList = (List<User>)    request.getAttribute("assignedVetters");
    String          ctx        = request.getContextPath();

    if (paper == null) {
        response.sendRedirect(ctx + "/VetterDashboardServlet?page=queue");
        return;
    }

    String  pType    = paper.getPaperType()       != null ? paper.getPaperType()       : "";
    String  pCode    = paper.getCourseCode()       != null ? paper.getCourseCode()       : "";
    String  pTitle   = paper.getCourseTitle()      != null ? paper.getCourseTitle()      : "";
    String  pSession = paper.getAcademicSession()  != null ? paper.getAcademicSession()  : "";
    int     pSem     = paper.getSemester();
    double  pWeight  = paper.getWeightage();
    int     pMarks   = paper.getAssignMarks();
    String  pSubMode = paper.getSubmissionMode()   != null ? paper.getSubmissionMode()   : "";
    String  pInstr   = paper.getInstructions()     != null ? paper.getInstructions()     : "";
    String  pRem     = paper.getRemarks()          != null ? paper.getRemarks()          : "";
    int     paperId  = paper.getPaperId();
    boolean isActive = "SUBMITTED".equals(paper.getStatus()) || "UNDER_REVIEW".equals(paper.getStatus());

    // Compute total rubric marks
    int rubricTotal = 0;
    if (rubricRows != null) {
        for (RubricRow r : rubricRows) rubricTotal += r.getMarks();
    }
%>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>Review — <%= pType %> — E-Vetting</title>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet"/>
<style>
:root{
  --navy:#2a1454;--teal:#6d28d9;--teal-soft:#f5f3ff;--teal-b:#ddd6fe;
  --cream:#f7f6fb;--surface:#fff;--border:#e4e9f0;--ink:#1e1133;--ink2:#364560;--muted:#7a8aab;
  --green:#15803d;--green-bg:#f0fdf4;--green-b:#86efac;
  --amber:#b45309;--amber-bg:#fffbeb;--amber-b:#fcd34d;
  --red:#be123c;--red-bg:#fff1f2;--red-b:#fda4af;
  --r:10px;--sh:0 1px 3px rgba(11,22,40,.06),0 4px 12px rgba(11,22,40,.06);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Sora',sans-serif;background:var(--cream);color:var(--ink);font-size:14px;min-height:100vh}

/* TOPNAV shared */
.topnav{background:linear-gradient(135deg,#312e81 0%,#4c1d95 55%,#6d28d9 100%);position:sticky;top:0;z-index:100;border-bottom:2px solid #f59e0b}
.nav-inner{max-width:1200px;margin:0 auto;padding:0 24px;height:58px;display:flex;align-items:center}
.brand{display:flex;align-items:center;gap:9px;padding-right:22px;border-right:1px solid rgba(255,255,255,.1);flex-shrink:0;text-decoration:none}
.brand-logo{width:34px;height:34px;object-fit:contain;border-radius:6px}
.brand-name{font-size:13px;font-weight:800;color:#fff}
.brand-sub{font-size:10px;color:rgba(255,255,255,.4)}
.nav-tabs{display:flex;align-items:center;gap:2px;padding-left:16px;flex:1}
.tab{display:flex;align-items:center;padding:7px 12px;border-radius:8px;border:1px solid transparent;background:none;color:rgba(255,255,255,.5);font-family:'Sora',sans-serif;font-size:13px;font-weight:600;white-space:nowrap;transition:.15s;text-decoration:none}
.tab:hover{background:rgba(255,255,255,.07);color:#fff}
.tab.active{background:rgba(245,158,11,.2);border-color:rgba(245,158,11,.45);color:#fbbf24}
.nav-right{margin-left:auto;display:flex;align-items:center;gap:10px;padding-left:16px;border-left:1px solid rgba(255,255,255,.1)}
.user-name{font-size:12px;font-weight:700;color:#fff}
.user-role{font-size:10px;color:rgba(255,255,255,.4)}
.avatar{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#f59e0b,#fcd34d);color:#2a1454;display:grid;place-items:center;font-weight:800;font-size:13px}
.nav-user-link{display:flex;align-items:center;gap:9px;text-decoration:none;border-radius:8px;padding:4px 8px;transition:.15s}
.nav-user-link:hover{background:rgba(255,255,255,.06)}
.logout-link{width:32px;height:32px;border-radius:50%;border:1px solid rgba(255,255,255,.15);background:none;color:rgba(255,255,255,.5);display:grid;place-items:center;text-decoration:none;transition:.15s}
.logout-link:hover{background:rgba(190,18,60,.25);color:#fda4af}

/* PAGE HEADER */
.page-header{background:var(--surface);border-bottom:1px solid var(--border);padding:14px 24px}
.page-header-inner{max-width:980px;margin:0 auto;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px}
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

/* GRID */
.gr2{display:grid;grid-template-columns:1fr 1fr;gap:12px}
.gr3{display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px}
.gr4{display:grid;grid-template-columns:1fr 1fr 1fr 1fr;gap:12px}
@media(max-width:680px){.gr2,.gr3,.gr4{grid-template-columns:1fr}}
.kv{background:var(--cream);border:1px solid var(--border);border-radius:8px;padding:10px 12px}
.kv b{display:block;font-size:10px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:3px}
.kv span{font-size:13px;font-weight:700;color:var(--ink2)}

/* RUBRIC TABLE */
.rubric-wrap{overflow-x:auto}
.rubric-table{width:100%;border-collapse:collapse;font-size:12px;min-width:600px}
.rubric-table th{padding:9px 12px;background:#f7f9fc;border-bottom:1px solid var(--border);text-align:left;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:var(--muted)}
.rubric-table td{padding:8px 12px;border-bottom:1px solid var(--border);vertical-align:top}
.rubric-table tr:last-child td{border-bottom:none}
.rubric-table tfoot td{background:#f7f9fc;font-weight:800;font-size:12px}
.marks-chip{display:inline-flex;align-items:center;background:var(--navy);color:#fff;border-radius:6px;padding:3px 10px;font-family:'JetBrains Mono',monospace;font-size:12px;font-weight:700}
.bloom-chip{display:inline-flex;align-items:center;background:var(--teal-soft);color:var(--teal);border:1px solid var(--teal-b);border-radius:5px;padding:1px 7px;font-size:10px;font-weight:700;font-family:'JetBrains Mono',monospace}
.clo-chip{display:inline-flex;align-items:center;background:#f0fdf4;color:#15803d;border:1px solid #86efac;border-radius:5px;padding:1px 7px;font-size:10px;font-weight:700}

/* BADGES */
.badge{display:inline-flex;align-items:center;gap:4px;border-radius:999px;padding:3px 9px;font-size:11px;font-weight:700;border:1px solid}
.bdot{width:5px;height:5px;border-radius:50%;background:currentColor}
.badge-submitted{color:var(--amber);background:var(--amber-bg);border-color:var(--amber-b)}
.badge-review   {color:#2563eb;background:#eff4ff;border-color:#c7d9fd}
.badge-approved {color:var(--green);background:var(--green-bg);border-color:var(--green-b)}
.badge-rejected {color:var(--red);background:var(--red-bg);border-color:var(--red-b)}
.badge-improve  {color:#7c3aed;background:#f5f3ff;border-color:#ddd6fe}

/* INSTRUCTIONS */
.instr-box{background:var(--cream);border:1px solid var(--border);border-radius:8px;padding:14px 16px;white-space:pre-wrap;font-size:13px;line-height:1.65;color:var(--ink2)}

/* VERDICT PANEL */
.verdict-panel{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);box-shadow:var(--sh);margin-bottom:16px;overflow:hidden}
.verdict-panel .vp-head{padding:14px 18px;border-bottom:1px solid var(--border);background:linear-gradient(135deg,#312e81,#4c1d95);display:flex;align-items:center;justify-content:space-between}
.verdict-panel .vp-head h2{font-size:13px;font-weight:800;color:#fff}
.verdict-panel .vp-body{padding:18px}

/* BUTTONS */
.btn{display:inline-flex;align-items:center;gap:5px;border:none;border-radius:7px;padding:8px 14px;font-family:'Sora',sans-serif;font-size:13px;font-weight:700;cursor:pointer;text-decoration:none;transition:.15s}
.btn-approve {background:#15803d;color:#fff}.btn-approve:hover{background:#166534}
.btn-improve {background:#b45309;color:#fff}.btn-improve:hover{background:#92400e}
.btn-reject  {background:var(--red);color:#fff}.btn-reject:hover{background:#9f1239}
.btn-ghost{background:transparent;color:var(--ink2);border:1px solid var(--border)}.btn-ghost:hover{background:var(--cream)}
.btn-sm{padding:5px 10px;font-size:12px}

/* PANEL CHIPS */
.panel-chip{display:flex;align-items:center;gap:8px;background:var(--cream);border:1px solid var(--border);border-radius:8px;padding:8px 12px}
.panel-avatar{width:30px;height:30px;border-radius:50%;background:linear-gradient(135deg,var(--teal),#4c1d95);color:#fff;display:grid;place-items:center;font-size:11px;font-weight:800;flex-shrink:0}
.panel-name{font-size:12px;font-weight:700;color:var(--ink2)}
.panel-role{font-size:10px;color:var(--muted)}
.star{color:#f59e0b;margin-left:4px}

/* ALERT */
.alert{border-radius:8px;padding:10px 14px;font-size:12px;font-weight:600;margin-bottom:14px;display:flex;gap:8px;align-items:flex-start}
.alert-warn{background:var(--amber-bg);border:1px solid var(--amber-b);color:var(--amber)}
.alert-ok  {background:var(--green-bg);border:1px solid var(--green-b);color:var(--green)}
</style>
</head>
<body>

<%-- TOPNAV --%>
<jsp:include page="topnav.jsp"/>

<%-- PAGE HEADER --%>
<div class="page-header">
  <div class="page-header-inner">
    <div>
      <div class="ph-title">Review Continuous Assessment</div>
      <div class="ph-sub">
        <%= pCode %><% if (!pTitle.isEmpty()) { %> — <%= pTitle %><% } %>
        &nbsp;·&nbsp;Session <%= pSession %>, Semester <%= pSem %>
      </div>
    </div>
    <div style="display:flex;align-items:center;gap:8px">
      <span class="type-badge"><%= pType %></span>
      <span class="badge <%= paper.getStatusClass() %>"><span class="bdot"></span><%= paper.getStatusLabel() %></span>
    </div>
  </div>
</div>

<div class="content">

  <% if ("true".equals(request.getParameter("verdict"))) { %>
  <div class="alert alert-ok">Verdict saved successfully.</div>
  <% } %>

  <% if (!isActive) { %>
  <div class="alert alert-warn">
    This assessment is <b><%= paper.getStatusLabel() %></b> — reviewing is closed.
  </div>
  <% } %>

  <%-- ── ASSESSMENT DETAILS ── --%>
  <div class="card">
    <div class="card-header"><h2>Assessment Details</h2></div>
    <div class="card-body">
      <div class="gr4" style="margin-bottom:12px">
        <div class="kv"><b>Type</b><span><%= pType %></span></div>
        <div class="kv"><b>Submission</b><span><%= pSubMode.isEmpty() ? "—" : pSubMode %></span></div>
        <div class="kv"><b>Weightage</b><span><%= pWeight > 0 ? (int)pWeight + "%" : "—" %></span></div>
        <div class="kv"><b>Total Marks</b><span><%= pMarks > 0 ? pMarks : "—" %></span></div>
      </div>
      <div class="gr2">
        <div class="kv"><b>Course</b><span><%= pCode %><% if (!pTitle.isEmpty()) { %> — <%= pTitle %><% } %></span></div>
        <div class="kv"><b>Deadline</b><span><%= paper.getDeadline() != null ? paper.getDeadline() : "—" %></span></div>
      </div>
    </div>
  </div>

  <%-- ── VETTING PANEL ── --%>
  <% if (vetterList != null && !vetterList.isEmpty()) { %>
  <div class="card">
    <div class="card-header"><h2>Vetting Panel</h2></div>
    <div class="card-body">
      <div class="gr3">
        <%
          java.util.List leaderList = (java.util.List) request.getAttribute("leaderMap");
          for (User v : vetterList) {
              String vInit = "V";
              if (v.getFullName() != null) {
                  String[] vp = v.getFullName().trim().split("\\s+");
                  int vs = (vp.length > 1 && vp[0].endsWith(".")) ? 1 : 0;
                  StringBuilder vsb = new StringBuilder();
                  for (int vi = vs; vi < vp.length && vsb.length() < 2; vi++) vsb.append(Character.toUpperCase(vp[vi].charAt(0)));
                  if (vsb.length() > 0) vInit = vsb.toString();
              }
        %>
        <div class="panel-chip">
          <div class="panel-avatar"><%= vInit %></div>
          <div>
            <div class="panel-name"><%= v.getFullName() != null ? v.getFullName() : "Vetter" %></div>
            <div class="panel-role"><%= v.getRole() != null ? v.getRole() : "Vetter" %></div>
          </div>
        </div>
        <% } %>
      </div>
    </div>
  </div>
  <% } %>

  <%-- ── TASK INSTRUCTIONS ── --%>
  <% if (!pInstr.isEmpty()) { %>
  <div class="card">
    <div class="card-header"><h2>Task Instructions</h2></div>
    <div class="card-body">
      <div class="instr-box"><%= pInstr %></div>
    </div>
  </div>
  <% } %>

  <%-- ── RUBRIC / MARKING SCHEME ── --%>
  <div class="card">
    <div class="card-header">
      <h2>Rubric / Marking Scheme</h2>
      <span style="font-family:'JetBrains Mono',monospace;font-size:12px;font-weight:700;color:var(--muted)">
        Total: <b style="color:var(--navy)"><%= rubricTotal %></b> / <b><%= pMarks %></b> marks
      </span>
    </div>
    <div class="card-body" style="padding:0">
      <% if (rubricRows == null || rubricRows.isEmpty()) { %>
      <div style="padding:24px;text-align:center;color:var(--muted);font-size:12px">No rubric criteria saved for this assessment.</div>
      <% } else { %>
      <div class="rubric-wrap">
        <table class="rubric-table">
          <thead>
            <tr>
              <th style="width:4%">No.</th>
              <th style="width:24%">Criterion</th>
              <th style="width:9%">Marks</th>
              <th style="width:9%">CLO</th>
              <th style="width:12%">Bloom's</th>
              <th>Level Descriptor</th>
            </tr>
          </thead>
          <tbody>
            <% int rNo = 1; for (RubricRow r : rubricRows) { %>
            <tr>
              <td style="color:var(--muted);font-size:11px"><%= rNo++ %></td>
              <td style="font-weight:700"><%= r.getCriterion() != null ? r.getCriterion() : "" %></td>
              <td><span class="marks-chip"><%= r.getMarks() %></span></td>
              <td><% if (r.getClo() != null && !r.getClo().isEmpty()) { %><span class="clo-chip"><%= r.getClo() %></span><% } else { %><span style="color:var(--muted)">—</span><% } %></td>
              <td><% if (r.getBloom() != null && !r.getBloom().isEmpty()) { %><span class="bloom-chip"><%= r.getBloom() %></span><% } else { %><span style="color:var(--muted)">—</span><% } %></td>
              <td style="font-size:12px;color:var(--ink2);line-height:1.5"><%= r.getDescription() != null ? r.getDescription() : "" %></td>
            </tr>
            <% } %>
          </tbody>
          <tfoot>
            <tr>
              <td colspan="2" style="text-align:right;padding:10px 12px">TOTAL</td>
              <td style="padding:10px 12px"><%= rubricTotal %></td>
              <td colspan="3"></td>
            </tr>
          </tfoot>
        </table>
      </div>
      <% } %>
    </div>
  </div>

  <%-- ── VERDICT ── --%>
  <% if (isActive) { %>
  <div class="verdict-panel">
    <div class="vp-head"><h2>Vetting Verdict</h2></div>
    <div class="vp-body">
      <div style="margin-bottom:12px">
        <label style="display:block;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.4px;color:var(--muted);margin-bottom:6px">Remarks / Feedback to Lecturer</label>
        <textarea id="remarksArea" rows="5"
          style="width:100%;border:1px solid var(--border);border-radius:8px;padding:10px 12px;font-family:'Sora',sans-serif;font-size:13px;color:var(--ink);background:#fafbfc;outline:none;resize:vertical;transition:.15s"
          onfocus="this.style.borderColor='var(--teal)';this.style.boxShadow='0 0 0 3px var(--teal-soft)'"
          onblur="this.style.borderColor='var(--border)';this.style.boxShadow='none'"
          placeholder="Provide detailed feedback to help the lecturer improve this assessment..."><%= pRem %></textarea>
      </div>
      <div style="font-size:11px;color:var(--muted);margin-bottom:16px">
        Remarks are sent to the lecturer and recorded in the system. Be constructive and specific.
      </div>
      <div style="display:flex;gap:10px;flex-wrap:wrap">
        <button type="button" class="btn btn-approve" onclick="submitVerdict('approve')">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
          Approve
        </button>
        <button type="button" class="btn btn-improve" onclick="submitVerdict('requestImprovement')">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
          Request Improvement
        </button>
        <button type="button" class="btn btn-reject" onclick="submitVerdict('reject')">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
          Reject
        </button>
        <a href="<%= ctx %>/VetterDashboardServlet?page=queue" class="btn btn-ghost">Back to Queue</a>
      </div>
    </div>
  </div>

  <form method="post" action="<%= ctx %>/VetterDashboardServlet" id="verdictForm" style="display:none">
    <input type="hidden" name="paperId" value="<%= paperId %>"/>
    <input type="hidden" name="action" id="verdictAction" value=""/>
    <input type="hidden" name="remarks" id="verdictRemarks" value=""/>
  </form>
  <% } else { %>
  <div style="text-align:center;padding:20px 0">
    <a href="<%= ctx %>/VetterDashboardServlet?page=queue" class="btn btn-ghost">Back to Queue</a>
  </div>
  <% } %>

  <%-- DISCUSSION PANEL --%>
  <% request.setAttribute("msgPaperId", paperId); %>
  <jsp:include page="messagePanel.jsp"/>

</div><%-- end content --%>

<script>
function submitVerdict(action) {
  var remarks = document.getElementById('remarksArea').value.trim();
  var label = action === 'approve' ? 'Approve'
            : action === 'requestImprovement' ? 'Request Improvement'
            : 'Reject';
  if (!confirm('Confirm: ' + label + ' this assessment?')) return;
  document.getElementById('verdictAction').value  = action;
  document.getElementById('verdictRemarks').value = remarks;
  document.getElementById('verdictForm').submit();
}
</script>
</body>
</html>
