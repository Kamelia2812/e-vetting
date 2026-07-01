<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Model.Assessment, Model.Question, Model.QuestionComment, Model.User" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp"); return;
    }
    int    myId       = (int) sess.getAttribute("userId");
    String myName     = (String) sess.getAttribute("fullName");
    String myRole     = (String) sess.getAttribute("role");
    String ctx        = request.getContextPath();

    Assessment     paper    = (Assessment)     request.getAttribute("paper");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    Map<Integer,List<QuestionComment>> commentMap =
        (Map<Integer,List<QuestionComment>>) request.getAttribute("commentMap");
    List<User>   assignedVetters = (List<User>) request.getAttribute("assignedVetters");
    List<Map<String,Object>> jssComments    = (List<Map<String,Object>>) request.getAttribute("jssComments");
    List<Map<String,Object>> schemeComments = (List<Map<String,Object>>) request.getAttribute("schemeComments");

    int approvedCount = request.getAttribute("approvedCount") != null ? (int) request.getAttribute("approvedCount") : 0;
    int needsRevCount = request.getAttribute("needsRevCount") != null ? (int) request.getAttribute("needsRevCount") : 0;
    int rejectedCount = request.getAttribute("rejectedCount") != null ? (int) request.getAttribute("rejectedCount") : 0;
    int pendingCount  = request.getAttribute("pendingCount")  != null ? (int) request.getAttribute("pendingCount")  : 0;
    boolean isLeaderVetter = Boolean.TRUE.equals(request.getAttribute("isLeaderVetter"));
    @SuppressWarnings("unchecked")
    java.util.Map<String,java.util.Map<String,Object>> myChecklist =
        (java.util.Map<String,java.util.Map<String,Object>>) request.getAttribute("myChecklist");

    if (paper == null) { response.sendRedirect(ctx + "/VetterDashboardServlet?page=queue"); return; }

    int    paperId     = paper.getPaperId();
    int    totalQs     = questions != null ? questions.size() : 0;
    boolean isFinal    = paper.isFinalAssessment();
    String schemeLabel = isFinal ? "Answer Scheme" : "Rubric";

    // Initials helper for nav
    String navInit = "V";
    if (myName != null && !myName.trim().isEmpty()) {
        String[] np = myName.trim().split("\\s+");
        int ns = (np.length > 1 && np[0].endsWith(".")) ? 1 : 0;
        StringBuilder nsb = new StringBuilder();
        for (int i = ns; i < np.length && nsb.length() < 2; i++)
            nsb.append(Character.toUpperCase(np[i].charAt(0)));
        if (nsb.length() > 0) navInit = nsb.toString();
    }

    String savedSection = request.getParameter("saved");
    String errorParam   = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>Review — <%= paper.getCourseCode() %></title>
