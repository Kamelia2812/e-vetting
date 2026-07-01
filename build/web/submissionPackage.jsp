<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Model.Assessment, Model.Question, Controller.SubmissionPackageServlet.PackageDoc" %>
<%@ page import="java.util.List" %>
<%
    /* ── Session guard ── */
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp"); return;
    }
    String fullName  = (String) sess.getAttribute("fullName");
    String role      = (String) sess.getAttribute("role");

    Assessment     paper      = (Assessment) request.getAttribute("paper");
    List<Question> questions  = (List<Question>) request.getAttribute("questions");
    PackageDoc     jssDoc        = (PackageDoc) request.getAttribute("jssDoc");
    PackageDoc     schemeDoc     = (PackageDoc) request.getAttribute("schemeDoc");
    PackageDoc     reserveJssDoc    = (PackageDoc) request.getAttribute("reserveJssDoc");
    PackageDoc     reserveSchemeDoc = (PackageDoc) request.getAttribute("reserveSchemeDoc");

    int     totalMarks   = request.getAttribute("totalMarks")   != null ? (int)  request.getAttribute("totalMarks")   : 0;
    Assessment reservePaper     = (Assessment)     request.getAttribute("reservePaper");
    List<Question> reserveQs    = (List<Question>) request.getAttribute("reserveQuestions");
    int reserveTotalMarks       = request.getAttribute("reserveTotalMarks") != null ? (int) request.getAttribute("reserveTotalMarks") : 0;
    boolean paperReady   = Boolean.TRUE.equals(request.getAttribute("paperReady"));
    boolean jssReady     = Boolean.TRUE.equals(request.getAttribute("jssReady"));
    boolean schemeReady  = Boolean.TRUE.equals(request.getAttribute("schemeReady"));
    boolean canSubmit    = Boolean.TRUE.equals(request.getAttribute("canSubmit"));
    boolean isVetterView = Boolean.TRUE.equals(request.getAttribute("isVetterView"));
    String  activeTab    = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "overview";

    int paperId      = paper != null ? paper.getPaperId() : 0;
    int questionCount = questions != null ? questions.size() : 0;
    String ctx = request.getContextPath();

    boolean submitted  = "true".equals(request.getParameter("submitted"));
    boolean savedOk    = "true".equals(request.getParameter("saved"));
    String  errorParam = request.getParameter("error");

    boolean paperEditable = paper != null && paper.isEditable();
    String  paperStatus   = paper != null ? paper.getStatus() : "";
    String  paperType     = paper != null ? paper.getPaperType() : "";
    // Final exams use Answer Scheme (model answers); continuous assessments use Rubric
    boolean isFinalExam   = paper != null && paper.isFinalAssessment();
    String  schemeTabLabel = isFinalExam ? "Answer Scheme" : "Rubric";

    // Count how many docs are complete (3 required documents)
    int completedDocs = (paperReady?1:0) + (jssReady?1:0) + (schemeReady?1:0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>Submission Package — <%= paper != null ? paper.getCourseCode() : "" %></title>
<style>
:root{
  --navy:#2a1454;--teal:#6d28d9;--teal-light:#f5f3ff;
  --blue:#2563eb;--blue-soft:#eff4ff;
  --green:#15803d;--green-bg:#f0fdf4;--green-b:#86efac;
  --amber:#b45309;--amber-bg:#fffbeb;--amber-b:#fcd34d;
  --red:#be123c;--red-bg:#fff1f2;--red-b:#fda4af;
  --slate-50:#f8fafc;--slate-100:#f1f5f9;--slate-200:#e2e8f0;
  --slate-400:#94a3b8;--slate-600:#475569;--slate-900:#0f172a;
  --surface:#fff;--cream:#f7f6fb;--border:#e4e9f0;
  --r:10px;--sh:0 1px 3px rgba(11,22,40,.06),0 4px 12px rgba(11,22,40,.06);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'Segoe UI',system-ui,sans-serif;background:var(--cream);color:var(--slate-900);font-size:14px;min-height:100vh;}

/* ── Topnav ── */
.topnav{background:var(--navy);position:sticky;top:0;z-index:100;height:58px;
        display:flex;align-items:center;padding:0 24px;gap:16px;}
.brand{font-size:15px;font-weight:800;color:#fff;text-decoration:none;display:flex;align-items:center;gap:9px;
       padding-right:20px;border-right:1px solid rgba(255,255,255,.1);flex-shrink:0;}
.brand-logo{width:34px;height:34px;object-fit:contain;border-radius:6px;}
.brand-name{font-size:13px;font-weight:800;color:#fff;}
.brand-sub{font-size:10px;color:rgba(255,255,255,.4);}
.nav-sep{width:1px;height:24px;background:rgba(255,255,255,.12);}
.nav-bc{display:flex;align-items:center;gap:6px;font-size:13px;color:rgba(255,255,255,.6);}
.nav-bc a{color:rgba(255,255,255,.6);text-decoration:none;}
.nav-bc a:hover{color:#fff;}
.nav-bc svg{width:14px;height:14px;}
.nav-right{margin-left:auto;display:flex;align-items:center;gap:10px;}
.nav-user-link{display:flex;align-items:center;gap:8px;text-decoration:none;border-radius:8px;padding:4px 8px;transition:.15s;}
.nav-user-link:hover{background:rgba(255,255,255,.07);}
.sp-uname{font-size:12px;font-weight:700;color:#fff;}
.sp-urole{font-size:10px;color:rgba(255,255,255,.4);}
.sp-avatar{width:32px;height:32px;border-radius:50%;background:var(--teal);color:#fff;display:grid;place-items:center;font-weight:800;font-size:12px;flex-shrink:0;}
.sp-logout{width:30px;height:30px;border-radius:50%;border:1px solid rgba(255,255,255,.15);background:none;color:rgba(255,255,255,.5);display:grid;place-items:center;text-decoration:none;transition:.15s;}
.sp-logout:hover{background:rgba(190,18,60,.25);color:#fda4af;}

/* ── Page layout ── */
.page{max-width:1100px;margin:0 auto;padding:24px 20px 60px;}

/* ── Paper header card ── */
.paper-hero{background:var(--navy);border-radius:var(--r);padding:24px 28px;
            display:flex;align-items:flex-start;justify-content:space-between;gap:16px;flex-wrap:wrap;
            margin-bottom:20px;}
.paper-hero-left h1{font-size:20px;font-weight:800;color:#fff;}
.paper-hero-left p{font-size:13px;color:rgba(255,255,255,.55);margin-top:4px;}
.paper-hero-meta{display:flex;gap:8px;flex-wrap:wrap;margin-top:12px;}
.hero-badge{padding:4px 12px;border-radius:20px;font-size:12px;font-weight:600;}
.hb-teal{background:rgba(91,33,182,.2);color:#5eead4;}
.hb-blue{background:rgba(37,99,235,.2);color:#93c5fd;}
.hb-amber{background:rgba(180,83,9,.25);color:#fbbf24;}
.hb-green{background:rgba(21,128,61,.2);color:#86efac;}
.hb-red  {background:rgba(190,18,60,.2);color:#fda4af;}

/* Progress ring area */
.hero-progress{display:flex;flex-direction:column;align-items:center;gap:4px;flex-shrink:0;}
.progress-ring-wrap{position:relative;width:80px;height:80px;}
.progress-ring-wrap svg{transform:rotate(-90deg);}
.ring-bg{fill:none;stroke:rgba(255,255,255,.12);stroke-width:8;}
.ring-fill{fill:none;stroke:var(--teal);stroke-width:8;stroke-linecap:round;
           stroke-dasharray:220;stroke-dashoffset:0;transition:stroke-dashoffset .4s;}
.ring-label{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;}
.ring-num{font-size:18px;font-weight:800;color:#fff;}
.ring-sub{font-size:10px;color:rgba(255,255,255,.5);}
.hero-progress p{font-size:11px;color:rgba(255,255,255,.5);}

/* ── Alerts ── */
.alert{padding:12px 18px;border-radius:8px;margin-bottom:16px;font-size:13px;}
.alert-success{background:var(--green-bg);color:var(--green);border:1px solid var(--green-b);}
.alert-error  {background:var(--red-bg);color:var(--red);border:1px solid var(--red-b);}

/* ── Tab bar ── */
.tab-bar{display:flex;gap:2px;background:var(--slate-100);border-radius:var(--r);
         padding:4px;margin-bottom:20px;flex-wrap:wrap;}
.tab-btn{flex:1;min-width:100px;padding:9px 14px;border-radius:7px;border:none;background:transparent;
         font-size:13px;font-weight:600;color:var(--slate-600);cursor:pointer;
         display:flex;align-items:center;justify-content:center;gap:6px;transition:all .15s;}
.tab-btn:hover{background:var(--surface);}
.tab-btn.active{background:var(--surface);color:var(--navy);box-shadow:var(--sh);}
.tab-dot{width:8px;height:8px;border-radius:50%;flex-shrink:0;}
.dot-green{background:var(--green);}
.dot-amber{background:#f59e0b;}
.dot-red  {background:var(--red);}

/* ── Tab panels ── */
.tab-panel{display:none;}
.tab-panel.active{display:block;}

/* ── Doc checklist cards ── */
.doc-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(240px,1fr));gap:16px;margin-bottom:24px;}
.doc-card{background:var(--surface);border-radius:var(--r);border:1px solid var(--border);
          padding:20px;display:flex;flex-direction:column;gap:12px;box-shadow:var(--sh);}
.doc-card.complete{border-left:4px solid var(--green);}
.doc-card.incomplete{border-left:4px solid #f59e0b;}
.doc-card.missing{border-left:4px solid var(--red);}
.doc-icon{width:44px;height:44px;border-radius:10px;display:grid;place-items:center;font-size:20px;flex-shrink:0;}
.doc-icon.ic-green{background:var(--green-bg);}
.doc-icon.ic-amber{background:var(--amber-bg);}
.doc-icon.ic-red  {background:var(--red-bg);}
.doc-name{font-size:14px;font-weight:700;color:var(--slate-900);}
.doc-status{font-size:12px;font-weight:600;}
.doc-status.ok  {color:var(--green);}
.doc-status.warn{color:#d97706;}
.doc-status.bad {color:var(--red);}
.doc-meta{font-size:12px;color:var(--slate-400);}
.doc-actions{display:flex;gap:8px;flex-wrap:wrap;margin-top:auto;}

/* ── Submit section ── */
.submit-box{background:var(--surface);border-radius:var(--r);border:1px solid var(--border);
            padding:24px;box-shadow:var(--sh);}
.submit-box h3{font-size:16px;font-weight:700;margin-bottom:8px;}
.submit-box p{font-size:13px;color:var(--slate-600);margin-bottom:18px;line-height:1.6;}
.submit-checklist{list-style:none;margin-bottom:20px;}
.submit-checklist li{display:flex;align-items:center;gap:10px;padding:8px 0;
                     border-bottom:1px solid var(--slate-100);font-size:13px;}
.submit-checklist li:last-child{border-bottom:none;}
.chk-icon{width:22px;height:22px;border-radius:50%;display:grid;place-items:center;font-size:11px;font-weight:700;flex-shrink:0;}
.chk-ok  {background:var(--green-bg);color:var(--green);}
.chk-warn{background:var(--amber-bg);color:#d97706;}
.chk-no  {background:var(--red-bg);color:var(--red);}

/* ── Question table ── */
.q-table{width:100%;border-collapse:collapse;font-size:13px;}
.q-table th{background:var(--navy);color:#fff;padding:9px 12px;text-align:left;font-size:12px;font-weight:600;}
.q-table td{padding:9px 12px;border-bottom:1px solid var(--slate-100);vertical-align:top;}
.q-table tr:hover td{background:var(--slate-50);}
.q-num{font-weight:700;color:var(--navy);width:40px;text-align:center;}
.q-text{max-width:380px;}
.q-text p{color:var(--slate-600);font-style:italic;font-size:12px;margin-top:3px;}
.badge-sm{padding:2px 8px;border-radius:12px;font-size:11px;font-weight:600;}
.b-obj{background:#dbeafe;color:#1d4ed8;}
.b-str{background:#fef3c7;color:#92400e;}
.b-ess{background:#f3e8ff;color:#6b21a8;}

/* ── Scheme table ── */
.scheme-table{width:100%;border-collapse:collapse;font-size:13px;}
.scheme-table th{background:#0f4c81;color:#fff;padding:8px 12px;font-size:12px;}
.scheme-table td{padding:8px 12px;border:1px solid var(--slate-200);vertical-align:top;}
.scheme-table tr:nth-child(even) td{background:var(--slate-50);}

/* ── Buttons ── */
.btn{display:inline-flex;align-items:center;gap:6px;padding:8px 18px;border-radius:7px;
     font-size:13px;font-weight:600;cursor:pointer;border:none;text-decoration:none;transition:all .15s;}
.btn-primary{background:var(--blue);color:#fff;}
.btn-primary:hover{background:#1d4ed8;}
.btn-success{background:var(--green);color:#fff;}
.btn-success:hover{background:#166534;}
.btn-teal{background:var(--teal);color:#fff;}
.btn-teal:hover{background:#4c1d95;}
.btn-ghost{background:transparent;color:var(--slate-600);border:1px solid var(--border);}
.btn-ghost:hover{background:var(--slate-100);}
.btn-disabled{background:var(--slate-100);color:var(--slate-400);cursor:not-allowed;pointer-events:none;}
.btn-lg{padding:12px 28px;font-size:15px;}

/* ── Section heading ── */
.sec-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;}
.sec-head h2{font-size:16px;font-weight:700;color:var(--slate-900);}
/* ── Two-paper layout ── */
.paper-section-head{display:flex;align-items:center;gap:12px;margin-bottom:14px;flex-wrap:wrap;}
.paper-section-head h2{font-size:15px;font-weight:700;color:var(--slate-900);flex:1;}
.paper-section-label{padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;white-space:nowrap;}
.main-label{background:rgba(91,33,182,.12);color:var(--teal);border:1px solid rgba(91,33,182,.25);}
.reserve-label{background:rgba(37,99,235,.1);color:var(--blue);border:1px solid rgba(37,99,235,.2);}
.paper-section-divider{border:none;border-top:2px dashed var(--border);margin:28px 0;}
.sec-subhead{font-size:12px;color:var(--slate-400);margin-top:2px;}

/* ── Info box ── */
.info-box{background:var(--blue-soft);border:1px solid #bfdbfe;border-radius:8px;
          padding:12px 16px;font-size:13px;color:#1e40af;margin-bottom:16px;}

/* ── FAP01 embed ── */
.embed-frame{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);
             padding:0;overflow:hidden;}
.embed-head{background:var(--navy);color:#fff;padding:14px 20px;font-size:13px;font-weight:700;
            display:flex;align-items:center;justify-content:space-between;}
.embed-body{padding:20px;}

/* ── JSS table ── */
.jss-table{width:100%;border-collapse:collapse;font-size:12px;}
.jss-table th{background:#1e3a5f;color:#fff;padding:7px 10px;font-size:11px;}
.jss-table td{padding:7px 10px;border:1px solid var(--slate-200);}
.jss-table tr:nth-child(even) td{background:var(--slate-50);}

/* ── Marks bar ── */
.marks-bar{height:8px;background:var(--slate-100);border-radius:4px;overflow:hidden;margin-top:4px;}
.marks-fill{height:100%;border-radius:4px;transition:width .3s;}
.mf-green{background:var(--green);}
.mf-amber{background:#f59e0b;}
.mf-red{background:var(--red);}

@media(max-width:680px){.doc-grid{grid-template-columns:1fr;}.paper-hero{flex-direction:column;}}
</style>
</head>
<body>

<%
  /* Initials for submissionPackage nav */
  String spInit = "U";
  if (fullName != null && !fullName.trim().isEmpty()) {
      String[] spP = fullName.trim().split("\\s+");
      int spS = (spP.length > 1 && spP[0].endsWith(".")) ? 1 : 0;
      StringBuilder spSb = new StringBuilder();
      for (int i = spS; i < spP.length && spSb.length() < 2; i++)
          spSb.append(Character.toUpperCase(spP[i].charAt(0)));
      if (spSb.length() > 0) spInit = spSb.toString();
  }
%>
<!-- ── Topnav ──────────────────────────────────────────────── -->
<nav class="topnav">
  <a class="brand" href="<%= isVetterView ? ctx+"/VetterDashboardServlet?page=dashboard" : ctx+"/LecturerDashboardServlet" %>">
    <img src="<%= ctx %>/images/umt-logo.png" alt="UMT Logo" class="brand-logo">
    <div><div class="brand-name">E-Vetting</div><div class="brand-sub">UMT</div></div>
  </a>
  <div class="nav-sep"></div>
  <div class="nav-bc">
    <% if (isVetterView) { %>
    <a href="<%= ctx %>/VetterDashboardServlet?page=queue">Vetting Queue</a>
    <% } else { %>
    <a href="<%= ctx %>/LecturerDashboardServlet?page=assessments">Assessments</a>
    <% } %>
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
    <span style="color:rgba(255,255,255,.85);">Submission Package</span>
  </div>
  <div class="nav-right">
    <a href="<%= ctx %>/UserProfileServlet" class="nav-user-link" title="My Profile">
      <div><div class="sp-uname"><%= fullName %></div><div class="sp-urole"><%= role %></div></div>
      <div class="sp-avatar"><%= spInit %></div>
    </a>
    <a href="<%= ctx %>/logout" class="sp-logout" title="Sign out">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" width="15" height="15"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
    </a>
  </div>
</nav>

<div class="page">

  <!-- ── Alerts ─────────────────────────────────────────────── -->
  <% if (submitted) { %>
  <div class="alert alert-success">✓ Package submitted successfully for vetting.</div>
  <% } else if (savedOk) { %>
  <div class="alert alert-success">✓ Changes saved.</div>
  <% } else if ("submit".equals(errorParam)) { %>
  <div class="alert alert-error">Submission failed — please ensure all required documents are complete and total marks = 100.</div>
  <% } %>

  <!-- ── Paper hero ──────────────────────────────────────────── -->
  <div class="paper-hero">
    <div class="paper-hero-left">
      <h1><%= paper.getCourseCode() %> — <%= paper.getCourseTitle() %></h1>
      <p>Submission Package &nbsp;·&nbsp; <%= paper.getPaperType() %></p>
      <div class="paper-hero-meta">
        <span class="hero-badge hb-teal"><%= paper.getAcademicSession() %> Sem <%= paper.getSemester() %></span>
        <span class="hero-badge hb-blue"><%= questionCount %> question<%= questionCount!=1?"s":"" %></span>
        <span class="hero-badge <%= totalMarks==100?"hb-green":totalMarks>0?"hb-amber":"hb-red" %>">
          <%= totalMarks %> / 100 marks
        </span>
        <span class="hero-badge <%= "SUBMITTED".equals(paperStatus)||"UNDER_REVIEW".equals(paperStatus)||"APPROVED".equals(paperStatus)?"hb-green":"NEEDS_IMPROVEMENT".equals(paperStatus)||"REJECTED".equals(paperStatus)?"hb-red":"hb-amber" %>">
          <%= paper.getStatusLabel() %>
        </span>
      </div>
      <%
        java.text.SimpleDateFormat tsFmt = new java.text.SimpleDateFormat("d MMM yyyy, h:mm a");
        if (paper.getCreatedAt() != null) {
      %>
      <div style="font-size:11px;color:rgba(255,255,255,.4);margin-top:8px;">
        Created: <%= tsFmt.format(paper.getCreatedAt()) %>
        <% if (paper.getSubmittedDate() != null) { %>
        &nbsp;&nbsp;|&nbsp;&nbsp; Submitted: <span style="color:#86efac;"><%= tsFmt.format(paper.getSubmittedDate()) %></span>
        <% } %>
        <% if (paper.getUpdatedAt() != null && !paper.getUpdatedAt().equals(paper.getCreatedAt())) { %>
        &nbsp;&nbsp;|&nbsp;&nbsp; Last updated: <%= tsFmt.format(paper.getUpdatedAt()) %>
        <% } %>
      </div>
      <% } %>
    </div>
    <!-- Completion ring -->
    <div class="hero-progress">
      <%
        int pct = completedDocs * 100 / 3; // 3 docs
        double offset = 220 - (220 * pct / 100.0);
      %>
      <div class="progress-ring-wrap">
        <svg width="80" height="80" viewBox="0 0 80 80">
          <circle class="ring-bg" cx="40" cy="40" r="35"/>
          <circle class="ring-fill" cx="40" cy="40" r="35"
                  style="stroke-dashoffset:<%= String.format("%.1f", offset) %>"/>
        </svg>
        <div class="ring-label">
          <span class="ring-num"><%= completedDocs %>/3</span>
          <span class="ring-sub">docs</span>
        </div>
      </div>
      <p>Package ready: <%= pct %>%</p>
    </div>
  </div>

  <!-- ── Tab bar ─────────────────────────────────────────────── -->
  <div class="tab-bar">
    <button class="tab-btn <%= "overview".equals(activeTab)?"active":"" %>" onclick="showTab('overview')">
      Overview
    </button>
    <button class="tab-btn <%= "paper".equals(activeTab)?"active":"" %>" onclick="showTab('paper')">
      <span class="tab-dot <%= paperReady?"dot-green":"dot-amber" %>"></span>
      Exam Paper
    </button>
    <button class="tab-btn <%= "jss".equals(activeTab)?"active":"" %>" onclick="showTab('jss')">
      <span class="tab-dot <%= jssReady?"dot-green":"dot-amber" %>"></span>
      JSS (FAP/02)
    </button>
    <button class="tab-btn <%= "scheme".equals(activeTab)?"active":"" %>" onclick="showTab('scheme')">
      <span class="tab-dot <%= schemeReady?"dot-green":"dot-amber" %>"></span>
      <%= schemeTabLabel %>
    </button>
  </div>

  <!-- ══════════════════════════════════════════════════════════
       TAB: OVERVIEW
       ══════════════════════════════════════════════════════════ -->
  <div id="tab-overview" class="tab-panel <%= "overview".equals(activeTab)?"active":"" %>">

    <!-- Document status cards -->
    <div class="doc-grid">

      <!-- 1. Exam Paper -->
      <div class="doc-card <%= paperReady?"complete":"incomplete" %>">
        <div style="display:flex;align-items:center;gap:12px;">
          <div class="doc-icon <%= paperReady?"ic-green":"ic-amber" %>"></div>
          <div>
            <div class="doc-name">Exam Paper</div>
            <div class="doc-status <%= paperReady?"ok":"warn" %>">
              <%= paperReady ? "✓ " + questionCount + " question(s)" : "No questions yet" %>
            </div>
          </div>
        </div>
        <div class="doc-meta">
          Total marks: <%= totalMarks %> / 100
          <div class="marks-bar"><div class="marks-fill <%= totalMarks==100?"mf-green":totalMarks>0?"mf-amber":"mf-red" %>"
               style="width:<%= Math.min(totalMarks,100) %>%"></div></div>
        </div>
        <div class="doc-actions">
          <% if (!isVetterView && paperEditable) { %>
          <a href="<%= ctx %>/NewPaperServlet?action=edit&paperId=<%= paperId %>"
             class="btn btn-ghost">Edit Paper</a>
          <% } %>
          <button class="btn btn-ghost" onclick="showTab('paper')">View</button>
        </div>
      </div>

      <!-- 2. JSS -->
      <div class="doc-card <%= jssReady?"complete":"incomplete" %>">
        <div style="display:flex;align-items:center;gap:12px;">
          <div class="doc-icon <%= jssReady?"ic-green":"ic-amber" %>"></div>
          <div>
            <div class="doc-name">JSS (FAP/02)</div>
            <div class="doc-status <%= jssReady?"ok":"warn" %>">
              <%= jssReady ? "✓ Completed" : "Not filled yet" %>
            </div>
          </div>
        </div>
        <div class="doc-meta">Jadual Spesifikasi Soalan</div>
        <div class="doc-actions">
          <% if (!isVetterView) { %>
          <a href="<%= ctx %>/JSSServlet?paperId=<%= paperId %>"
             class="btn <%= jssReady?"btn-ghost":"btn-teal" %>">
            <%= jssReady ? "Edit JSS" : "Fill JSS" %>
          </a>
          <% } %>
          <% if (jssReady) { %>
          <button class="btn btn-ghost" onclick="showTab('jss')">View</button>
          <% } %>
        </div>
      </div>

      <!-- 3. Answer Scheme / Rubric -->
      <div class="doc-card <%= schemeReady?"complete":"incomplete" %>">
        <div style="display:flex;align-items:center;gap:12px;">
          <div class="doc-icon <%= schemeReady?"ic-green":"ic-amber" %>"></div>
          <div>
            <div class="doc-name"><%= schemeTabLabel %></div>
            <div class="doc-status <%= schemeReady?"ok":"warn" %>">
              <%= schemeReady ? "✓ " + (schemeDoc.extraInfo != null ? schemeDoc.extraInfo : "Present") : "Not added yet" %>
            </div>
          </div>
        </div>
        <div class="doc-meta"><%= isFinalExam ? "Model answers per question" : "Marking criteria &amp; rubric rows" %></div>
        <div class="doc-actions">
          <% if (!isVetterView && paperEditable) { %>
          <a href="<%= ctx %>/NewPaperServlet?action=edit&paperId=<%= paperId %>"
             class="btn btn-ghost">Edit in Paper</a>
          <% } %>
          <% if (schemeReady) { %>
          <button class="btn btn-ghost" onclick="showTab('scheme')">View</button>
          <% } %>
        </div>
      </div>
    </div><!-- /doc-grid -->

    <!-- Submit box -->
    <div class="submit-box">
      <h3><%= isVetterView ? "Package Summary" : "Submit Package for Vetting" %></h3>
      <p>
        <% if (isVetterView) { %>
        All documents submitted by the lecturer for this assessment.
        Use the Review button to provide question-level feedback.
        <% } else if ("SUBMITTED".equals(paperStatus) || "UNDER_REVIEW".equals(paperStatus)) { %>
        This package has been submitted and is now under review. You can still view all documents.
        <% } else if ("APPROVED".equals(paperStatus)) { %>
        This package has been approved. No further changes are required.
        <% } else { %>
        Complete all required documents below, then submit the entire package for vetting in one step.
        The exam paper and JSS (marked ★) are required before submission.
        <% } %>
      </p>
      <ul class="submit-checklist">
        <li>
          <div class="chk-icon <%= paperReady && totalMarks==100 ? "chk-ok" : paperReady ? "chk-warn" : "chk-no" %>">
            <%= paperReady && totalMarks==100 ? "✓" : paperReady ? "!" : "✗" %>
          </div>
          <div>
            <strong>Exam Paper ★</strong>
            <div style="font-size:12px;color:var(--slate-400);">
              <%= paperReady ? questionCount + " questions, " + totalMarks + "/100 marks" : "No questions added" %>
              <% if (paperReady && totalMarks != 100) { %>&nbsp;— <span style="color:#d97706;">must equal 100</span><% } %>
            </div>
          </div>
        </li>
        <li>
          <div class="chk-icon <%= jssReady ? "chk-ok" : "chk-warn" %>">
            <%= jssReady ? "✓" : "!" %>
          </div>
          <div>
            <strong>JSS / FAP/02 ★</strong>
            <div style="font-size:12px;color:var(--slate-400);"><%= jssReady ? "Completed" : "Not filled — required for submission" %></div>
          </div>
        </li>
        <li>
          <div class="chk-icon <%= schemeReady ? "chk-ok" : "chk-warn" %>">
            <%= schemeReady ? "✓" : "○" %>
          </div>
          <div>
            <strong><%= schemeTabLabel %></strong>
            <div style="font-size:12px;color:var(--slate-400);">
              <%= schemeReady ? (schemeDoc.extraInfo != null ? schemeDoc.extraInfo : "Present") : "Recommended before submission" %>
            </div>
          </div>
        </li>
      </ul>

      <% if (!isVetterView && paperEditable) { %>
      <form method="post" action="<%= ctx %>/SubmissionPackageServlet"
            onsubmit="return confirm('Submit this complete package for vetting? This cannot be undone.');">
        <input type="hidden" name="paperId" value="<%= paperId %>"/>
        <input type="hidden" name="action"  value="submitPackage"/>
        <button type="submit" class="btn btn-success btn-lg <%= canSubmit ? "" : "btn-disabled" %>"
                <%= canSubmit ? "" : "disabled title='Complete the exam paper (100 marks) and JSS first'" %>>
          Submit Package for Vetting
        </button>
        <% if (!canSubmit) { %>
        <div style="font-size:12px;color:#d97706;margin-top:8px;">
          Note: Ensure exam paper has 100 total marks and JSS is completed before submitting.
        </div>
        <% } %>
      </form>
      <% } else if (isVetterView) { %>
      <a href="<%= ctx %>/VetterDashboardServlet?page=review&paperId=<%= paperId %>"
         class="btn btn-primary btn-lg">Go to Question Review</a>
      <% } %>
    </div>
  </div><!-- /tab-overview -->

  <!-- ══════════════════════════════════════════════════════════
       TAB: EXAM PAPER  (Main + Reserve)
       ══════════════════════════════════════════════════════════ -->
  <div id="tab-paper" class="tab-panel <%= "paper".equals(activeTab)?"active":"" %>">

    <%-- ── Main Paper ─────────────────────────────────────────── --%>
    <div class="paper-section-head">
      <div class="paper-section-label main-label">Main Paper</div>
      <div>
        <h2>Exam Paper Questions</h2>
        <div class="sec-subhead"><%= paper.getCourseCode() %> — <%= paper.getPaperType() %></div>
      </div>
      <% if (!isVetterView && paperEditable) { %>
      <a href="<%= ctx %>/NewPaperServlet?action=edit&paperId=<%= paperId %>"
         class="btn btn-primary">Edit Paper</a>
      <% } %>
    </div>
    <% if (questions == null || questions.isEmpty()) { %>
    <div class="info-box">No questions have been added to the main paper yet.</div>
    <% } else { %>
    <div style="overflow-x:auto;margin-bottom:28px;">
      <table class="q-table">
        <thead><tr>
          <th style="width:40px;text-align:center;">No.</th><th>Question</th>
          <th style="width:90px;">Type</th><th style="width:60px;text-align:center;">Marks</th>
          <th style="width:70px;">CLO</th><th style="width:50px;">Bloom</th>
          <th>Model Answer / Rubric</th>
        </tr></thead>
        <tbody>
          <% for (Question q : questions) {
               String typeCls = "STRUCTURE".equals(q.getQuestionType()) ? "b-str"
                              : "ESSAY".equals(q.getQuestionType()) ? "b-ess" : "b-obj"; %>
          <tr>
            <td class="q-num"><%= q.getQuestionNo() %></td>
            <td class="q-text">
              <%= q.getQuestionText() != null ? q.getQuestionText().replace("<","&lt;") : "—" %>
              <% if (q.getQuestionTextMs() != null && !q.getQuestionTextMs().trim().isEmpty()) { %>
              <p><em>BM: <%= q.getQuestionTextMs().replace("<","&lt;") %></em></p>
              <% } %>
              <% if (q.getParts() != null && !q.getParts().isEmpty()) { %>
              <div style="margin-top:8px; padding-left:12px; border-left:2px solid var(--slate-200);">
                <% for (Model.QuestionPart p : q.getParts()) { %>
                <div style="margin-bottom:4px; font-size:12px;">
                  <strong style="color:var(--slate-700);"><%= p.getPartLabel() %></strong>
                  <%= p.getPartQuestionText() != null ? p.getPartQuestionText().replace("<","&lt;") : "" %>
                  <span style="color:var(--slate-500);">[<%= p.getPartMarks() %>m]</span>
                </div>
                <% } %>
              </div>
              <% } %>
              <% if ("OBJECTIVE".equals(q.getQuestionType()) && q.getChoiceA() != null) { %>
              <div style="font-size:11px;color:var(--slate-400);margin-top:4px;line-height:1.8;">
                A: <%= q.getChoiceA() %><br/>B: <%= q.getChoiceB() %><br/>
                C: <%= q.getChoiceC() %><br/>D: <%= q.getChoiceD() %>
              </div>
              <% if (q.getCorrectAnswer() != null) { %>
              <div style="font-size:11px;font-weight:700;color:var(--green);margin-top:2px;">Answer: <%= q.getCorrectAnswer() %></div>
              <% } } %>
            </td>
            <td><span class="badge-sm <%= typeCls %>"><%= q.getQuestionType() %></span></td>
            <td style="text-align:center;font-weight:700;"><%= q.getMarks() %></td>
            <td style="font-size:12px;"><%= q.getCloMapping() %></td>
            <td style="font-size:12px;"><%= q.getTaxonomyLevel() %></td>
            <td style="font-size:12px;color:var(--slate-600);max-width:220px;">
              <%= q.getModelAnswer() != null && !q.getModelAnswer().isEmpty()
                  ? q.getModelAnswer().replace("<","&lt;") : "<em style='color:var(--slate-400);'>—</em>" %>
            </td>
          </tr>
          <% } %>
        </tbody>
        <tfoot><tr style="background:var(--slate-50);">
          <td colspan="3" style="padding:10px 12px;font-weight:700;">Total</td>
          <td style="text-align:center;font-weight:800;color:<%= totalMarks==100?"var(--green)":"var(--red)" %>;">
            <%= totalMarks %></td>
          <td colspan="3"></td>
        </tr></tfoot>
      </table>
    </div>
    <% } %>

    <%-- ── Reserve / Alternative Paper ────────────────────────── --%>
    <div class="paper-section-divider"></div>
    <div class="paper-section-head">
      <div class="paper-section-label reserve-label">Reserve / Alternative Paper</div>
      <% if (reservePaper != null) { %>
      <div>
        <h2>Reserve Paper Questions</h2>
        <div class="sec-subhead"><%= reservePaper.getCourseCode() %> — <%= reservePaper.getPaperType() %></div>
      </div>
      <% if (!isVetterView) { %>
      <a href="<%= ctx %>/SubmissionPackageServlet?paperId=<%= reservePaper.getPaperId() %>&tab=paper"
         class="btn btn-ghost">View Reserve Package</a>
      <% } %>
      <% } else { %>
      <div>
        <h2>Reserve Paper</h2>
        <div class="sec-subhead">No reserve paper linked yet</div>
      </div>
      <% } %>
    </div>
    <% if (reservePaper == null) { %>
    <div class="info-box">
      No reserve/alternative paper has been created for this assessment yet.
      <% if (!isVetterView) { %>
      Create a second exam paper with the same course code and academic session to link it automatically.
      <% } %>
    </div>
    <% } else if (reserveQs == null || reserveQs.isEmpty()) { %>
    <div class="info-box">Reserve paper exists but has no questions yet.</div>
    <% } else { %>
    <div style="overflow-x:auto;">
      <table class="q-table">
        <thead><tr>
          <th style="width:40px;text-align:center;">No.</th><th>Question</th>
          <th style="width:90px;">Type</th><th style="width:60px;text-align:center;">Marks</th>
          <th style="width:70px;">CLO</th><th style="width:50px;">Bloom</th>
          <th>Model Answer / Rubric</th>
        </tr></thead>
        <tbody>
          <% for (Question rq : reserveQs) {
               String rtCls = "STRUCTURE".equals(rq.getQuestionType()) ? "b-str"
                            : "ESSAY".equals(rq.getQuestionType()) ? "b-ess" : "b-obj"; %>
          <tr>
            <td class="q-num"><%= rq.getQuestionNo() %></td>
            <td class="q-text">
              <%= rq.getQuestionText() != null ? rq.getQuestionText().replace("<","&lt;") : "—" %>
              <% if (rq.getQuestionTextMs() != null && !rq.getQuestionTextMs().trim().isEmpty()) { %>
              <p><em>BM: <%= rq.getQuestionTextMs().replace("<","&lt;") %></em></p>
              <% } %>
              <% if (rq.getParts() != null && !rq.getParts().isEmpty()) { %>
              <div style="margin-top:8px; padding-left:12px; border-left:2px solid var(--slate-200);">
                <% for (Model.QuestionPart p : rq.getParts()) { %>
                <div style="margin-bottom:4px; font-size:12px;">
                  <strong style="color:var(--slate-700);"><%= p.getPartLabel() %></strong>
                  <%= p.getPartQuestionText() != null ? p.getPartQuestionText().replace("<","&lt;") : "" %>
                  <span style="color:var(--slate-500);">[<%= p.getPartMarks() %>m]</span>
                </div>
                <% } %>
              </div>
              <% } %>
            </td>
            <td><span class="badge-sm <%= rtCls %>"><%= rq.getQuestionType() %></span></td>
            <td style="text-align:center;font-weight:700;"><%= rq.getMarks() %></td>
            <td style="font-size:12px;"><%= rq.getCloMapping() %></td>
            <td style="font-size:12px;"><%= rq.getTaxonomyLevel() %></td>
            <td style="font-size:12px;color:var(--slate-600);max-width:220px;">
              <%= rq.getModelAnswer() != null && !rq.getModelAnswer().isEmpty()
                  ? rq.getModelAnswer().replace("<","&lt;") : "<em style='color:var(--slate-400);'>—</em>" %>
            </td>
          </tr>
          <% } %>
        </tbody>
        <tfoot><tr style="background:var(--slate-50);">
          <td colspan="3" style="padding:10px 12px;font-weight:700;">Total</td>
          <td style="text-align:center;font-weight:800;color:<%= reserveTotalMarks==100?"var(--green)":"var(--red)" %>;">
            <%= reserveTotalMarks %></td>
          <td colspan="3"></td>
        </tr></tfoot>
      </table>
    </div>
    <% } %>

  </div><!-- /tab-paper -->

  <!-- ══════════════════════════════════════════════════════════
       TAB: JSS
       ══════════════════════════════════════════════════════════ -->
  <div id="tab-jss" class="tab-panel <%= "jss".equals(activeTab)?"active":"" %>">

    <%-- ── Main Paper JSS ─────────────────────────────────────────── --%>
    <div class="paper-section-head">
      <div class="paper-section-label main-label">Main Paper</div>
      <div>
        <h2>JSS — Jadual Spesifikasi Soalan (FAP/02)</h2>
        <div class="sec-subhead"><%= paper.getCourseCode() %> — Question Specification Table</div>
      </div>
      <a href="<%= ctx %>/JSSServlet?paperId=<%= paperId %>"
         class="btn <%= jssReady ? "btn-ghost" : "btn-teal" %>">
        <%= jssReady ? "Edit JSS" : "Fill JSS" %>
      </a>
    </div>
    <% if (!jssReady) { %>
    <div class="info-box">JSS has not been filled yet for the main paper. Click "Fill JSS" to complete it.</div>
    <% } else { %>
    <div class="info-box">
      JSS is complete. <a href="<%= ctx %>/JSSServlet?paperId=<%= paperId %>" style="color:#1d4ed8;font-weight:600;">Open full JSS page →</a>
    </div>
    <div style="overflow-x:auto;margin-bottom:8px;">
      <table class="jss-table">
        <thead><tr>
          <th>Topic / Tajuk</th><th>Lecture Hours</th><th>Q No.</th>
          <th>PLO</th><th>CLO</th><th>Type</th><th>Marks</th><th>Taxonomy</th>
        </tr></thead>
        <tbody>
          <%
            try (java.sql.Connection jcon = util.DBConnection.getConnection()) {
              java.sql.PreparedStatement jps = jcon.prepareStatement(
                "SELECT jr.* FROM jss_rows jr JOIN jss j ON jr.jss_id=j.jss_id WHERE j.paper_id=? ORDER BY jr.row_order");
              jps.setInt(1, paperId);
              java.sql.ResultSet jrs = jps.executeQuery();
              boolean hasRows = false;
              while (jrs.next()) { hasRows = true; %>
          <tr>
            <td><%= jrs.getString("topic_name")    != null ? jrs.getString("topic_name")    : "—" %></td>
            <td style="text-align:center;"><%= jrs.getObject("lecture_hours") != null ? jrs.getObject("lecture_hours") : "—" %></td>
            <td style="text-align:center;"><%= jrs.getString("question_no")   != null ? jrs.getString("question_no")   : "—" %></td>
            <td style="text-align:center;"><%= jrs.getString("plo")           != null ? jrs.getString("plo")           : "—" %></td>
            <td style="text-align:center;"><%= jrs.getString("clo")           != null ? jrs.getString("clo")           : "—" %></td>
            <td style="text-align:center;"><%= jrs.getString("question_type") != null ? jrs.getString("question_type") : "—" %></td>
            <td style="text-align:center;font-weight:700;"><%= jrs.getObject("marks") != null ? jrs.getObject("marks") : "—" %></td>
            <td style="text-align:center;"><%= jrs.getString("taxonomy_level")!= null ? jrs.getString("taxonomy_level"): "—" %></td>
          </tr>
          <% } if (!hasRows) { %>
          <tr><td colspan="8" style="text-align:center;color:var(--slate-400);padding:16px;">No JSS rows found.</td></tr>
          <% } jrs.close(); jps.close(); } catch(Exception ex) { ex.printStackTrace(); } %>
        </tbody>
      </table>
    </div>
    <% } %>

    <%-- ── Reserve Paper JSS ──────────────────────────────────────── --%>
    <div class="paper-section-divider"></div>
    <div class="paper-section-head">
      <div class="paper-section-label reserve-label">Reserve / Alternative Paper</div>
      <% if (reservePaper != null) { %>
      <div>
        <h2>JSS — Reserve Paper</h2>
        <div class="sec-subhead"><%= reservePaper.getCourseCode() %> — Question Specification Table</div>
      </div>
      <% if (!isVetterView) { %>
      <a href="<%= ctx %>/JSSServlet?paperId=<%= reservePaper.getPaperId() %>"
         class="btn <%= reserveJssDoc != null && reserveJssDoc.exists ? "btn-ghost" : "btn-teal" %>">
        <%= reserveJssDoc != null && reserveJssDoc.exists ? "Edit JSS" : "Fill JSS" %>
      </a>
      <% } %>
      <% } else { %>
      <div><h2>Reserve Paper JSS</h2><div class="sec-subhead">No reserve paper linked</div></div>
      <% } %>
    </div>
    <% if (reservePaper == null) { %>
    <div class="info-box">No reserve paper linked — JSS not available.</div>
    <% } else if (reserveJssDoc == null || !reserveJssDoc.exists) { %>
    <div class="info-box">
      JSS not filled for the reserve paper yet.
      <% if (!isVetterView) { %>
      <a href="<%= ctx %>/JSSServlet?paperId=<%= reservePaper.getPaperId() %>" style="color:#1d4ed8;font-weight:600;">Fill it now →</a>
      <% } %>
    </div>
    <% } else { %>
    <div class="info-box">
      Reserve JSS is complete. <a href="<%= ctx %>/JSSServlet?paperId=<%= reservePaper.getPaperId() %>" style="color:#1d4ed8;font-weight:600;">Open full JSS page →</a>
    </div>
    <div style="overflow-x:auto;">
      <table class="jss-table">
        <thead><tr>
          <th>Topic / Tajuk</th><th>Lecture Hours</th><th>Q No.</th>
          <th>PLO</th><th>CLO</th><th>Type</th><th>Marks</th><th>Taxonomy</th>
        </tr></thead>
        <tbody>
          <%
            int rJssPaperId = reservePaper.getPaperId();
            try (java.sql.Connection rjcon = util.DBConnection.getConnection()) {
              java.sql.PreparedStatement rjps = rjcon.prepareStatement(
                "SELECT jr.* FROM jss_rows jr JOIN jss j ON jr.jss_id=j.jss_id WHERE j.paper_id=? ORDER BY jr.row_order");
              rjps.setInt(1, rJssPaperId);
              java.sql.ResultSet rjrs = rjps.executeQuery();
              boolean rHasRows = false;
              while (rjrs.next()) { rHasRows = true; %>
          <tr>
            <td><%= rjrs.getString("topic_name")    != null ? rjrs.getString("topic_name")    : "—" %></td>
            <td style="text-align:center;"><%= rjrs.getObject("lecture_hours") != null ? rjrs.getObject("lecture_hours") : "—" %></td>
            <td style="text-align:center;"><%= rjrs.getString("question_no")   != null ? rjrs.getString("question_no")   : "—" %></td>
            <td style="text-align:center;"><%= rjrs.getString("plo")           != null ? rjrs.getString("plo")           : "—" %></td>
            <td style="text-align:center;"><%= rjrs.getString("clo")           != null ? rjrs.getString("clo")           : "—" %></td>
            <td style="text-align:center;"><%= rjrs.getString("question_type") != null ? rjrs.getString("question_type") : "—" %></td>
            <td style="text-align:center;font-weight:700;"><%= rjrs.getObject("marks") != null ? rjrs.getObject("marks") : "—" %></td>
            <td style="text-align:center;"><%= rjrs.getString("taxonomy_level")!= null ? rjrs.getString("taxonomy_level"): "—" %></td>
          </tr>
          <% } if (!rHasRows) { %>
          <tr><td colspan="8" style="text-align:center;color:var(--slate-400);padding:16px;">No JSS rows found.</td></tr>
          <% } rjrs.close(); rjps.close(); } catch(Exception ex) { ex.printStackTrace(); } %>
        </tbody>
      </table>
    </div>
    <% } %>
  </div><!-- /tab-jss -->

  <!-- ══════════════════════════════════════════════════════════
       TAB: ANSWER SCHEME / RUBRIC
       ══════════════════════════════════════════════════════════ -->
  <div id="tab-scheme" class="tab-panel <%= "scheme".equals(activeTab)?"active":"" %>">

    <%-- ── Main Paper Scheme ──────────────────────────────────────── --%>
    <div class="paper-section-head">
      <div class="paper-section-label main-label">Main Paper</div>
      <div>
        <h2><%= schemeTabLabel %></h2>
        <div class="sec-subhead"><%= paper.getCourseCode() %> — <%= isFinalExam ? "Model answers per question" : "Marking criteria and rubric rows" %></div>
      </div>
      <% if (!isVetterView && paperEditable) { %>
      <a href="<%= ctx %>/NewPaperServlet?action=edit&paperId=<%= paperId %>"
         class="btn btn-ghost">Edit in Paper Builder</a>
      <% } %>
    </div>
    <% if (isFinalExam) {
         // ── Final exam: show model answers only ──────────────────────
         boolean anyModelAnswers = false;
         if (questions != null) {
           for (Question q : questions) {
             if (q.getModelAnswer() != null && !q.getModelAnswer().trim().isEmpty()) {
               anyModelAnswers = true; break;
             }
           }
         }
         if (anyModelAnswers) { %>
    <table class="scheme-table" style="margin-bottom:24px;">
      <thead><tr><th style="width:50px;">No.</th><th>Question</th><th>Model Answer</th><th style="width:60px;">Marks</th></tr></thead>
      <tbody>
        <% for (Question q : questions) {
           if (q.getModelAnswer() == null || q.getModelAnswer().trim().isEmpty()) continue; %>
        <tr>
          <td style="text-align:center;font-weight:700;"><%= q.getQuestionNo() %></td>
          <td style="font-size:12px;color:var(--slate-600);">
            <%= q.getQuestionText() != null ? q.getQuestionText().substring(0, Math.min(q.getQuestionText().length(), 80)).replace("<","&lt;") : "—" %>...
          </td>
          <td>
            <% if (q.getParts() != null && !q.getParts().isEmpty()) {
                 for (Model.QuestionPart p : q.getParts()) { %>
                   <div style="margin-bottom:4px;">
                     <strong><%= p.getPartLabel() %>:</strong>
                     <%= p.getModelAnswer() != null ? p.getModelAnswer().replace("<","&lt;").replace("\n","<br/>") : "" %>
                   </div>
            <%   }
               } else { %>
                 <%= q.getModelAnswer().replace("<","&lt;").replace("\n","<br/>") %>
            <% } %>
          </td>
          <td style="text-align:center;font-weight:700;"><%= q.getMarks() %></td>
        </tr>
        <% } %>
      </tbody>
    </table>
    <% } if (!anyModelAnswers) { %>
    <div class="info-box">
      No model answers have been added yet.
      <% if (!isVetterView && paperEditable) { %>
      Add them in the <a href="<%= ctx %>/NewPaperServlet?action=edit&paperId=<%= paperId %>" style="color:#1d4ed8;font-weight:600;">Paper Builder</a>.
      <% } %>
    </div>
    <% }
       } else {
         // ── Continuous assessment: show rubric only ──────────────────
         boolean hasRubric = false;
         try (java.sql.Connection rcon = util.DBConnection.getConnection()) {
           java.sql.PreparedStatement rps = rcon.prepareStatement(
             "SELECT * FROM rubric_rows WHERE paper_id=? ORDER BY row_order");
           rps.setInt(1, paperId);
           java.sql.ResultSet rrs = rps.executeQuery();
           if (rrs.next()) { hasRubric = true; %>
    <table class="scheme-table" style="margin-bottom:8px;">
      <thead><tr><th style="width:40px;">No.</th><th>Criterion</th><th style="width:60px;">Marks</th><th style="width:60px;">CLO</th><th style="width:60px;">Bloom</th><th>Description</th></tr></thead>
      <tbody>
        <% int rrow=1; do { %>
        <tr>
          <td style="text-align:center;font-weight:700;"><%= rrow++ %></td>
          <td><%= rrs.getString("criterion") != null ? rrs.getString("criterion").replace("<","&lt;") : "—" %></td>
          <td style="text-align:center;font-weight:700;"><%= rrs.getInt("marks") %></td>
          <td style="text-align:center;"><%= rrs.getString("clo")   != null ? rrs.getString("clo")   : "—" %></td>
          <td style="text-align:center;"><%= rrs.getString("bloom") != null ? rrs.getString("bloom") : "—" %></td>
          <td style="font-size:12px;color:var(--slate-600);">
            <%= rrs.getString("description") != null ? rrs.getString("description").replace("<","&lt;").replace("\n","<br/>") : "—" %>
          </td>
        </tr>
        <% } while(rrs.next()); rrs.close(); rps.close(); %>
      </tbody>
    </table>
    <% } else { rrs.close(); rps.close(); } } catch(Exception ex){ ex.printStackTrace(); } %>
    <% if (!hasRubric) { %>
    <div class="info-box">
      No rubric has been added yet.
      <% if (!isVetterView && paperEditable) { %>
      Add it in the <a href="<%= ctx %>/NewPaperServlet?action=edit&paperId=<%= paperId %>" style="color:#1d4ed8;font-weight:600;">Paper Builder</a>.
      <% } %>
    </div>
    <% } } /* end else (continuous assessment) */ %>

    <%-- ── Reserve Paper Scheme ───────────────────────────────────── --%>
    <div class="paper-section-divider"></div>
    <div class="paper-section-head">
      <div class="paper-section-label reserve-label">Reserve / Alternative Paper</div>
      <% if (reservePaper != null) { %>
      <div>
        <h2><%= schemeTabLabel %> — Reserve Paper</h2>
        <div class="sec-subhead"><%= reservePaper.getCourseCode() %></div>
      </div>
      <% if (!isVetterView) { %>
      <a href="<%= ctx %>/NewPaperServlet?action=edit&paperId=<%= reservePaper.getPaperId() %>"
         class="btn btn-ghost">Edit in Paper Builder</a>
      <% } %>
      <% } else { %>
      <div><h2>Reserve Paper Scheme</h2><div class="sec-subhead">No reserve paper linked</div></div>
      <% } %>
    </div>
    <% if (reservePaper == null) { %>
    <div class="info-box">No reserve paper linked — <%= schemeTabLabel.toLowerCase() %> not available.</div>
    <% } else if (isFinalExam) {
        // ── Final exam reserve: model answers ──────────────────────
        boolean rAnyModelAnswers = false;
        if (reserveQs != null) {
          for (Question rq2 : reserveQs) {
            if (rq2.getModelAnswer() != null && !rq2.getModelAnswer().trim().isEmpty()) {
              rAnyModelAnswers = true; break;
            }
          }
        }
        if (rAnyModelAnswers) { %>
    <table class="scheme-table" style="margin-bottom:24px;">
      <thead><tr><th style="width:50px;">No.</th><th>Question</th><th>Model Answer</th><th style="width:60px;">Marks</th></tr></thead>
      <tbody>
        <% for (Question rq2 : reserveQs) {
           if (rq2.getModelAnswer() == null || rq2.getModelAnswer().trim().isEmpty()) continue; %>
        <tr>
          <td style="text-align:center;font-weight:700;"><%= rq2.getQuestionNo() %></td>
          <td style="font-size:12px;color:var(--slate-600);">
            <%= rq2.getQuestionText() != null ? rq2.getQuestionText().substring(0, Math.min(rq2.getQuestionText().length(), 80)).replace("<","&lt;") : "—" %>...
          </td>
          <td><%= rq2.getModelAnswer().replace("<","&lt;").replace("\n","<br/>") %></td>
          <td style="text-align:center;font-weight:700;"><%= rq2.getMarks() %></td>
        </tr>
        <% } %>
      </tbody>
    </table>
    <% } if (!rAnyModelAnswers) { %>
    <div class="info-box">
      No model answers for the reserve paper yet.
      <% if (!isVetterView) { %>
      Add them in the <a href="<%= ctx %>/NewPaperServlet?action=edit&paperId=<%= reservePaper.getPaperId() %>" style="color:#1d4ed8;font-weight:600;">Paper Builder</a>.
      <% } %>
    </div>
    <% }
       } else {
        // ── Continuous assessment reserve: rubric ───────────────────
        boolean rHasRubric = false;
        int rPid = reservePaper.getPaperId();
        try (java.sql.Connection rc2 = util.DBConnection.getConnection()) {
          java.sql.PreparedStatement rp2 = rc2.prepareStatement(
            "SELECT * FROM rubric_rows WHERE paper_id=? ORDER BY row_order");
          rp2.setInt(1, rPid);
          java.sql.ResultSet rr2 = rp2.executeQuery();
          if (rr2.next()) { rHasRubric = true; %>
    <table class="scheme-table" style="margin-bottom:8px;">
      <thead><tr><th style="width:40px;">No.</th><th>Criterion</th><th style="width:60px;">Marks</th><th style="width:60px;">CLO</th><th style="width:60px;">Bloom</th><th>Description</th></tr></thead>
      <tbody>
        <% int rrow2=1; do { %>
        <tr>
          <td style="text-align:center;font-weight:700;"><%= rrow2++ %></td>
          <td><%= rr2.getString("criterion") != null ? rr2.getString("criterion").replace("<","&lt;") : "—" %></td>
          <td style="text-align:center;font-weight:700;"><%= rr2.getInt("marks") %></td>
          <td style="text-align:center;"><%= rr2.getString("clo")   != null ? rr2.getString("clo")   : "—" %></td>
          <td style="text-align:center;"><%= rr2.getString("bloom") != null ? rr2.getString("bloom") : "—" %></td>
          <td style="font-size:12px;color:var(--slate-600);">
            <%= rr2.getString("description") != null ? rr2.getString("description").replace("<","&lt;").replace("\n","<br/>") : "—" %>
          </td>
        </tr>
        <% } while(rr2.next()); rr2.close(); rp2.close(); %>
      </tbody>
    </table>
    <% } else { rr2.close(); rp2.close(); } } catch(Exception ex2){ ex2.printStackTrace(); } %>
    <% if (!rHasRubric) { %>
    <div class="info-box">
      No rubric for the reserve paper yet.
      <% if (!isVetterView) { %>
      Add it in the <a href="<%= ctx %>/NewPaperServlet?action=edit&paperId=<%= reservePaper.getPaperId() %>" style="color:#1d4ed8;font-weight:600;">Paper Builder</a>.
      <% } %>
    </div>
    <% } } %>
  </div><!-- /tab-scheme -->

</div><!-- /page -->

<script>
function showTab(name) {
  document.querySelectorAll('.tab-panel').forEach(function(p){ p.classList.remove('active'); });
  document.querySelectorAll('.tab-btn').forEach(function(b){ b.classList.remove('active'); });
  var panel = document.getElementById('tab-' + name);
  if (panel) panel.classList.add('active');
  // find the button by onclick content
  document.querySelectorAll('.tab-btn').forEach(function(b){
    if (b.getAttribute('onclick') === "showTab('" + name + "')") b.classList.add('active');
  });
}
// Deep-link via URL hash
(function(){
  var hash = window.location.hash.replace('#','');
  if (hash) showTab(hash);
})();
</script>
</body>
</html>

