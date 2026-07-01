<%--
  FILE:    lecturerDashboard.jsp
  SERVLET: LecturerDashboardServlet sets:
           courses (List<Course>), assessments (List<Assessment>),
           draftCount, submittedCount, approvedCount, rejectedCount,
           needsImprovementCount, activePage
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, Model.Course, Model.Assessment" %>
<%
    String fullName = (String) session.getAttribute("fullName");
    String userRole = (String) session.getAttribute("role");
    if (fullName == null) fullName = "Lecturer";
    if (userRole == null) userRole = "Lecturer";
    String initial = String.valueOf(fullName.charAt(0)).toUpperCase();

    List<Course>     courses     = (List<Course>)     request.getAttribute("courses");
    List<Assessment> assessments = (List<Assessment>) request.getAttribute("assessments");

    int draftCount            = request.getAttribute("draftCount")            != null ? (int) request.getAttribute("draftCount")            : 0;
    int submittedCount        = request.getAttribute("submittedCount")        != null ? (int) request.getAttribute("submittedCount")        : 0;
    int approvedCount         = request.getAttribute("approvedCount")         != null ? (int) request.getAttribute("approvedCount")         : 0;
    int rejectedCount         = request.getAttribute("rejectedCount")         != null ? (int) request.getAttribute("rejectedCount")         : 0;
    int needsImprovementCount = request.getAttribute("needsImprovementCount") != null ? (int) request.getAttribute("needsImprovementCount") : 0;

    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "dashboard";
    boolean justSubmitted   = "true".equals(request.getParameter("submitted"));
    boolean justSaved       = "true".equals(request.getParameter("saved"));
    boolean leaderSubmitted = "true".equals(request.getParameter("leaderSubmitted"));
    String ctx = request.getContextPath();