<style>
:root{
  --navy:#2a1454;--teal:#6d28d9;--blue:#185FA5;--blue-lt:#E6F1FB;--blue-dk:#0C447C;
  --green:#3B6D11;--green-bg:#EAF3DE;--amber:#854F0B;--amber-bg:#FAEEDA;
  --red:#A32D2D;--red-bg:#FCEBEB;--purple:#3C3489;--purple-bg:#EEEDFE;
  --teal-bg:#E1F5EE;--teal-txt:#0F6E56;
  --bg:#F5F7FA;--surface:#fff;--border:#E2E8F0;--border-lt:#EEF2F7;
  --txt:#1A2435;--txt2:#5A6A80;--txt3:#8A9AB0;
  --r:8px;--sh:0 1px 3px rgba(0,0,0,.06),0 2px 8px rgba(0,0,0,.05);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Segoe UI',system-ui,sans-serif;background:var(--bg);color:var(--txt);font-size:13px;min-height:100vh}

/* ── Topnav ── */
.topnav{background:linear-gradient(135deg,#312e81 0%,#4c1d95 55%,#6d28d9 100%);height:52px;display:flex;align-items:center;padding:0 20px;gap:14px;position:sticky;top:0;z-index:100;border-bottom:2px solid #f59e0b}
.brand{display:flex;align-items:center;gap:9px;text-decoration:none;padding-right:16px;border-right:1px solid rgba(255,255,255,.1);flex-shrink:0}
.brand-logo{width:30px;height:30px;object-fit:contain;border-radius:5px}
.brand-name{font-size:13px;font-weight:800;color:#fff}
.brand-sub{font-size:10px;color:rgba(255,255,255,.35)}
.nav-bc{display:flex;align-items:center;gap:5px;font-size:12px;color:rgba(255,255,255,.55)}
.nav-bc a{color:rgba(255,255,255,.55);text-decoration:none}
.nav-bc a:hover{color:#fff}
.nav-bc svg{width:12px;height:12px;flex-shrink:0}
.nav-right{margin-left:auto;display:flex;align-items:center;gap:8px}
.nav-user-link{display:flex;align-items:center;gap:7px;text-decoration:none;border-radius:7px;padding:3px 7px;transition:.15s}
.nav-user-link:hover{background:rgba(255,255,255,.07)}
.nav-uname{font-size:12px;font-weight:700;color:#fff}
.nav-urole{font-size:10px;color:rgba(255,255,255,.4)}
.nav-avatar{width:30px;height:30px;border-radius:50%;background:var(--teal);color:#fff;display:grid;place-items:center;font-weight:800;font-size:11px;flex-shrink:0}
.nav-logout{width:28px;height:28px;border-radius:50%;border:1px solid rgba(255,255,255,.15);background:none;color:rgba(255,255,255,.5);display:grid;place-items:center;text-decoration:none;transition:.15s}
.nav-logout:hover{background:rgba(190,18,60,.25);color:#fda4af}

/* ── Layout ── */
.page{max-width:1180px;margin:0 auto;padding:20px 18px 60px;display:flex;gap:18px;align-items:flex-start}
.main-col{flex:1;min-width:0}
.side-col{width:230px;flex-shrink:0;position:sticky;top:70px}

/* ── Paper header ── */
.paper-hdr{background:var(--navy);border-radius:var(--r);padding:18px 22px;margin-bottom:16px}
.paper-hdr h1{font-size:16px;font-weight:700;color:#fff;margin-bottom:3px}
.paper-hdr p{font-size:12px;color:rgba(255,255,255,.5)}
.paper-hdr-meta{display:flex;gap:7px;flex-wrap:wrap;margin-top:10px}
.hbadge{padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600}
.hb-teal{background:rgba(91,33,182,.2);color:#5eead4}
.hb-blue{background:rgba(24,95,165,.25);color:#93c5fd}
.hb-amber{background:rgba(133,79,11,.3);color:#fbbf24}

/* ── Stats row ── */
.stats-row{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:16px}
.stat-card{background:var(--surface);border-radius:var(--r);padding:12px 14px;border:1px solid var(--border);box-shadow:var(--sh)}
.stat-lbl{font-size:10px;color:var(--txt2);margin-bottom:4px;text-transform:uppercase;letter-spacing:.04em}
.stat-val{font-size:22px;font-weight:600}
.sv-blue{color:var(--blue)} .sv-green{color:var(--green)} .sv-amber{color:var(--amber)} .sv-red{color:var(--red)}

/* ── Alert ── */
.alert{padding:10px 16px;border-radius:var(--r);font-size:12px;margin-bottom:14px}
.alert-success{background:var(--green-bg);color:var(--green);border:1px solid #b6d98a}
.alert-error  {background:var(--red-bg);color:var(--red);border:1px solid #f5b0b0}

/* ── Checklist nav ── */
.checklist-nav{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);padding:10px 14px;margin-bottom:16px;box-shadow:var(--sh);position:sticky;top:58px;z-index:90}
.cl-nav-row{display:flex;gap:6px;flex-wrap:wrap;align-items:center}
.cl-section-label{font-size:10px;font-weight:700;color:var(--txt3);text-transform:uppercase;letter-spacing:.05em;margin-right:2px;flex-shrink:0}
.cl-chip{display:inline-flex;align-items:center;gap:4px;padding:3px 9px;border-radius:20px;font-size:11px;font-weight:600;border:1px solid var(--border);background:var(--border-lt);color:var(--txt2);cursor:pointer;transition:.12s;flex-shrink:0}
.cl-chip:hover{background:var(--surface);border-color:var(--blue);color:var(--blue)}
.cl-chip.cl-done{background:var(--green-bg);border-color:#b6d98a;color:var(--green)}
.cl-chip.cl-needs{background:var(--amber-bg);border-color:var(--amber);color:var(--amber)}
.cl-chip.cl-bad{background:var(--red-bg);border-color:#f5b0b0;color:var(--red)}
.cl-dot{width:6px;height:6px;border-radius:50%;background:currentColor;flex-shrink:0}
.cl-divider{width:1px;height:18px;background:var(--border);flex-shrink:0}

/* ── Review sections ── */
.review-section{margin-bottom:28px}
.sec-anchor{display:block;height:0;visibility:hidden;margin-top:-70px;padding-top:70px}

/* ── Question cards ── */
.q-card{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);margin-bottom:12px;overflow:hidden;box-shadow:var(--sh)}
.q-card.qs-approved {border-left:3px solid var(--green)}
.q-card.qs-needs    {border-left:3px solid #BA7517}
.q-card.qs-rejected {border-left:3px solid var(--red)}
.q-card.qs-draft    {border-left:3px solid var(--border)}
.q-header{padding:14px 16px;display:flex;align-items:flex-start;gap:12px}
.q-num{width:32px;height:32px;border-radius:6px;background:var(--blue-lt);display:grid;place-items:center;font-size:12px;font-weight:600;color:var(--blue);flex-shrink:0}
.q-meta{flex:1;min-width:0}
.q-top{display:flex;align-items:center;gap:7px;margin-bottom:6px;flex-wrap:wrap}
.pill{font-size:10px;padding:2px 8px;border-radius:20px;font-weight:500}
.pill-blue{background:var(--blue-lt);color:var(--blue)}
.pill-gray{background:var(--border-lt);color:var(--txt2)}
.pill-teal{background:var(--teal-bg);color:var(--teal-txt)}
.q-text{font-size:13px;color:var(--txt);line-height:1.6;margin-bottom:8px}
.q-choices{font-size:11px;color:var(--txt2);line-height:1.9;margin-bottom:6px;padding-left:4px}
.q-foot{display:flex;align-items:center;gap:8px;flex-wrap:wrap}
.badge{display:inline-flex;align-items:center;gap:4px;font-size:10px;font-weight:600;padding:3px 9px;border-radius:20px}
.badge-approved{background:var(--green-bg);color:var(--green)}
.badge-needs   {background:var(--amber-bg);color:var(--amber)}
.badge-rejected{background:var(--red-bg);color:var(--red)}
.badge-draft   {background:var(--border-lt);color:var(--txt2)}
.dot{width:5px;height:5px;border-radius:50%;display:inline-block}
.dot-g{background:#639922} .dot-a{background:#BA7517} .dot-r{background:#E24B4A}
.tax-chip{font-size:10px;padding:2px 7px;border-radius:4px;background:var(--purple-bg);color:var(--purple);font-weight:500}
.q-divider{height:1px;background:var(--border-lt)}

/* ── Comments ── */
.comments-wrap{padding:14px 16px}
.comments-toggle{display:flex;align-items:center;gap:6px;font-size:11px;color:var(--blue);cursor:pointer;font-weight:600;margin-bottom:10px}
.comments-toggle svg{width:12px;height:12px}
.hidden{display:none}
.comment-list{margin-bottom:10px;display:flex;flex-direction:column;gap:10px}
/* each comment is a self-contained identity block */
.comment-card{background:var(--surface);border-radius:8px;border:1px solid var(--border);overflow:hidden;box-shadow:0 1px 3px rgba(0,0,0,.05)}
.comment-card.mine{border-color:#bfdbfe}
.c-id-bar{display:flex;align-items:center;gap:10px;padding:9px 13px;border-bottom:1px solid var(--border-lt)}
.c-avatar{width:30px;height:30px;border-radius:50%;display:grid;place-items:center;font-size:11px;font-weight:700;flex-shrink:0;color:#fff}
/* vetter colour palette — cycles by vetter index */
.cv-0{background:#185FA5}.cv-1{background:#5b21b6}.cv-2{background:#7c3aed}.cv-3{background:#b45309}.cv-4{background:#be123c}
.c-id-info{flex:1;min-width:0}
.c-name{font-size:12px;font-weight:700;color:var(--txt);display:flex;align-items:center;gap:6px}
.c-you-tag{font-size:9px;font-weight:700;padding:1px 6px;border-radius:10px;background:#dbeafe;color:var(--blue);letter-spacing:.03em}
.c-role-line{font-size:10px;color:var(--txt2);margin-top:1px}
.c-date{font-size:10px;color:var(--txt3);white-space:nowrap}
.c-body-wrap{padding:10px 13px}
.c-body{font-size:12px;color:var(--txt);line-height:1.6;margin-bottom:7px}
.c-tags{display:flex;gap:5px;flex-wrap:wrap}
.ctag{font-size:10px;padding:2px 7px;border-radius:4px}
.ctag-teal  {background:var(--teal-bg);color:var(--teal-txt)}
.ctag-purple{background:var(--purple-bg);color:var(--purple)}
.ctag-green {background:var(--green-bg);color:var(--green)}
.ctag-amber {background:var(--amber-bg);color:var(--amber)}
.ctag-red   {background:var(--red-bg);color:var(--red)}
.c-footer{display:flex;align-items:center;justify-content:space-between;padding:7px 13px;border-top:1px solid var(--border-lt);background:var(--bg)}

/* ── Comment form ── */
.add-form-wrap{display:none;margin-top:10px}
.add-form-wrap.open{display:block}
.add-comment-form{background:var(--bg);border-radius:6px;padding:12px;border:1px solid var(--border)}
.form-label{font-size:10px;color:var(--txt2);margin-bottom:3px;display:block;font-weight:600}
.form-group{margin-bottom:8px}
textarea{width:100%;border:1px solid var(--border);border-radius:6px;padding:7px 9px;font-size:12px;font-family:inherit;background:var(--surface);color:var(--txt);resize:vertical;line-height:1.5;min-height:60px}
textarea:focus{outline:none;border-color:var(--blue)}
select.form-sel{width:100%;border:1px solid var(--border);border-radius:6px;padding:5px 8px;font-size:12px;font-family:inherit;background:var(--surface);color:var(--txt)}
.form-row{display:grid;grid-template-columns:1fr 1fr;gap:8px}
.form-actions{display:flex;gap:7px;justify-content:flex-end;margin-top:8px}
.btn-primary{background:var(--blue);color:#fff;border:none;border-radius:6px;padding:6px 14px;font-size:12px;font-weight:600;cursor:pointer;font-family:inherit}
.btn-primary:hover{background:var(--blue-dk)}
.btn-ghost{background:transparent;color:var(--txt2);border:1px solid var(--border);border-radius:6px;padding:6px 12px;font-size:12px;cursor:pointer;font-family:inherit}
.btn-ghost:hover{background:var(--border-lt)}
.btn-sm{padding:4px 10px;font-size:11px}
.btn-add-comment{font-size:11px;color:var(--blue);background:none;border:1px dashed rgba(24,95,165,.4);border-radius:6px;padding:5px 12px;cursor:pointer;font-family:inherit;font-weight:600}
.btn-add-comment:hover{background:var(--blue-lt)}

/* ── Final verdict box ── */
.verdict-box{background:var(--surface);border-radius:var(--r);border:1px solid var(--border);padding:18px;margin-top:16px;box-shadow:var(--sh)}
.verdict-box h3{font-size:14px;font-weight:700;margin-bottom:6px}
.verdict-box p{font-size:12px;color:var(--txt2);margin-bottom:14px;line-height:1.6}
.verdict-btns{display:flex;gap:8px;flex-wrap:wrap}
.btn-approve{background:#15803d;color:#fff;border:none;border-radius:6px;padding:9px 20px;font-size:13px;font-weight:700;cursor:pointer;font-family:inherit}
.btn-approve:hover{background:#166534}
.btn-improve{background:#b45309;color:#fff;border:none;border-radius:6px;padding:9px 20px;font-size:13px;font-weight:700;cursor:pointer;font-family:inherit}
.btn-improve:hover{background:#92400e}
.btn-reject{background:#be123c;color:#fff;border:none;border-radius:6px;padding:9px 20px;font-size:13px;font-weight:700;cursor:pointer;font-family:inherit}
.btn-reject:hover{background:#9f1239}

/* ── Side panel (JSS quick view) ── */
.side-card{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);padding:14px;box-shadow:var(--sh);margin-bottom:12px}
.side-title{font-size:12px;font-weight:700;margin-bottom:10px;color:var(--txt)}
.jss-table{width:100%;border-collapse:collapse;font-size:11px}
.jss-table th{font-size:10px;color:var(--txt2);font-weight:600;padding:4px 5px;border-bottom:1px solid var(--border);text-align:left}
.jss-table td{padding:5px;border-bottom:1px solid var(--border-lt);color:var(--txt)}
.jss-table tr:last-child td{border-bottom:none}
.tax-badge{font-size:9px;padding:1px 5px;border-radius:3px;background:var(--purple-bg);color:var(--purple);font-weight:600}
.bar-lbl{font-size:10px;color:var(--txt2);margin-bottom:2px;display:flex;justify-content:space-between}
.bar-track{height:5px;background:var(--border-lt);border-radius:3px;overflow:hidden;margin-bottom:5px}
.bar-fill{height:100%;border-radius:3px}
.info-box{background:var(--blue-lt);border:1px solid #bfdbfe;border-radius:6px;padding:10px 13px;font-size:12px;color:#1e40af;margin-bottom:12px}

/* ── Section feedback ── */
.section-hdr{display:flex;align-items:center;justify-content:space-between;margin-bottom:12px}
.section-hdr h2{font-size:14px;font-weight:700}
.section-comment-list{display:flex;flex-direction:column;gap:10px;margin-bottom:14px}

@media(max-width:780px){.page{flex-direction:column}.side-col{width:100%;position:static}.stats-row{grid-template-columns:repeat(2,1fr)}}
/* ── Vetting checklist ── */
.vcl-wrap{padding:12px 16px;border-bottom:1px solid var(--border-lt);background:#fafbfc}
.vcl-title{font-size:10px;font-weight:700;color:var(--txt3);text-transform:uppercase;letter-spacing:.05em;margin-bottom:7px}
.vcl-table{width:100%;border-collapse:collapse;font-size:12px}
.vcl-table th{font-size:10px;font-weight:600;color:var(--txt2);padding:5px 8px;border-bottom:1px solid var(--border);text-align:left;background:var(--border-lt)}
.vcl-table td{padding:6px 8px;border-bottom:1px solid var(--border-lt);vertical-align:middle;transition:background .15s}
.vcl-table tr:last-child td{border-bottom:none}
.vcl-input{width:100%;border:1px solid var(--border);border-radius:4px;padding:3px 7px;font-size:11px;font-family:inherit;background:var(--surface);color:var(--txt)}
.vcl-input:focus{outline:none;border-color:var(--blue)}
/* toggle buttons */
.vcl-btn{width:28px;height:28px;border-radius:6px;border:2px solid var(--border);background:var(--surface);cursor:pointer;font-size:13px;font-weight:800;display:inline-flex;align-items:center;justify-content:center;transition:all .15s ease,transform .1s;flex-shrink:0;line-height:1;color:var(--txt3)}
.vcl-btn:active{transform:scale(.92)}
.vcl-btn-ok:hover{border-color:#16a34a;background:#f0fdf4;color:#16a34a}
.vcl-btn-ok.active{background:#16a34a;border-color:#15803d;color:#fff}
.vcl-btn-ok.active:hover{background:#15803d;color:#fff}
.vcl-btn-fail:hover{border-color:#dc2626;background:#fef2f2;color:#dc2626}
.vcl-btn-fail.active{background:#dc2626;border-color:#b91c1c;color:#fff}
.vcl-btn-fail.active:hover{background:#b91c1c;color:#fff}
/* row states */
.vcl-row-ok td{background:#f0fdf4!important}
.vcl-row-ok td:first-child{border-left:3px solid var(--green)}
.vcl-row-fail td{background:#fef2f2!important}
.vcl-row-fail td:first-child{border-left:3px solid #dc2626}
.vcl-row-empty td:first-child{border-left:3px solid var(--border)}
/* progress badge */
.vcl-header-row{display:flex;align-items:center;justify-content:space-between;margin-bottom:7px}
.vcl-progress-badge{font-size:11px;font-weight:700;padding:3px 10px;border-radius:12px;background:var(--border-lt);color:var(--txt2)}
.vcl-progress-badge.all-ok{background:var(--green-bg);color:var(--green)}
.vcl-progress-badge.has-issues{background:var(--amber-bg);color:var(--amber)}
/* mark-all button */
.btn-mark-all{font-size:10px;font-weight:600;padding:3px 9px;border-radius:5px;border:1px solid var(--border);background:var(--surface);color:var(--txt2);cursor:pointer;font-family:inherit;transition:.12s}
.btn-mark-all:hover{background:var(--green-bg);border-color:#b6d98a;color:var(--green)}
/* all-vetters panel */
.avp-wrap{padding:10px 16px 14px;background:#f8f9ff;border-top:1px solid var(--border-lt)}
.avp-toggle{font-size:11px;font-weight:600;color:var(--blue);cursor:pointer;display:flex;align-items:center;gap:5px;margin-bottom:0}
.avp-toggle svg{width:11px;height:11px;transition:transform .2s}
.avp-toggle.open svg{transform:rotate(90deg)}
.avp-body{display:none;margin-top:10px}
.avp-body.open{display:block}
.avp-table{width:100%;border-collapse:collapse;font-size:11px}
.avp-table th{font-size:10px;color:var(--txt3);font-weight:700;padding:4px 8px;border-bottom:1px solid var(--border);background:var(--border-lt);text-align:left;text-transform:uppercase;letter-spacing:.04em}
.avp-table td{padding:5px 8px;border-bottom:1px solid var(--border-lt);vertical-align:top}
.avp-table tr:last-child td{border-bottom:none}
.avp-ok{color:var(--green);font-weight:700}
.avp-fail{color:var(--amber);font-weight:700}
.avp-cmt{font-size:11px;color:var(--txt2);font-style:italic}
.avp-agree{font-size:10px;padding:2px 7px;border-radius:10px;font-weight:600;display:inline-block}
.avp-agree.all-agree{background:var(--green-bg);color:var(--green)}
.avp-agree.disagree{background:var(--amber-bg);color:var(--amber)}
</style>
</head>
<body>

<!-- ── Topnav ────────────────────────────────────────────── -->
<nav class="topnav">
  <a class="brand" href="<%= ctx %>/VetterDashboardServlet?page=queue">
    <img src="<%= ctx %>/images/umt-logo.png" alt="UMT" class="brand-logo">
    <div><div class="brand-name">E-Vetting</div><div class="brand-sub">UMT</div></div>
  </a>
  <div class="nav-bc">
    <a href="<%= ctx %>/VetterDashboardServlet?page=queue">Vetting Queue</a>
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
    <span style="color:rgba(255,255,255,.85);"><%= paper.getCourseCode() %> Review</span>
  </div>
  <div class="nav-right">
    <a href="<%= ctx %>/UserProfileServlet" class="nav-user-link" title="Profile">
      <div><div class="nav-uname"><%= myName %></div><div class="nav-urole"><%= myRole %></div></div>
      <div class="nav-avatar"><%= navInit %></div>
    </a>
    <jsp:include page="notificationBell.jsp"/>
    <a href="<%= ctx %>/logout" class="nav-logout" title="Sign out">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" width="14" height="14"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
    </a>
  </div>
</nav>

<div class="page">
<div class="main-col">

  <!-- ── Alerts ── -->
  <% if ("true".equals(savedSection)) { %>
  <div class="alert alert-success">Comment saved successfully.</div>
  <% } else if ("error".equals(errorParam)) { %>
  <div class="alert alert-error">An error occurred. Please try again.</div>
  <% } %>

  <!-- ── Paper header ── -->
  <div class="paper-hdr">
    <h1><%= paper.getCourseCode() %> — <%= paper.getCourseTitle() %></h1>
    <p>Question Review &amp; Vetting &nbsp;·&nbsp; <%= paper.getPaperType() %></p>
    <div class="paper-hdr-meta">
      <span class="hbadge hb-teal"><%= paper.getAcademicSession() %> Sem <%= paper.getSemester() %></span>
      <span class="hbadge hb-blue"><%= totalQs %> questions</span>
      <span class="hbadge hb-amber"><%= paper.getStatusLabel() %></span>
      <% if (paper.getSubmittedDate() != null) {
           java.text.SimpleDateFormat sf = new java.text.SimpleDateFormat("d MMM yyyy");
      %>
      <span class="hbadge" style="background:rgba(255,255,255,.1);color:rgba(255,255,255,.6);">Submitted: <%= sf.format(paper.getSubmittedDate()) %></span>
      <% } %>
    </div>
  </div>

  <!-- ── Stats ── -->
  <div class="stats-row">
    <div class="stat-card"><div class="stat-lbl">Total Questions</div><div class="stat-val sv-blue"><%= totalQs %></div></div>
    <div class="stat-card"><div class="stat-lbl">Approved</div><div class="stat-val sv-green"><%= approvedCount %></div></div>
    <div class="stat-card"><div class="stat-lbl">Needs Revision</div><div class="stat-val sv-amber"><%= needsRevCount %></div></div>
    <div class="stat-card"><div class="stat-lbl">Rejected</div><div class="stat-val sv-red"><%= rejectedCount %></div></div>
  </div>

  <!-- ── Checklist navigation ── -->
  <div class="checklist-nav">
    <div class="cl-nav-row">
      <span class="cl-section-label">Questions</span>
      <% if (questions != null) { for (Question _cq : questions) {
           String _cqst = _cq.getStatus() != null ? _cq.getStatus() : "DRAFT";
           String _cqCls = "APPROVED".equals(_cqst) ? "cl-done" : "NEEDS_REVISION".equals(_cqst) ? "cl-needs" : "REJECTED".equals(_cqst) ? "cl-bad" : "";
           // Count checklist completion for this question
           int _navOk = 0; int _navTotal = DAO.VettingChecklistDAO.QUESTION_CRITERIA.length;
           for (String[] _nc : DAO.VettingChecklistDAO.QUESTION_CRITERIA) {
             String _nk = DAO.VettingChecklistDAO.buildKey("QUESTION", _cq.getQuestionId(), _nc[0]);
             if (myChecklist != null && myChecklist.get(_nk) != null && Boolean.TRUE.equals(myChecklist.get(_nk).get("is_ok"))) _navOk++;
           }
      %>
      <span class="cl-chip <%= _cqCls %>" onclick="scrollToSection('q-anchor-<%= _cq.getQuestionId() %>')" title="<%= _navOk %>/<%= _navTotal %> criteria OK">
        <span class="cl-dot"></span>Q<%= _cq.getQuestionNo() %>
        <% if (_navOk == _navTotal && _navTotal > 0) { %><span style="font-size:9px;opacity:.8">✓</span><% } else if (_navOk > 0) { %><span style="font-size:9px;opacity:.7"><%= _navOk %>/<%= _navTotal %></span><% } %>
      </span>
      <% } } %>
      <div class="cl-divider"></div>
      <%
        int _jssOk=0; for(String[] _jnc:DAO.VettingChecklistDAO.JSS_CRITERIA){ String _jnk=DAO.VettingChecklistDAO.buildKey("JSS",null,_jnc[0]); if(myChecklist!=null&&myChecklist.get(_jnk)!=null&&Boolean.TRUE.equals(myChecklist.get(_jnk).get("is_ok"))) _jssOk++; }
        int _jssTotal = DAO.VettingChecklistDAO.JSS_CRITERIA.length;
        int _scOk=0; for(String[] _snc:DAO.VettingChecklistDAO.SCHEME_CRITERIA){ String _snk=DAO.VettingChecklistDAO.buildKey("SCHEME",null,_snc[0]); if(myChecklist!=null&&myChecklist.get(_snk)!=null&&Boolean.TRUE.equals(myChecklist.get(_snk).get("is_ok"))) _scOk++; }
        int _scTotal = DAO.VettingChecklistDAO.SCHEME_CRITERIA.length;
      %>
      <span class="cl-chip <%= _jssOk==_jssTotal&&_jssTotal>0?"cl-done":_jssOk>0?"cl-needs":"" %>" onclick="scrollToSection('sec-jss')" title="JSS: <%= _jssOk %>/<%= _jssTotal %> OK">
        <span class="cl-dot"></span>JSS <span style="font-size:9px;opacity:.8"><%= _jssOk %>/<%= _jssTotal %></span>
      </span>
      <span class="cl-chip <%= _scOk==_scTotal&&_scTotal>0?"cl-done":_scOk>0?"cl-needs":"" %>" onclick="scrollToSection('sec-scheme')" title="<%= schemeLabel %>: <%= _scOk %>/<%= _scTotal %> OK">
        <span class="cl-dot"></span><%= schemeLabel %> <span style="font-size:9px;opacity:.8"><%= _scOk %>/<%= _scTotal %></span>
      </span>
      <div class="cl-divider"></div>
      <span class="cl-chip" id="chip-verdict" onclick="scrollToSection('sec-verdict')" style="background:#f5f3ff;border-color:#ddd6fe;color:#6d28d9">
        <span class="cl-dot"></span>Verdict
      </span>
    </div>
  </div>

  <!-- ════════════ SECTION: QUESTIONS ════════════ -->
  <div id="sec-questions" class="review-section">
  <div class="section-hdr" style="margin-bottom:12px">
    <h2 style="font-size:14px;font-weight:700">Questions</h2>
  </div>
  <% if (questions == null || questions.isEmpty()) { %>
  <div class="info-box">No questions have been added to this paper yet.</div>
  <% } else { for (Question q : questions) {
        int    qid    = q.getQuestionId();
        String qst    = q.getStatus() != null ? q.getStatus() : "DRAFT";
        String qstCls = "APPROVED".equals(qst) ? "qs-approved"
                      : "NEEDS_REVISION".equals(qst) ? "qs-needs"
                      : "REJECTED".equals(qst) ? "qs-rejected" : "qs-draft";
        String qstBadge = "APPROVED".equals(qst) ? "badge-approved"
                        : "NEEDS_REVISION".equals(qst) ? "badge-needs"
                        : "REJECTED".equals(qst) ? "badge-rejected" : "badge-draft";
        String qstLabel = "APPROVED".equals(qst) ? "Approved"
                        : "NEEDS_REVISION".equals(qst) ? "Needs Revision"
                        : "REJECTED".equals(qst) ? "Rejected" : "Pending";
        List<QuestionComment> qcoms = commentMap != null ? commentMap.get(qid) : null;
        int comCount = qcoms != null ? qcoms.size() : 0;
        String typeCls = "STRUCTURE".equals(q.getQuestionType()) ? "pill-blue"
                       : "ESSAY".equals(q.getQuestionType()) ? "pill-teal" : "pill-gray";
  %>
  <span id="q-anchor-<%= qid %>" class="sec-anchor"></span>
  <div class="q-card <%= qstCls %>">
    <div class="q-header">
      <div class="q-num"><%= q.getQuestionNo() %></div>
      <div class="q-meta">
        <div class="q-top">
          <span class="pill <%= typeCls %>"><%= q.getQuestionType() %></span>
          <span class="pill pill-gray"><%= q.getMarks() %> marks</span>
          <% if (q.getChapter() != null && !q.getChapter().trim().isEmpty()) { %>
          <span class="pill pill-teal"><%= q.getChapter() %></span>
          <% } %>
          <span class="tax-chip"><%= q.getTaxonomyLevel() %></span>
        </div>
        <div class="q-text">
          <%= q.getQuestionText() != null ? q.getQuestionText().replace("<","&lt;") : "—" %>
          <% if (q.getParts() != null && !q.getParts().isEmpty()) { %>
          <div class="q-parts" style="margin-top:10px; margin-left:20px;">
            <% for (Model.QuestionPart p : q.getParts()) { %>
            <div class="q-part" style="margin-bottom:6px; display:flex; gap:10px;">
              <span style="font-weight:700;"><%= p.getPartLabel() %></span>
              <div style="flex:1"><%= p.getPartQuestionText() != null ? p.getPartQuestionText().replace("<","&lt;") : "" %></div>
              <span style="font-size:11px; color:#666;">[<%= p.getPartMarks() %> marks]</span>
            </div>
            <% } %>
          </div>
          <% } %>
        </div>
        <% if ("OBJECTIVE".equals(q.getQuestionType()) && q.getChoiceA() != null) { %>
        <div class="q-choices">
          A. <%= q.getChoiceA() %><br/>
          B. <%= q.getChoiceB() %><br/>
          C. <%= q.getChoiceC() %><br/>
          D. <%= q.getChoiceD() %>
          <% if (q.getCorrectAnswer() != null) { %>
          <br/><strong style="color:var(--green)">Answer: <%= q.getCorrectAnswer() %></strong>
          <% } %>
        </div>
        <% } %>
        <div class="q-foot">
          <span class="badge <%= qstBadge %>">
            <% if (!"DRAFT".equals(qst)) { %><span class="dot <%= "APPROVED".equals(qst)?"dot-g":"NEEDS_REVISION".equals(qst)?"dot-a":"dot-r" %>"></span><% } %>
            <%= qstLabel %>
          </span>
          <% if (q.getCloMapping() != null && !q.getCloMapping().trim().isEmpty()) { %>
          <span style="font-size:10px;color:var(--txt2)">CLO: <%= q.getCloMapping() %></span>
          <% } %>
        </div>
      </div>
    </div>
    <div class="q-divider"></div>
    <!-- Vetting checklist for this question -->
    <div class="vcl-wrap">
      <%
        int _qOkCount = 0;
        int _qTotalCrit = DAO.VettingChecklistDAO.QUESTION_CRITERIA.length;
        for (String[] _pc : DAO.VettingChecklistDAO.QUESTION_CRITERIA) {
          String _pk = DAO.VettingChecklistDAO.buildKey("QUESTION", qid, _pc[0]);
          if (myChecklist != null && myChecklist.get(_pk) != null && Boolean.TRUE.equals(myChecklist.get(_pk).get("is_ok"))) _qOkCount++;
        }
        String _qProgCls = _qOkCount == _qTotalCrit ? "all-ok" : _qOkCount > 0 ? "has-issues" : "";
      %>
      <div class="vcl-header-row">
        <div class="vcl-title" style="margin-bottom:0">Vetting Checklist</div>
        <div style="display:flex;align-items:center;gap:7px">
          <span class="vcl-progress-badge <%= _qProgCls %>" id="prog-Q-<%= qid %>"><%= _qOkCount %> / <%= _qTotalCrit %> OK</span>
          <button class="btn-mark-all" onclick="markAllOk('QUESTION',<%= qid %>,[<% for(int _mi=0;_mi<DAO.VettingChecklistDAO.QUESTION_CRITERIA.length;_mi++){if(_mi>0)out.print(",");out.print("'" + DAO.VettingChecklistDAO.QUESTION_CRITERIA[_mi][0] + "'");} %>])" title="Mark all criteria as OK">✓ All OK</button>
        </div>
      </div>
      <table class="vcl-table" style="margin-top:8px">
        <thead><tr><th style="width:80px;text-align:center">Vetting</th><th>Criterion</th><th>Comment</th></tr></thead>
        <tbody>
        <% for (String[] _crit : DAO.VettingChecklistDAO.QUESTION_CRITERIA) {
             String _clKey = DAO.VettingChecklistDAO.buildKey("QUESTION", qid, _crit[0]);
             java.util.Map<String,Object> _clEntry = myChecklist != null ? myChecklist.get(_clKey) : null;
             boolean _clOk = _clEntry != null && Boolean.TRUE.equals(_clEntry.get("is_ok"));
             boolean _clTouched = _clEntry != null;
             String  _clCmt = _clEntry != null && _clEntry.get("comment") != null ? (String)_clEntry.get("comment") : "";
             String  _rowCls = _clOk ? "vcl-row-ok" : (_clTouched ? "vcl-row-fail" : "vcl-row-empty");
        %>
        <tr id="clrow-Q-<%= qid %>-<%= _crit[0] %>" class="<%= _rowCls %>">
          <td style="text-align:center;padding:5px 4px">
            <div style="display:inline-flex;gap:4px;justify-content:center;align-items:center;width:100%">
              <button type="button" class="vcl-btn vcl-btn-ok<%= _clOk ? " active" : "" %>"
                id="clok-Q-<%= qid %>-<%= _crit[0] %>"
                data-ok="<%= _clOk ? "1" : "0" %>"
                onclick="clickChecklistButton('QUESTION',<%= qid %>,'<%= _crit[0] %>',true)"
                title="Mark as OK">✓</button>
              <button type="button" class="vcl-btn vcl-btn-fail<%= (_clTouched && !_clOk) ? " active" : "" %>"
                id="clfail-Q-<%= qid %>-<%= _crit[0] %>"
                data-fail="<%= (_clTouched && !_clOk) ? "1" : "0" %>"
                onclick="clickChecklistButton('QUESTION',<%= qid %>,'<%= _crit[0] %>',false)"
                title="Mark as Fail">✗</button>
            </div>
          </td>
          <td><%= _crit[1] %></td>
          <td>
            <input type="text" class="vcl-input"
              id="clc-Q-<%= qid %>-<%= _crit[0] %>"
              value="<%= _clCmt.replace("\"","&quot;") %>"
              placeholder="Comment (optional)"
              onblur="saveChecklistItemComment('QUESTION',<%= qid %>,'<%= _crit[0] %>',this.value)">
          </td>
        </tr>
        <% } %>
        </tbody>
      </table>
    </div>
    <!-- All-vetters checklist summary (read-only) -->
    <%
      java.util.List<java.util.Map<String,Object>> _avList = (java.util.List<java.util.Map<String,Object>>) request.getAttribute("allChecklists");
      // filter to QUESTION section, ref_id == qid
      java.util.Map<String, java.util.List<java.util.Map<String,Object>>> _avByCrit = new java.util.LinkedHashMap<>();
      java.util.Set<Integer> _avVetterIds = new java.util.LinkedHashSet<>();
      if (_avList != null) {
        for (java.util.Map<String,Object> _av : _avList) {
          if ("QUESTION".equals(_av.get("section")) && _av.get("ref_id") != null && ((Number)_av.get("ref_id")).intValue() == qid) {
            String _avck = (String)_av.get("criterion_key");
            java.util.List<java.util.Map<String,Object>> _avListForCrit = _avByCrit.get(_avck);
            if (_avListForCrit == null) {
              _avListForCrit = new java.util.ArrayList<>();
              _avByCrit.put(_avck, _avListForCrit);
            }
            _avListForCrit.add(_av);
            _avVetterIds.add(((Number)_av.get("vetter_id")).intValue());
          }
        }
      }
      boolean _hasAvData = !_avByCrit.isEmpty() && _avVetterIds.size() > 0;
    %>
    <% if (_hasAvData) { %>
    <div class="avp-wrap">
      <div class="avp-toggle" id="avp-toggle-Q-<%= qid %>" onclick="toggleAvp('Q-<%= qid %>')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="9 18 15 12 9 6"/></svg>
        All Vetters — Checklist Comparison (<%= _avVetterIds.size() %> vetter<%= _avVetterIds.size()!=1?"s":"" %>)
      </div>
      <div class="avp-body" id="avp-body-Q-<%= qid %>">
        <table class="avp-table">
          <thead><tr><th>Criterion</th>
          <% for (java.util.Map<String,Object> _av0 : _avList) {
               if ("QUESTION".equals(_av0.get("section")) && _av0.get("ref_id") != null && ((Number)_av0.get("ref_id")).intValue() == qid) {
                 String _vnn = (String)_av0.get("vetter_name");
                 // print each unique vetter name only once
          %>
            <th><%= _vnn != null ? _vnn : "Vetter" %></th>
          <%   break; } } %>
          <%
            // Collect unique vetters in order
            java.util.Map<Integer,String> _avNames = new java.util.LinkedHashMap<>();
            if (_avList != null) for (java.util.Map<String,Object> _avr : _avList) {
              if ("QUESTION".equals(_avr.get("section")) && _avr.get("ref_id") != null && ((Number)_avr.get("ref_id")).intValue() == qid) {
                int _avrid = ((Number)_avr.get("vetter_id")).intValue();
                if (!_avNames.containsKey(_avrid)) _avNames.put(_avrid, _avr.get("vetter_name") != null ? (String)_avr.get("vetter_name") : "Vetter");
              }
            }
          %>
          <% boolean _firstTh = true; for (java.util.Map.Entry<Integer,String> _avne : _avNames.entrySet()) { if (_firstTh) { _firstTh=false; continue; } %>
            <th><%= _avne.getValue() %></th>
          <% } %>
          <th>Agreement</th></tr></thead>
          <tbody>
          <% for (String[] _avcrit : DAO.VettingChecklistDAO.QUESTION_CRITERIA) {
               java.util.List<java.util.Map<String,Object>> _avRows = _avByCrit.get(_avcrit[0]);
               if (_avRows == null) continue;
               long _avOkCnt = 0; for (java.util.Map<String,Object> _avrow : _avRows) if (Boolean.TRUE.equals(_avrow.get("is_ok"))) _avOkCnt++;
               boolean _avAllAgree = _avOkCnt == _avRows.size() || _avOkCnt == 0;
          %>
          <tr>
            <td><%= _avcrit[1] %></td>
            <% for (java.util.Map.Entry<Integer,String> _avne2 : _avNames.entrySet()) {
                 java.util.Map<String,Object> _avMatch = null;
                 for (java.util.Map<String,Object> _avr2 : _avRows) if (((Number)_avr2.get("vetter_id")).intValue() == _avne2.getKey()) { _avMatch = _avr2; break; }
                 if (_avMatch == null) { %><td style="color:var(--txt3)">—</td><% continue; }
                 boolean _avisOk = Boolean.TRUE.equals(_avMatch.get("is_ok"));
                 String _avcmt = _avMatch.get("comment") != null ? (String)_avMatch.get("comment") : "";
            %>
            <td>
              <span class="<%= _avisOk ? "avp-ok" : "avp-fail" %>"><%= _avisOk ? "✓" : "✗" %></span>
              <% if (!_avcmt.isEmpty()) { %><br/><span class="avp-cmt"><%= _avcmt.replace("<","&lt;") %></span><% } %>
            </td>
            <% } %>
            <td><span class="avp-agree <%= _avAllAgree ? "all-agree" : "disagree" %>"><%= _avAllAgree ? "Agree" : "Differ" %></span></td>
          </tr>
          <% } %>
          </tbody>
        </table>
      </div>
    </div>
    <% } %>
    <div class="comments-wrap">
      <div class="comments-toggle" onclick="toggleQ(<%= qid %>)">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
        <span id="qlbl-<%= qid %>"><%= comCount %> comment<%= comCount!=1?"s":"" %> — click to <%= comCount>0?"view":"add" %></span>
      </div>
      <div id="qwrap-<%= qid %>" class="<%= comCount > 0 ? "" : "hidden" %>">
        <div class="comment-list">
          <% if (qcoms != null) {
               // Build a stable colour index per vetter for this question
               java.util.Map<Integer,Integer> vetterColorIdx = new java.util.LinkedHashMap<>();
               int colorCounter = 0;
               for (QuestionComment _c : qcoms) {
                 if (!vetterColorIdx.containsKey(_c.getVetterId()))
                   vetterColorIdx.put(_c.getVetterId(), colorCounter++ % 5);
               }
               for (QuestionComment c : qcoms) {
               boolean isMe = c.getVetterId() == myId;
               int colorIdx = vetterColorIdx.getOrDefault(c.getVetterId(), 0);
               String cbadge = "APPROVED".equals(c.getVerdict()) ? "badge-approved"
                             : "NEEDS_REVISION".equals(c.getVerdict()) ? "badge-needs"
                             : "REJECTED".equals(c.getVerdict()) ? "badge-rejected" : null;
          %>
          <div class="comment-card <%= isMe ? "mine" : "" %>">
            <!-- Identity bar -->
            <div class="c-id-bar">
              <div class="c-avatar cv-<%= colorIdx %>"><%= c.getInitials() %></div>
              <div class="c-id-info">
                <div class="c-name">
                  <%= c.getVetterName() != null ? c.getVetterName() : "Vetter" %>
                  <% if (isMe) { %><span class="c-you-tag">You</span><% } %>
                  <% if (cbadge != null) { %>
                  <span class="badge <%= cbadge %>" style="font-size:10px;margin-left:2px"><%= c.getVerdict().replace("_"," ") %></span>
                  <% } %>
                </div>
                <div class="c-role-line">Vetter &nbsp;·&nbsp; <%= c.getFormattedDate() %></div>
              </div>
              <% if (isMe) { %>
              <button class="btn-ghost btn-sm" style="font-size:10px;flex-shrink:0" onclick="clearComment(<%= qid %>)">Clear my comment</button>
              <% } %>
            </div>
            <!-- Comment body -->
            <div class="c-body-wrap">
              <div class="c-body"><%= c.getCommentText().replace("<","&lt;").replace("\n","<br/>") %></div>
              <% boolean hasTags = c.getContentTag()!=null || c.getTaxonomyTag()!=null || c.getSuggestedTaxonomy()!=null;
                 if (hasTags) { %>
              <div class="c-tags">
                <% if (c.getContentTag()  != null) { %><span class="ctag ctag-teal"><%= c.getContentTag() %></span><% } %>
                <% if (c.getTaxonomyTag() != null) { %><span class="ctag ctag-purple"><%= c.getTaxonomyTag() %></span><% } %>
                <% if (c.getSuggestedTaxonomy() != null) { %><span class="ctag ctag-purple">Suggest: <%= c.getSuggestedTaxonomy() %></span><% } %>
              </div>
              <% } %>
            </div>
          </div>
          <% } } %>
        </div>

        <!-- Add comment form -->
        <div class="add-form-wrap" id="qform-<%= qid %>">
          <div class="add-comment-form">
            <div class="form-group">
              <label class="form-label">Feedback / Comment</label>
              <textarea rows="3" id="qtxt-<%= qid %>" placeholder="Enter your review comment here…"></textarea>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="form-label">Suggest Taxonomy Level</label>
                <select class="form-sel" id="qtax-<%= qid %>">
                  <option value="">— No change —</option>
                  <option value="C1"<%= "C1".equals(q.getTaxonomyLevel())?" selected":"" %>>C1 — Remember</option>
                  <option value="C2"<%= "C2".equals(q.getTaxonomyLevel())?" selected":"" %>>C2 — Understand</option>
                  <option value="C3"<%= "C3".equals(q.getTaxonomyLevel())?" selected":"" %>>C3 — Apply</option>
                  <option value="C4"<%= "C4".equals(q.getTaxonomyLevel())?" selected":"" %>>C4 — Analyze</option>
                  <option value="C5"<%= "C5".equals(q.getTaxonomyLevel())?" selected":"" %>>C5 — Evaluate</option>
                  <option value="C6"<%= "C6".equals(q.getTaxonomyLevel())?" selected":"" %>>C6 — Create</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label">Set Status</label>
                <select class="form-sel" id="qverdict-<%= qid %>">
                  <option value="">— No change —</option>
                  <option value="APPROVED">Approved</option>
                  <option value="NEEDS_REVISION">Needs Revision</option>
                  <option value="REJECTED">Rejected</option>
                </select>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="form-label">Content Tag</label>
                <select class="form-sel" id="qctag-<%= qid %>">
                  <option value="">— None —</option>
                  <option>Content: Approved</option>
                  <option>Content: Needs refinement</option>
                  <option>Content: Mark adjustment needed</option>
                  <option>Content: Rejected — insufficient rigor</option>
                  <option>Content: Ambiguous wording</option>
                </select>
              </div>
              <div class="form-group">
                <label class="form-label">Taxonomy Tag</label>
                <select class="form-sel" id="qttag-<%= qid %>">
                  <option value="">— None —</option>
                  <option>Taxonomy: C1 — confirmed</option>
                  <option>Taxonomy: Suggest C3 Apply or higher</option>
                  <option>Taxonomy: C4 Analyze — confirmed</option>
                  <option>Taxonomy: C5 Evaluate — confirmed</option>
                  <option>Taxonomy: Level too low for final exam</option>
                </select>
              </div>
            </div>
            <div class="form-actions">
              <button class="btn-ghost" onclick="document.getElementById('qform-<%= qid %>').classList.remove('open')">Cancel</button>
              <button class="btn-primary" onclick="submitQComment(<%= qid %>)">Submit Comment</button>
            </div>
          </div>
        </div>
        <button class="btn-add-comment" onclick="document.getElementById('qform-<%= qid %>').classList.toggle('open')">+ Add Comment</button>
      </div>
    </div>
  </div>
  <% } } %>

  </div><!-- /sec-questions -->

  <!-- ════════════ SECTION: JSS ════════════ -->
  <span id="sec-jss" class="sec-anchor"></span>
  <div class="review-section">
    <div class="section-hdr">
      <div><h2>JSS — Jadual Spesifikasi Soalan</h2>
           <div style="font-size:11px;color:var(--txt2);margin-top:2px">Review the question specification table submitted by the lecturer</div>
      </div>
      <a href="<%= ctx %>/JSSServlet?paperId=<%= paperId %>" target="_blank" class="btn-ghost btn-sm">View full JSS</a>
    </div>
    <!-- JSS rows (read-only, from DB) -->
    <div style="overflow-x:auto;margin-bottom:16px">
      <table class="jss-table" style="font-size:12px;border:1px solid var(--border);border-radius:var(--r);overflow:hidden;border-collapse:separate;border-spacing:0">
        <thead style="background:var(--navy)">
          <tr>
            <th style="padding:9px 12px;color:#fff;text-align:left">Topic</th>
            <th style="padding:9px 12px;color:#fff;text-align:left">Q No.</th>
            <th style="padding:9px 12px;color:#fff;text-align:center">Taxonomy</th>
            <th style="padding:9px 12px;color:#fff;text-align:left">Type</th>
            <th style="padding:9px 12px;color:#fff;text-align:center">Marks</th>
            <th style="padding:9px 12px;color:#fff;text-align:left">PLO</th>
            <th style="padding:9px 12px;color:#fff;text-align:left">CLO</th>
          </tr>
        </thead>
        <tbody>
          <%
            boolean jssHasRows = false;
            try (java.sql.Connection jcon = util.DBConnection.getConnection()) {
              java.sql.PreparedStatement jps = jcon.prepareStatement(
                "SELECT jr.* FROM jss_rows jr JOIN jss j ON jr.jss_id=j.jss_id WHERE j.paper_id=? ORDER BY jr.row_order");
              jps.setInt(1, paperId);
              java.sql.ResultSet jrs = jps.executeQuery();
              while (jrs.next()) {
                jssHasRows = true;
          %>
          <tr style="border-bottom:1px solid var(--border-lt)">
            <td style="padding:8px 12px"><%= jrs.getString("topic_name") != null ? jrs.getString("topic_name") : "—" %></td>
            <td style="padding:8px 12px;font-family:monospace"><%= jrs.getString("question_no") != null ? jrs.getString("question_no") : "—" %></td>
            <td style="padding:8px 12px;text-align:center"><span class="tax-badge"><%= jrs.getString("taxonomy_level") != null ? jrs.getString("taxonomy_level") : "—" %></span></td>
            <td style="padding:8px 12px"><%= jrs.getString("question_type") != null ? jrs.getString("question_type") : "—" %></td>
            <td style="padding:8px 12px;text-align:center;font-weight:700"><%= jrs.getObject("marks") != null ? jrs.getObject("marks") : "—" %></td>
            <td style="padding:8px 12px"><%= jrs.getString("plo") != null ? jrs.getString("plo") : "—" %></td>
            <td style="padding:8px 12px"><%= jrs.getString("clo") != null ? jrs.getString("clo") : "—" %></td>
          </tr>
          <% } if (!jssHasRows) { %>
          <tr><td colspan="7" style="padding:14px 12px;color:var(--txt3);text-align:center">No JSS rows found — the lecturer has not filled the JSS yet.</td></tr>
          <% } jrs.close(); jps.close(); } catch(Exception ejss){ ejss.printStackTrace(); } %>
        </tbody>
      </table>
    </div>

    <!-- JSS vetting checklist -->
    <div class="vcl-wrap" style="border-radius:var(--r);border:1px solid var(--border);margin-bottom:16px">
      <%
        int _jssOkCount = 0;
        int _jssTotalCrit = DAO.VettingChecklistDAO.JSS_CRITERIA.length;
        for (String[] _jpc : DAO.VettingChecklistDAO.JSS_CRITERIA) {
          String _jpk = DAO.VettingChecklistDAO.buildKey("JSS", null, _jpc[0]);
          if (myChecklist != null && myChecklist.get(_jpk) != null && Boolean.TRUE.equals(myChecklist.get(_jpk).get("is_ok"))) _jssOkCount++;
        }
        String _jssProgCls = _jssOkCount == _jssTotalCrit ? "all-ok" : _jssOkCount > 0 ? "has-issues" : "";
      %>
      <div class="vcl-header-row">
        <div class="vcl-title" style="margin-bottom:0">JSS Vetting Checklist</div>
        <div style="display:flex;align-items:center;gap:7px">
          <span class="vcl-progress-badge <%= _jssProgCls %>" id="prog-JSS-0"><%= _jssOkCount %> / <%= _jssTotalCrit %> OK</span>
          <button class="btn-mark-all" onclick="markAllOk('JSS',0,[<% for(int _mi=0;_mi<DAO.VettingChecklistDAO.JSS_CRITERIA.length;_mi++){if(_mi>0)out.print(",");out.print("'" + DAO.VettingChecklistDAO.JSS_CRITERIA[_mi][0] + "'");} %>])" title="Mark all JSS criteria as OK">✓ All OK</button>
        </div>
      </div>
      <table class="vcl-table" style="margin-top:8px">
        <thead><tr><th style="width:80px;text-align:center">Vetting</th><th>Criterion</th><th>Comment</th></tr></thead>
        <tbody>
        <% for (String[] _jcrit : DAO.VettingChecklistDAO.JSS_CRITERIA) {
             String _jKey = DAO.VettingChecklistDAO.buildKey("JSS", null, _jcrit[0]);
             java.util.Map<String,Object> _jEntry = myChecklist != null ? myChecklist.get(_jKey) : null;
             boolean _jOk = _jEntry != null && Boolean.TRUE.equals(_jEntry.get("is_ok"));
             boolean _jTouched = _jEntry != null;
             String  _jCmt = _jEntry != null && _jEntry.get("comment") != null ? (String)_jEntry.get("comment") : "";
             String  _jRowCls = _jOk ? "vcl-row-ok" : (_jTouched ? "vcl-row-fail" : "vcl-row-empty");
        %>
        <tr id="clrow-JSS-0-<%= _jcrit[0] %>" class="<%= _jRowCls %>">
          <td style="text-align:center;padding:5px 4px">
            <div style="display:inline-flex;gap:4px;justify-content:center;align-items:center;width:100%">
              <button type="button" class="vcl-btn vcl-btn-ok<%= _jOk ? " active" : "" %>"
                id="clok-JSS-0-<%= _jcrit[0] %>"
                data-ok="<%= _jOk ? "1" : "0" %>"
                onclick="clickChecklistButton('JSS',0,'<%= _jcrit[0] %>',true)"
                title="Mark as OK">✓</button>
              <button type="button" class="vcl-btn vcl-btn-fail<%= (_jTouched && !_jOk) ? " active" : "" %>"
                id="clfail-JSS-0-<%= _jcrit[0] %>"
                data-fail="<%= (_jTouched && !_jOk) ? "1" : "0" %>"
                onclick="clickChecklistButton('JSS',0,'<%= _jcrit[0] %>',false)"
                title="Mark as Fail">✗</button>
            </div>
          </td>
          <td><%= _jcrit[1] %></td>
          <td>
            <input type="text" class="vcl-input"
              id="clc-JSS-0-<%= _jcrit[0] %>"
              value="<%= _jCmt.replace("\"","&quot;") %>"
              placeholder="Comment (optional)"
              onblur="saveChecklistItemComment('JSS',0,'<%= _jcrit[0] %>',this.value)">
          </td>
        </tr>
        <% } %>
        </tbody>
      </table>
    </div>

    <!-- Existing JSS comments -->
    <div class="section-hdr" style="margin-top:18px">
      <h2 style="font-size:13px">Vetter Comments on JSS</h2>
    </div>
    <div class="section-comment-list">
    <% if (jssComments != null && !jssComments.isEmpty()) {
         java.util.Map<Integer,Integer> jssColorMap = new java.util.LinkedHashMap<>();
         int jssColorCtr = 0;
         for (java.util.Map<String,Object> _jc : jssComments) {
           int _jvid = (int)_jc.get("vetterId");
           if (!jssColorMap.containsKey(_jvid)) jssColorMap.put(_jvid, jssColorCtr++ % 5);
         }
         java.text.SimpleDateFormat jsdf = new java.text.SimpleDateFormat("d MMM yyyy, HH:mm");
         for (java.util.Map<String,Object> jc : jssComments) {
           String jv = (String) jc.get("verdict");
           String jvBadge = "APPROVED".equals(jv) ? "badge-approved"
                          : "NEEDS_REVISION".equals(jv) ? "badge-needs"
                          : "REJECTED".equals(jv) ? "badge-rejected" : null;
           java.sql.Timestamp jts = (java.sql.Timestamp) jc.get("createdAt");
           int jvid = (int) jc.get("vetterId");
           boolean jIsMe = jvid == myId;
           int jColorIdx = jssColorMap.getOrDefault(jvid, 0);
           String jvn = (String) jc.get("vetterName");
           String jInit = "?";
           if (jvn != null) { String[] jp = jvn.trim().split("\\s+"); int js2=(jp.length>1&&jp[0].endsWith("."))?1:0; StringBuilder jsb=new StringBuilder(); for(int ji=js2;ji<jp.length&&jsb.length()<2;ji++) jsb.append(Character.toUpperCase(jp[ji].charAt(0))); if(jsb.length()>0) jInit=jsb.toString(); }
    %>
    <div class="comment-card <%= jIsMe ? "mine" : "" %>" style="margin-bottom:0">
      <div class="c-id-bar">
        <div class="c-avatar cv-<%= jColorIdx %>"><%= jInit %></div>
        <div class="c-id-info">
          <div class="c-name">
            <%= jvn != null ? jvn : "Vetter" %>
            <% if (jIsMe) { %><span class="c-you-tag">You</span><% } %>
            <% if (jvBadge != null) { %><span class="badge <%= jvBadge %>" style="font-size:10px;margin-left:2px"><%= jv.replace("_"," ") %></span><% } %>
          </div>
          <div class="c-role-line">Vetter &nbsp;·&nbsp; JSS Review &nbsp;·&nbsp; <%= jts != null ? jsdf.format(jts) : "" %></div>
        </div>
      </div>
      <div class="c-body-wrap">
        <div class="c-body"><%= ((String)jc.get("commentText")).replace("<","&lt;").replace("\n","<br/>") %></div>
      </div>
    </div>
    <% } } else { %>
    <div style="font-size:12px;color:var(--txt3);padding:4px 0">No comments on JSS yet.</div>
    <% } %>
    </div><!-- /section-comment-list -->

    <!-- Add JSS comment form -->
    <div class="add-form-wrap open" id="jss-form">
      <div class="add-comment-form">
        <div class="form-group">
          <label class="form-label">Feedback on JSS</label>
          <textarea rows="3" id="jss-txt" placeholder="Enter your feedback on the question specification table…"></textarea>
        </div>
        <div class="form-group" style="max-width:260px">
          <label class="form-label">JSS Status</label>
          <select class="form-sel" id="jss-verdict">
            <option value="">— No verdict —</option>
            <option value="APPROVED">Approved</option>
            <option value="NEEDS_REVISION">Needs Revision</option>
            <option value="REJECTED">Rejected</option>
          </select>
        </div>
        <div class="form-actions">
          <button class="btn-primary" onclick="submitSectionComment('JSS','jss-txt','jss-verdict')">Submit Comment</button>
        </div>
      </div>
    </div>
  </div><!-- /sec-jss -->

  <!-- ════════════ SECTION: SCHEME / RUBRIC ════════════ -->
  <span id="sec-scheme" class="sec-anchor"></span>
  <div class="review-section">
    <div class="section-hdr">
      <div><h2><%= schemeLabel %></h2>
           <div style="font-size:11px;color:var(--txt2);margin-top:2px">Review the <%= isFinal ? "model answers" : "rubric and marking criteria" %> submitted by the lecturer</div>
      </div>
    </div>

    <!-- Model answers / rubric (read-only) -->
    <% if (isFinal) {
         // Show model answers
         boolean hasAns = false;
         if (questions != null) {
           for (Question q2 : questions) {
             if (q2.getModelAnswer() != null && !q2.getModelAnswer().trim().isEmpty()) {
               hasAns = true; break;
             }
           }
         }
         if (hasAns) { %>
    <div style="overflow-x:auto;margin-bottom:16px">
      <table style="width:100%;border-collapse:collapse;font-size:12px;border:1px solid var(--border);border-radius:var(--r)">
        <thead style="background:var(--navy)">
          <tr>
            <th style="padding:9px 12px;color:#fff;width:50px">No.</th>
            <th style="padding:9px 12px;color:#fff">Question</th>
            <th style="padding:9px 12px;color:#fff">Model Answer</th>
            <th style="padding:9px 12px;color:#fff;width:60px;text-align:center">Marks</th>
          </tr>
        </thead>
        <tbody>
          <% for (Question q2 : questions) {
             if (q2.getModelAnswer() == null || q2.getModelAnswer().trim().isEmpty()) continue; %>
          <tr style="border-bottom:1px solid var(--border-lt)">
            <td style="padding:8px 12px;font-weight:700;text-align:center"><%= q2.getQuestionNo() %></td>
            <td style="padding:8px 12px;color:var(--txt2);font-size:11px"><%= q2.getQuestionText() != null ? q2.getQuestionText().substring(0,Math.min(q2.getQuestionText().length(),80)).replace("<","&lt;") : "—" %>...</td>
            <td style="padding:8px 12px"><%= q2.getModelAnswer().replace("<","&lt;").replace("\n","<br/>") %></td>
            <td style="padding:8px 12px;text-align:center;font-weight:700"><%= q2.getMarks() %></td>
          </tr>
          <% } %>
        </tbody>
      </table>
    </div>
    <% } else { %>
    <div class="info-box">No model answers have been entered for this paper yet.</div>
    <% }
       } else {
         // Show rubric rows
         boolean hasRubric = false;
         try (java.sql.Connection rcon = util.DBConnection.getConnection()) {
           java.sql.PreparedStatement rps = rcon.prepareStatement("SELECT * FROM rubric_rows WHERE paper_id=? ORDER BY row_order");
           rps.setInt(1, paperId);
           java.sql.ResultSet rrs = rps.executeQuery();
           if (rrs.next()) { hasRubric = true; %>
    <div style="overflow-x:auto;margin-bottom:16px">
      <table style="width:100%;border-collapse:collapse;font-size:12px;border:1px solid var(--border);border-radius:var(--r)">
        <thead style="background:var(--navy)">
          <tr>
            <th style="padding:9px 12px;color:#fff;width:40px">No.</th>
            <th style="padding:9px 12px;color:#fff">Criterion</th>
            <th style="padding:9px 12px;color:#fff;width:60px;text-align:center">Marks</th>
            <th style="padding:9px 12px;color:#fff;width:60px;text-align:center">CLO</th>
            <th style="padding:9px 12px;color:#fff;width:60px;text-align:center">Bloom</th>
            <th style="padding:9px 12px;color:#fff">Description</th>
          </tr>
        </thead>
        <tbody>
          <% int rn=1; do { %>
          <tr style="border-bottom:1px solid var(--border-lt)">
            <td style="padding:8px 12px;text-align:center;font-weight:700"><%= rn++ %></td>
            <td style="padding:8px 12px"><%= rrs.getString("criterion")!=null?rrs.getString("criterion").replace("<","&lt;"):"—" %></td>
            <td style="padding:8px 12px;text-align:center;font-weight:700"><%= rrs.getInt("marks") %></td>
            <td style="padding:8px 12px;text-align:center"><%= rrs.getString("clo")!=null?rrs.getString("clo"):"—" %></td>
            <td style="padding:8px 12px;text-align:center"><span class="tax-badge"><%= rrs.getString("bloom")!=null?rrs.getString("bloom"):"—" %></span></td>
            <td style="padding:8px 12px;font-size:11px;color:var(--txt2)"><%= rrs.getString("description")!=null?rrs.getString("description").replace("<","&lt;"):"—" %></td>
          </tr>
          <% } while(rrs.next()); rrs.close(); rps.close(); %>
        </tbody>
      </table>
    </div>
    <% } else { rrs.close(); rps.close(); %>
    <div class="info-box">No rubric rows found for this paper.</div>
    <% } } catch(Exception er){ er.printStackTrace(); } } %>

    <!-- Scheme vetting checklist -->
    <div class="vcl-wrap" style="border-radius:var(--r);border:1px solid var(--border);margin-bottom:16px">
      <%
        int _scOkCount = 0;
        int _scTotalCrit = DAO.VettingChecklistDAO.SCHEME_CRITERIA.length;
        for (String[] _spc : DAO.VettingChecklistDAO.SCHEME_CRITERIA) {
          String _spk = DAO.VettingChecklistDAO.buildKey("SCHEME", null, _spc[0]);
          if (myChecklist != null && myChecklist.get(_spk) != null && Boolean.TRUE.equals(myChecklist.get(_spk).get("is_ok"))) _scOkCount++;
        }
        String _scProgCls = _scOkCount == _scTotalCrit ? "all-ok" : _scOkCount > 0 ? "has-issues" : "";
      %>
      <div class="vcl-header-row">
        <div class="vcl-title" style="margin-bottom:0"><%= schemeLabel %> Vetting Checklist</div>
        <div style="display:flex;align-items:center;gap:7px">
          <span class="vcl-progress-badge <%= _scProgCls %>" id="prog-SCHEME-0"><%= _scOkCount %> / <%= _scTotalCrit %> OK</span>
          <button class="btn-mark-all" onclick="markAllOk('SCHEME',0,[<% for(int _mi=0;_mi<DAO.VettingChecklistDAO.SCHEME_CRITERIA.length;_mi++){if(_mi>0)out.print(",");out.print("'" + DAO.VettingChecklistDAO.SCHEME_CRITERIA[_mi][0] + "'");} %>])" title="Mark all scheme criteria as OK">✓ All OK</button>
        </div>
      </div>
      <table class="vcl-table" style="margin-top:8px">
        <thead><tr><th style="width:80px;text-align:center">Vetting</th><th>Criterion</th><th>Comment</th></tr></thead>
        <tbody>
        <% for (String[] _scrit : DAO.VettingChecklistDAO.SCHEME_CRITERIA) {
             String _sKey = DAO.VettingChecklistDAO.buildKey("SCHEME", null, _scrit[0]);
             java.util.Map<String,Object> _sEntry = myChecklist != null ? myChecklist.get(_sKey) : null;
             boolean _sOk = _sEntry != null && Boolean.TRUE.equals(_sEntry.get("is_ok"));
             boolean _sTouched = _sEntry != null;
             String  _sCmt = _sEntry != null && _sEntry.get("comment") != null ? (String)_sEntry.get("comment") : "";
             String  _sRowCls = _sOk ? "vcl-row-ok" : (_sTouched ? "vcl-row-fail" : "vcl-row-empty");
        %>
        <tr id="clrow-SCHEME-0-<%= _scrit[0] %>" class="<%= _sRowCls %>">
          <td style="text-align:center;padding:5px 4px">
            <div style="display:inline-flex;gap:4px;justify-content:center;align-items:center;width:100%">
              <button type="button" class="vcl-btn vcl-btn-ok<%= _sOk ? " active" : "" %>"
                id="clok-SCHEME-0-<%= _scrit[0] %>"
                data-ok="<%= _sOk ? "1" : "0" %>"
                onclick="clickChecklistButton('SCHEME',0,'<%= _scrit[0] %>',true)"
                title="Mark as OK">✓</button>
              <button type="button" class="vcl-btn vcl-btn-fail<%= (_sTouched && !_sOk) ? " active" : "" %>"
                id="clfail-SCHEME-0-<%= _scrit[0] %>"
                data-fail="<%= (_sTouched && !_sOk) ? "1" : "0" %>"
                onclick="clickChecklistButton('SCHEME',0,'<%= _scrit[0] %>',false)"
                title="Mark as Fail">✗</button>
            </div>
          </td>
          <td><%= _scrit[1] %></td>
          <td>
            <input type="text" class="vcl-input"
              id="clc-SCHEME-0-<%= _scrit[0] %>"
              value="<%= _sCmt.replace("\"","&quot;") %>"
              placeholder="Comment (optional)"
              onblur="saveChecklistItemComment('SCHEME',0,'<%= _scrit[0] %>',this.value)">
          </td>
        </tr>
        <% } %>
        </tbody>
      </table>
    </div>

    <!-- Existing scheme comments -->
    <div class="section-hdr" style="margin-top:18px">
      <h2 style="font-size:13px">Vetter Comments on <%= schemeLabel %></h2>
    </div>
    <div class="section-comment-list">
    <% if (schemeComments != null && !schemeComments.isEmpty()) {
         java.util.Map<Integer,Integer> schColorMap = new java.util.LinkedHashMap<>();
         int schColorCtr = 0;
         for (java.util.Map<String,Object> _sc : schemeComments) {
           int _svid = (int)_sc.get("vetterId");
           if (!schColorMap.containsKey(_svid)) schColorMap.put(_svid, schColorCtr++ % 5);
         }
         java.text.SimpleDateFormat ssdf = new java.text.SimpleDateFormat("d MMM yyyy, HH:mm");
         for (java.util.Map<String,Object> sc : schemeComments) {
           String sv = (String) sc.get("verdict");
           String svBadge = "APPROVED".equals(sv) ? "badge-approved"
                          : "NEEDS_REVISION".equals(sv) ? "badge-needs"
                          : "REJECTED".equals(sv) ? "badge-rejected" : null;
           java.sql.Timestamp sts = (java.sql.Timestamp) sc.get("createdAt");
           int svid = (int) sc.get("vetterId");
           boolean sIsMe = svid == myId;
           int sColorIdx = schColorMap.getOrDefault(svid, 0);
           String svn = (String) sc.get("vetterName");
           String sInit = "?";
           if (svn != null) { String[] sp = svn.trim().split("\\s+"); int si2=(sp.length>1&&sp[0].endsWith("."))?1:0; StringBuilder ssb=new StringBuilder(); for(int si=si2;si<sp.length&&ssb.length()<2;si++) ssb.append(Character.toUpperCase(sp[si].charAt(0))); if(ssb.length()>0) sInit=ssb.toString(); }
    %>
    <div class="comment-card <%= sIsMe ? "mine" : "" %>" style="margin-bottom:0">
      <div class="c-id-bar">
        <div class="c-avatar cv-<%= sColorIdx %>"><%= sInit %></div>
        <div class="c-id-info">
          <div class="c-name">
            <%= svn != null ? svn : "Vetter" %>
            <% if (sIsMe) { %><span class="c-you-tag">You</span><% } %>
            <% if (svBadge != null) { %><span class="badge <%= svBadge %>" style="font-size:10px;margin-left:2px"><%= sv.replace("_"," ") %></span><% } %>
          </div>
          <div class="c-role-line">Vetter &nbsp;·&nbsp; <%= schemeLabel %> Review &nbsp;·&nbsp; <%= sts != null ? ssdf.format(sts) : "" %></div>
        </div>
      </div>
      <div class="c-body-wrap">
        <div class="c-body"><%= ((String)sc.get("commentText")).replace("<","&lt;").replace("\n","<br/>") %></div>
      </div>
    </div>
    <% } } else { %>
    <div style="font-size:12px;color:var(--txt3);padding:4px 0">No comments on <%= schemeLabel %> yet.</div>
    <% } %>
    </div><!-- /section-comment-list -->

    <!-- Add scheme comment form -->
    <div class="add-form-wrap open" id="scheme-form">
      <div class="add-comment-form">
        <div class="form-group">
          <label class="form-label">Feedback on <%= schemeLabel %></label>
          <textarea rows="3" id="scheme-txt" placeholder="Enter your feedback on the <%= isFinal ? "model answers" : "rubric" %>…"></textarea>
        </div>
        <div class="form-group" style="max-width:260px">
          <label class="form-label"><%= schemeLabel %> Status</label>
          <select class="form-sel" id="scheme-verdict">
            <option value="">— No verdict —</option>
            <option value="APPROVED">Approved</option>
            <option value="NEEDS_REVISION">Needs Revision</option>
            <option value="REJECTED">Rejected</option>
          </select>
        </div>
        <div class="form-actions">
          <button class="btn-primary" onclick="submitSectionComment('SCHEME','scheme-txt','scheme-verdict')">Submit Comment</button>
        </div>
      </div>
    </div>
  </div><!-- /sec-scheme -->

  <!-- ════════════ SECTION: VERDICT ════════════ -->
  <span id="sec-verdict" class="sec-anchor"></span>

  <%-- ── Leader Vetter: Approve and Sign section ── --%>
  <% if (isLeaderVetter && paper.isPendingLeaderSign()) { %>
  <div class="verdict-box" style="border:2px solid #15803d;background:#f0fdf4">
    <h3 style="color:#15803d">Leader Vetter — Final Approval</h3>
    <p style="color:#166534">You are the Leader Vetter for this assessment. Once you have reviewed all sections, approve and sign to confirm the paper is ready for submission to KP.</p>
    <div class="form-group" style="margin-bottom:12px">
      <label class="form-label">Remarks (optional)</label>
      <textarea rows="2" id="leader-remarks" placeholder="Optional remarks for the record…" style="background:#fff"></textarea>
    </div>
    <div class="verdict-btns">
      <form method="post" action="<%= ctx %>/VetterDashboardServlet" id="leader-approve-form">
        <input type="hidden" name="action"  value="leaderApprove"/>
        <input type="hidden" name="paperId" value="<%= paperId %>"/>
        <button type="button" onclick="submitLeaderApprove()" style="background:#15803d;color:#fff;font-weight:700;padding:9px 20px;border-radius:7px;border:none;cursor:pointer;font-size:13px">Approve and Sign</button>
      </form>
    </div>
  </div>
  <% } %>

  <div class="verdict-box" <%= isLeaderVetter && paper.isPendingLeaderSign() ? "style='margin-top:12px'" : "" %>>
    <h3>Final Paper Verdict</h3>
    <p>Review all sections above, then submit your overall verdict. Add optional remarks below.</p>
    <!-- Checklist completion summary -->
    <%
      int _vsTotal = 0; int _vsOk = 0;
      if (myChecklist != null && questions != null) {
        for (Question _vq : questions) {
          for (String[] _vc : DAO.VettingChecklistDAO.QUESTION_CRITERIA) {
            _vsTotal++;
            String _vk = DAO.VettingChecklistDAO.buildKey("QUESTION", _vq.getQuestionId(), _vc[0]);
            if (myChecklist.get(_vk) != null && Boolean.TRUE.equals(myChecklist.get(_vk).get("is_ok"))) _vsOk++;
          }
        }
        for (String[] _jvc : DAO.VettingChecklistDAO.JSS_CRITERIA) {
          _vsTotal++;
          String _jvk = DAO.VettingChecklistDAO.buildKey("JSS", null, _jvc[0]);
          if (myChecklist.get(_jvk) != null && Boolean.TRUE.equals(myChecklist.get(_jvk).get("is_ok"))) _vsOk++;
        }
        for (String[] _svc : DAO.VettingChecklistDAO.SCHEME_CRITERIA) {
          _vsTotal++;
          String _svk = DAO.VettingChecklistDAO.buildKey("SCHEME", null, _svc[0]);
          if (myChecklist.get(_svk) != null && Boolean.TRUE.equals(myChecklist.get(_svk).get("is_ok"))) _vsOk++;
        }
      }
      boolean _vsIncomplete = _vsTotal > 0 && _vsOk < _vsTotal;
      int _vsPct = _vsTotal > 0 ? _vsOk * 100 / _vsTotal : 0;
    %>
    <div style="background:<%= _vsIncomplete ? "#fffbeb" : "#f0fdf4" %>;border:1px solid <%= _vsIncomplete ? "#fde68a" : "#b6d98a" %>;border-radius:6px;padding:10px 14px;margin-bottom:14px">
      <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:6px">
        <span style="font-size:12px;font-weight:700;color:<%= _vsIncomplete ? "#b45309" : "var(--green)" %>">
          <%= _vsIncomplete ? "⚠ Checklist Incomplete" : "✓ Checklist Complete" %>
        </span>
        <span style="font-size:11px;font-weight:600;color:var(--txt2)"><%= _vsOk %> / <%= _vsTotal %> criteria checked OK</span>
      </div>
      <div style="height:6px;background:var(--border-lt);border-radius:3px;overflow:hidden">
        <div style="height:100%;width:<%= _vsPct %>%;background:<%= _vsIncomplete ? "#f59e0b" : "var(--green)" %>;border-radius:3px;transition:width .3s"></div>
      </div>
      <% if (_vsIncomplete) { %>
      <div style="font-size:11px;color:#b45309;margin-top:6px">Complete all checklist items before submitting the final verdict.</div>
      <% } %>
    </div>
    <div class="form-group" style="margin-bottom:12px">
      <label class="form-label">Overall Remarks (optional)</label>
      <textarea rows="3" id="overall-remarks" placeholder="e.g. 3 questions need revision before approval…" style="background:var(--surface)"></textarea>
    </div>
    <div class="verdict-btns">
      <button class="btn-approve" onclick="submitVerdict('approve')">Approve Paper</button>
      <button class="btn-improve" onclick="submitVerdict('requestImprovement')">Needs Improvement</button>
      <button class="btn-reject"  onclick="submitVerdict('reject')">Reject</button>
    </div>
    <form id="verdict-form" method="post" action="<%= ctx %>/VetterDashboardServlet" style="display:none">
      <input type="hidden" name="paperId"  value="<%= paperId %>"/>
      <input type="hidden" name="remarks"  id="verdict-remarks"/>
      <input type="hidden" name="action"   id="verdict-action"/>
    </form>
  </div>

</div><!-- /main-col -->

<!-- ── Side panel ── -->
<div class="side-col">

  <!-- JSS Quick View -->
  <div class="side-card">
    <div class="side-title">JSS — Quick View</div>
    <table class="jss-table">
      <thead><tr><th>Topic</th><th>Tax.</th><th>Marks</th></tr></thead>
      <tbody>
        <%
          int[] bloomCounts = new int[7]; // index 1-6 for C1-C6
          int totalJssMarks = 0;
          try (java.sql.Connection scon = util.DBConnection.getConnection()) {
            java.sql.PreparedStatement sps = scon.prepareStatement(
              "SELECT jr.topic_name, jr.taxonomy_level, jr.marks FROM jss_rows jr JOIN jss j ON jr.jss_id=j.jss_id WHERE j.paper_id=? ORDER BY jr.row_order");
            sps.setInt(1, paperId);
            java.sql.ResultSet srs = sps.executeQuery();
            boolean sHasRows = false;
            while (srs.next()) {
              sHasRows = true;
              int m = srs.getInt("marks");
              totalJssMarks += m;
              String tl = srs.getString("taxonomy_level");
              if (tl != null && tl.startsWith("C") && tl.length()==2) {
                try { int ci = Integer.parseInt(tl.substring(1)); if(ci>=1&&ci<=6) bloomCounts[ci]+=m; } catch(Exception ignored) {}
              }
        %>
        <tr>
          <td style="max-width:90px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap" title="<%= srs.getString("topic_name") %>">
            <%= srs.getString("topic_name") != null ? srs.getString("topic_name") : "—" %></td>
          <td><span class="tax-badge"><%= srs.getString("taxonomy_level") != null ? srs.getString("taxonomy_level") : "—" %></span></td>
          <td style="text-align:right;font-weight:600"><%= m %></td>
        </tr>
        <% } if (!sHasRows) { %>
        <tr><td colspan="3" style="color:var(--txt3);text-align:center;padding:8px">No JSS data</td></tr>
        <% } srs.close(); sps.close(); } catch(Exception es){ es.printStackTrace(); } %>
      </tbody>
    </table>

    <!-- Bloom's distribution bars -->
    <% int lowOrder=bloomCounts[1]+bloomCounts[2], midOrder=bloomCounts[3]+bloomCounts[4], highOrder=bloomCounts[5]+bloomCounts[6];
       int total4bar = lowOrder+midOrder+highOrder; if(total4bar==0) total4bar=1; %>
    <div style="margin-top:12px">
      <div style="font-size:10px;font-weight:600;color:var(--txt2);margin-bottom:7px">Bloom's Distribution (by marks)</div>
      <div class="bar-lbl"><span>Low (C1–C2)</span><span><%= Math.round(lowOrder*100.0/total4bar) %>%</span></div>
      <div class="bar-track"><div class="bar-fill" style="width:<%= Math.round(lowOrder*100.0/total4bar) %>%;background:#B5D4F4"></div></div>
      <div class="bar-lbl"><span>Mid (C3–C4)</span><span><%= Math.round(midOrder*100.0/total4bar) %>%</span></div>
      <div class="bar-track"><div class="bar-fill" style="width:<%= Math.round(midOrder*100.0/total4bar) %>%;background:#5DCAA5"></div></div>
      <div class="bar-lbl"><span>High (C5–C6)</span><span><%= Math.round(highOrder*100.0/total4bar) %>%</span></div>
      <div class="bar-track"><div class="bar-fill" style="width:<%= Math.round(highOrder*100.0/total4bar) %>%;background:#7F77DD"></div></div>
    </div>
    <div style="margin-top:10px;padding:8px 10px;background:var(--bg);border-radius:6px">
      <div style="font-size:10px;color:var(--txt2);margin-bottom:2px">JSS total marks</div>
      <div style="font-size:17px;font-weight:600"><%= totalJssMarks %></div>
    </div>
  </div>

  <!-- Progress summary -->
  <div class="side-card">
    <div class="side-title">Review Progress</div>
    <%
      int progPct = totalQs > 0 ? ((approvedCount + needsRevCount + rejectedCount) * 100 / totalQs) : 0;
    %>
    <div style="display:flex;justify-content:space-between;font-size:11px;margin-bottom:5px">
      <span style="color:var(--txt2)">Actioned</span>
      <span style="font-weight:700"><%= approvedCount + needsRevCount + rejectedCount %> / <%= totalQs %></span>
    </div>
    <div class="bar-track" style="height:8px;margin-bottom:10px">
      <div class="bar-fill" style="width:<%= progPct %>%;background:var(--blue)"></div>
    </div>
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:6px;font-size:11px">
      <div style="background:var(--green-bg);border-radius:5px;padding:6px 8px">
        <div style="color:var(--green);font-weight:700;font-size:15px"><%= approvedCount %></div>
        <div style="color:var(--green)">Approved</div>
      </div>
      <div style="background:var(--amber-bg);border-radius:5px;padding:6px 8px">
        <div style="color:var(--amber);font-weight:700;font-size:15px"><%= needsRevCount %></div>
        <div style="color:var(--amber)">Needs Rev.</div>
      </div>
      <div style="background:var(--red-bg);border-radius:5px;padding:6px 8px">
        <div style="color:var(--red);font-weight:700;font-size:15px"><%= rejectedCount %></div>
        <div style="color:var(--red)">Rejected</div>
      </div>
      <div style="background:var(--border-lt);border-radius:5px;padding:6px 8px">
        <div style="color:var(--txt2);font-weight:700;font-size:15px"><%= pendingCount %></div>
        <div style="color:var(--txt2)">Pending</div>
      </div>
    </div>
  </div>

  <!-- Assigned vetters -->
  <% if (assignedVetters != null && !assignedVetters.isEmpty()) { %>
  <div class="side-card">
    <div class="side-title">Assigned Vetters</div>
    <% for (User av : assignedVetters) { %>
    <div style="display:flex;align-items:center;gap:8px;padding:5px 0;border-bottom:1px solid var(--border-lt)">
      <div style="width:26px;height:26px;border-radius:50%;background:var(--blue-lt);display:grid;place-items:center;font-size:10px;font-weight:600;color:var(--blue);flex-shrink:0">
        <% String avn = av.getFullName();
           if (avn != null && !avn.trim().isEmpty()) {
             String[] avp = avn.trim().split("\\s+");
             int avs = (avp.length > 1 && avp[0].endsWith(".")) ? 1 : 0;
             StringBuilder avsb = new StringBuilder();
             for (int avi = avs; avi < avp.length && avsb.length() < 2; avi++)
               avsb.append(Character.toUpperCase(avp[avi].charAt(0)));
             out.print(avsb.length() > 0 ? avsb.toString() : "?");
           } else { out.print("?"); } %>
      </div>
      <div>
        <div style="font-size:11px;font-weight:600"><%= av.getFullName() %></div>
        <div style="font-size:10px;color:var(--txt3)"><%= av.getEmail() %></div>
      </div>
    </div>
    <% } %>
  </div>
  <% } %>

</div><!-- /side-col -->
</div><!-- /page -->

<%-- DISCUSSION PANEL — full width below two-column layout --%>
<div style="max-width:1100px;margin:0 auto;padding:0 22px 60px">
  <% request.setAttribute("msgPaperId", paperId); %>
  <jsp:include page="messagePanel.jsp"/>
</div>

<script>
const CTX = '<%= ctx %>';
const PAPER_ID = <%= paperId %>;

/* ── Toast notification system ── */
var _toastContainer = null;
function showToast(msg, type) {
  if (!_toastContainer) {
    _toastContainer = document.createElement('div');
    _toastContainer.style.cssText = 'position:fixed;top:16px;right:20px;z-index:9999;display:flex;flex-direction:column;gap:6px;pointer-events:none';
    document.body.appendChild(_toastContainer);
  }
  var t = document.createElement('div');
  t.style.cssText = 'background:'+(type==='success'?'#166534':type==='error'?'#be123c':'#1e293b')+';color:#fff;padding:8px 14px;border-radius:8px;font-size:12px;font-weight:600;box-shadow:0 4px 12px rgba(0,0,0,.2);display:flex;align-items:center;gap:8px;transform:translateX(120%);transition:transform .25s ease;pointer-events:all';
  t.innerHTML = (type==='success'?'<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>':type==='error'?'<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>':'') + msg;
  _toastContainer.appendChild(t);
  requestAnimationFrame(function(){ t.style.transform = 'translateX(0)'; });
  setTimeout(function(){ t.style.transform = 'translateX(120%)'; setTimeout(function(){ _toastContainer.removeChild(t); }, 280); }, 2800);
}

/* ── Checklist scroll navigation ── */
function scrollToSection(id) {
  var el = document.getElementById(id);
  if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

/* ── Toggle question comments ── */
function toggleQ(qid) {
  var w = document.getElementById('qwrap-' + qid);
  var l = document.getElementById('qlbl-' + qid);
  var hidden = w.classList.toggle('hidden');
  l.textContent = hidden ? 'Click to view comments' : 'Hide comments';
}

/* ── Toggle all-vetters panel ── */
function toggleAvp(key) {
  var toggle = document.getElementById('avp-toggle-' + key);
  var body   = document.getElementById('avp-body-' + key);
  if (!toggle || !body) return;
  var open = body.classList.toggle('open');
  toggle.classList.toggle('open', open);
}

/* ── Update checklist row visual state ── */
function updateRowState(rowId, isOk) {
  var row = document.getElementById(rowId);
  if (!row) return;
  row.classList.remove('vcl-row-ok','vcl-row-fail','vcl-row-empty');
  row.classList.add(isOk ? 'vcl-row-ok' : 'vcl-row-fail');
}

/* ── Click handler for two-button checklist setup (OK vs Fail) ── */
function clickChecklistButton(section, refId, criterionKey, clickOk) {
  var prefix = section === 'QUESTION' ? 'Q' : section;
  var btnOk = document.getElementById('clok-' + prefix + '-' + refId + '-' + criterionKey);
  var btnFail = document.getElementById('clfail-' + prefix + '-' + refId + '-' + criterionKey);
  if (!btnOk || !btnFail) return;

  var currentOk = btnOk.dataset.ok === '1';
  var currentFail = btnFail.dataset.fail === '1';
  var commentEl = document.getElementById('clc-' + prefix + '-' + refId + '-' + criterionKey);
  var comment = commentEl ? commentEl.value : '';

  if (clickOk) {
    if (currentOk) {
      // Toggle off -> Untouched (delete from DB)
      btnOk.dataset.ok = '0';
      btnOk.classList.remove('active');
      btnFail.dataset.fail = '0';
      btnFail.classList.remove('active');
      
      var row = document.getElementById('clrow-' + prefix + '-' + refId + '-' + criterionKey);
      if (row) {
        row.classList.remove('vcl-row-ok', 'vcl-row-fail');
        row.classList.add('vcl-row-empty');
      }
      saveChecklistItem(section, refId, criterionKey, false, comment, btnOk, true);
    } else {
      // Toggle on OK
      btnOk.dataset.ok = '1';
      btnOk.classList.add('active');
      btnFail.dataset.fail = '0';
      btnFail.classList.remove('active');
      
      var row = document.getElementById('clrow-' + prefix + '-' + refId + '-' + criterionKey);
      if (row) {
        row.classList.remove('vcl-row-fail', 'vcl-row-empty');
        row.classList.add('vcl-row-ok');
      }
      saveChecklistItem(section, refId, criterionKey, true, comment, btnOk, false);
    }
  } else {
    if (currentFail) {
      // Toggle off -> Untouched (delete from DB)
      btnOk.dataset.ok = '0';
      btnOk.classList.remove('active');
      btnFail.dataset.fail = '0';
      btnFail.classList.remove('active');
      
      var row = document.getElementById('clrow-' + prefix + '-' + refId + '-' + criterionKey);
      if (row) {
        row.classList.remove('vcl-row-ok', 'vcl-row-fail');
        row.classList.add('vcl-row-empty');
      }
      saveChecklistItem(section, refId, criterionKey, false, comment, btnFail, true);
    } else {
      // Toggle on Fail
      btnOk.dataset.ok = '0';
      btnOk.classList.remove('active');
      btnFail.dataset.fail = '1';
      btnFail.classList.add('active');
      
      var row = document.getElementById('clrow-' + prefix + '-' + refId + '-' + criterionKey);
      if (row) {
        row.classList.remove('vcl-row-ok', 'vcl-row-empty');
        row.classList.add('vcl-row-fail');
      }
      saveChecklistItem(section, refId, criterionKey, false, comment, btnFail, false);
    }
  }
}

/* ── Blur handler for comment input to save checklist comments dynamically ── */
function saveChecklistItemComment(section, refId, criterionKey, comment) {
  var prefix = section === 'QUESTION' ? 'Q' : section;
  var btnOk = document.getElementById('clok-' + prefix + '-' + refId + '-' + criterionKey);
  var btnFail = document.getElementById('clfail-' + prefix + '-' + refId + '-' + criterionKey);
  if (!btnOk || !btnFail) return;
  
  var isOk = btnOk.dataset.ok === '1';
  var isFail = btnFail.dataset.fail === '1';
  
  if (!isOk && !isFail) {
    if (comment.trim() === '') {
      saveChecklistItem(section, refId, criterionKey, false, '', null, true);
    } else {
      saveChecklistItem(section, refId, criterionKey, false, comment, null, false);
    }
  } else {
    saveChecklistItem(section, refId, criterionKey, isOk, comment, null, false);
  }
}

/* ── Update progress badge for a section ── */
function updateProgressBadge(progId, keys, section, refId) {
  var badge = document.getElementById(progId);
  if (!badge) return;
  var ok = 0;
  var prefix = section === 'QUESTION' ? 'Q' : section;
  for (var i = 0; i < keys.length; i++) {
    var btn = document.getElementById('clok-' + prefix + '-' + refId + '-' + keys[i]);
    if (btn && btn.dataset.ok === '1') ok++;
  }
  badge.textContent = ok + ' / ' + keys.length + ' OK';
  badge.className = 'vcl-progress-badge' + (ok === keys.length ? ' all-ok' : ok > 0 ? ' has-issues' : '');
}

/* ── Mark all criteria OK for a section ── */
function markAllOk(section, refId, keys) {
  var prefix = section === 'QUESTION' ? 'Q' : section;
  for (var i = 0; i < keys.length; i++) {
    var btnOk = document.getElementById('clok-' + prefix + '-' + refId + '-' + keys[i]);
    var btnFail = document.getElementById('clfail-' + prefix + '-' + refId + '-' + keys[i]);
    if (btnOk) {
      btnOk.dataset.ok = '1';
      btnOk.classList.add('active');
    }
    if (btnFail) {
      btnFail.dataset.fail = '0';
      btnFail.classList.remove('active');
    }
    var cmt = document.getElementById('clc-' + prefix + '-' + refId + '-' + keys[i]);
    var cmtVal = cmt ? cmt.value : '';
    saveChecklistItem(section, refId, keys[i], true, cmtVal, null, false);
    
    var row = document.getElementById('clrow-' + prefix + '-' + refId + '-' + keys[i]);
    if (row) {
      row.classList.remove('vcl-row-fail', 'vcl-row-empty');
      row.classList.add('vcl-row-ok');
    }
  }
  showToast('All criteria marked as OK', 'success');
  var badge = document.getElementById('prog-' + prefix + '-' + refId);
  if (badge) { badge.textContent = keys.length + ' / ' + keys.length + ' OK'; badge.className = 'vcl-progress-badge all-ok'; }
}

/* ── Robust fetch helper — handles non-JSON responses gracefully ── */
function postJSON(btn, fd, onSuccess) {
  fetch(CTX + '/VetterDashboardServlet', { method: 'POST', body: fd })
    .then(function(r) {
      var ct = r.headers.get('Content-Type') || '';
      if (!ct.includes('application/json')) {
        if (r.url.indexOf('login') !== -1 || r.status === 401) {
          alert('Your session has expired. Please log in again.');
          window.location.href = CTX + '/login.jsp';
        } else {
          alert('Server error (status ' + r.status + '). Please refresh and try again.');
        }
        if (btn) { btn.disabled = false; }
        throw new Error('non-json');
      }
      return r.json();
    })
    .then(onSuccess)
    .catch(function(err) {
      if (err.message !== 'non-json') {
        alert('Network error — please check your connection and try again.');
        if (btn) { btn.disabled = false; }
      }
    });
}

/* ── Submit question comment via AJAX ── */
function submitQComment(qid) {
  var txt     = document.getElementById('qtxt-' + qid).value.trim();
  var tax     = document.getElementById('qtax-' + qid).value;
  var verdict = document.getElementById('qverdict-' + qid).value;
  var ctag    = document.getElementById('qctag-' + qid).value;
  var ttag    = document.getElementById('qttag-' + qid).value;

  if (!txt) { alert('Please enter a comment before submitting.'); return; }

  var fd = new FormData();
  fd.append('action',            'saveComment');
  fd.append('questionId',        qid);
  fd.append('commentText',       txt);
  fd.append('contentTag',        ctag);
  fd.append('taxonomyTag',       ttag);
  fd.append('verdict',           verdict);
  fd.append('suggestedTaxonomy', tax);

  postJSON(null, fd, function(data) {
    if (data.success) { location.reload(); }
    else { alert('Error saving comment: ' + (data.message || 'Unknown error')); }
  });
}

/* ── Clear (delete) a question comment ── */
function clearComment(qid) {
  if (!confirm('Remove your comment on this question?')) return;
  var fd = new FormData();
  fd.append('action', 'deleteComment');
  fd.append('questionId', qid);
  postJSON(null, fd, function(data) {
    if (data.success) location.reload(); else alert('Delete failed: ' + (data.message || ''));
  });
}

/* ── Submit JSS or Scheme section comment ── */
function submitSectionComment(section, txtId, verdictId) {
  var txt     = document.getElementById(txtId).value.trim();
  var verdict = document.getElementById(verdictId).value;
  if (!txt) { alert('Please enter a comment before submitting.'); return; }

  var btn = event.target;
  btn.disabled = true; btn.textContent = 'Saving…';

  var fd = new FormData();
  fd.append('action',      'saveSectionComment');
  fd.append('paperId',     PAPER_ID);
  fd.append('section',     section);
  fd.append('commentText', txt);
  fd.append('verdict',     verdict);

  postJSON(btn, fd, function(data) {
    if (data.success) {
      location.reload();
    } else {
      btn.disabled = false; btn.textContent = 'Submit Comment';
      alert('Error: ' + (data.message || 'Unknown error'));
    }
  });
}

/* ── Paper final verdict (with checklist completion guard) ── */
function submitVerdict(action) {
  var remarks = document.getElementById('overall-remarks').value.trim();

  // Checklist completion guard — count OK toggle buttons
  var allToggles = document.querySelectorAll('.vcl-btn-ok');
  var totalChecks = allToggles.length;
  var okChecks = 0;
  for (var i = 0; i < allToggles.length; i++) { if (allToggles[i].dataset.ok === '1') okChecks++; }
  var pct = totalChecks > 0 ? Math.round(okChecks * 100 / totalChecks) : 100;

  if (okChecks < totalChecks && action === 'approve') {
    if (!confirm('⚠ Checklist is only ' + pct + '% complete (' + okChecks + '/' + totalChecks + ' criteria marked OK).\n\nAre you sure you want to APPROVE this paper with an incomplete checklist?')) return;
  } else {
    var labels = {approve:'Approve this paper?', requestImprovement:'Request improvement for this paper?', reject:'Reject this paper?'};
    if (!confirm(labels[action] || 'Submit verdict?')) return;
  }

  document.getElementById('verdict-action').value  = action;
  document.getElementById('verdict-remarks').value = remarks;
  document.getElementById('verdict-form').submit();
}

/* ── Save a single checklist item via XMLHttpRequest ── */
function saveChecklistItem(section, refId, criterionKey, isOk, comment, triggerEl, isDelete) {
  // Update row state immediately for instant visual feedback
  var prefix = section === 'QUESTION' ? 'Q' : section;
  var rowId = 'clrow-' + prefix + '-' + refId + '-' + criterionKey;
  if (isDelete) {
    var row = document.getElementById(rowId);
    if (row) {
      row.classList.remove('vcl-row-ok', 'vcl-row-fail');
      row.classList.add('vcl-row-empty');
    }
  } else {
    updateRowState(rowId, isOk);
  }

  var fd = new FormData();
  fd.append('action',       'saveChecklist');
  fd.append('paperId',      PAPER_ID);
  fd.append('section',      section);
  fd.append('refId',        refId);
  fd.append('criterionKey', criterionKey);
  fd.append('isOk',         isOk ? '1' : '0');
  fd.append('comment',      comment || '');
  if (isDelete) {
    fd.append('delete',     '1');
  }

  var xhr = new XMLHttpRequest();
  xhr.open('POST', CTX + '/VetterDashboardServlet', true);
  xhr.onreadystatechange = function() {
    if (xhr.readyState !== 4) return;
    if (xhr.status === 200) {
      try {
        var data = JSON.parse(xhr.responseText);
        if (data.success) {
          showToast('Saved', 'success');
          // Derive the keys array for this section to update the badge
          var sectionKeys = [];
          var allRows = document.querySelectorAll('[id^="clrow-' + prefix + '-' + refId + '-"]');
          for (var i = 0; i < allRows.length; i++) {
            var rid = allRows[i].id.replace('clrow-' + prefix + '-' + refId + '-', '');
            sectionKeys.push(rid);
          }
          updateProgressBadge('prog-' + prefix + '-' + refId, sectionKeys, section, refId);
        } else {
          showToast('Save failed: ' + (data.message || 'Unknown error'), 'error');
        }
      } catch(e) {
        if (xhr.responseURL && xhr.responseURL.indexOf('login') !== -1) {
          alert('Your session has expired. Please log in again.');
          window.location.href = CTX + '/login.jsp';
        }
      }
    }
  };
  xhr.send(fd);
}

function submitLeaderApprove() {
  if (!confirm('Approve and sign this assessment? This will allow you to submit it to KP.')) return;
  document.getElementById('leader-approve-form').submit();
}
</script>
</body>
</html>
