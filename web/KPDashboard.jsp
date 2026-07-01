<%--
  FILE:    KPDashboard.jsp  (Bootstrap 5 redesign)
  SERVLET: KPDashboardServlet
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.util.Map, Model.Course, Model.User, Model.Assessment, java.text.SimpleDateFormat" %>
<%!
    /* HTML-escape for user-entered text (synopsis etc.) */
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");
    }
%>
<%
    String fullName  = (String) session.getAttribute("fullName");
    if (fullName == null) fullName = "Ketua Program";
    String ctx       = request.getContextPath();
    String activePage = (String) request.getAttribute("activePage");
    if (activePage == null) activePage = "dashboard";

    List<Course>     courses     = (List<Course>)     request.getAttribute("courses");
    List<User>       lecturers   = (List<User>)       request.getAttribute("lecturers");
    List<User>       vetters     = (List<User>)       request.getAttribute("vetters");
    List<User>       potentialVetters = new java.util.ArrayList<User>();
    if (lecturers != null) potentialVetters.addAll(lecturers);
    if (vetters != null) potentialVetters.addAll(vetters);
    List<Assessment> allPackages = (List<Assessment>) request.getAttribute("allPackages");
    List<Assessment> repoPackages= (List<Assessment>) request.getAttribute("repoPackages");
    java.util.Map    vetterMap   = (java.util.Map)    request.getAttribute("vetterMap");
    java.util.Map    leaderMap   = (java.util.Map)    request.getAttribute("leaderMap");

    java.util.Map    synopsisMap = (java.util.Map)    request.getAttribute("synopsisMap");

    /* userId -> full name lookup (vetters are chosen from lecturers) */
    java.util.Map<Integer,String> nameMap = new java.util.HashMap<Integer,String>();
    if (lecturers != null) for (User u : lecturers) nameMap.put(u.getUserId(), u.getFullName());
    if (vetters   != null) for (User u : vetters)   nameMap.put(u.getUserId(), u.getFullName());

    int totalLecturers = request.getAttribute("totalLecturers") != null ? (int)request.getAttribute("totalLecturers") : 0;
    int totalVetters   = request.getAttribute("totalVetters")   != null ? (int)request.getAttribute("totalVetters")   : 0;
    int totalCourses   = request.getAttribute("totalCourses")   != null ? (int)request.getAttribute("totalCourses")   : 0;
    int pendingCount   = request.getAttribute("pendingCount")   != null ? (int)request.getAttribute("pendingCount")   : 0;
    int approvedCount  = request.getAttribute("approvedCount")  != null ? (int)request.getAttribute("approvedCount")  : 0;
    int submittedCount = request.getAttribute("submittedCount") != null ? (int)request.getAttribute("submittedCount") : 0;

    boolean saved   = "true".equals(request.getParameter("saved"));
    boolean deleted = "true".equals(request.getParameter("deleted"));
    boolean sent    = "true".equals(request.getParameter("sent"));
    String  errMsg  = request.getParameter("err");

    /* Notification count */
    int kpUnread = 0;
    int kpUid    = session.getAttribute("userId") != null ? (int)session.getAttribute("userId") : 0;
    if (kpUid > 0) {
        try (java.sql.Connection _nc = util.DBConnection.getConnection();
             java.sql.PreparedStatement _np = _nc.prepareStatement(
                 "SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=0")) {
            _np.setInt(1, kpUid);
            java.sql.ResultSet _nr = _np.executeQuery();
            if (_nr.next()) kpUnread = _nr.getInt(1);
        } catch (Exception _ne) { /* non-fatal */ }
    }
    /* Initials */
    String kpInit = "K";
    {
        String[] kpParts = fullName.trim().split("\\s+");
        int kpS = (kpParts.length > 1 && kpParts[0].endsWith(".")) ? 1 : 0;
        StringBuilder kpSb = new StringBuilder();
        for (int i = kpS; i < kpParts.length && kpSb.length() < 2; i++)
            kpSb.append(Character.toUpperCase(kpParts[i].charAt(0)));
        if (kpSb.length() > 0) kpInit = kpSb.toString();
    }
%>
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>KP Dashboard — E-Vetting</title>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet"/>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet"/>
<style>
:root{
  /* UMT palette: deep purple primary, gold accent, red highlight */
  --navy:#2a1454;            /* topnav: deep UMT purple */
  --teal:#6d28d9;            /* primary action: UMT purple */
  --teal-soft:#f5f3ff;--teal-b:#ddd6fe;
  --gold:#d97706;--gold-soft:#fffbeb;--gold-b:#fcd34d;
  --cream:#f7f6fb;--surface:#fff;--border:#e6e3f0;--ink:#1e1133;--ink2:#3f2d63;--muted:#8b80a8;
  --blue:#2563eb;--blue-soft:#eff4ff;--blue-b:#c7d9fd;
  --green:#15803d;--green-bg:#f0fdf4;--green-b:#86efac;
  --amber:#b45309;--amber-bg:#fffbeb;--amber-b:#fcd34d;
  --red:#be123c;--red-bg:#fff1f2;--red-b:#fda4af;
}
*,*::before,*::after{box-sizing:border-box}
body{font-family:'Sora',sans-serif;background:var(--cream);color:var(--ink);min-height:100vh}