%>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>Lecturer Dashboard — E-Vetting</title>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet"/>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet"/>
<style>
/* ── TOKENS — matching KP Dashboard exactly ── */
:root{
  --navy:#2a1454;--teal:#6d28d9;--teal-soft:#f5f3ff;--teal-b:#ddd6fe;
  --cream:#f7f6fb;--surface:#fff;--border:#e4e9f0;--ink:#1e1133;--ink2:#364560;--muted:#7a8aab;
  --blue:#2563eb;--blue-soft:#eff4ff;--blue-b:#c7d9fd;
  --green:#15803d;--green-bg:#f0fdf4;--green-b:#86efac;
  --amber:#b45309;--amber-bg:#fffbeb;--amber-b:#fcd34d;
  --red:#be123c;--red-bg:#fff1f2;--red-b:#fda4af;
  --purple:#7c3aed;--purple-bg:#f5f3ff;--purple-b:#ddd6fe;
  --r:10px;--sh:0 1px 3px rgba(11,22,40,.06),0 4px 12px rgba(11,22,40,.06);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Sora',system-ui,sans-serif;background:var(--cream);color:var(--ink);font-size:14px;min-height:100vh}

/* ── TOPNAV ── */
.topnav{background:linear-gradient(135deg,#312e81 0%,#4c1d95 55%,#6d28d9 100%);position:sticky;top:0;z-index:100;border-bottom:2px solid #f59e0b}
.nav-inner{max-width:1200px;margin:0 auto;padding:0 24px;height:58px;display:flex;align-items:center}
.brand{display:flex;align-items:center;gap:9px;padding-right:22px;border-right:1px solid rgba(255,255,255,.1);flex-shrink:0;text-decoration:none}
.brand-logo{width:34px;height:34px;background:var(--teal);border-radius:9px;display:grid;place-items:center;font-size:11px;font-weight:900;color:#fff;letter-spacing:-.5px}
.brand-name{font-size:13px;font-weight:800;color:#fff}
.brand-sub{font-size:10px;color:rgba(255,255,255,.4)}
.nav-tabs{display:flex;align-items:center;gap:2px;padding-left:16px;flex:1;overflow-x:auto}
.nav-tabs::-webkit-scrollbar{display:none}
.tab{display:flex;align-items:center;gap:6px;padding:7px 12px;border-radius:8px;border:1px solid transparent;background:none;color:rgba(255,255,255,.5);font-family:'Sora',sans-serif;font-size:13px;font-weight:600;cursor:pointer;white-space:nowrap;transition:.15s}
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

/* ── PAGE HEADER ── */
.page-header{background:var(--surface);border-bottom:1px solid var(--border);padding:14px 24px}
.page-header-inner{max-width:1200px;margin:0 auto;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px}
.ph-title{font-size:18px;font-weight:800}
.ph-sub{font-size:12px;color:var(--muted);margin-top:2px}

/* ── LAYOUT ── */
.content{max-width:1200px;margin:0 auto;padding:22px 24px 60px}
.page-section{display:none}
.page-section.active{display:block;animation:fadeUp .2s ease}
@keyframes fadeUp{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}

/* ── COMMON ── */
.card{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);box-shadow:var(--sh);padding:18px}
.sec-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:14px}
.sec-head h2{font-size:14px;font-weight:800}
.sec-head p{font-size:12px;color:var(--muted);margin-top:2px}
.btn{display:inline-flex;align-items:center;gap:5px;border:none;border-radius:8px;padding:8px 14px;font-family:'Sora',sans-serif;font-size:13px;font-weight:700;cursor:pointer;text-decoration:none;transition:.15s}
.btn-teal {background:var(--teal);color:#fff}.btn-teal:hover{background:#4c1d95}
.btn-navy {background:var(--navy);color:#fff}.btn-navy:hover{background:#132240}
.btn-ghost{background:transparent;color:var(--ink2);border:1px solid var(--border)}.btn-ghost:hover{background:var(--cream)}
.btn-red  {background:var(--red-bg);color:var(--red);border:1px solid var(--red-b)}
.btn-sm{padding:5px 10px;font-size:12px;border-radius:6px}
.badge{display:inline-flex;align-items:center;gap:4px;border-radius:999px;padding:3px 9px;font-size:11px;font-weight:700;border:1px solid}
.bdot{width:5px;height:5px;border-radius:50%;background:currentColor}
.badge-draft    {color:var(--blue);background:var(--blue-soft);border-color:var(--blue-b)}
.badge-submitted{color:var(--amber);background:var(--amber-bg);border-color:var(--amber-b)}
.badge-approved {color:var(--green);background:var(--green-bg);border-color:var(--green-b)}
.badge-rejected {color:var(--red);background:var(--red-bg);border-color:var(--red-b)}
.badge-review   {color:var(--blue);background:var(--blue-soft);border-color:var(--blue-b)}
.badge-improve  {color:var(--purple);background:var(--purple-bg);border-color:var(--purple-b)}
.badge-sent     {color:var(--teal);background:var(--teal-soft);border-color:var(--teal-b)}
.badge-leader   {color:#d97706;background:#fffbeb;border-color:#fcd34d}
.mono{font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--muted)}

/* ── TABLE ── */
.tw{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);box-shadow:var(--sh);overflow:hidden}
table{width:100%;border-collapse:collapse;font-size:13px}
thead th{padding:10px 14px;background:#f7f9fc;border-bottom:1px solid var(--border);text-align:left;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--muted)}
tbody td{padding:12px 14px;border-bottom:1px solid var(--border);vertical-align:middle}
tbody tr:last-child td{border-bottom:none}
tbody tr:hover td{background:#f7f9fc}
.empty{text-align:center;padding:40px 20px;color:var(--muted)}
.empty .ei{font-size:32px;margin-bottom:8px}
.empty p{font-size:13px}

/* ── STAT CARDS ── */
.stat-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:14px;margin-bottom:22px}
@media(max-width:900px){.stat-grid{grid-template-columns:repeat(3,1fr)}}
@media(max-width:580px){.stat-grid{grid-template-columns:repeat(2,1fr)}}
.stat-card{border-radius:var(--r);padding:18px 16px 14px;position:relative;overflow:hidden;cursor:pointer;transition:.15s;border:1px solid}
.stat-card:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(11,22,40,.1)}
.stat-card::before{content:'';position:absolute;top:0;left:0;right:0;height:3px;background:currentColor;border-radius:var(--r) var(--r) 0 0}
.s-draft{color:var(--blue);background:var(--blue-soft);border-color:var(--blue-b)}
.s-sub  {color:var(--amber);background:var(--amber-bg);border-color:var(--amber-b)}
.s-ok   {color:var(--green);background:var(--green-bg);border-color:var(--green-b)}
.s-warn {color:var(--purple);background:var(--purple-bg);border-color:var(--purple-b)}
.s-rej  {color:var(--red);background:var(--red-bg);border-color:var(--red-b)}
.stat-num{font-size:32px;font-weight:800;letter-spacing:-1.5px;line-height:1}
.stat-lbl{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--ink2);margin-top:4px}
.stat-card .stat-icon{position:absolute;right:16px;top:50%;transform:translateY(-50%);font-size:36px;opacity:.15;pointer-events:none}

/* ── COURSE CARDS ── */
.courses-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}
@media(max-width:960px){.courses-grid{grid-template-columns:repeat(2,1fr)}}
@media(max-width:580px){.courses-grid{grid-template-columns:1fr}}
.course-card{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);padding:16px;box-shadow:var(--sh);transition:.15s}
.course-card:hover{transform:translateY(-2px);border-color:var(--teal)}
.cc-top{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:8px}
.cc-code{font-family:'JetBrains Mono',monospace;font-size:11px;font-weight:700;color:var(--teal);background:var(--teal-soft);border:1px solid var(--teal-b);border-radius:5px;padding:2px 7px}
.cc-cr{font-size:11px;font-weight:700;color:var(--muted);border:1px solid var(--border);border-radius:5px;padding:2px 7px}
.cc-name{font-size:14px;font-weight:800;margin-bottom:10px;line-height:1.35}
.kv-grid{display:grid;grid-template-columns:1fr 1fr;gap:6px;margin-bottom:10px}
.kv-item{background:var(--cream);border:1px solid var(--border);border-radius:8px;padding:7px 9px}
.kv-item b{display:block;font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:2px}
.kv-item span{font-size:12px;font-weight:700}
.kv-full{grid-column:1/-1}

/* ── JSS CARDS ── */
.jss-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}
@media(max-width:900px){.jss-grid{grid-template-columns:1fr}}
.jss-card{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);padding:16px;box-shadow:var(--sh)}

