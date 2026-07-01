<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Model.Assessment, Model.Question, Model.QuestionComment" %>
<%@ page import="java.util.List, java.util.Map" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp"); return;
    }
    int    myId      = (int)    sess.getAttribute("userId");
    String myName    = (String) sess.getAttribute("fullName");
    String myRole    = (String) sess.getAttribute("role");
    String ctx       = request.getContextPath();

    Assessment     paper      = (Assessment)     request.getAttribute("paper");
    List<Question> questions  = (List<Question>) request.getAttribute("questions");
    Map<Integer,List<QuestionComment>> commentMap =
        (Map<Integer,List<QuestionComment>>) request.getAttribute("commentMap");
    List<Map<String,Object>> jssComments    = (List<Map<String,Object>>) request.getAttribute("jssComments");
    List<Map<String,Object>> schemeComments = (List<Map<String,Object>>) request.getAttribute("schemeComments");
    boolean isOwner     = Boolean.TRUE.equals(request.getAttribute("isOwner"));
    String  viewerRole  = (String) request.getAttribute("viewerRole");
    @SuppressWarnings("unchecked")
    java.util.List<java.util.Map<String,Object>> allChecklists =
        (java.util.List<java.util.Map<String,Object>>) request.getAttribute("allChecklists");

    if (paper == null) { response.sendRedirect(ctx + "/LecturerDashboardServlet"); return; }

    int     paperId    = paper.getPaperId();
    boolean isFinal    = paper.isFinalAssessment();
    String  schemeLabel = isFinal ? "Answer Scheme" : "Rubric";
    String  status      = paper.getStatus() != null ? paper.getStatus() : "";

    // Verdict display config
    String verdictLabel  = "APPROVED".equals(status)          ? "Approved by Vetter"
                         : "NEEDS_IMPROVEMENT".equals(status) ? "Needs Improvement — Please Revise"
                         : "REJECTED".equals(status)          ? "Rejected"
                         : "UNDER_REVIEW".equals(status)      ? "Under Review"
                         : status;
    String verdictColor  = "APPROVED".equals(status)          ? "#15803d"
                         : "NEEDS_IMPROVEMENT".equals(status) ? "#b45309"
                         : "REJECTED".equals(status)          ? "#be123c"
                         : "#185FA5";
    String verdictBg     = "APPROVED".equals(status)          ? "#dcfce7"
                         : "NEEDS_IMPROVEMENT".equals(status) ? "#fef3c7"
                         : "REJECTED".equals(status)          ? "#fce7f3"
                         : "#e0f2fe";

    int totalQs     = questions != null ? questions.size() : 0;
    int approvedQs  = 0, needsRevQs = 0, rejectedQs = 0, pendingQs = 0;
    if (questions != null) for (Question q : questions) {
        String qs = q.getStatus() != null ? q.getStatus() : "DRAFT";
        if      ("APPROVED".equals(qs))       approvedQs++;
        else if ("NEEDS_REVISION".equals(qs)) needsRevQs++;
        else if ("REJECTED".equals(qs))       rejectedQs++;
        else                                   pendingQs++;
    }

    // Nav initials
    String navInit = "?";
    if (myName != null && !myName.trim().isEmpty()) {
        String[] np = myName.trim().split("\\s+");
        int ns = (np.length > 1 && np[0].endsWith(".")) ? 1 : 0;
        StringBuilder nsb = new StringBuilder();
        for (int i = ns; i < np.length && nsb.length() < 2; i++)
            nsb.append(Character.toUpperCase(np[i].charAt(0)));
        if (nsb.length() > 0) navInit = nsb.toString();
    }

    // Back URL
    String backUrl = "Lecturer".equalsIgnoreCase(myRole) || "LECTURER".equalsIgnoreCase(myRole)
        ? ctx + "/LecturerDashboardServlet"
        : "KP".equalsIgnoreCase(myRole)
        ? ctx + "/KPDashboardServlet"
        : ctx + "/VetterDashboardServlet?page=queue";
    String backLabel = "Lecturer".equalsIgnoreCase(myRole) || "LECTURER".equalsIgnoreCase(myRole)
        ? "My Assessments" : "KP".equalsIgnoreCase(myRole) ? "KP Dashboard" : "Vetting Queue";

    java.text.SimpleDateFormat dtFmt = new java.text.SimpleDateFormat("d MMM yyyy, HH:mm");
    java.text.SimpleDateFormat dFmt  = new java.text.SimpleDateFormat("d MMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>Vetter Feedback — <%= paper.getCourseCode() %></title>
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
.page{max-width:1100px;margin:0 auto;padding:20px 18px 60px}

/* ── Verdict banner ── */
.verdict-banner{border-radius:var(--r);padding:16px 20px;margin-bottom:16px;border:1px solid;display:flex;align-items:flex-start;gap:14px}
.vb-icon{width:36px;height:36px;border-radius:50%;display:grid;place-items:center;flex-shrink:0}
.vb-icon svg{width:18px;height:18px}
.vb-title{font-size:14px;font-weight:700;margin-bottom:3px}
.vb-sub{font-size:12px;opacity:.85;line-height:1.5}
.vb-remarks{margin-top:8px;padding:8px 12px;border-radius:6px;font-size:12px;line-height:1.6;background:rgba(0,0,0,.05)}

/* ── Paper header ── */
.paper-hdr{background:var(--navy);border-radius:var(--r);padding:18px 22px;margin-bottom:16px}
.paper-hdr h1{font-size:16px;font-weight:700;color:#fff;margin-bottom:3px}
.paper-hdr p{font-size:12px;color:rgba(255,255,255,.5)}
.paper-hdr-meta{display:flex;gap:7px;flex-wrap:wrap;margin-top:10px}
.hbadge{padding:3px 10px;border-radius:20px;font-size:11px;font-weight:600}
.hb-teal{background:rgba(91,33,182,.2);color:#5eead4}
.hb-blue{background:rgba(24,95,165,.25);color:#93c5fd}

/* ── KP observer ribbon ── */
.observer-ribbon{background:#1e3a5f;color:#93c5fd;font-size:11px;padding:7px 18px;text-align:center;margin-bottom:14px;border-radius:var(--r)}

/* ── Stats row ── */
.stats-row{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-bottom:16px}
.stat-card{background:var(--surface);border-radius:var(--r);padding:12px 14px;border:1px solid var(--border);box-shadow:var(--sh)}
.stat-lbl{font-size:10px;color:var(--txt2);margin-bottom:4px;text-transform:uppercase;letter-spacing:.04em}
.stat-val{font-size:22px;font-weight:600}
.sv-blue{color:var(--blue)} .sv-green{color:var(--green)} .sv-amber{color:var(--amber)} .sv-red{color:var(--red)}

/* ── Tabs ── */
.tab-bar{display:flex;gap:2px;background:var(--border-lt);border-radius:var(--r);padding:3px;margin-bottom:14px}
.tab-btn{flex:1;padding:8px 12px;border-radius:6px;border:none;background:transparent;font-size:12px;font-weight:600;color:var(--txt2);cursor:pointer;transition:.15s}
.tab-btn:hover{background:var(--surface)}
.tab-btn.active{background:var(--surface);color:var(--txt);box-shadow:var(--sh)}
.tab-panel{display:none}.tab-panel.active{display:block}

/* ── Question cards ── */
.q-card{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);margin-bottom:12px;overflow:hidden;box-shadow:var(--sh)}
.q-card.qs-approved{border-left:3px solid var(--green)}
.q-card.qs-needs   {border-left:3px solid #BA7517}
.q-card.qs-rejected{border-left:3px solid var(--red)}
.q-card.qs-draft   {border-left:3px solid var(--border)}
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
.dot-g{background:#639922}.dot-a{background:#BA7517}.dot-r{background:#E24B4A}
.tax-chip{font-size:10px;padding:2px 7px;border-radius:4px;background:var(--purple-bg);color:var(--purple);font-weight:500}
.q-divider{height:1px;background:var(--border-lt)}

/* ── Review feedback section ── */
.feedback-section{padding:14px 16px}
.feedback-empty{font-size:12px;color:var(--txt3);padding:6px 0}

/* ── Vetter comment cards ── */
.vc-list{display:flex;flex-direction:column;gap:10px}
.vc-card{background:var(--surface);border-radius:8px;border:1px solid var(--border);overflow:hidden}
.vc-id-bar{display:flex;align-items:center;gap:10px;padding:9px 13px;border-bottom:1px solid var(--border-lt)}
.vc-avatar{width:30px;height:30px;border-radius:50%;display:grid;place-items:center;font-size:11px;font-weight:700;flex-shrink:0;color:#fff}
.cv-0{background:#185FA5}.cv-1{background:#5b21b6}.cv-2{background:#7c3aed}.cv-3{background:#b45309}.cv-4{background:#be123c}
.vc-id-info{flex:1;min-width:0}
.vc-name{font-size:12px;font-weight:700;color:var(--txt);display:flex;align-items:center;gap:6px}
.vc-role-line{font-size:10px;color:var(--txt2);margin-top:1px}
.vc-body-wrap{padding:10px 13px}
.vc-body{font-size:12px;color:var(--txt);line-height:1.6;margin-bottom:6px}
.vc-tags{display:flex;gap:5px;flex-wrap:wrap}
.ctag{font-size:10px;padding:2px 7px;border-radius:4px}
.ctag-teal  {background:var(--teal-bg);color:var(--teal-txt)}
.ctag-purple{background:var(--purple-bg);color:var(--purple)}
.ctag-green {background:var(--green-bg);color:var(--green)}
.ctag-amber {background:var(--amber-bg);color:var(--amber)}
.ctag-red   {background:var(--red-bg);color:var(--red)}

/* ── Read-only vetting checklist ── */
.rcl-wrap{padding:12px 16px;background:#fafbfc;border-top:1px solid var(--border-lt)}
.rcl-title{font-size:10px;font-weight:700;color:var(--txt3);text-transform:uppercase;letter-spacing:.05em;margin-bottom:8px}
.rcl-vetter-hdr{font-size:11px;font-weight:700;color:var(--txt);margin:8px 0 4px;display:flex;align-items:center;gap:6px}
.rcl-table{width:100%;border-collapse:collapse;font-size:11px;margin-bottom:6px}
.rcl-table th{font-size:10px;font-weight:600;color:var(--txt2);padding:4px 8px;border-bottom:1px solid var(--border);background:var(--border-lt);text-align:left}
.rcl-table td{padding:6px 8px;border-bottom:1px solid var(--border-lt);vertical-align:top}
.rcl-table tr:last-child td{border-bottom:none}
.rcl-ok{color:var(--green);font-weight:700;font-size:14px}
.rcl-no{color:#dc2626;font-weight:700;font-size:14px}
.rcl-table tr.rcl-fail-row{background:#fff5f5}
.rcl-table tr.rcl-fail-row td{border-bottom-color:#fecaca}
.rcl-fail-crit{font-weight:600;color:#b91c1c}
.rcl-fail-cmt{font-size:11px;color:#b91c1c;margin-top:3px;line-height:1.4;font-style:italic}
.rcl-ok-cmt{font-size:11px;color:var(--txt2);margin-top:3px}
/* Needs-improvement banner */
.ni-banner{background:#fff7ed;border:1px solid #fed7aa;border-radius:8px;padding:12px 16px;
  margin-bottom:16px;display:flex;gap:10px;align-items:flex-start}
.ni-banner-icon{color:#ea580c;font-size:18px;flex-shrink:0;margin-top:1px}
.ni-banner-body{flex:1}
.ni-banner-title{font-size:13px;font-weight:700;color:#9a3412;margin-bottom:4px}
.ni-banner-text{font-size:12px;color:#c2410c;line-height:1.5}
.rcl-fail-count{display:inline-block;background:#fef2f2;border:1px solid #fecaca;color:#dc2626;
  font-size:10px;font-weight:700;border-radius:10px;padding:1px 7px;margin-left:6px}
/* ── Section comment card ── */
.sec-comment-list{display:flex;flex-direction:column;gap:10px;margin-bottom:16px}
.info-box{background:var(--blue-lt);border:1px solid #bfdbfe;border-radius:6px;padding:10px 13px;font-size:12px;color:#1e40af;margin-bottom:12px}
.empty-note{font-size:12px;color:var(--txt3);padding:6px 0}
.jss-table{width:100%;border-collapse:collapse;font-size:12px;border:1px solid var(--border);border-radius:var(--r)}
.jss-table th{font-size:10px;color:#fff;font-weight:600;padding:9px 12px;text-align:left;background:var(--navy)}
.jss-table td{padding:8px 12px;border-bottom:1px solid var(--border-lt);color:var(--txt)}
.jss-table tr:last-child td{border-bottom:none}
.tax-badge{font-size:9px;padding:1px 5px;border-radius:3px;background:var(--purple-bg);color:var(--purple);font-weight:600}
.section-hdr{display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;margin-top:20px}
.section-hdr h2{font-size:13px;font-weight:700}

/* ── Action strip for lecturer ── */
.action-strip{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);padding:16px 20px;margin-top:20px;display:flex;align-items:center;justify-content:space-between;gap:12px;flex-wrap:wrap;box-shadow:var(--sh)}
.action-strip p{font-size:12px;color:var(--txt2);max-width:520px;line-height:1.6}
.btn-primary{background:var(--blue);color:#fff;border:none;border-radius:6px;padding:9px 20px;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-block}
.btn-primary:hover{background:var(--blue-dk)}

@media(max-width:640px){.stats-row{grid-template-columns:repeat(2,1fr)}}
</style>
</head>
<body>

<!-- ── Topnav ── -->
<nav class="topnav">
  <a class="brand" href="<%= backUrl %>">
    <img src="<%= ctx %>/images/umt-logo.png" alt="UMT" class="brand-logo">
    <div><div class="brand-name">E-Vetting</div><div class="brand-sub">UMT</div></div>
  </a>
  <div class="nav-bc">
    <a href="<%= backUrl %>"><%= backLabel %></a>
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
    <span style="color:rgba(255,255,255,.85);"><%= paper.getCourseCode() %> — Vetter Feedback</span>
  </div>
  <div class="nav-right">
    <a href="<%= ctx %>/UserProfileServlet" class="nav-user-link">
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

  <!-- KP / Vetter observer ribbon -->
  <% if (!isOwner) { %>
  <div class="observer-ribbon">
    You are viewing this feedback as <strong><%= myRole %></strong> — read-only oversight access.
  </div>
  <% } %>

  <!-- ── Verdict banner ── -->
  <div class="verdict-banner" style="background:<%= verdictBg %>;border-color:<%= verdictColor %>;color:<%= verdictColor %>">
    <div class="vb-icon" style="background:<%= verdictColor %>20">
      <% if ("APPROVED".equals(status)) { %>
      <svg fill="none" stroke="<%= verdictColor %>" stroke-width="2.5" viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
      <% } else if ("NEEDS_IMPROVEMENT".equals(status)) { %>
      <svg fill="none" stroke="<%= verdictColor %>" stroke-width="2.5" viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
      <% } else { %>
      <svg fill="none" stroke="<%= verdictColor %>" stroke-width="2.5" viewBox="0 0 24 24"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
      <% } %>
    </div>
    <div style="flex:1">
      <div class="vb-title"><%= verdictLabel %></div>
      <div class="vb-sub">
        <%= paper.getCourseCode() %> — <%= paper.getCourseTitle() %> &nbsp;|&nbsp;
        <%= paper.getAcademicSession() %> Sem <%= paper.getSemester() %>
        <% if (paper.getSubmittedDate() != null) { %>
          &nbsp;|&nbsp; Submitted: <%= dFmt.format(paper.getSubmittedDate()) %>
        <% } %>
      </div>
      <% String remarks = paper.getRemarks();
         if (remarks != null && !remarks.trim().isEmpty()) { %>
      <div class="vb-remarks" style="border-left:3px solid <%= verdictColor %>"><strong>Vetter remarks:</strong> <%= remarks.replace("<","&lt;") %></div>
      <% } %>
    </div>
  </div>

  <!-- ── Needs-improvement checklist summary ── -->
  <% if ("NEEDS_IMPROVEMENT".equals(status) && allChecklists != null && !allChecklists.isEmpty()) {
       // Count all failing items
       int _niFails = 0;
       java.util.LinkedHashMap<String,java.util.List<String>> _niMap = new java.util.LinkedHashMap<String,java.util.List<String>>();
       for (java.util.Map<String,Object> _ni : allChecklists) {
           if (!Boolean.TRUE.equals(_ni.get("is_ok"))) {
               _niFails++;
               String _niVetter = (String) _ni.get("vetter_name");
               String _niCmt    = _ni.get("comment") != null ? (String) _ni.get("comment") : "";
               String _niSec    = (String) _ni.get("section");
               String _niKey    = (String) _ni.get("criterion_key");
               // Find criterion label
               String _niLabel  = _niKey;
               for (String[][] _cArr : new String[][][]{DAO.VettingChecklistDAO.QUESTION_CRITERIA, DAO.VettingChecklistDAO.JSS_CRITERIA, DAO.VettingChecklistDAO.SCHEME_CRITERIA}) {
                   for (String[] _ce : _cArr) { if (_ce[0].equals(_niKey)) { _niLabel = _ce[1]; break; } }
               }
               String _niMapKey = "[" + _niSec + "] " + _niLabel;
               if (!_niMap.containsKey(_niMapKey)) _niMap.put(_niMapKey, new java.util.ArrayList<String>());
               _niMap.get(_niMapKey).add((_niVetter != null ? _niVetter : "Vetter") + (_niCmt.isEmpty() ? "" : ": " + _niCmt));
           }
       }
       if (_niFails > 0) {
  %>
  <div class="ni-banner" style="margin:0 0 16px 0">
    <div class="ni-banner-icon">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor"
           stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/>
        <line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
      </svg>
    </div>
    <div class="ni-banner-body">
      <div class="ni-banner-title">Action Required — <%= _niFails %> checklist item<%= _niFails!=1?"s":"" %> flagged by vetters</div>
      <div class="ni-banner-text" style="margin-bottom:10px">
        Please review each flagged item below and make the necessary corrections before resubmitting.
      </div>
      <% for (java.util.Map.Entry<String,java.util.List<String>> _ne : _niMap.entrySet()) { %>
      <div style="margin-bottom:6px">
        <span style="font-size:11px;font-weight:700;color:#9a3412">&#10007; <%= _ne.getKey() %></span>
        <% for (String _nrem : _ne.getValue()) { %>
        <div style="font-size:11px;color:#c2410c;padding-left:14px;margin-top:2px;font-style:italic"><%= _nrem.replace("<","&lt;") %></div>
        <% } %>
      </div>
      <% } %>
    </div>
  </div>
  <% } } %>

  <!-- ── Paper header ── -->
  <div class="paper-hdr">
    <h1><%= paper.getCourseCode() %> — <%= paper.getCourseTitle() %></h1>
    <p>Vetter Review Feedback &nbsp;·&nbsp; <%= paper.getPaperType() %></p>
    <div class="paper-hdr-meta">
      <span class="hbadge hb-teal"><%= paper.getAcademicSession() %> Sem <%= paper.getSemester() %></span>
      <span class="hbadge hb-blue"><%= totalQs %> questions</span>
    </div>
  </div>

  <!-- ── Stats ── -->
  <div class="stats-row">
    <div class="stat-card"><div class="stat-lbl">Total Questions</div><div class="stat-val sv-blue"><%= totalQs %></div></div>
    <div class="stat-card"><div class="stat-lbl">Approved</div><div class="stat-val sv-green"><%= approvedQs %></div></div>
    <div class="stat-card"><div class="stat-lbl">Needs Revision</div><div class="stat-val sv-amber"><%= needsRevQs %></div></div>
    <div class="stat-card"><div class="stat-lbl">Rejected / Pending</div><div class="stat-val sv-red"><%= rejectedQs + pendingQs %></div></div>
  </div>

  <!-- ── Tabs ── -->
  <div class="tab-bar">
    <button class="tab-btn active" id="tb-q" onclick="showTab('q')">Questions</button>
    <button class="tab-btn" id="tb-jss" onclick="showTab('jss')">JSS (FAP/02)</button>
    <button class="tab-btn" id="tb-scheme" onclick="showTab('scheme')"><%= schemeLabel %></button>
  </div>

  <!-- ════════ TAB: QUESTIONS ════════ -->
  <div id="tab-q" class="tab-panel active">
  <% if (questions == null || questions.isEmpty()) { %>
  <div class="info-box">No questions have been added to this paper yet.</div>
  <% } else { for (Question q : questions) {
        int    qid     = q.getQuestionId();
        String qst     = q.getStatus() != null ? q.getStatus() : "DRAFT";
        String qstCls  = "APPROVED".equals(qst) ? "qs-approved"
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
          A. <%= q.getChoiceA() %><br/>B. <%= q.getChoiceB() %><br/>C. <%= q.getChoiceC() %><br/>D. <%= q.getChoiceD() %>
          <% if (q.getCorrectAnswer() != null) { %><br/><strong style="color:var(--green)">Answer: <%= q.getCorrectAnswer() %></strong><% } %>
        </div>
        <% } %>
        <div class="q-foot">
          <span class="badge <%= qstBadge %>">
            <% if (!"DRAFT".equals(qst)) { %><span class="dot <%= "APPROVED".equals(qst)?"dot-g":"NEEDS_REVISION".equals(qst)?"dot-a":"dot-r" %>"></span><% } %>
            <%= qstLabel %>
          </span>
          <% if (q.getCloMapping() != null) { %><span style="font-size:10px;color:var(--txt2)">CLO: <%= q.getCloMapping() %></span><% } %>
        </div>
      </div>
    </div>
    <!-- Vetter comments on this question -->
    <% if (comCount > 0) { %>
    <div class="q-divider"></div>
    <div class="feedback-section">
      <div style="font-size:11px;font-weight:600;color:var(--txt2);margin-bottom:10px;display:flex;align-items:center;gap:5px">
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/></svg>
        <%= comCount %> vetter comment<%= comCount!=1?"s":"" %>
      </div>
      <div class="vc-list">
        <%
          java.util.Map<Integer,Integer> vetterColorMap = new java.util.LinkedHashMap<>();
          int colorCtr = 0;
          for (QuestionComment _c : qcoms)
            if (!vetterColorMap.containsKey(_c.getVetterId()))
              vetterColorMap.put(_c.getVetterId(), colorCtr++ % 5);
          for (QuestionComment c : qcoms) {
            int cIdx = vetterColorMap.getOrDefault(c.getVetterId(), 0);
            String cbadge = "APPROVED".equals(c.getVerdict()) ? "badge-approved"
                          : "NEEDS_REVISION".equals(c.getVerdict()) ? "badge-needs"
                          : "REJECTED".equals(c.getVerdict()) ? "badge-rejected" : null;
        %>
        <div class="vc-card">
          <div class="vc-id-bar">
            <div class="vc-avatar cv-<%= cIdx %>"><%= c.getInitials() %></div>
            <div class="vc-id-info">
              <div class="vc-name">
                <%= c.getVetterName() != null ? c.getVetterName() : "Vetter" %>
                <% if (cbadge != null) { %><span class="badge <%= cbadge %>" style="font-size:10px"><%= c.getVerdict().replace("_"," ") %></span><% } %>
              </div>
              <div class="vc-role-line">Vetter &nbsp;·&nbsp; <%= c.getFormattedDate() %></div>
            </div>
          </div>
          <div class="vc-body-wrap">
            <div class="vc-body"><%= c.getCommentText().replace("<","&lt;").replace("\n","<br/>") %></div>
            <% boolean hasTags = c.getContentTag()!=null||c.getTaxonomyTag()!=null||c.getSuggestedTaxonomy()!=null;
               if (hasTags) { %>
            <div class="vc-tags">
              <% if (c.getContentTag()  != null) { %><span class="ctag ctag-teal"><%= c.getContentTag() %></span><% } %>
              <% if (c.getTaxonomyTag() != null) { %><span class="ctag ctag-purple"><%= c.getTaxonomyTag() %></span><% } %>
              <% if (c.getSuggestedTaxonomy() != null) { %><span class="ctag ctag-purple">Suggest: <%= c.getSuggestedTaxonomy() %></span><% } %>
            </div>
            <% } %>
          </div>
        </div>
        <% } %>
      </div>
    </div>
    <% } else { %>
    <div class="q-divider"></div>
    <div class="feedback-section"><span class="feedback-empty">No vetter comments on this question.</span></div>
    <% } %>
    <!-- Read-only checklist for this question -->
    <%
      boolean rcl_hasQEntries = false;
      if (allChecklists != null) {
        for (java.util.Map<String,Object> _re : allChecklists) {
          if ("QUESTION".equals(_re.get("section")) && qid == ((Number)_re.get("ref_id")).intValue()) {
            rcl_hasQEntries = true; break;
          }
        }
      }
      if (rcl_hasQEntries) {
        // Collect unique vetters for this question's checklist
        java.util.LinkedHashMap<Integer,String> rclVetters = new java.util.LinkedHashMap<>();
        for (java.util.Map<String,Object> _re : allChecklists) {
          if ("QUESTION".equals(_re.get("section")) && qid == ((Number)_re.get("ref_id")).intValue()) {
            int _rvid = ((Number)_re.get("vetter_id")).intValue();
            rclVetters.put(_rvid, (String)_re.get("vetter_name"));
          }
        }
    %>
    <div class="rcl-wrap">
      <div class="rcl-title">Vetting Checklist
        <%-- Count total failures across all vetters for this question --%>
        <% int _totalFails = 0;
           for (java.util.Map<String,Object> _rf : allChecklists) {
             if ("QUESTION".equals(_rf.get("section")) && qid == ((Number)_rf.get("ref_id")).intValue()
                 && !Boolean.TRUE.equals(_rf.get("is_ok"))) _totalFails++;
           }
           if (_totalFails > 0) { %>
        <span class="rcl-fail-count"><%= _totalFails %> item<%= _totalFails!=1?"s":"" %> flagged</span>
        <% } %>
      </div>
      <% for (java.util.Map.Entry<Integer,String> _rv : rclVetters.entrySet()) {
           int _rvId = _rv.getKey(); String _rvName = _rv.getValue() != null ? _rv.getValue() : "Vetter";
           // Count this vetter's fails for this question
           int _vFails = 0;
           for (java.util.Map<String,Object> _rf2 : allChecklists) {
             if ("QUESTION".equals(_rf2.get("section")) && qid == ((Number)_rf2.get("ref_id")).intValue()
                 && _rvId == ((Number)_rf2.get("vetter_id")).intValue()
                 && !Boolean.TRUE.equals(_rf2.get("is_ok"))) _vFails++;
           }
      %>
      <div class="rcl-vetter-hdr">
        <span style="width:20px;height:20px;border-radius:50%;background:var(--blue-lt);color:var(--blue);display:inline-flex;align-items:center;justify-content:center;font-size:9px;font-weight:700"><%= _rvName.length()>0?String.valueOf(_rvName.charAt(0)).toUpperCase():"V" %></span>
        <%= _rvName %>
        <% if (_vFails > 0) { %><span class="rcl-fail-count"><%= _vFails %> flagged</span><% } %>
      </div>
      <table class="rcl-table">
        <thead><tr><th style="width:28px"></th><th>Criterion</th><th>Vetter Remark</th></tr></thead>
        <tbody>
        <% for (String[] _crit : DAO.VettingChecklistDAO.QUESTION_CRITERIA) {
             java.util.Map<String,Object> _rEntry = null;
             for (java.util.Map<String,Object> _re2 : allChecklists) {
               if ("QUESTION".equals(_re2.get("section")) && qid == ((Number)_re2.get("ref_id")).intValue()
                   && _rvId == ((Number)_re2.get("vetter_id")).intValue()
                   && _crit[0].equals(_re2.get("criterion_key"))) { _rEntry = _re2; break; }
             }
             boolean _rOk  = _rEntry != null && Boolean.TRUE.equals(_rEntry.get("is_ok"));
             String  _rCmt = _rEntry != null && _rEntry.get("comment") != null ? (String)_rEntry.get("comment") : "";
        %>
        <tr class="<%= !_rOk && _rEntry != null ? "rcl-fail-row" : "" %>">
          <td style="text-align:center;width:28px"><span class="<%= _rOk ? "rcl-ok" : "rcl-no" %>"><%= _rOk ? "&#10003;" : "&#10007;" %></span></td>
          <td>
            <span class="<%= !_rOk && _rEntry != null ? "rcl-fail-crit" : "" %>"><%= _crit[1] %></span>
          </td>
          <td>
            <% if (!_rCmt.isEmpty()) { %>
            <span class="<%= !_rOk ? "rcl-fail-cmt" : "rcl-ok-cmt" %>"><%= _rCmt.replace("<","&lt;") %></span>
            <% } else if (!_rOk && _rEntry != null) { %>
            <span style="font-size:11px;color:#f87171;font-style:italic">No remark provided</span>
            <% } %>
          </td>
        </tr>
        <% } %>
        </tbody>
      </table>
      <% } %>
    </div>
    <% } %>
  </div>
  <% } } %>

  <!-- Action strip for lecturer -->
  <% if (isOwner && "NEEDS_IMPROVEMENT".equals(status)) { %>
  <div class="action-strip">
    <p>Please review all vetter comments above, make the required corrections to your paper, then resubmit when ready.</p>
    <a href="<%= ctx %>/NewPaperServlet?action=edit&paperId=<%= paperId %>" class="btn-primary">Edit Assessment</a>
  </div>
  <% } %>
  </div><!-- /tab-q -->

  <!-- ════════ TAB: JSS ════════ -->
  <div id="tab-jss" class="tab-panel">
    <div style="overflow-x:auto;margin-bottom:6px">
      <table class="jss-table">
        <thead><tr>
          <th>Topic</th><th>Q No.</th><th style="text-align:center">Taxonomy</th>
          <th>Type</th><th style="text-align:center">Marks</th><th>PLO</th><th>CLO</th>
        </tr></thead>
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
          <tr>
            <td><%= jrs.getString("topic_name")!=null?jrs.getString("topic_name"):"—" %></td>
            <td style="font-family:monospace"><%= jrs.getString("question_no")!=null?jrs.getString("question_no"):"—" %></td>
            <td style="text-align:center"><span class="tax-badge"><%= jrs.getString("taxonomy_level")!=null?jrs.getString("taxonomy_level"):"—" %></span></td>
            <td><%= jrs.getString("question_type")!=null?jrs.getString("question_type"):"—" %></td>
            <td style="text-align:center;font-weight:700"><%= jrs.getObject("marks")!=null?jrs.getObject("marks"):"—" %></td>
            <td><%= jrs.getString("plo")!=null?jrs.getString("plo"):"—" %></td>
            <td><%= jrs.getString("clo")!=null?jrs.getString("clo"):"—" %></td>
          </tr>
          <% } if (!jssHasRows) { %>
          <tr><td colspan="7" style="text-align:center;color:var(--txt3);padding:14px">No JSS rows found.</td></tr>
          <% } jrs.close(); jps.close(); } catch(Exception e){ e.printStackTrace(); } %>
        </tbody>
      </table>
    </div>

    <!-- JSS read-only checklist -->
    <%
      java.util.LinkedHashMap<Integer,String> jssRclVetters = new java.util.LinkedHashMap<>();
      if (allChecklists != null) {
        for (java.util.Map<String,Object> _je : allChecklists) {
          if ("JSS".equals(_je.get("section"))) {
            int _jvid = ((Number)_je.get("vetter_id")).intValue();
            jssRclVetters.put(_jvid, (String)_je.get("vetter_name"));
          }
        }
      }
      if (!jssRclVetters.isEmpty()) {
    %>
    <div class="rcl-wrap" style="border-radius:var(--r);border:1px solid var(--border);margin-bottom:12px">
      <div class="rcl-title">JSS Vetting Checklist</div>
      <% for (java.util.Map.Entry<Integer,String> _jrv : jssRclVetters.entrySet()) {
           int _jrvId = _jrv.getKey(); String _jrvName = _jrv.getValue() != null ? _jrv.getValue() : "Vetter";
      %>
      <div class="rcl-vetter-hdr"><span style="width:20px;height:20px;border-radius:50%;background:var(--blue-lt);color:var(--blue);display:inline-flex;align-items:center;justify-content:center;font-size:9px;font-weight:700"><%= _jrvName.length()>0?String.valueOf(_jrvName.charAt(0)).toUpperCase():"V" %></span><%= _jrvName %></div>
      <table class="rcl-table">
        <thead><tr><th style="width:32px">OK</th><th>Criterion</th><th>Comment</th></tr></thead>
        <tbody>
        <% for (String[] _jcrit : DAO.VettingChecklistDAO.JSS_CRITERIA) {
             java.util.Map<String,Object> _jrEntry = null;
             if (allChecklists != null) for (java.util.Map<String,Object> _je2 : allChecklists) {
               if ("JSS".equals(_je2.get("section")) && _jrvId==((Number)_je2.get("vetter_id")).intValue()
                   && _jcrit[0].equals(_je2.get("criterion_key"))) { _jrEntry = _je2; break; }
             }
             boolean _jrOk = _jrEntry != null && Boolean.TRUE.equals(_jrEntry.get("is_ok"));
             String  _jrCmt = _jrEntry != null && _jrEntry.get("comment") != null ? (String)_jrEntry.get("comment") : "";
        %>
        <tr>
          <td style="text-align:center"><span class="<%= _jrOk ? "rcl-ok" : "rcl-no" %>"><%= _jrOk ? "&#10003;" : "&#8211;" %></span></td>
          <td><%= _jcrit[1] %></td>
          <td style="color:var(--txt2)"><%= _jrCmt.isEmpty() ? "" : _jrCmt.replace("<","&lt;") %></td>
        </tr>
        <% } %>
        </tbody>
      </table>
      <% } %>
    </div>
    <% } %>
    <div class="section-hdr">
      <h2>Vetter Comments on JSS</h2>
    </div>
    <div class="sec-comment-list">
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
           int jci  = jssColorMap.getOrDefault(jvid, 0);
           String jvn = (String) jc.get("vetterName");
           String jInit = "?"; if (jvn!=null){String[]jp=jvn.trim().split("\\s+");int js2=(jp.length>1&&jp[0].endsWith("."))?1:0;StringBuilder jsb=new StringBuilder();for(int ji=js2;ji<jp.length&&jsb.length()<2;ji++)jsb.append(Character.toUpperCase(jp[ji].charAt(0)));if(jsb.length()>0)jInit=jsb.toString();}
    %>
    <div class="vc-card">
      <div class="vc-id-bar">
        <div class="vc-avatar cv-<%= jci %>"><%= jInit %></div>
        <div class="vc-id-info">
          <div class="vc-name"><%= jvn!=null?jvn:"Vetter" %><% if(jvBadge!=null){%> <span class="badge <%= jvBadge %>" style="font-size:10px"><%= jv.replace("_"," ") %></span><%}%></div>
          <div class="vc-role-line">Vetter &nbsp;·&nbsp; JSS Review &nbsp;·&nbsp; <%= jts!=null?jsdf.format(jts):"" %></div>
        </div>
      </div>
      <div class="vc-body-wrap"><div class="vc-body"><%= ((String)jc.get("commentText")).replace("<","&lt;").replace("\n","<br/>") %></div></div>
    </div>
    <% } } else { %>
    <div class="empty-note">No vetter comments on JSS yet.</div>
    <% } %>
    </div>
  </div><!-- /tab-jss -->

  <!-- ════════ TAB: SCHEME / RUBRIC ════════ -->
  <div id="tab-scheme" class="tab-panel">
    <% if (isFinal) {
         boolean hasAns = false;
         if (questions!=null) for(Question q2:questions) if(q2.getModelAnswer()!=null&&!q2.getModelAnswer().trim().isEmpty()){hasAns=true;break;}
         if (hasAns) { %>
    <div style="overflow-x:auto;margin-bottom:6px">
      <table class="jss-table">
        <thead><tr><th style="width:40px">No.</th><th>Question</th><th>Model Answer</th><th style="text-align:center;width:60px">Marks</th></tr></thead>
        <tbody>
          <% for(Question q2:questions){if(q2.getModelAnswer()==null||q2.getModelAnswer().trim().isEmpty())continue; %>
          <tr>
            <td style="text-align:center;font-weight:700"><%= q2.getQuestionNo() %></td>
            <td style="color:var(--txt2);font-size:11px"><%= q2.getQuestionText()!=null?q2.getQuestionText().substring(0,Math.min(q2.getQuestionText().length(),80)).replace("<","&lt;"):"—" %>...</td>
            <td><%= q2.getModelAnswer().replace("<","&lt;").replace("\n","<br/>") %></td>
            <td style="text-align:center;font-weight:700"><%= q2.getMarks() %></td>
          </tr>
          <% } %>
        </tbody>
      </table>
    </div>
    <% } else { %><div class="info-box">No model answers entered yet.</div><% }
       } else {
         boolean hasRubric = false;
         try (java.sql.Connection rcon = util.DBConnection.getConnection()) {
           java.sql.PreparedStatement rps = rcon.prepareStatement("SELECT * FROM rubric_rows WHERE paper_id=? ORDER BY row_order");
           rps.setInt(1,paperId);
           java.sql.ResultSet rrs = rps.executeQuery();
           if(rrs.next()){hasRubric=true; %>
    <div style="overflow-x:auto;margin-bottom:6px">
      <table class="jss-table">
        <thead><tr><th style="width:40px">No.</th><th>Criterion</th><th style="text-align:center;width:60px">Marks</th><th style="width:60px">CLO</th><th style="width:60px">Bloom</th><th>Description</th></tr></thead>
        <tbody>
          <% int rn=1; do { %>
          <tr>
            <td style="text-align:center;font-weight:700"><%= rn++ %></td>
            <td><%= rrs.getString("criterion")!=null?rrs.getString("criterion").replace("<","&lt;"):"—" %></td>
            <td style="text-align:center;font-weight:700"><%= rrs.getInt("marks") %></td>
            <td><%= rrs.getString("clo")!=null?rrs.getString("clo"):"—" %></td>
            <td><span class="tax-badge"><%= rrs.getString("bloom")!=null?rrs.getString("bloom"):"—" %></span></td>
            <td style="font-size:11px;color:var(--txt2)"><%= rrs.getString("description")!=null?rrs.getString("description").replace("<","&lt;"):"—" %></td>
          </tr>
          <% } while(rrs.next()); rrs.close(); rps.close(); %>
        </tbody>
      </table>
    </div>
    <% } else{rrs.close();rps.close(); %><div class="info-box">No rubric rows found.</div><% } } catch(Exception er){er.printStackTrace();} } %>

    <!-- Scheme read-only checklist -->
    <%
      java.util.LinkedHashMap<Integer,String> schRclVetters = new java.util.LinkedHashMap<>();
      if (allChecklists != null) {
        for (java.util.Map<String,Object> _sre : allChecklists) {
          if ("SCHEME".equals(_sre.get("section"))) {
            int _srvid = ((Number)_sre.get("vetter_id")).intValue();
            schRclVetters.put(_srvid, (String)_sre.get("vetter_name"));
          }
        }
      }
      if (!schRclVetters.isEmpty()) {
    %>
    <div class="rcl-wrap" style="border-radius:var(--r);border:1px solid var(--border);margin-bottom:12px">
      <div class="rcl-title"><%= schemeLabel %> Vetting Checklist</div>
      <% for (java.util.Map.Entry<Integer,String> _srv : schRclVetters.entrySet()) {
           int _srvId = _srv.getKey(); String _srvName = _srv.getValue() != null ? _srv.getValue() : "Vetter";
      %>
      <div class="rcl-vetter-hdr"><span style="width:20px;height:20px;border-radius:50%;background:var(--blue-lt);color:var(--blue);display:inline-flex;align-items:center;justify-content:center;font-size:9px;font-weight:700"><%= _srvName.length()>0?String.valueOf(_srvName.charAt(0)).toUpperCase():"V" %></span><%= _srvName %></div>
      <table class="rcl-table">
        <thead><tr><th style="width:32px">OK</th><th>Criterion</th><th>Comment</th></tr></thead>
        <tbody>
        <% for (String[] _scrit : DAO.VettingChecklistDAO.SCHEME_CRITERIA) {
             java.util.Map<String,Object> _srEntry = null;
             if (allChecklists != null) for (java.util.Map<String,Object> _sre2 : allChecklists) {
               if ("SCHEME".equals(_sre2.get("section")) && _srvId==((Number)_sre2.get("vetter_id")).intValue()
                   && _scrit[0].equals(_sre2.get("criterion_key"))) { _srEntry = _sre2; break; }
             }
             boolean _srOk = _srEntry != null && Boolean.TRUE.equals(_srEntry.get("is_ok"));
             String  _srCmt = _srEntry != null && _srEntry.get("comment") != null ? (String)_srEntry.get("comment") : "";
        %>
        <tr>
          <td style="text-align:center"><span class="<%= _srOk ? "rcl-ok" : "rcl-no" %>"><%= _srOk ? "&#10003;" : "&#8211;" %></span></td>
          <td><%= _scrit[1] %></td>
          <td style="color:var(--txt2)"><%= _srCmt.isEmpty() ? "" : _srCmt.replace("<","&lt;") %></td>
        </tr>
        <% } %>
        </tbody>
      </table>
      <% } %>
    </div>
    <% } %>
    <div class="section-hdr">
      <h2>Vetter Comments on <%= schemeLabel %></h2>
    </div>
    <div class="sec-comment-list">
    <% if (schemeComments != null && !schemeComments.isEmpty()) {
         java.util.Map<Integer,Integer> schColorMap = new java.util.LinkedHashMap<>();
         int schCtr = 0;
         for (java.util.Map<String,Object> _sc : schemeComments) {
           int _svid = (int)_sc.get("vetterId");
           if (!schColorMap.containsKey(_svid)) schColorMap.put(_svid, schCtr++ % 5);
         }
         java.text.SimpleDateFormat ssdf = new java.text.SimpleDateFormat("d MMM yyyy, HH:mm");
         for (java.util.Map<String,Object> sc : schemeComments) {
           String sv = (String) sc.get("verdict");
           String svBadge = "APPROVED".equals(sv) ? "badge-approved"
                          : "NEEDS_REVISION".equals(sv) ? "badge-needs"
                          : "REJECTED".equals(sv) ? "badge-rejected" : null;
           java.sql.Timestamp sts = (java.sql.Timestamp) sc.get("createdAt");
           int svid = (int) sc.get("vetterId");
           int sci  = schColorMap.getOrDefault(svid, 0);
           String svn = (String) sc.get("vetterName");
           String sInit = "?"; if(svn!=null){String[]sp=svn.trim().split("\\s+");int si2=(sp.length>1&&sp[0].endsWith("."))?1:0;StringBuilder ssb=new StringBuilder();for(int si=si2;si<sp.length&&ssb.length()<2;si++)ssb.append(Character.toUpperCase(sp[si].charAt(0)));if(ssb.length()>0)sInit=ssb.toString();}
    %>
    <div class="vc-card">
      <div class="vc-id-bar">
        <div class="vc-avatar cv-<%= sci %>"><%= sInit %></div>
        <div class="vc-id-info">
          <div class="vc-name"><%= svn!=null?svn:"Vetter" %><% if(svBadge!=null){%> <span class="badge <%= svBadge %>" style="font-size:10px"><%= sv.replace("_"," ") %></span><%}%></div>
          <div class="vc-role-line">Vetter &nbsp;·&nbsp; <%= schemeLabel %> Review &nbsp;·&nbsp; <%= sts!=null?ssdf.format(sts):"" %></div>
        </div>
      </div>
      <div class="vc-body-wrap"><div class="vc-body"><%= ((String)sc.get("commentText")).replace("<","&lt;").replace("\n","<br/>") %></div></div>
    </div>
    <% } } else { %>
    <div class="empty-note">No vetter comments on <%= schemeLabel %> yet.</div>
    <% } %>
    </div>
  </div><!-- /tab-scheme -->

</div><!-- /page -->

<script>
function showTab(name) {
  document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
  document.getElementById('tab-' + name).classList.add('active');
  document.getElementById('tb-' + name).classList.add('active');
}
</script>
</body>
</html>