/* ══ TOPNAV (unchanged) ══════════════════════════════════════════════ */
.topnav{background:linear-gradient(135deg,#312e81 0%,#4c1d95 55%,#6d28d9 100%);position:sticky;top:0;z-index:1030;border-bottom:2px solid var(--gold)}
.nav-inner{max-width:1280px;margin:0 auto;padding:0 24px;height:58px;display:flex;align-items:center}
.brand{display:flex;align-items:center;gap:9px;padding-right:22px;border-right:1px solid rgba(255,255,255,.1);flex-shrink:0;text-decoration:none}
.brand-logo{width:34px;height:34px;border-radius:9px;object-fit:cover}
.brand-name{font-size:13px;font-weight:800;color:#fff}
.brand-sub{font-size:10px;color:#fbbf24;letter-spacing:.5px}
.nav-tabs-kp{display:flex;align-items:center;gap:2px;padding-left:16px;flex:1;overflow-x:auto;border:none!important}
.nav-tabs-kp::-webkit-scrollbar{display:none}
.tab{display:flex;align-items:center;gap:6px;padding:7px 12px;border-radius:8px;border:1px solid transparent;background:none;color:rgba(255,255,255,.5);font-family:'Sora',sans-serif;font-size:13px;font-weight:600;cursor:pointer;white-space:nowrap;transition:.15s}
.tab:hover{background:rgba(255,255,255,.07);color:#fff}
.tab.active{background:rgba(245,158,11,.2);border-color:rgba(245,158,11,.45);color:#fbbf24}
.nav-right{margin-left:auto;display:flex;align-items:center;gap:10px;padding-left:16px;border-left:1px solid rgba(255,255,255,.1);flex-shrink:0}
.user-name{font-size:12px;font-weight:700;color:#fff}
.user-role{font-size:10px;color:rgba(255,255,255,.4)}
.avatar{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#f59e0b,#fcd34d);color:#2a1454;display:grid;place-items:center;font-weight:800;font-size:13px;flex-shrink:0}
.logout-link{width:32px;height:32px;border-radius:50%;border:1px solid rgba(255,255,255,.15);background:none;color:rgba(255,255,255,.5);display:grid;place-items:center;text-decoration:none;transition:.15s}
.logout-link:hover{background:rgba(190,18,60,.25);color:#fda4af}
/* Notification bell */
.notif-wrap{position:relative;display:flex;align-items:center}
.notif-btn{width:34px;height:34px;border-radius:50%;border:1px solid rgba(255,255,255,.15);background:none;color:rgba(255,255,255,.65);display:grid;place-items:center;cursor:pointer;position:relative;transition:.15s;flex-shrink:0}
.notif-btn:hover{background:rgba(255,255,255,.1);color:#fff}
.notif-btn svg{width:17px;height:17px}
.notif-badge{position:absolute;top:-3px;right:-3px;min-width:17px;height:17px;background:#dc2626;color:#fff;border-radius:10px;font-size:10px;font-weight:700;display:flex;align-items:center;justify-content:center;padding:0 4px;border:2px solid #2a1454;line-height:1;pointer-events:none}
.notif-panel{display:none;position:absolute;top:calc(100% + 10px);right:0;width:340px;background:#fff;border-radius:10px;border:1px solid #e2e8f0;box-shadow:0 8px 32px rgba(0,0,0,.18);z-index:9999;overflow:hidden}
.notif-panel.open{display:block}
.notif-head{display:flex;align-items:center;justify-content:space-between;padding:13px 16px;border-bottom:1px solid #f1f5f9}
.notif-head-title{font-size:13px;font-weight:700;color:#2a1454}
.notif-mark-all{font-size:11px;color:#185FA5;cursor:pointer;font-weight:600;background:none;border:none;padding:0}
.notif-scroll{max-height:380px;overflow-y:auto}
.notif-item{display:flex;gap:10px;padding:12px 16px;border-bottom:1px solid #f8fafc;cursor:pointer;transition:.12s;align-items:flex-start}
.notif-item:hover{background:#f8fafc}
.notif-item.notif-read{opacity:.65}
.notif-icon{width:32px;height:32px;border-radius:50%;background:#e6f1fb;display:grid;place-items:center;flex-shrink:0;margin-top:1px}
.notif-item:not(.notif-read) .notif-icon{background:#fef3c7}
.notif-content{flex:1;min-width:0}
.notif-text{font-size:12px;color:#1a2435;line-height:1.55;margin-bottom:3px}
.notif-item:not(.notif-read) .notif-text{font-weight:600}
.notif-time{font-size:10px;color:#8a9ab0}
.notif-empty{padding:28px 16px;text-align:center;font-size:12px;color:#8a9ab0}
.notif-footer{padding:10px 16px;text-align:center;border-top:1px solid #f1f5f9}
.notif-footer a{font-size:12px;color:#185FA5;text-decoration:none;font-weight:600}
.notif-loading{padding:24px;text-align:center;font-size:12px;color:#8a9ab0}

/* ══ PAGE HEADER ═══════════════════════════════════════════════════ */
.page-header{background:#fff;border-bottom:1px solid var(--border);padding:14px 0}
.ph-title{font-size:20px;font-weight:800;color:var(--ink)}
.ph-sub{font-size:12px;color:var(--muted);margin-top:1px}

/* ══ LAYOUT ════════════════════════════════════════════════════════ */
.content-wrap{max-width:1280px;margin:0 auto;padding:0 24px}
.page-section{display:none}
.page-section.active{display:block;animation:fadeUp .2s ease}
@keyframes fadeUp{from{opacity:0;transform:translateY(6px)}to{opacity:1;transform:translateY(0)}}

/* ══ STAT CARDS ════════════════════════════════════════════════════ */
.kp-stat{border:0;border-radius:14px;padding:20px 22px;position:relative;overflow:hidden}
.kp-stat::after{content:'';position:absolute;top:0;left:0;right:0;height:3px;background:currentColor;border-radius:14px 14px 0 0}
.kp-stat .stat-num{font-size:36px;font-weight:800;letter-spacing:-1.5px;line-height:1}
.kp-stat .stat-lbl{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;margin-top:4px}
.kp-stat .stat-icon{position:absolute;right:18px;top:50%;transform:translateY(-50%);font-size:40px;opacity:.12}
.s-teal{color:var(--teal);background:var(--teal-soft)}
.s-blue{color:var(--blue);background:var(--blue-soft)}
.s-amber{color:var(--amber);background:var(--amber-bg)}
.s-green{color:var(--green);background:var(--green-bg)}

/* ══ COURSE CARDS ══════════════════════════════════════════════════ */
.cc-code{font-family:'JetBrains Mono',monospace;font-size:11px;font-weight:700;color:var(--teal);background:var(--teal-soft);border:1px solid var(--teal-b);border-radius:5px;padding:2px 8px;display:inline-block}
.cc-name{font-size:14px;font-weight:700;line-height:1.35}
.cc-meta{font-size:12px;color:var(--muted)}
.assign-pill{display:inline-flex;align-items:center;gap:4px;font-size:11px;font-weight:600;padding:2px 8px;border-radius:20px}
.assign-pill.ok{color:var(--green);background:var(--green-bg)}
.assign-pill.na{color:var(--muted);background:#f1f5f9}

/* ══ COURSE CARD EXTRAS ════════════════════════════════════════════ */
.course-card{overflow:hidden;transition:.18s;border-radius:14px}
.course-card:hover{transform:translateY(-3px);box-shadow:0 10px 28px rgba(76,29,149,.14)!important}
.course-accent{height:4px}
.accent-ok{background:linear-gradient(90deg,#6d28d9,#a78bfa)}
.accent-pending{background:linear-gradient(90deg,#f59e0b,#fcd34d)}
.ready-pill{background:var(--green-bg);color:var(--green);font-size:10px;font-weight:700;padding:4px 9px}
.pending-pill{background:var(--amber-bg);color:var(--amber);font-size:10px;font-weight:700;padding:4px 9px}
.cc-syn{font-size:12px;color:var(--muted);line-height:1.55;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
.cc-syn-empty{font-style:italic;opacity:.65}
.meta-chip{display:inline-flex;align-items:center;font-size:11px;font-weight:600;color:var(--ink2);background:#f4f2fa;border:1px solid var(--border);border-radius:20px;padding:3px 10px}
.meta-chip i{color:var(--teal)}
.people-panel{background:#faf9fd;border:1px solid var(--border);border-radius:10px;padding:10px 12px;display:flex;flex-direction:column;gap:9px}
.people-row{display:flex;gap:9px;align-items:flex-start}
.people-icon{width:26px;height:26px;border-radius:8px;display:grid;place-items:center;font-size:12px;flex-shrink:0;margin-top:1px}
.lec-icon{background:var(--blue-soft);color:var(--blue)}
.vet-icon{background:var(--teal-soft);color:var(--teal)}
.people-label{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;color:var(--muted)}
.people-name{font-size:12px;font-weight:600;color:var(--ink)}
.leader-tag{font-size:9px;font-weight:800;text-transform:uppercase;letter-spacing:.4px;color:#b45309;background:#fef3c7;border-radius:4px;padding:1px 5px}

/* ══ STATUS BADGES ════════════════════════════════════════════════ */
.st-badge{display:inline-flex;align-items:center;gap:5px;border-radius:20px;padding:4px 10px;font-size:11px;font-weight:700;border:1px solid}
.bdot{width:6px;height:6px;border-radius:50%;background:currentColor;flex-shrink:0}
.b-submitted{color:var(--amber);background:var(--amber-bg);border-color:var(--amber-b)}
.b-review   {color:var(--blue);background:var(--blue-soft);border-color:var(--blue-b)}
.b-approved {color:var(--green);background:var(--green-bg);border-color:var(--green-b)}
.b-rejected {color:var(--red);background:var(--red-bg);border-color:var(--red-b)}
.b-sent     {color:var(--teal);background:var(--teal-soft);border-color:var(--teal-b)}
.b-draft    {color:var(--muted);background:#f1f5f9;border-color:var(--border)}
.b-improve  {color:#7c3aed;background:#f5f3ff;border-color:#ddd6fe}
.b-leader   {color:#d97706;background:#fffbeb;border-color:#fcd34d}

/* ══ TABLE ═════════════════════════════════════════════════════════ */
.kp-table thead th{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);background:#f7f9fc;border-bottom:2px solid var(--border);padding:10px 14px;vertical-align:middle}
.kp-table tbody td{font-size:13px;padding:12px 14px;vertical-align:middle;border-bottom:1px solid var(--border)}
.kp-table tbody tr:last-child td{border-bottom:none}
.kp-table tbody tr:hover td{background:#f8fafc}
.mono{font-family:'JetBrains Mono',monospace;font-size:11px;color:var(--muted)}

/* ══ CUSTOM BUTTONS ════════════════════════════════════════════════ */
.btn-kp-teal{background:var(--teal);color:#fff;border:none;font-family:'Sora',sans-serif;font-weight:600}
.btn-kp-teal:hover{background:#6d28d9;color:#fff}
.btn-kp-navy{background:var(--navy);color:#fff;border:none;font-family:'Sora',sans-serif;font-weight:600}
.btn-kp-navy:hover{background:#3b1f6e;color:#fff}
.btn-kp-ghost{background:transparent;color:var(--ink2);border:1px solid var(--border);font-family:'Sora',sans-serif;font-weight:600}
.btn-kp-ghost:hover{background:var(--cream);color:var(--ink)}
.btn-kp-red{background:var(--red-bg);color:var(--red);border:1px solid var(--red-b);font-family:'Sora',sans-serif;font-weight:600}
.btn-kp-red:hover{background:#ffe4e6;color:var(--red)}

/* ══ ASSIGNMENT TABLE ROW ═══════════════════════════════════════════ */
.assign-row-grid{display:grid;grid-template-columns:240px 1fr 1fr 1fr 90px;align-items:center}
.assign-cell{padding:10px 12px;border-right:1px solid var(--border)}
.assign-cell:last-child{border-right:none;text-align:center}

/* ══ QUICK ACTION CARD ══════════════════════════════════════════════ */
.qa-btn{display:flex;align-items:center;gap:10px;padding:11px 14px;border-radius:10px;border:1px solid var(--border);background:#fff;cursor:pointer;transition:.15s;font-family:'Sora',sans-serif;font-size:13px;font-weight:600;color:var(--ink2);text-decoration:none;width:100%}
.qa-btn:hover{border-color:var(--teal);color:var(--teal);background:var(--teal-soft)}
.qa-btn .qa-icon{width:34px;height:34px;border-radius:9px;display:grid;place-items:center;font-size:16px;flex-shrink:0}

/* ══ MISC ═══════════════════════════════════════════════════════════ */
.section-title{font-size:15px;font-weight:800;color:var(--ink)}
.section-sub{font-size:12px;color:var(--muted);margin-top:1px}
</style>
</head>
<body>

<%-- ══ TOPNAV ══════════════════════════════════════════════════════ --%>
<header class="topnav">
  <div class="nav-inner">
    <a href="<%= ctx %>/KPDashboardServlet" class="brand">
      <img src="<%= ctx %>/images/umt-logo.png" alt="UMT" class="brand-logo">
      <div><div class="brand-name">E-Vetting</div><div class="brand-sub">Ketua Program</div></div>
    </a>
    <nav class="nav-tabs-kp">
      <button class="tab" data-page="dashboard">
        <i class="bi bi-speedometer2"></i> Dashboard
      </button>
      <button class="tab" data-page="submissions">
        <i class="bi bi-file-earmark-text"></i> Submissions
      </button>
      <button class="tab" data-page="repository">
        <i class="bi bi-archive"></i> Repository
      </button>
      <button class="tab" data-page="vetting">
        <i class="bi bi-file-earmark-check"></i> Vetting
      </button>
      <button class="tab" data-page="assignment">
        <i class="bi bi-people"></i> Lecturers
      </button>
      <button class="tab" data-page="courses">
        <i class="bi bi-journal-bookmark"></i> Courses
      </button>
      <button class="tab" data-page="report">
        <i class="bi bi-file-earmark-bar-graph"></i> Reports
      </button>
    </nav>
    <div class="nav-right">
      <div class="notif-wrap" id="notifWrap">
        <button class="notif-btn" id="notifBtn" onclick="toggleNotif()" title="Notifications">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/>
          </svg>
          <% if (kpUnread > 0) { %>
          <span class="notif-badge" id="notifBadge"><%= kpUnread > 99 ? "99+" : kpUnread %></span>
          <% } else { %>
          <span class="notif-badge" id="notifBadge" style="display:none">0</span>
          <% } %>
        </button>
        <div class="notif-panel" id="notifPanel">
          <div class="notif-head">
            <span class="notif-head-title">Notifications</span>
            <button class="notif-mark-all" onclick="markAllRead()" title="Mark all read">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
            </button>
          </div>
          <div class="notif-scroll" id="notifList"><div class="notif-loading">Loading...</div></div>
          <div class="notif-footer"><a href="<%= ctx %>/NotificationServlet?action=all">See all notifications</a></div>
        </div>
      </div>
      <a href="<%= ctx %>/UserProfileServlet" style="text-decoration:none; display:flex; align-items:center; gap:12px; color:inherit;" title="My Profile">
        <div class="d-none d-md-block text-end">
          <div class="user-name"><%= fullName %></div>
          <div class="user-role">Ketua Program</div>
        </div>
        <div class="avatar"><%= kpInit %></div>
      </a>
      <a href="<%= ctx %>/logout" class="logout-link" title="Sign out">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="16" height="16">
          <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/>
        </svg>
      </a>
    </div>
  </div>
</header>

<%-- ══ PAGE HEADER ══════════════════════════════════════════════════ --%>
<div class="page-header">
  <div class="content-wrap d-flex align-items-center justify-content-between flex-wrap gap-2">
    <div>
      <div class="ph-title" id="phTitle">Dashboard</div>
      <div class="ph-sub"   id="phSub">Overview of the vetting system.</div>
    </div>
    <button class="btn btn-kp-teal btn-sm px-3 d-none" id="addCourseBtn"
            data-bs-toggle="modal" data-bs-target="#addCourseModal">
      <i class="bi bi-plus-lg me-1"></i> Add Course
    </button>
  </div>
</div>

<%-- ══ ALERTS ══════════════════════════════════════════════════════ --%>
<div class="content-wrap mt-3">
<% if (saved)   { %>
<div class="alert alert-success d-flex align-items-center gap-2 py-2" role="alert">
  <i class="bi bi-check-circle-fill"></i> Saved successfully.
</div>
<% } if (deleted) { %>
<div class="alert alert-warning d-flex align-items-center gap-2 py-2" role="alert">
  <i class="bi bi-exclamation-triangle-fill"></i> Course deleted.
</div>
<% } if (sent) { %>
<div class="alert alert-success d-flex align-items-center gap-2 py-2" role="alert">
  <i class="bi bi-send-check-fill"></i> Paper sent to Faculty.
</div>
<% } if (errMsg != null && !errMsg.isEmpty()) { %>
<div class="alert alert-danger d-flex align-items-center gap-2 py-2" role="alert">
  <i class="bi bi-x-circle-fill"></i> <%= errMsg %>
</div>
<% } %>
</div>

<%-- ══ MAIN CONTENT ═══════════════════════════════════════════════ --%>
<div class="content-wrap pb-5 mt-2">

  <%-- ════ DASHBOARD ════ --%>
  <div class="page-section" id="page-dashboard">
    <div style="display:flex; flex-wrap:wrap; gap:20px;">
      <div style="flex:1; min-width: 0;">


    <%-- Stat row --%>
    <div class="row g-3 mb-4">
      <div class="col-6 col-lg-3">
        <div class="kp-stat s-teal h-100">
          <div class="stat-icon"><i class="bi bi-mortarboard-fill"></i></div>
          <div class="stat-num"><%= totalLecturers %></div>
          <div class="stat-lbl">Lecturers</div>
        </div>
      </div>
      <div class="col-6 col-lg-3">
        <div class="kp-stat s-blue h-100">
          <div class="stat-icon"><i class="bi bi-journal-bookmark-fill"></i></div>
          <div class="stat-num"><%= totalCourses %></div>
          <div class="stat-lbl">Courses</div>
        </div>
      </div>
      <div class="col-6 col-lg-3">
        <div class="kp-stat s-amber h-100">
          <div class="stat-icon"><i class="bi bi-hourglass-split"></i></div>
          <div class="stat-num"><%= submittedCount + pendingCount %></div>
          <div class="stat-lbl">Pending Review</div>
        </div>
      </div>
      <div class="col-6 col-lg-3">
        <div class="kp-stat s-green h-100">
          <div class="stat-icon"><i class="bi bi-patch-check-fill"></i></div>
          <div class="stat-num"><%= approvedCount %></div>
          <div class="stat-lbl">Approved</div>
        </div>
      </div>
    </div>

    <%-- Info cards --%>
    <div class="row g-3">
      <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
          <div class="card-body">
            <h6 class="fw-bold mb-3 d-flex align-items-center gap-2">
              <span class="rounded-2 p-1 bg-info bg-opacity-10 text-info"><i class="bi bi-info-circle-fill fs-5"></i></span>
              KP Responsibilities
            </h6>
            <ol class="ps-3 mb-0" style="font-size:13px;color:var(--muted);line-height:2">
              <li>Assign lecturers and vetters to courses</li>
              <li>Monitor vetting progress</li>
              <li>Final sign-off on approved papers</li>
              <li>Send papers to Fakulti for printing</li>
            </ol>
          </div>
        </div>
      </div>
      <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
          <div class="card-body">
            <h6 class="fw-bold mb-3 d-flex align-items-center gap-2">
              <span class="rounded-2 p-1 bg-primary bg-opacity-10 text-primary"><i class="bi bi-people-fill fs-5"></i></span>
              Staff Overview
            </h6>
            <div style="font-size:42px;font-weight:800;letter-spacing:-2px;color:var(--teal)"><%= totalLecturers + totalVetters %></div>
            <div style="font-size:12px;color:var(--muted);margin-top:4px">
              <span class="me-2"><i class="bi bi-person-fill text-primary"></i> <%= totalLecturers %> Lecturers</span>
              <span><i class="bi bi-shield-check text-success"></i> <%= totalVetters %> Vetters</span>
            </div>
          </div>
        </div>
      </div>
      <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
          <div class="card-body">
            <h6 class="fw-bold mb-3 d-flex align-items-center gap-2">
              <span class="rounded-2 p-1 bg-success bg-opacity-10 text-success"><i class="bi bi-lightning-fill fs-5"></i></span>
              Quick Actions
            </h6>
            <div class="d-flex flex-column gap-2 mt-1">
              <button class="qa-btn" onclick="switchTab('assignment')">
                <span class="qa-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-person-plus-fill"></i></span>
                Assign Vetter
              </button>
              <button class="qa-btn" onclick="switchTab('vetting')">
                <span class="qa-icon bg-success bg-opacity-10 text-success"><i class="bi bi-file-earmark-check-fill"></i></span>
                Review Assessments
              </button>
              <button class="qa-btn" onclick="switchTab('courses')">
                <span class="qa-icon bg-warning bg-opacity-10 text-warning"><i class="bi bi-journal-plus"></i></span>
                Manage Courses
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <%-- Active assessments overview on dashboard --%>
    <% if (allPackages != null && !allPackages.isEmpty()) { %>
    <div class="mt-4">
      <div class="section-title mb-2">Assessment Status Overview</div>
      <div class="card border-0 shadow-sm overflow-hidden p-0">
        <div class="table-responsive">
          <table class="table kp-table mb-0">
            <thead><tr><th>Course</th><th>Type</th><th>Lecturer</th><th>Last Updated</th><th>Status</th><th></th></tr></thead>
            <tbody>
            <% SimpleDateFormat _ovDf = new SimpleDateFormat("d MMM yyyy HH:mm");
               for (Assessment _ov : allPackages) {
                 String _ovSc;
                 switch (_ov.getStatus() != null ? _ov.getStatus() : "") {
                   case "SUBMITTED":           _ovSc = "b-submitted"; break;
                   case "UNDER_REVIEW":        _ovSc = "b-review";    break;
                   case "APPROVED":            _ovSc = "b-approved";  break;
                   case "REJECTED":            _ovSc = "b-rejected";  break;
                   case "NEEDS_IMPROVEMENT":   _ovSc = "b-improve";   break;
                   case "PENDING_LEADER_SIGN": _ovSc = "b-leader";    break;
                   case "LEADER_APPROVED":     _ovSc = "b-leader";    break;
                   case "SENT_TO_FAKULTI":     _ovSc = "b-sent";      break;
                   default:                    _ovSc = "b-draft";
                 } %>
            <tr>
              <td><div class="cc-code"><%= _ov.getCourseCode() %></div><div style="font-size:12px;font-weight:600;margin-top:1px"><%= _ov.getCourseTitle() != null ? _ov.getCourseTitle() : "" %></div></td>
              <td style="font-size:12px"><%= _ov.getPaperTypeLabel() %></td>
              <td style="font-size:12px"><%= _ov.getLecturerName() != null ? _ov.getLecturerName() : "" %></td>
              <td class="mono" style="font-size:11px;white-space:nowrap"><% java.util.Date _od = _ov.getUpdatedAt() != null ? _ov.getUpdatedAt() : _ov.getSubmittedDate(); %><%= _od != null ? _ovDf.format(_od) : "—" %></td>
              <td><span class="st-badge <%= _ovSc %>"><span class="bdot"></span><%= _ov.getStatusLabel() %></span></td>
              <td>
                <div class="d-flex gap-1">
                  <a href="<%= ctx %>/LecturerReviewServlet?paperId=<%= _ov.getPaperId() %>" class="btn btn-kp-ghost btn-sm">View</a>
                  <% if ("SENT_TO_FAKULTI".equals(_ov.getStatus())) { %>
                  <form method="post" action="<%= ctx %>/KPDashboardServlet" style="display:inline"
                        onsubmit="return confirm('Approve and finalize this assessment?')">
                    <input type="hidden" name="action"  value="finalizeAssessment"/>
                    <input type="hidden" name="paperId" value="<%= _ov.getPaperId() %>"/>
                    <button type="submit" class="btn btn-sm" style="background:#312e81;color:#fff;font-weight:700;border:none;font-size:12px;padding:4px 10px;border-radius:6px;cursor:pointer">Finalize</button>
                  </form>
                  <% } %>
                </div>
              </td>
            </tr>
            <% } %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <% } %>
  </div>

  <%-- ════ COURSES ════ --%>
  
      </div>
      <div style="width: 320px;">
        <jsp:include page="calendarWidget.jsp"/>
      </div>
    </div>
<div class="page-section" id="page-courses">
    <div class="d-flex align-items-start justify-content-between mb-3 flex-wrap gap-2">
      <div>
        <div class="section-title">All Courses
          <span class="badge rounded-pill ms-1" style="background:var(--teal-soft);color:var(--teal);font-size:11px"><%= courses != null ? courses.size() : 0 %></span>
        </div>
        <div class="section-sub">Add, edit or remove courses in the programme.</div>
      </div>
      <div class="d-flex gap-2 flex-wrap">
        <div class="position-relative">
          <i class="bi bi-search position-absolute" style="left:11px;top:50%;transform:translateY(-50%);font-size:12px;color:var(--muted)"></i>
          <input type="text" id="courseSearch" class="form-control form-control-sm" placeholder="Search code or name..."
                 style="padding-left:30px;width:220px;border-radius:20px" onkeyup="filterCourses(this.value)"/>
        </div>
        <button class="btn btn-kp-teal btn-sm px-3" data-bs-toggle="modal" data-bs-target="#addCourseModal">
          <i class="bi bi-plus-lg me-1"></i> Add Course
        </button>
      </div>
    </div>
    <% if (courses == null || courses.isEmpty()) { %>
    <div class="card border-0 shadow-sm">
      <div class="card-body text-center py-5 text-muted">
        <i class="bi bi-journal-x fs-1 d-block mb-2 opacity-25"></i>
        No courses yet. Add one to get started.
      </div>
    </div>
    <% } else { %>
    <div class="row g-3" id="courseGrid">
      <% for (Course c : courses) {
           String lecName = c.getLecturerId() > 0 ? nameMap.get(c.getLecturerId()) : null;
           java.util.List ccVetterIds = (vetterMap != null && vetterMap.containsKey(c.getCourseId()))
               ? (java.util.List) vetterMap.get(c.getCourseId()) : new java.util.ArrayList();
           int ccLeaderId = (leaderMap != null && leaderMap.get(c.getCourseId()) != null)
               ? (Integer) leaderMap.get(c.getCourseId()) : 0;
           if (ccLeaderId == 0 && !ccVetterIds.isEmpty()) ccLeaderId = (Integer) ccVetterIds.get(0);
           boolean fullyAssigned = lecName != null && ccVetterIds.size() >= 2;
           String ccSyn = synopsisMap != null ? (String) synopsisMap.get(c.getCourseId()) : null;
      %>
      <div class="col-md-6 col-xl-4 course-item"
           data-search="<%= (c.getCourseCode() + " " + c.getCourseName()).toLowerCase() %>">
        <div class="card border-0 shadow-sm h-100 course-card">
          <div class="course-accent <%= fullyAssigned ? "accent-ok" : "accent-pending" %>"></div>
          <div class="card-body d-flex flex-column">
            <div class="d-flex justify-content-between align-items-start mb-2">
              <span class="cc-code"><%= c.getCourseCode() %></span>
              <div class="d-flex gap-1 align-items-center">
                <span class="badge rounded-pill <%= fullyAssigned ? "ready-pill" : "pending-pill" %>">
                  <i class="bi bi-<%= fullyAssigned ? "check-circle-fill" : "exclamation-circle-fill" %> me-1"></i><%= fullyAssigned ? "Ready" : "Setup needed" %>
                </span>
                <button class="btn btn-kp-ghost btn-sm"
                  onclick="openEditModal('<%= c.getCourseId() %>','<%= c.getCourseCode() %>','<%= c.getCourseName().replace("'","\\'") %>','<%= c.getCredit() %>','<%= c.getExamHour() %>','<%= c.getCore()!=null?c.getCore():"" %>','<%= c.getCoCategory()!=null?c.getCoCategory():"" %>','<%= c.getUniOffer()!=null?c.getUniOffer():"" %>','<%= c.getOfferPeriod()!=null?c.getOfferPeriod():"" %>','<%= c.getSenateRef()!=null?c.getSenateRef():"" %>','<%= c.getDepartment()!=null?c.getDepartment():"" %>','<%= c.getFaculty()!=null?c.getFaculty():"FSKM" %>')">
                  <i class="bi bi-pencil-fill"></i>
                </button>
                <form method="post" action="<%= ctx %>/KPDashboardServlet" style="margin:0"
                      onsubmit="return confirm('Delete <%= c.getCourseCode() %>? This cannot be undone.')">
                  <input type="hidden" name="action"   value="deleteCourse"/>
                  <input type="hidden" name="courseId" value="<%= c.getCourseId() %>"/>
                  <button type="submit" class="btn btn-kp-red btn-sm"><i class="bi bi-trash3-fill"></i></button>
                </form>
              </div>
            </div>
            <div class="cc-name mb-1"><%= c.getCourseName() %></div>
            <% if (ccSyn != null) { %>
            <div class="cc-syn mb-2" title="<%= esc(ccSyn) %>"><%= esc(ccSyn) %></div>
            <% } else { %>
            <div class="cc-syn cc-syn-empty mb-2">No synopsis yet. Click edit to add a short course brief.</div>
            <% } %>
            <div id="syn-<%= c.getCourseId() %>" class="d-none"><%= esc(ccSyn != null ? ccSyn : "") %></div>
            <div class="d-flex flex-wrap gap-2 mb-3">
              <span class="meta-chip"><i class="bi bi-award me-1"></i><%= c.getCredit() %> Credits</span>
              <span class="meta-chip"><i class="bi bi-clock me-1"></i><%= c.getExamHour() %>h Exam</span>
              <% if (c.getOfferPeriod() != null && !c.getOfferPeriod().isEmpty()) { %>
              <span class="meta-chip"><i class="bi bi-calendar3 me-1"></i><%= c.getOfferPeriod() %></span>
              <% } %>
              <% if (c.getDepartment() != null && !c.getDepartment().isEmpty()) { %>
              <span class="meta-chip"><i class="bi bi-building me-1"></i><%= c.getDepartment() %></span>
              <% } %>
            </div>

            <%-- People panel --%>
            <div class="people-panel mt-auto">
              <div class="people-row">
                <span class="people-icon lec-icon"><i class="bi bi-person-fill"></i></span>
                <div class="flex-grow-1 min-w-0">
                  <div class="people-label">Lecturer</div>
                  <div class="people-name <%= lecName == null ? "text-muted fst-italic" : "" %>">
                    <%= lecName != null ? lecName : "Not assigned" %>
                  </div>
                </div>
              </div>
              <div class="people-row">
                <span class="people-icon vet-icon"><i class="bi bi-shield-check"></i></span>
                <div class="flex-grow-1 min-w-0">
                  <div class="people-label">Vetter Panel
                    <% if (!ccVetterIds.isEmpty() && ccVetterIds.size() < 2) { %>
                    <span style="color:var(--red);font-weight:700">(needs <%= 2 - ccVetterIds.size() %> more)</span>
                    <% } %>
                  </div>
                  <% if (ccVetterIds.isEmpty()) { %>
                  <div class="people-name text-muted fst-italic">Not assigned</div>
                  <% } else { for (Object vidObj : ccVetterIds) {
                       int vid = (Integer) vidObj;
                       String vName = nameMap.get(vid);
                       boolean isLead = vid == ccLeaderId;
                  %>
                  <div class="people-name d-flex align-items-center gap-1">
                    <% if (isLead) { %><i class="bi bi-star-fill" style="color:#f59e0b;font-size:10px" title="Panel leader"></i><% } %>
                    <span><%= vName != null ? vName : ("ID " + vid) %></span>
                    <% if (isLead) { %><span class="leader-tag">Leader</span><% } %>
                  </div>
                  <% } } %>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <% } %>
    </div>
    <div class="text-center py-5 text-muted d-none" id="noCourseMatch">
      <i class="bi bi-search fs-1 d-block mb-2 opacity-25"></i>No courses match your search.
    </div>
    <% } %>
  </div>

  <%-- ════ ASSIGNMENT ════ --%>
  <div class="page-section" id="page-assignment">
    <div class="mb-3">
      <div class="section-title">Assign Lecturers and Vetters</div>
      <div class="section-sub">Assign 1 lecturer and a flexible panel of vetters per course (minimum 2). Mark one vetter as the panel leader.</div>
    </div>
    <% if (courses == null || courses.isEmpty()) { %>
    <div class="card border-0 shadow-sm">
      <div class="card-body text-center py-5 text-muted">
        <i class="bi bi-journal-x fs-1 d-block mb-2 opacity-25"></i>No courses.
      </div>
    </div>
    <% } else { for (Course c : courses) {
        java.util.List cVetterIds = (vetterMap != null && vetterMap.containsKey(c.getCourseId()))
            ? (java.util.List) vetterMap.get(c.getCourseId()) : new java.util.ArrayList();
        int cLeaderId = (leaderMap != null && leaderMap.get(c.getCourseId()) != null)
            ? (Integer) leaderMap.get(c.getCourseId()) : 0;
        if (cLeaderId == 0 && !cVetterIds.isEmpty()) cLeaderId = (Integer) cVetterIds.get(0);
        int rowsToShow = Math.max(cVetterIds.size(), 2);
    %>
    <div class="card border-0 shadow-sm mb-3">
      <div class="card-body">
        <form method="post" action="<%= ctx %>/KPDashboardServlet"
              class="assign-form" onsubmit="return prepAssign(this)">
          <input type="hidden" name="action"   value="assignStaff"/>
          <input type="hidden" name="courseId" value="<%= c.getCourseId() %>"/>
          <input type="hidden" name="leaderId" value="0"/>

          <div class="row g-3 align-items-start">
            <%-- Course identity --%>
            <div class="col-lg-3">
              <div class="cc-code"><%= c.getCourseCode() %></div>
              <div style="font-size:13px;font-weight:700;margin-top:4px;line-height:1.35"><%= c.getCourseName() %></div>
            </div>

            <%-- Lecturer --%>
            <div class="col-lg-3">
              <label class="form-label fw-semibold" style="font-size:11px;text-transform:uppercase;letter-spacing:.4px;color:var(--muted)">
                <i class="bi bi-person-fill me-1"></i>Lecturer
              </label>
              <select name="lecturerId" class="form-select form-select-sm">
                <option value="0">None</option>
                <% if (lecturers != null) { for (User l : lecturers) { %>
                <option value="<%= l.getUserId() %>" <%= c.getLecturerId()==l.getUserId()?"selected":"" %>><%= l.getFullName() %></option>
                <% } } %>
              </select>
            </div>

            <%-- Vetter panel (dynamic) --%>
            <div class="col-lg-5">
              <label class="form-label fw-semibold" style="font-size:11px;text-transform:uppercase;letter-spacing:.4px;color:var(--muted)">
                <i class="bi bi-shield-check me-1"></i>Vetter Panel <span class="text-muted text-lowercase fw-normal">(min 2, select one leader)</span>
              </label>
              <div class="vetter-rows d-flex flex-column gap-2">
                <% for (int vi = 0; vi < rowsToShow; vi++) {
                     int selId = vi < cVetterIds.size() ? (Integer) cVetterIds.get(vi) : 0;
                %>
                <div class="d-flex align-items-center gap-2 vetter-row">
                  <select name="vetterIds" class="form-select form-select-sm">
                    <option value="0">None</option>
                    <% if (potentialVetters != null) { for (User v : potentialVetters) { %>
                    <option value="<%= v.getUserId() %>" <%= selId==v.getUserId()?"selected":"" %>><%= v.getFullName() %></option>
                    <% } } %>
                  </select>
                  <label class="d-flex align-items-center gap-1 flex-shrink-0" style="font-size:11px;font-weight:600;cursor:pointer"
                         title="Panel leader">
                    <input type="radio" name="leadpick_<%= c.getCourseId() %>" class="form-check-input m-0 lead-radio"
                           <%= (selId != 0 && selId == cLeaderId) ? "checked" : "" %>/>
                    <i class="bi bi-star-fill" style="color:#d97706"></i> Leader
                  </label>
                  <button type="button" class="btn btn-kp-red btn-sm flex-shrink-0 remove-vetter" title="Remove vetter">
                    <i class="bi bi-x-lg"></i>
                  </button>
                </div>
                <% } %>
              </div>
              <button type="button" class="btn btn-kp-ghost btn-sm mt-2 add-vetter">
                <i class="bi bi-plus-lg me-1"></i>Add Vetter
              </button>
            </div>

            <%-- Save --%>
            <div class="col-lg-1 d-flex align-items-end">
              <button type="submit" class="btn btn-kp-teal btn-sm w-100" title="Save assignment">
                <i class="bi bi-floppy2-fill"></i>
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <% } } %>
  </div>

  <%-- ════ SUBMISSIONS ════ --%>
  <div class="page-section" id="page-submissions">
    <div class="mb-3">
      <div class="section-title">Assessment Submissions</div>
      <div class="section-sub">All submissions with full status history and timestamps.</div>
    </div>
    <div class="card border-0 shadow-sm overflow-hidden p-0">
      <div class="table-responsive">
        <table class="table kp-table mb-0">
          <thead>
            <tr>
              <th>Course</th>
              <th>Type</th>
              <th>Lecturer</th>
              <th>Submitted</th>
              <th>Last Updated</th>
              <th>Status</th>
              <th>Remarks</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
          <%
            SimpleDateFormat subDf = new SimpleDateFormat("d MMM yyyy HH:mm");
            if (allPackages == null || allPackages.isEmpty()) {
          %>
            <tr><td colspan="8" class="text-center py-5 text-muted">
              <i class="bi bi-inbox fs-1 d-block mb-2 opacity-25"></i>No assessments submitted yet.
            </td></tr>
          <% } else { for (Assessment sa : allPackages) {
              String subSc;
              switch (sa.getStatus() != null ? sa.getStatus() : "") {
                  case "SUBMITTED":           subSc = "b-submitted"; break;
                  case "UNDER_REVIEW":        subSc = "b-review";    break;
                  case "APPROVED":            subSc = "b-approved";  break;
                  case "REJECTED":            subSc = "b-rejected";  break;
                  case "NEEDS_IMPROVEMENT":   subSc = "b-improve";   break;
                  case "PENDING_LEADER_SIGN": subSc = "b-leader";    break;
                  case "LEADER_APPROVED":     subSc = "b-leader";    break;
                  case "SENT_TO_FAKULTI":     subSc = "b-sent";      break;
                  case "FINALIZED":           subSc = "b-sent";      break;
                  default:                    subSc = "b-draft";
              }
              String saLecName = sa.getLecturerName() != null ? sa.getLecturerName() : "";
              boolean saCanFinalize = "SENT_TO_FAKULTI".equals(sa.getStatus());
          %>
            <tr>
              <td>
                <div class="cc-code"><%= sa.getCourseCode() %></div>
                <div style="font-size:12px;font-weight:700;margin-top:2px"><%= sa.getCourseTitle() != null ? sa.getCourseTitle() : "" %></div>
              </td>
              <td style="font-size:12px"><%= sa.getPaperTypeLabel() %></td>
              <td style="font-size:12px"><%= saLecName %></td>
              <td class="mono" style="font-size:11px;white-space:nowrap"><%= sa.getSubmittedDate() != null ? subDf.format(sa.getSubmittedDate()) : "—" %></td>
              <td class="mono" style="font-size:11px;white-space:nowrap"><%= sa.getUpdatedAt() != null ? subDf.format(sa.getUpdatedAt()) : "—" %></td>
              <td><span class="st-badge <%= subSc %>"><span class="bdot"></span><%= sa.getStatusLabel() %></span></td>
              <td style="font-size:11px;max-width:160px;color:var(--muted);font-style:italic">
                <% String saRem = sa.getRemarks(); %>
                <%= (saRem != null && !saRem.isEmpty()) ? (saRem.length() > 60 ? saRem.substring(0,60)+"…" : saRem) : "—" %>
              </td>
              <td style="white-space:nowrap">
                <div class="d-flex gap-1 flex-wrap">
                  <a href="<%= ctx %>/SubmissionPackageServlet?paperId=<%= sa.getPaperId() %>"
                     class="btn btn-kp-ghost btn-sm"><i class="bi bi-folder2-open me-1"></i>Package</a>
                  <a href="<%= ctx %>/LecturerReviewServlet?paperId=<%= sa.getPaperId() %>"
                     class="btn btn-kp-navy btn-sm"><i class="bi bi-eye-fill me-1"></i>Review</a>
                  <% if (saCanFinalize) { %>
                  <form method="post" action="<%= ctx %>/KPDashboardServlet" style="display:inline"
                        onsubmit="return confirm('Approve and finalize this assessment?')">
                    <input type="hidden" name="action"  value="finalizeAssessment"/>
                    <input type="hidden" name="paperId" value="<%= sa.getPaperId() %>"/>
                    <button type="submit" class="btn btn-sm" style="background:#312e81;color:#fff;font-weight:700;border:none;font-size:12px;padding:4px 10px;border-radius:6px;cursor:pointer">Finalize</button>
                  </form>
                  <% } %>
                </div>
              </td>
            </tr>
          <% } } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <%-- ════ REPOSITORY ════ --%>
  <div class="page-section" id="page-repository">
    <div class="mb-3">
      <div class="section-title">Finalized Repository</div>
      <div class="section-sub">All assessments finalized by the Leader Vetter and sent to Fakulti. This is the official record.</div>
    </div>
    <% if (repoPackages == null || repoPackages.isEmpty()) { %>
    <div class="card border-0 shadow-sm p-5 text-center text-muted">
      <i class="bi bi-archive fs-1 d-block mb-2 opacity-25"></i>
      No finalized assessments yet.
    </div>
    <% } else { %>
    <div class="card border-0 shadow-sm overflow-hidden p-0">
      <div class="table-responsive">
        <table class="table kp-table mb-0">
          <thead>
            <tr>
              <th>Course</th>
              <th>Type</th>
              <th>Lecturer</th>
              <th>Submitted</th>
              <th>Finalized</th>
              <th>Session / Sem</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
          <%
            SimpleDateFormat repoDf = new SimpleDateFormat("d MMM yyyy HH:mm");
            for (Assessment ra3 : repoPackages) {
              String raLec = ra3.getLecturerName() != null ? ra3.getLecturerName() : "";
          %>
            <tr>
              <td>
                <div class="cc-code"><%= ra3.getCourseCode() %></div>
                <div style="font-size:12px;font-weight:700;margin-top:2px"><%= ra3.getCourseTitle() != null ? ra3.getCourseTitle() : "" %></div>
              </td>
              <td style="font-size:12px"><%= ra3.getPaperTypeLabel() %></td>
              <td style="font-size:12px"><%= raLec %></td>
              <td class="mono" style="font-size:11px;white-space:nowrap"><%= ra3.getSubmittedDate() != null ? repoDf.format(ra3.getSubmittedDate()) : "—" %></td>
              <td class="mono" style="font-size:11px;white-space:nowrap"><%= ra3.getUpdatedAt() != null ? repoDf.format(ra3.getUpdatedAt()) : "—" %></td>
              <td class="mono" style="font-size:11px"><%= ra3.getAcademicSession() != null ? ra3.getAcademicSession() : "" %> Sem <%= ra3.getSemester() %></td>
              <td style="white-space:nowrap">
                <div class="d-flex gap-1 flex-wrap">
                  <a href="<%= ctx %>/SubmissionPackageServlet?paperId=<%= ra3.getPaperId() %>"
                     class="btn btn-kp-ghost btn-sm"><i class="bi bi-folder2-open me-1"></i>Package</a>
                  <a href="<%= ctx %>/LecturerReviewServlet?paperId=<%= ra3.getPaperId() %>"
                     class="btn btn-kp-navy btn-sm"><i class="bi bi-eye-fill me-1"></i>Review</a>
                </div>
              </td>
            </tr>
          <% } %>
          </tbody>
        </table>
      </div>
    </div>
    <% } %>
  </div>

  <%-- ════ VETTING ════ --%>
  <div class="page-section" id="page-vetting">
    <div class="mb-3">
      <div class="section-title">All Submitted Assessments</div>
      <div class="section-sub">All packages submitted by lecturers. View the package or vetter review, or send approved papers to Fakulti.</div>
    </div>
    <div class="card border-0 shadow-sm overflow-hidden p-0">
      <div class="table-responsive">
        <table class="table kp-table mb-0">
          <thead>
            <tr>
              <th>Course</th>
              <th>Type</th>
              <th>Lecturer</th>
              <th>Vetter</th>
              <th>Session</th>
              <th>Submitted</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
          <%
            SimpleDateFormat kpDf = new SimpleDateFormat("d MMM yyyy");
            if (allPackages == null || allPackages.isEmpty()) {
          %>
            <tr><td colspan="8" class="text-center py-5 text-muted">
              <i class="bi bi-inbox fs-1 d-block mb-2 opacity-25"></i>No assessments submitted yet.
            </td></tr>
          <% } else { for (Assessment a : allPackages) {
              String kpSc;
              switch (a.getStatus() != null ? a.getStatus() : "") {
                  case "SUBMITTED":         kpSc = "b-submitted"; break;
                  case "UNDER_REVIEW":      kpSc = "b-review";    break;
                  case "APPROVED":          kpSc = "b-approved";  break;
                  case "REJECTED":          kpSc = "b-rejected";  break;
                  case "NEEDS_IMPROVEMENT":   kpSc = "b-improve"; break;
                  case "PENDING_LEADER_SIGN": kpSc = "b-leader";  break;
                  case "SENT_TO_FAKULTI":     kpSc = "b-sent";    break;
                  default:                  kpSc = "b-draft";
              }
              String kpLecName = a.getLecturerName() != null ? a.getLecturerName() : ("ID " + a.getLecturerId());
              String kpVetName = a.getVetterName() != null ? a.getVetterName() : "Not assigned";
              String kpDate    = a.getSubmittedDate() != null ? kpDf.format(a.getSubmittedDate()) : "Not submitted";
              boolean kpHasReview = "UNDER_REVIEW".equals(a.getStatus()) || "APPROVED".equals(a.getStatus())
                                 || "REJECTED".equals(a.getStatus()) || "NEEDS_IMPROVEMENT".equals(a.getStatus())
                                 || "SENT_TO_FAKULTI".equals(a.getStatus());
          %>
            <tr>
              <td>
                <div class="cc-code"><%= a.getCourseCode() %></div>
                <div style="font-size:12px;font-weight:700;margin-top:3px"><%= a.getCourseTitle() != null ? a.getCourseTitle() : "" %></div>
              </td>
              <td style="font-size:12px"><%= a.getPaperTypeLabel() %></td>
              <td style="font-size:12px"><%= kpLecName %></td>
              <td style="font-size:12px"><%= kpVetName %></td>
              <td class="mono" style="white-space:nowrap"><%= a.getAcademicSession() != null ? a.getAcademicSession() : "" %> Sem <%= a.getSemester() %></td>
              <td class="mono" style="white-space:nowrap"><%= kpDate %></td>
              <td><span class="st-badge <%= kpSc %>"><span class="bdot"></span><%= a.getStatusLabel() %></span></td>
              <td style="white-space:nowrap">
                <div class="d-flex gap-1 flex-wrap">
                  <a href="<%= ctx %>/SubmissionPackageServlet?paperId=<%= a.getPaperId() %>"
                     class="btn btn-kp-ghost btn-sm" title="View Package">
                    <i class="bi bi-folder2-open me-1"></i>Package
                  </a>
                  <% if (kpHasReview) { %>
                  <a href="<%= ctx %>/LecturerReviewServlet?paperId=<%= a.getPaperId() %>"
                     class="btn btn-kp-navy btn-sm" title="View Review">
                    <i class="bi bi-eye-fill me-1"></i>Review
                  </a>
                  <% } %>
                  <% if ("APPROVED".equals(a.getStatus())) { %>
                  <form method="post" action="<%= ctx %>/KPDashboardServlet" style="margin:0"
                        onsubmit="return confirm('Send <%= a.getCourseCode() %> to Fakulti? This cannot be undone.')">
                    <input type="hidden" name="action"  value="sendToFakulti"/>
                    <input type="hidden" name="paperId" value="<%= a.getPaperId() %>"/>
                    <button type="submit" class="btn btn-kp-teal btn-sm">
                      <i class="bi bi-send-fill me-1"></i>Send
                    </button>
                  </form>
                  <% } %>
                </div>
              </td>
            </tr>
          <% } } %>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <%-- ════ REPORT panel ════════════════════════════════════════════ --%>
  <div class="page-section" id="page-report">
  <%@ page import="java.text.SimpleDateFormat" %>
  <%
    java.util.List<java.util.Map<String,Object>> _rptPapers =
        (java.util.List<java.util.Map<String,Object>>) request.getAttribute("rptPapers");
    java.util.Map<String,Integer> _rptSc =
        (java.util.Map<String,Integer>) request.getAttribute("rptStatusCounts");
    java.util.Date _rptGen = (java.util.Date) request.getAttribute("rptGeneratedAt");
    java.text.SimpleDateFormat _rptDf = new java.text.SimpleDateFormat("d MMM yyyy HH:mm");
    java.text.SimpleDateFormat _rptDs = new java.text.SimpleDateFormat("d MMM yyyy");
  %>
  <% if (_rptPapers != null) { %>
  <div class="d-flex align-items-center justify-content-between mb-3">
    <div style="font-size:12px;color:var(--muted)">
      Generated: <%= _rptGen != null ? _rptDf.format(_rptGen) : "" %>
      &nbsp;|&nbsp; Total papers: <%= _rptPapers.size() %>
    </div>
    <a href="<%= ctx %>/ReportSummaryServlet" target="_blank"
       class="btn btn-sm" style="background:#312e81;color:#fff;font-size:12px;padding:5px 14px;border-radius:6px;font-weight:600;text-decoration:none">
      Print Report
    </a>
  </div>

  <%-- Status summary cards --%>
  <% if (_rptSc != null && !_rptSc.isEmpty()) { %>
  <div class="row g-2 mb-4">
  <% for (java.util.Map.Entry<String,Integer> _rse : _rptSc.entrySet()) {
       String _rsStatus = _rse.getKey();
       int _rsCount = _rse.getValue();
       String _rsBg = "FINALIZED".equals(_rsStatus) ? "#312e81"
           : "APPROVED".equals(_rsStatus) || "LEADER_APPROVED".equals(_rsStatus) ? "#059669"
           : "NEEDS_IMPROVEMENT".equals(_rsStatus) ? "#d97706"
           : "UNDER_REVIEW".equals(_rsStatus) || "SUBMITTED".equals(_rsStatus) ? "#2563eb"
           : "REJECTED".equals(_rsStatus) ? "#dc2626"
           : "#6b7280";
  %>
  <div class="col-6 col-md-3 col-lg-2">
    <div class="card border-0 h-100" style="background:<%= _rsBg %>12;border-left:3px solid <%= _rsBg %> !important;border-radius:8px">
      <div class="card-body py-2 px-3">
        <div style="font-size:22px;font-weight:800;color:<%= _rsBg %>"><%= _rsCount %></div>
        <div style="font-size:10px;font-weight:600;color:<%= _rsBg %>;text-transform:uppercase;letter-spacing:.3px"><%= _rsStatus.replace("_"," ") %></div>
      </div>
    </div>
  </div>
  <% } %>
  </div>
  <% } %>

  <%-- Main table --%>
  <div class="card border-0 shadow-sm overflow-hidden">
    <div class="table-responsive">
      <table class="table kp-table mb-0" style="font-size:12px">
        <thead>
          <tr>
            <th>No.</th>
            <th>Course Code</th>
            <th>Course Title</th>
            <th>Lecturer</th>
            <th>Vetter(s)</th>
            <th>Type</th>
            <th>Session / Sem</th>
            <th>Date Submitted</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
        <% int _rptNo = 0;
           for (java.util.Map<String,Object> _rp : _rptPapers) {
             _rptNo++;
             String _rpStatus = (String) _rp.get("status");
             String _rpSc;
             if ("SUBMITTED".equals(_rpStatus))           _rpSc = "b-submitted";
             else if ("UNDER_REVIEW".equals(_rpStatus))   _rpSc = "b-review";
             else if ("APPROVED".equals(_rpStatus))       _rpSc = "b-approved";
             else if ("REJECTED".equals(_rpStatus))       _rpSc = "b-rejected";
             else if ("NEEDS_IMPROVEMENT".equals(_rpStatus)) _rpSc = "b-improve";
             else if ("PENDING_LEADER_SIGN".equals(_rpStatus) || "LEADER_APPROVED".equals(_rpStatus)) _rpSc = "b-leader";
             else if ("SENT_TO_FAKULTI".equals(_rpStatus)) _rpSc = "b-sent";
             else if ("FINALIZED".equals(_rpStatus))      _rpSc = "b-finalized";
             else                                         _rpSc = "b-draft";
             java.util.List<String> _rpVetters = (java.util.List<String>) _rp.get("vetterNames");
             java.sql.Timestamp _rpSub = (java.sql.Timestamp) _rp.get("submittedDate");
        %>
        <tr>
          <td class="mono"><%= _rptNo %></td>
          <td><strong><%= _rp.get("courseCode") %></strong></td>
          <td><%= _rp.get("courseTitle") %></td>
          <td><%= _rp.get("lecturerName") %></td>
          <td style="color:var(--muted)">
            <% if (_rpVetters != null && !_rpVetters.isEmpty()) {
                 for (String _vn : _rpVetters) { %><div><%= _vn %></div><% }
               } else { %><span style="color:#ccc">—</span><% } %>
          </td>
          <td><%= _rp.get("paperType") %></td>
          <td class="mono" style="white-space:nowrap"><%= _rp.get("session") %> Sem <%= _rp.get("semester") %></td>
          <td class="mono" style="white-space:nowrap"><%= _rpSub != null ? _rptDs.format(_rpSub) : "—" %></td>
          <td><span class="st-badge <%= _rpSc %>"><span class="bdot"></span><%= _rpStatus != null ? _rpStatus.replace("_"," ") : "" %></span></td>
        </tr>
        <% } %>
        </tbody>
      </table>
    </div>
  </div>
  <% } else { %>
  <div class="text-center py-5 text-muted">
    <i class="bi bi-file-earmark-bar-graph fs-1 d-block mb-2"></i>
    No report data available.
  </div>
  <% } %>
  </div><%-- end page-report --%>

</div><%-- end content-wrap --%>

<%-- ══ ADD COURSE MODAL (Bootstrap) ══════════════════════════════ --%>
<div class="modal fade" id="addCourseModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title fw-bold"><i class="bi bi-plus-circle-fill text-success me-2"></i>Add New Course</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <form method="post" action="<%= ctx %>/KPDashboardServlet">
        <input type="hidden" name="action" value="addCourse"/>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-semibold">Course Code <span class="text-danger">*</span></label>
              <input type="text" name="courseCode" class="form-control" required placeholder="e.g. CSM3401"/>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Credits <span class="text-danger">*</span></label>
              <input type="number" name="credit" class="form-control" required value="3" min="1" max="6"/>
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Course Name <span class="text-danger">*</span></label>
              <input type="text" name="courseName" class="form-control" required placeholder="e.g. Internet of Things Computing"/>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Exam Hours</label>
              <input type="number" name="examHour" class="form-control" value="2" min="1" max="4"/>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Core</label>
              <input type="text" name="core" class="form-control" placeholder="e.g. Core"/>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Category</label>
              <input type="text" name="coCategory" class="form-control" placeholder="e.g. CS"/>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Offer Period</label>
              <input type="text" name="offerPeriod" class="form-control" placeholder="e.g. 2024/2025"/>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Senate Ref</label>
              <input type="text" name="senateRef" class="form-control" placeholder="e.g. UMT/001"/>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Department</label>
              <input type="text" name="department" class="form-control" placeholder="e.g. Bidang Komputer"/>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Faculty</label>
              <input type="text" name="faculty" class="form-control" value="FSKM"/>
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Synopsis <span class="text-muted fw-normal">(short course brief)</span></label>
              <textarea name="synopsis" class="form-control" rows="3" maxlength="1000"
                        placeholder="e.g. This course introduces the fundamentals of IoT computing, covering sensors, connectivity protocols and cloud integration..."></textarea>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-kp-ghost" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-kp-teal"><i class="bi bi-plus-lg me-1"></i>Add Course</button>
        </div>
      </form>
    </div>
  </div>
</div>

<%-- ══ EDIT COURSE MODAL (Bootstrap) ════════════════════════════ --%>
<div class="modal fade" id="editCourseModal" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title fw-bold"><i class="bi bi-pencil-fill text-primary me-2"></i>Edit Course</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <form method="post" action="<%= ctx %>/KPDashboardServlet">
        <input type="hidden" name="action"   value="updateCourse"/>
        <input type="hidden" name="courseId" id="editCourseId"/>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label fw-semibold">Course Code <span class="text-danger">*</span></label>
              <input type="text" name="courseCode" id="editCourseCode" class="form-control" required/>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Credits <span class="text-danger">*</span></label>
              <input type="number" name="credit" id="editCredit" class="form-control" required min="1" max="6"/>
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Course Name <span class="text-danger">*</span></label>
              <input type="text" name="courseName" id="editCourseName" class="form-control" required/>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Exam Hours</label>
              <input type="number" name="examHour" id="editExamHour" class="form-control" min="1" max="4"/>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Core</label>
              <input type="text" name="core" id="editCore" class="form-control"/>
            </div>
            <div class="col-md-4">
              <label class="form-label fw-semibold">Category</label>
              <input type="text" name="coCategory" id="editCoCategory" class="form-control"/>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Offer Period</label>
              <input type="text" name="offerPeriod" id="editOfferPeriod" class="form-control"/>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Senate Ref</label>
              <input type="text" name="senateRef" id="editSenateRef" class="form-control"/>
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Uni Offer</label>
              <input type="text" name="uniOffer" id="editUniOffer" class="form-control"/>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Department</label>
              <input type="text" name="department" id="editDepartment" class="form-control"/>
            </div>
            <div class="col-md-6">
              <label class="form-label fw-semibold">Faculty</label>
              <input type="text" name="faculty" id="editFaculty" class="form-control"/>
            </div>
            <div class="col-12">
              <label class="form-label fw-semibold">Synopsis <span class="text-muted fw-normal">(short course brief)</span></label>
              <textarea name="synopsis" id="editSynopsis" class="form-control" rows="3" maxlength="1000"
                        placeholder="Short description of what this course covers..."></textarea>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-kp-ghost" data-bs-dismiss="modal">Cancel</button>
          <button type="submit" class="btn btn-kp-teal"><i class="bi bi-floppy2-fill me-1"></i>Save Changes</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
const PAGE_META = {
  dashboard:  { title:'Dashboard',   sub:'Overview of the vetting system.' },
  courses:    { title:'Courses',     sub:'Manage all courses in the programme.' },
  assignment: { title:'Lecturers',   sub:'Assign lecturers and vetters to courses.' },
  vetting:    { title:'Assessments', sub:'All packages submitted by lecturers.' },
  report:     { title:'Reports',     sub:'Assessment vetting summary report.' }
};
const tabs     = document.querySelectorAll('.tab[data-page]');
const sections = document.querySelectorAll('.page-section');
const phTitle  = document.getElementById('phTitle');
const phSub    = document.getElementById('phSub');
const addCourseBtn = document.getElementById('addCourseBtn');

function switchTab(key) {
  tabs.forEach(b => b.classList.toggle('active', b.dataset.page === key));
  sections.forEach(s => s.classList.remove('active'));
  const t = document.getElementById('page-' + key);
  if (t) t.classList.add('active');
  const m = PAGE_META[key] || {};
  phTitle.textContent = m.title || key;
  phSub.textContent   = m.sub   || '';
  addCourseBtn.classList.toggle('d-none', key !== 'courses');
  const url = new URL(window.location.href);
  url.searchParams.set('page', key);
  window.history.replaceState({}, '', url);
}
tabs.forEach(b => b.addEventListener('click', function() {
  var key = b.dataset.page;
  if (key === 'report') {
    window.location.href = '<%= ctx %>/KPDashboardServlet?page=report';
  } else {
    switchTab(key);
  }
}));
switchTab('<%= activePage %>');

function openEditModal(id,code,name,credit,examHour,core,coCategory,uniOffer,offerPeriod,senateRef,department,faculty) {
  document.getElementById('editCourseId').value    = id;
  document.getElementById('editCourseCode').value  = code;
  document.getElementById('editCourseName').value  = name;
  document.getElementById('editCredit').value      = credit;
  document.getElementById('editExamHour').value    = examHour;
  document.getElementById('editCore').value        = core;
  document.getElementById('editCoCategory').value  = coCategory;
  document.getElementById('editUniOffer').value    = uniOffer;
  document.getElementById('editOfferPeriod').value = offerPeriod;
  document.getElementById('editSenateRef').value   = senateRef;
  document.getElementById('editDepartment').value  = department;
  document.getElementById('editFaculty').value     = faculty;
  // Synopsis is stored in a hidden div to survive quotes/newlines
  var synEl = document.getElementById('syn-' + id);
  document.getElementById('editSynopsis').value = synEl ? synEl.textContent : '';
  new bootstrap.Modal(document.getElementById('editCourseModal')).show();
}

/* ── Course search filter ── */
function filterCourses(q) {
  q = q.trim().toLowerCase();
  var any = false;
  document.querySelectorAll('.course-item').forEach(function(item) {
    var match = q === '' || item.dataset.search.indexOf(q) !== -1;
    item.style.display = match ? '' : 'none';
    if (match) any = true;
  });
  var empty = document.getElementById('noCourseMatch');
  if (empty) empty.classList.toggle('d-none', any);
}

/* ── Vetter panel: add/remove rows + leader + min-2 validation ── */
document.querySelectorAll('.assign-form').forEach(function(form) {
  var rows = form.querySelector('.vetter-rows');

  // Add vetter: clone the first row, reset it
  form.querySelector('.add-vetter').addEventListener('click', function() {
    var first = rows.querySelector('.vetter-row');
    var clone = first.cloneNode(true);
    clone.querySelector('select').value = '0';
    clone.querySelector('.lead-radio').checked = false;
    rows.appendChild(clone);
  });

  // Remove vetter (keep at least 2 rows)
  rows.addEventListener('click', function(e) {
    var btn = e.target.closest('.remove-vetter');
    if (!btn) return;
    if (rows.querySelectorAll('.vetter-row').length <= 2) {
      alert('A minimum of 2 vetters is required for each assessment.');
      return;
    }
    btn.closest('.vetter-row').remove();
  });
});

/* Validate before submit: min 2 distinct vetters, set leaderId from the checked row */
function prepAssign(form) {
  var rows = form.querySelectorAll('.vetter-row');
  var seen = {};
  var ids  = [];
  var leaderId = 0;
  var emptyLeader = false;

  rows.forEach(function(row) {
    var val = parseInt(row.querySelector('select').value) || 0;
    var isLead = row.querySelector('.lead-radio').checked;
    if (val > 0) {
      if (seen[val]) return;
      seen[val] = true;
      ids.push(val);
      if (isLead) leaderId = val;
    } else if (isLead) {
      emptyLeader = true;
    }
  });

  // No vetters at all is allowed (clears the panel); otherwise enforce min 2
  if (ids.length > 0 && ids.length < 2) {
    alert('A minimum of 2 vetters is required for each assessment.');
    return false;
  }
  if (emptyLeader) {
    alert('The leader must be an assigned vetter. Pick a vetter in that row first.');
    return false;
  }
  // Lecturer cannot vet their own course
  var lecturerId = parseInt(form.querySelector('select[name=lecturerId]').value) || 0;
  if (lecturerId > 0 && seen[lecturerId]) {
    alert('The course lecturer cannot be a vetter of their own course.');
    return false;
  }
  if (ids.length > 0 && leaderId === 0) {
    alert('Please mark one vetter as the panel leader.');
    return false;
  }
  form.querySelector('input[name=leaderId]').value = leaderId;
  return true;
}

/* Notification bell */
(function() {
  var CTX_KP = '<%= ctx %>';
  var panelOpen = false, loaded = false;
  window.toggleNotif = function() {
    var panel = document.getElementById('notifPanel');
    panelOpen = !panelOpen;
    panel.classList.toggle('open', panelOpen);
    if (panelOpen && !loaded) loadNotifications();
  };
  document.addEventListener('click', function(e) {
    var wrap = document.getElementById('notifWrap');
    if (wrap && !wrap.contains(e.target) && panelOpen) {
      document.getElementById('notifPanel').classList.remove('open');
      panelOpen = false;
    }
  });
  function loadNotifications() {
    var listEl = document.getElementById('notifList');
    listEl.innerHTML = '<div class="notif-loading">Loading...</div>';
    var xhr = new XMLHttpRequest();
    xhr.open('GET', CTX_KP + '/NotificationServlet?action=list', true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        listEl.innerHTML = xhr.status === 200 ? xhr.responseText : '<div class="notif-empty">Could not load notifications.</div>';
        loaded = true;
      }
    };
    xhr.send();
  }
  window.markRead = function(nid, paperId) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', CTX_KP + '/NotificationServlet', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        updateBadge(-1);
        if (paperId > 0) window.location.href = CTX_KP + '/LecturerReviewServlet?paperId=' + paperId;
        else { loaded = false; loadNotifications(); }
      }
    };
    xhr.send('action=markRead&id=' + nid);
  };
  window.markAllRead = function() {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', CTX_KP + '/NotificationServlet', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        var badge = document.getElementById('notifBadge');
        if (badge) badge.style.display = 'none';
        loaded = false; loadNotifications();
      }
    };
    xhr.send('action=markAllRead');
  };
  function updateBadge(delta) {
    var badge = document.getElementById('notifBadge');
    if (!badge) return;
    var next = Math.max(0, (parseInt(badge.textContent) || 0) + delta);
    if (next === 0) badge.style.display = 'none';
    else { badge.style.display = ''; badge.textContent = next > 99 ? '99+' : next; }
  }
})();
</script>
  <jsp:include page="footer.jsp"/>
</body>
</html>