/* ── MODAL ── */
.modal{display:none;position:fixed;inset:0;z-index:200;background:rgba(11,22,40,.5);place-items:center}
.modal.open{display:grid}
.modal-box{background:#fff;border-radius:var(--r);padding:28px;width:min(560px,92vw);box-shadow:0 20px 60px rgba(11,22,40,.25);animation:fadeUp .2s ease}
.modal-box h3{font-size:16px;font-weight:800;margin-bottom:6px}
.modal-box p{font-size:12px;color:var(--muted);margin-bottom:20px}
.type-grid{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:8px}
.type-card{border:2px solid var(--border);border-radius:var(--r);padding:18px 16px;cursor:pointer;transition:.15s;text-decoration:none;color:var(--ink);display:block}
.type-card:hover{transform:translateY(-2px);box-shadow:0 6px 20px rgba(11,22,40,.1)}
.type-card-title{font-size:14px;font-weight:800;margin-bottom:4px}
.type-card-sub{font-size:11px;color:var(--muted);line-height:1.5}
.type-card.final{border-color:var(--blue-b);background:var(--blue-soft)}.type-card.final:hover{border-color:var(--blue)}
.type-card.assign{border-color:var(--green-b);background:var(--green-bg)}.type-card.assign:hover{border-color:var(--green)}
.modal-cancel{width:100%;margin-top:10px;padding:8px;border:1px solid var(--border);border-radius:8px;background:transparent;font-family:'Sora',sans-serif;font-size:12px;font-weight:700;color:var(--muted);cursor:pointer}
.modal-cancel:hover{background:var(--cream)}
#toast{position:fixed;bottom:22px;left:50%;transform:translateX(-50%) translateY(60px);background:var(--navy);color:#fff;border-radius:9px;padding:10px 18px;font-size:13px;font-weight:600;opacity:0;transition:.3s cubic-bezier(.34,1.56,.64,1);z-index:999;pointer-events:none;white-space:nowrap}
#toast.show{transform:translateX(-50%) translateY(0);opacity:1}
</style>
</head>
<body>

<%-- ── TOPNAV ── --%>
<header class="topnav">
  <div class="nav-inner">
    <a href="<%= ctx %>/LecturerDashboardServlet" class="brand">
      <img src="<%= ctx %>/images/umt-logo.png" alt="UMT Logo" class="brand-logo" style="object-fit:contain;border-radius:6px;">
      <div><div class="brand-name">E-Vetting</div><div class="brand-sub">UMT</div></div>
    </a>
    <nav class="nav-tabs">
      <button class="tab" data-page="dashboard"><i class="bi bi-speedometer2"></i> Dashboard</button>
      <button class="tab" data-page="courses"><i class="bi bi-journal-bookmark"></i> My Courses</button>
      <button class="tab" data-page="assessments"><i class="bi bi-file-earmark-text"></i> Assessments</button>
      <button class="tab" data-page="jss"><i class="bi bi-clipboard-data"></i> JSS</button>
    </nav>
    <div class="nav-right">
      <a href="<%= ctx %>/UserProfileServlet" class="nav-user-link" title="My Profile">
        <div><div class="user-name"><%= fullName %></div><div class="user-role"><%= userRole %></div></div>
        <div class="avatar"><%= initial %></div>
      </a>
      <jsp:include page="notificationBell.jsp"/>
      <a href="<%= ctx %>/logout" class="logout-link" title="Sign out">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" width="16" height="16"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
      </a>
    </div>
  </div>
</header>

<%-- ── PAGE HEADER ── --%>
<div class="page-header">
  <div class="page-header-inner">
    <div><div class="ph-title" id="phTitle">Dashboard</div><div class="ph-sub" id="phSub">Welcome back, <%= fullName %>!</div></div>
    <button class="btn btn-teal" id="newPaperBtn" style="display:none" onclick="openModal('assessTypeModal')">+ New Assessment</button>
  </div>
</div>

<div class="content">

  <% if (justSubmitted) { %>
  <div style="background:var(--green-bg);border:1px solid var(--green-b);color:var(--green);border-radius:var(--r);padding:12px 16px;margin-bottom:16px;font-size:13px;font-weight:700;display:flex;align-items:center;gap:10px">
    Paper submitted successfully! Your vetter has been notified.
  </div>
  <% } %>
  <% if (justSaved) { %>
  <div style="background:var(--amber-bg);border:1px solid var(--amber-b);color:var(--amber);border-radius:var(--r);padding:12px 16px;margin-bottom:16px;font-size:13px;font-weight:700">
    Draft saved successfully.
  </div>
  <% } %>
  <% if (leaderSubmitted) { %>
  <div style="background:#fffbeb;border:1px solid #fcd34d;color:#d97706;border-radius:var(--r);padding:12px 16px;margin-bottom:16px;font-size:13px;font-weight:700">
    Assessment submitted to Leader Vetter for final signature. You will be notified once finalized.
  </div>
  <% } %>

  <%-- ════════════════════════════════════════════
       DASHBOARD TAB
  ════════════════════════════════════════════ --%>
  <div class="page-section" id="page-dashboard">
    <div style="display:flex; flex-wrap:wrap; gap:20px;">
      <div style="flex:1; min-width: 0;">


    <%-- Stat cards: 5 cards, all properly closed --%>
    <div class="stat-grid">
      <div class="stat-card s-draft" onclick="switchTab('assessments')">
        <div class="stat-icon"><i class="bi bi-file-earmark-text"></i></div>
        <div class="stat-num"><%= draftCount %></div>
        <div class="stat-lbl">Draft</div>
      </div>
      <div class="stat-card s-sub" onclick="switchTab('assessments')">
        <div class="stat-icon"><i class="bi bi-file-earmark-arrow-up"></i></div>
        <div class="stat-num"><%= submittedCount %></div>
        <div class="stat-lbl">Submitted</div>
      </div>
      <div class="stat-card s-ok" onclick="switchTab('assessments')">
        <div class="stat-icon"><i class="bi bi-patch-check"></i></div>
        <div class="stat-num"><%= approvedCount %></div>
        <div class="stat-lbl">Approved</div>
      </div>
      <div class="stat-card s-warn" onclick="switchTab('assessments')">
        <div class="stat-icon"><i class="bi bi-arrow-counterclockwise"></i></div>
        <div class="stat-num"><%= needsImprovementCount %></div>
        <div class="stat-lbl">Resubmission</div>
      </div>
      <div class="stat-card s-rej" onclick="switchTab('assessments')">
        <div class="stat-icon"><i class="bi bi-x-circle"></i></div>
        <div class="stat-num"><%= rejectedCount %></div>
        <div class="stat-lbl">Rejected</div>
      </div>
    </div>

    <%-- Rejected / needs improvement feedback banner --%>
    <% if (assessments != null) { for (Assessment a : assessments) {
         if (("REJECTED".equals(a.getStatus()) || "NEEDS_IMPROVEMENT".equals(a.getStatus()))
             && a.getRemarks() != null && !a.getRemarks().isEmpty()) { %>
    <div style="background:var(--red-bg);border:1px solid var(--red-b);border-radius:var(--r);padding:14px 16px;margin-bottom:16px">
      <div style="font-size:13px;font-weight:800;color:var(--red);margin-bottom:6px">
        <%= a.getStatusLabel() %> — <%= a.getCourseCode() %>
      </div>
      <div style="font-size:13px;color:var(--ink2);line-height:1.6;margin-bottom:10px"><%= a.getRemarks() %></div>
      <div style="display:flex;gap:8px;flex-wrap:wrap">
        <a href="<%= ctx %>/LecturerReviewServlet?paperId=<%= a.getPaperId() %>"
           style="background:#b45309;color:#fff;font-weight:700;padding:6px 14px;border-radius:6px;text-decoration:none;font-size:12px">View Vetter Feedback</a>
        <a href="<%= ctx %>/<%= a.isContinuousAssessment() ? "AssignmentServlet" : "NewPaperServlet" %>?action=edit&paperId=<%= a.getPaperId() %>" class="btn btn-navy btn-sm">Revise Paper</a>
        <form method="post" action="<%= ctx %>/LecturerDashboardServlet" style="display:inline"
              onsubmit="return confirm('Submit this assessment to the Leader Vetter for final review and signature?')">
          <input type="hidden" name="action"  value="submitToLeader"/>
          <input type="hidden" name="paperId" value="<%= a.getPaperId() %>"/>
          <button type="submit" style="background:#d97706;color:#fff;font-weight:700;padding:6px 14px;border-radius:6px;font-size:12px;border:none;cursor:pointer">Submit to Leader</button>
        </form>
      </div>
    </div>
    <% break; } } } %>

    <%-- Recent papers table --%>
    <div class="sec-head">
      <h2>Recent Exam Papers</h2>
      <button class="btn btn-ghost btn-sm" onclick="switchTab('assessments')">View All</button>
    </div>
    <div class="tw">
      <table>
        <thead>
          <tr><th>Course</th><th>Type</th><th>Last Updated</th><th>Status</th><th></th></tr>
        </thead>
        <tbody>
        <% if (assessments == null || assessments.isEmpty()) { %>
          <tr><td colspan="5"><div class="empty"><p>No exam papers yet. Click <b>+ New Assessment</b> to start.</p></div></td></tr>
        <% } else { int shown = 0; for (Assessment a : assessments) { if (shown++ >= 5) break; %>
          <tr>
            <td>
              <div class="mono"><%= a.getCourseCode() %></div>
              <div style="font-weight:700;font-size:12px;margin-top:2px"><%= a.getCourseTitle() != null ? a.getCourseTitle() : "" %></div>
            </td>
            <td style="font-size:12px;color:var(--ink2)"><%= a.getPaperTypeLabel() %></td>
            <td class="mono">
              <% java.util.Date _disp2 = a.getUpdatedAt() != null ? a.getUpdatedAt() : a.getSubmittedDate(); %>
              <%= _disp2 != null ? new java.text.SimpleDateFormat("d MMM yyyy HH:mm").format(_disp2) : "—" %>
            </td>
            <td><span class="badge <%= a.getStatusClass() %>"><span class="bdot"></span><%= a.getStatusLabel() %></span></td>
            <td style="display:flex;gap:6px;align-items:center;flex-wrap:wrap">
              <% String _ast2 = a.getStatus() != null ? a.getStatus() : "";
                 if ("NEEDS_IMPROVEMENT".equals(_ast2) || "REJECTED".equals(_ast2) || "APPROVED".equals(_ast2) || "PENDING_LEADER_SIGN".equals(_ast2)) { %>
                <a href="<%= ctx %>/LecturerReviewServlet?paperId=<%= a.getPaperId() %>"
                   class="btn btn-sm"
                   style="background:<%= "NEEDS_IMPROVEMENT".equals(_ast2) ? "#b45309" : "REJECTED".equals(_ast2) ? "#be123c" : "#15803d" %>;color:#fff;font-weight:700;padding:5px 10px;border-radius:6px;text-decoration:none;font-size:12px;white-space:nowrap">
                  View Feedback
                </a>
              <% } %>
              <% if (a.isSubmittableToLeader()) { %>
                <form method="post" action="<%= ctx %>/LecturerDashboardServlet" style="display:inline"
                      onsubmit="return confirm('Submit this assessment to the Leader Vetter for final review and signature?')">
                  <input type="hidden" name="action"  value="submitToLeader"/>
                  <input type="hidden" name="paperId" value="<%= a.getPaperId() %>"/>
                  <button type="submit" class="btn btn-sm" style="background:#d97706;color:#fff;font-weight:700;padding:5px 10px;border-radius:6px;font-size:12px;border:none;cursor:pointer;white-space:nowrap">Submit to Leader</button>
                </form>
              <% } %>
              <% if (a.isEditable()) { %>
                <a href="<%= ctx %>/<%= a.isContinuousAssessment() ? "AssignmentServlet" : "NewPaperServlet" %>?action=edit&paperId=<%= a.getPaperId() %>" class="btn btn-navy btn-sm">Edit</a>
              <% } else { %>
                <a href="<%= ctx %>/<%= a.isContinuousAssessment() ? "AssignmentServlet" : "NewPaperServlet" %>?action=view&paperId=<%= a.getPaperId() %>" class="btn btn-ghost btn-sm">View</a>
              <% } %>
            </td>
          </tr>
        <% } } %>
        </tbody>
      </table>
    </div>
  </div>

  <%-- ════════════════════════════════════════════
       MY COURSES TAB
  ════════════════════════════════════════════ --%>
  
      </div>
      <div style="width: 320px;">
        <jsp:include page="calendarWidget.jsp"/>
      </div>
    </div>
<div class="page-section" id="page-courses">
    <div class="sec-head">
      <div><h2>Assigned Courses</h2><p>Assigned by Ketua Program.</p></div>
    </div>
    <% if (courses == null || courses.isEmpty()) { %>
      <div class="card"><div class="empty"><p>No courses assigned. Contact your Ketua Program.</p></div></div>
    <% } else { %>
    <div class="courses-grid">
      <% for (Course c : courses) { %>
      <div class="course-card">
        <div class="cc-top">
          <span class="cc-code"><%= c.getCourseCode() %></span>
          <span class="cc-cr"><%= c.getCredit() %> CR</span>
        </div>
        <div class="cc-name"><%= c.getCourseName() %></div>
        <div class="kv-grid">
          <div class="kv-item"><b>Credits</b><span><%= c.getCredit() %> CR</span></div>
          <div class="kv-item"><b>Exam</b><span><%= c.getExamHour() %> hrs</span></div>
          <div class="kv-item"><b>Core</b><span><%= c.getCore() != null ? c.getCore() : "—" %></span></div>
          <div class="kv-item"><b>Category</b><span><%= c.getCoCategory() != null ? c.getCoCategory() : "—" %></span></div>
          <div class="kv-item kv-full"><b>Department</b><span><%= c.getDepartment() != null ? c.getDepartment() : "—" %></span></div>
          <div class="kv-item"><b>Faculty</b><span><%= c.getFaculty() != null ? c.getFaculty() : "FSKM" %></span></div>
          <div class="kv-item"><b>Senate Ref</b><span><%= c.getSenateRef() != null ? c.getSenateRef() : "—" %></span></div>
        </div>
        <div style="font-size:11px;color:var(--muted);margin-bottom:10px">
          Vetter: <b style="color:var(--ink2)"><%= c.getVetterName() != null ? c.getVetterName() : "Not assigned" %></b>
        </div>
        <a href="<%= ctx %>/NewPaperServlet?action=new&courseCode=<%= c.getCourseCode() %>" class="btn btn-teal btn-sm" style="width:100%;justify-content:center">Create Assessment</a>
      </div>
      <% } %>
    </div>
    <% } %>
  </div>

  <%-- ════════════════════════════════════════════
       ASSESSMENTS TAB
  ════════════════════════════════════════════ --%>
  <div class="page-section" id="page-assessments">
    <div class="sec-head">
      <div><h2>My Assessments</h2><p>Final exams, assignments and group projects.</p></div>
      <button class="btn btn-teal" onclick="openModal('assessTypeModal')">+ New Assessment</button>
    </div>
    <div class="tw">
      <table>
        <thead>
          <tr><th>Course</th><th>Type</th><th>Session / Sem</th><th>Questions</th><th>Last Updated</th><th>Status</th><th>Remarks</th><th></th></tr>
        </thead>
        <tbody>
        <% if (assessments == null || assessments.isEmpty()) { %>
          <tr><td colspan="8"><div class="empty"><p>No papers yet. Click <b>+ New Assessment</b> to start.</p></div></td></tr>
        <% } else { for (Assessment a : assessments) { %>
          <tr>
            <td>
              <div class="mono"><%= a.getCourseCode() %></div>
              <div style="font-weight:700;font-size:12px;margin-top:2px"><%= a.getCourseTitle() != null ? a.getCourseTitle() : "" %></div>
            </td>
            <td style="font-size:12px"><%= a.getPaperTypeLabel() %></td>
            <td>
              <div style="font-size:12px;font-weight:600"><%= a.getAcademicSession() != null ? a.getAcademicSession() : "—" %></div>
              <div class="mono">Sem <%= a.getSemester() %></div>
            </td>
            <td style="font-weight:700"><%= a.getTotalQuestions() %></td>
            <td class="mono">
              <% java.util.Date _disp = a.getUpdatedAt() != null ? a.getUpdatedAt() : a.getSubmittedDate(); %>
              <%= _disp != null ? new java.text.SimpleDateFormat("d MMM yyyy HH:mm").format(_disp) : "—" %>
            </td>
            <td><span class="badge <%= a.getStatusClass() %>"><span class="bdot"></span><%= a.getStatusLabel() %></span></td>
            <td style="max-width:140px;font-size:12px;color:var(--red);font-style:italic">
              <% String rem = a.getRemarks(); %>
              <%= (rem != null && !rem.isEmpty()) ? (rem.length() > 55 ? rem.substring(0,55)+"…" : rem) : "—" %>
            </td>
            <td style="display:flex;gap:6px;align-items:center;flex-wrap:wrap">
              <a href="<%= ctx %>/SubmissionPackageServlet?paperId=<%= a.getPaperId() %>"
                 class="btn btn-sm" style="background:#6d28d9;color:#fff;font-weight:700;padding:5px 10px;border-radius:6px;text-decoration:none;font-size:12px;">Package</a>
              <% String _ast = a.getStatus() != null ? a.getStatus() : "";
                 if ("NEEDS_IMPROVEMENT".equals(_ast) || "REJECTED".equals(_ast) || "APPROVED".equals(_ast) || "PENDING_LEADER_SIGN".equals(_ast)) { %>
                <a href="<%= ctx %>/LecturerReviewServlet?paperId=<%= a.getPaperId() %>"
                   class="btn btn-sm"
                   style="background:<%= "NEEDS_IMPROVEMENT".equals(_ast) ? "#b45309" : "REJECTED".equals(_ast) ? "#be123c" : "#15803d" %>;color:#fff;font-weight:700;padding:5px 10px;border-radius:6px;text-decoration:none;font-size:12px;white-space:nowrap">
                  View Feedback
                </a>
              <% } %>
              <% if (a.isSubmittableToLeader()) { %>
                <form method="post" action="<%= ctx %>/LecturerDashboardServlet" style="display:inline"
                      onsubmit="return confirm('Submit this assessment to the Leader Vetter for final review and signature?')">
                  <input type="hidden" name="action"  value="submitToLeader"/>
                  <input type="hidden" name="paperId" value="<%= a.getPaperId() %>"/>
                  <button type="submit" class="btn btn-sm" style="background:#d97706;color:#fff;font-weight:700;padding:5px 10px;border-radius:6px;font-size:12px;border:none;cursor:pointer;white-space:nowrap">Submit to Leader</button>
                </form>
              <% } %>
              <% if (a.isEditable()) { %>
                <a href="<%= ctx %>/<%= a.isContinuousAssessment() ? "AssignmentServlet" : "NewPaperServlet" %>?action=edit&paperId=<%= a.getPaperId() %>" class="btn btn-navy btn-sm">Edit</a>
              <% } else { %>
                <a href="<%= ctx %>/<%= a.isContinuousAssessment() ? "AssignmentServlet" : "NewPaperServlet" %>?action=view&paperId=<%= a.getPaperId() %>" class="btn btn-ghost btn-sm">View</a>
              <% } %>
            </td>
          </tr>
        <% } } %>
        </tbody>
      </table>
    </div>
  </div>

  <%-- ════════════════════════════════════════════
       JSS TAB
  ════════════════════════════════════════════ --%>
  <div class="page-section" id="page-jss">
    <div class="sec-head">
      <div><h2>Jadual Spesifikasi Soalan (JSS)</h2><p>JSS is required alongside every final exam paper submission.</p></div>
    </div>
    <% if (courses == null || courses.isEmpty()) { %>
    <div class="card"><div class="empty"><p>No courses assigned yet.</p></div></div>
    <% } else { %>
    <div class="jss-grid">
      <% if (assessments != null) {
           for (Assessment a : assessments) {
      %>
      <div class="jss-card">
        <div class="mono" style="margin-bottom:3px"><%= a.getCourseCode() %></div>
        <div style="font-size:13px;font-weight:800;margin-bottom:8px;line-height:1.3">
          <%= (a.getCourseTitle() != null) ? a.getCourseTitle() : "Course Name" %>
        </div>
        <div style="font-size:11px;color:var(--muted);margin-bottom:10px">
          <b style="color:var(--ink2)"><%= a.getPaperTypeLabel() %></b>
          &nbsp;&middot;&nbsp;<span class="badge <%= a.getStatusClass() %>" style="font-size:10px;padding:1px 6px"><%= a.getStatusLabel() %></span>
        </div>
        <div style="display:flex;gap:7px;flex-wrap:wrap">
          <a href="<%= ctx %>/JSSServlet?paperId=<%= a.getPaperId() %>" class="btn btn-navy btn-sm">Open JSS</a>
        </div>
      </div>
      <%   }
         } %>
    </div>
    <% } %>
  </div>

</div><%-- end content --%>

<%-- ── ASSESSMENT TYPE MODAL ── --%>
<div class="modal" id="assessTypeModal">
  <div class="modal-box">
    <h3>What type of assessment?</h3>
    <p>Choose the category to open the right builder.</p>
    <div class="type-grid">
      <a href="<%= ctx %>/NewPaperServlet?action=new" class="type-card final">
        <div class="type-card-title">Final Assessment</div>
        <div class="type-card-sub">Final Exam · Supplementary Exam<br/>Full UMT bilingual exam paper with Section A/B/C</div>
      </a>
      <div class="type-card assign" onclick="toggleSubmenu()">
        <div class="type-card-title">Continuous Assessment</div>
        <div class="type-card-sub">Lab · Assignment · Project · Test<br/>Task instruction sheet with rubric</div>
      </div>
    </div>
    <div id="continuousSubmenu" style="display:none;margin-top:12px">
      <div style="font-size:11px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;margin-bottom:8px">Select Type</div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:6px">
        <% String[] contTypes = {"Lab Report","Lab Test","Group Assignment","Individual Assignment","Project","Practical Test"};
           for (String t : contTypes) { %>
        <a href="<%= ctx %>/AssignmentServlet?action=new&type=<%= java.net.URLEncoder.encode(t, "UTF-8") %>"
           style="display:flex;align-items:center;padding:8px 10px;border:1px solid var(--border);border-radius:7px;text-decoration:none;color:var(--ink);font-size:12px;font-weight:600;transition:.15s;background:var(--cream)"
           onmouseover="this.style.borderColor='var(--teal)';this.style.background='var(--teal-soft)'"
           onmouseout="this.style.borderColor='var(--border)';this.style.background='var(--cream)'">
          <%= t %>
        </a>
        <% } %>
      </div>
    </div>
    <button class="modal-cancel" onclick="closeModal('assessTypeModal');hideSubmenu()">Cancel</button>
  </div>
</div>

<div id="toast"></div>

<script>
const PAGE_META = {
  dashboard:   { title:'Dashboard',   sub:'Welcome back, <%= fullName %>!' },
  courses:     { title:'My Courses',  sub:'Courses assigned by Ketua Program.' },
  assessments: { title:'Assessments', sub:'Create and manage your assessments.' },
  jss:         { title:'JSS',         sub:'Jadual Spesifikasi Soalan for each course.' }
};
const tabs       = document.querySelectorAll('.tab[data-page]');
const sections   = document.querySelectorAll('.page-section');
const phTitle    = document.getElementById('phTitle');
const phSub      = document.getElementById('phSub');
const newPaperBtn = document.getElementById('newPaperBtn');

function switchTab(key) {
  tabs.forEach(function(b) { b.classList.toggle('active', b.dataset.page === key); });
  sections.forEach(function(s) { s.classList.remove('active'); });
  var t = document.getElementById('page-' + key);
  if (t) t.classList.add('active');
  var m = PAGE_META[key] || {};
  phTitle.textContent = m.title || key;
  phSub.textContent   = m.sub   || '';
  newPaperBtn.style.display = key === 'assessments' ? 'inline-flex' : 'none';
  var url = new URL(window.location.href);
  url.searchParams.set('page', key);
  window.history.replaceState({}, '', url);
}

tabs.forEach(function(b) { b.addEventListener('click', function() { switchTab(b.dataset.page); }); });
switchTab('<%= activePage %>');

function openModal(id)  { document.getElementById(id).classList.add('open'); }
function closeModal(id) { document.getElementById(id).classList.remove('open'); }
function toggleSubmenu() {
  var el = document.getElementById('continuousSubmenu');
  if (el) el.style.display = el.style.display === 'none' ? 'block' : 'none';
}
function hideSubmenu() {
  var el = document.getElementById('continuousSubmenu');
  if (el) el.style.display = 'none';
}
document.querySelectorAll('.modal').forEach(function(m) {
  m.addEventListener('click', function(e) { if (e.target === m) { closeModal(m.id); hideSubmenu(); } });
});
var _tt;
function showToast(msg) {
  var el = document.getElementById('toast');
  el.textContent = msg; el.classList.add('show');
  clearTimeout(_tt); _tt = setTimeout(function() { el.classList.remove('show'); }, 2500);
}
</script>
  <jsp:include page="footer.jsp"/>
</body>
</html>

