<%--
    topnav.jsp  —  Shared navigation bar fragment
    Include via:  <jsp:include page="topnav.jsp"/>

    Expects session attrs: fullName (String), role (String)
    Optional request attr: currentPage (String) — highlights the matching tab
--%>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="Model.VetterCourseInfo" %>
<%
    String tnName = (String) session.getAttribute("fullName");
    String tnRole = (String) session.getAttribute("role");
    String tnPage = (String) request.getAttribute("currentPage");
    int    tnUid  = session.getAttribute("userId") != null ? (int) session.getAttribute("userId") : 0;
    if (tnName == null) tnName = "User";
    if (tnRole == null) tnRole = "";
    if (tnPage == null) tnPage = "";

    /* Initials */
    String tnInit = "U";
    {
        String[] p = tnName.trim().split("\\s+");
        int s = (p.length > 1 && p[0].endsWith(".")) ? 1 : 0;
        StringBuilder sb = new StringBuilder();
        for (int i = s; i < p.length && sb.length() < 2; i++)
            sb.append(Character.toUpperCase(p[i].charAt(0)));
        if (sb.length() > 0) tnInit = sb.toString();
    }

    boolean tnIsVetter = "Vetter".equalsIgnoreCase(tnRole)
                      || Boolean.TRUE.equals(session.getAttribute("isVetter"));
    boolean tnIsKP     = "KP".equalsIgnoreCase(tnRole) || "KP_ADMIN".equalsIgnoreCase(tnRole);
    String tnCtx = request.getContextPath();
    String tnDash = tnIsVetter
            ? tnCtx + "/VetterDashboardServlet?page=dashboard"
            : tnIsKP
                ? tnCtx + "/KPDashboardServlet"
                : tnCtx + "/LecturerDashboardServlet";

    /* Unread notification count — queried once per page load */
    int tnUnread = 0;
    if (tnUid > 0) {
        try (java.sql.Connection _nc = util.DBConnection.getConnection();
             java.sql.PreparedStatement _np = _nc.prepareStatement(
                 "SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=0")) {
            _np.setInt(1, tnUid);
            java.sql.ResultSet _nr = _np.executeQuery();
            if (_nr.next()) tnUnread = _nr.getInt(1);
        } catch (Exception _ne) { /* non-fatal */ }
    }

    /* Check if this vetter is a leader for any course */
    boolean tnIsLeader = false;
    if (tnUid > 0 && tnIsVetter) {
        try (java.sql.Connection _nc = util.DBConnection.getConnection();
             java.sql.PreparedStatement _lp = _nc.prepareStatement(
                 "SELECT COUNT(*) FROM course_vetters WHERE vetter_id=? AND is_leader=1")) {
            _lp.setInt(1, tnUid);
            java.sql.ResultSet _lr = _lp.executeQuery();
            if (_lr.next() && _lr.getInt(1) > 0) {
                tnIsLeader = true;
            }
        } catch (Exception _le) { /* non-fatal */ }
    }

    /* Load courses, lecturers, and co-vetters for the navbar display */
    java.util.List<VetterCourseInfo> tnCourses = new java.util.ArrayList<>();
    if (tnUid > 0 && tnIsVetter) {
        String sql =
            "SELECT c.course_id, c.course_code, c.course_name, cv.is_leader, " +
            "       u.full_name AS lecturer_name " +
            "FROM course c " +
            "INNER JOIN course_vetters cv ON cv.course_id = c.course_id AND cv.vetter_id = ? " +
            "LEFT JOIN users u ON u.user_id = c.lecturer_id " +
            "ORDER BY c.course_code";
        try (java.sql.Connection con = util.DBConnection.getConnection();
             java.sql.PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, tnUid);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    VetterCourseInfo ci = new VetterCourseInfo();
                    ci.courseId = rs.getInt("course_id");
                    ci.courseCode = rs.getString("course_code");
                    ci.courseName = rs.getString("course_name");
                    ci.isLeader = rs.getInt("is_leader") == 1;
                    ci.lecturerName = rs.getString("lecturer_name");
                    
                    // Load co-vetters for this course
                    String sqlCo = "SELECT u.full_name, cv.is_leader FROM course_vetters cv " +
                                   "JOIN users u ON u.user_id = cv.vetter_id " +
                                   "WHERE cv.course_id = ? AND cv.vetter_id != ?";
                    try (java.sql.PreparedStatement psCo = con.prepareStatement(sqlCo)) {
                        psCo.setInt(1, ci.courseId);
                        psCo.setInt(2, tnUid);
                        try (java.sql.ResultSet rsCo = psCo.executeQuery()) {
                            while (rsCo.next()) {
                                String name = rsCo.getString("full_name");
                                if (rsCo.getInt("is_leader") == 1) name += " (Leader)";
                                ci.coVetters.add(name);
                            }
                        }
                    }
                    tnCourses.add(ci);
                }
            }
        } catch (Exception e) { /* non-fatal */ }
    }
%>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet"/>
<style>
/* ── TOPNAV STYLE Unification ── */
.topnav {
  background: linear-gradient(135deg,#312e81 0%,#4c1d95 55%,#6d28d9 100%);
  position: sticky;
  top: 0;
  z-index: 1030;
  border-bottom: 2px solid #f59e0b;
  font-family: 'Sora', system-ui, -apple-system, sans-serif;
  color: #fff;
}
.nav-inner {
  max-width: 1280px;
  margin: 0 auto;
  padding: 0 24px;
  height: 58px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}
.brand {
  display: flex;
  align-items: center;
  gap: 9px;
  padding-right: 22px;
  border-right: 1px solid rgba(255,255,255,.1);
  flex-shrink: 0;
  text-decoration: none !important;
}
.brand-logo {
  width: 36px;
  height: 36px;
  object-fit: contain;
  border-radius: 6px;
}
.brand-name {
  font-size: 13px;
  font-weight: 800;
  color: #fff;
  line-height: 1.2;
}
.brand-sub {
  font-size: 10px;
  color: #fbbf24;
  letter-spacing: .5px;
  line-height: 1.2;
}
.nav-tabs {
  display: flex;
  align-items: center;
  gap: 2px;
  padding-left: 16px;
  flex: 1;
  overflow: visible;
  flex-wrap: wrap;
  border: none !important;
}
.nav-tabs::-webkit-scrollbar {
  display: none;
}
.tab {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 7px 12px;
  border-radius: 8px;
  border: 1px solid transparent;
  background: none;
  color: rgba(255,255,255,.5) !important;
  font-family: 'Sora', sans-serif;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  white-space: nowrap;
  transition: .15s;
  text-decoration: none !important;
}
.tab:hover {
  background: rgba(255,255,255,.07);
  color: #fff !important;
}
.tab.active {
  background: rgba(245,158,11,.2);
  border-color: rgba(245,158,11,.45);
  color: #fbbf24 !important;
}
.nav-right {
  margin-left: auto;
  display: flex;
  align-items: center;
  gap: 12px;
  padding-left: 16px;
  border-left: 1px solid rgba(255,255,255,.1);
  flex-shrink: 0;
}
.nav-user-link {
  display: flex;
  align-items: center;
  gap: 9px;
  text-decoration: none !important;
  border-radius: 8px;
  padding: 4px 8px;
  transition: .15s;
  color: #fff !important;
}
.nav-user-link:hover {
  background: rgba(255,255,255,.06);
}
.user-name {
  font-size: 12px;
  font-weight: 700;
  color: #fff;
  text-align: right;
  line-height: 1.3;
}
.user-role {
  font-size: 10px;
  color: rgba(255,255,255,.5);
  text-align: right;
  line-height: 1.2;
}
.avatar {
  width: 34px;
  height: 34px;
  border-radius: 50%;
  background: linear-gradient(135deg,#f59e0b,#fcd34d);
  color: #2a1454;
  display: grid;
  place-items: center;
  font-weight: 800;
  font-size: 13px;
  flex-shrink: 0;
}
.logout-link {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  border: 1px solid rgba(255,255,255,.15);
  background: none;
  color: rgba(255,255,255,.5);
  display: grid;
  place-items: center;
  text-decoration: none;
  transition: .15s;
}
.logout-link:hover {
  background: rgba(190,18,60,.25);
  color: #fda4af;
}

/* ── Notification bell ─────────────────────────────────── */
.notif-wrap{position:relative;display:flex;align-items:center}
.notif-btn{width:34px;height:34px;border-radius:50%;border:1px solid rgba(255,255,255,.15);
  background:none;color:rgba(255,255,255,.65);display:grid;place-items:center;
  cursor:pointer;position:relative;transition:.15s;flex-shrink:0}
.notif-btn:hover{background:rgba(255,255,255,.1);color:#fff}
.notif-btn svg{width:17px;height:17px}
.notif-badge{position:absolute;top:-3px;right:-3px;min-width:17px;height:17px;
  background:#dc2626;color:#fff;border-radius:10px;font-size:10px;font-weight:700;
  display:flex;align-items:center;justify-content:center;padding:0 4px;
  border:2px solid #2a1454;line-height:1;pointer-events:none}
/* Dropdown panel */
.notif-panel{display:none;position:absolute;top:calc(100% + 10px);right:0;
  width:340px;background:#fff;border-radius:10px;border:1px solid #e2e8f0;
  box-shadow:0 8px 32px rgba(0,0,0,.18);z-index:9999;overflow:hidden}
.notif-panel.open{display:block}
.notif-head{display:flex;align-items:center;justify-content:space-between;
  padding:13px 16px;border-bottom:1px solid #f1f5f9}
.notif-head-title{font-size:13px;font-weight:700;color:#2a1454}
.notif-head-actions{display:flex;align-items:center;gap:8px}
.notif-mark-all{font-size:11px;color:#185FA5;cursor:pointer;font-weight:600;
  background:none;border:none;padding:0}
.notif-mark-all:hover{text-decoration:underline}
.notif-scroll{max-height:380px;overflow-y:auto}
.notif-item{display:flex;gap:10px;padding:12px 16px;border-bottom:1px solid #f8fafc;
  cursor:pointer;transition:.12s;align-items:flex-start}
.notif-item:hover{background:#f8fafc}
.notif-item.notif-read{opacity:.65}
.notif-icon{width:32px;height:32px;border-radius:50%;background:#e6f1fb;
  display:grid;place-items:center;font-size:15px;flex-shrink:0;margin-top:1px}
.notif-item:not(.notif-read) .notif-icon{background:#fef3c7}
.notif-content{flex:1;min-width:0}
.notif-text{font-size:12px;color:#1a2435;line-height:1.55;margin-bottom:3px}
.notif-item:not(.notif-read) .notif-text{font-weight:600}
.notif-time{font-size:10px;color:#8a9ab0}
.notif-unread-dot{width:8px;height:8px;border-radius:50%;background:#185FA5;
  flex-shrink:0;margin-top:5px}
.notif-empty{padding:28px 16px;text-align:center;font-size:12px;color:#8a9ab0}
.notif-footer{padding:10px 16px;text-align:center;border-top:1px solid #f1f5f9}
.notif-footer a{font-size:12px;color:#185FA5;text-decoration:none;font-weight:600}
.notif-footer a:hover{text-decoration:underline}
.notif-loading{padding:24px;text-align:center;font-size:12px;color:#8a9ab0}
</style>

<header class="topnav">
  <div class="nav-inner">

    <%-- Brand --%>
    <a href="<%= tnDash %>" class="brand">
      <img src="<%= tnCtx %>/images/umt-logo.png" alt="UMT Logo" class="brand-logo">
      <div>
        <div class="brand-name">E-Vetting</div>
        <div class="brand-sub">UMT</div>
      </div>
    </a>

    <%-- Navigation tabs (role-aware) --%>
    <nav class="nav-tabs">
      <% if (tnIsVetter) { %>
        <a href="<%= tnCtx %>/VetterDashboardServlet?page=dashboard"
           class="tab <%= "dashboard".equals(tnPage) ? "active" : "" %>">
           <i class="bi bi-speedometer2"></i> Dashboard
        </a>
        <a href="<%= tnCtx %>/VetterDashboardServlet?page=queue"
           class="tab <%= ("queue".equals(tnPage)||"review".equals(tnPage)) ? "active" : "" %>">
           <i class="bi bi-file-earmark-check"></i> Vetting Queue
        </a>
        <a href="<%= tnCtx %>/VetterDashboardServlet?page=reviewed"
           class="tab <%= "reviewed".equals(tnPage) ? "active" : "" %>">
           <i class="bi bi-check-all"></i> Reviewed
        </a>

        <a href="<%= tnCtx %>/VetterDashboardServlet?page=courses"
           class="tab <%= "courses".equals(tnPage) ? "active" : "" %>">
           <i class="bi bi-journal-text"></i> Assigned Courses
        </a>

        <a href="<%= tnCtx %>/VetterDashboardServlet?page=teams"
           class="tab <%= "teams".equals(tnPage) ? "active" : "" %>">
           <i class="bi bi-people"></i> Vetting Teams
        </a>
      <% } else if (tnIsKP) { %>
        <a href="<%= tnCtx %>/KPDashboardServlet?page=dashboard"
           class="tab <%= "dashboard".equals(tnPage) ? "active" : "" %>">
           <i class="bi bi-speedometer2"></i> Dashboard
        </a>
        <a href="<%= tnCtx %>/KPDashboardServlet?page=vetting"
           class="tab <%= "vetting".equals(tnPage) ? "active" : "" %>">
           <i class="bi bi-file-earmark-check"></i> Assessments
        </a>
        <a href="<%= tnCtx %>/KPDashboardServlet?page=assignment"
           class="tab <%= "assignment".equals(tnPage) ? "active" : "" %>">
           <i class="bi bi-people"></i> Lecturers
        </a>
        <a href="<%= tnCtx %>/KPDashboardServlet?page=courses"
           class="tab <%= "courses".equals(tnPage) ? "active" : "" %>">
           <i class="bi bi-journal-bookmark"></i> Courses
        </a>
        <a href="<%= tnCtx %>/ReportSummaryServlet"
           class="tab <%= "reports".equals(tnPage) ? "active" : "" %>">
           <i class="bi bi-file-earmark-bar-graph"></i> Reports
        </a>
      <% } else { %>
        <a href="<%= tnCtx %>/LecturerDashboardServlet?page=dashboard"
           class="tab <%= "dashboard".equals(tnPage) ? "active" : "" %>">
           <i class="bi bi-speedometer2"></i> Dashboard
        </a>
        <a href="<%= tnCtx %>/LecturerDashboardServlet?page=courses"
           class="tab <%= "courses".equals(tnPage) ? "active" : "" %>">
           <i class="bi bi-journal-bookmark"></i> My Courses
        </a>
        <a href="<%= tnCtx %>/LecturerDashboardServlet?page=assessments"
           class="tab <%= "assessments".equals(tnPage) ? "active" : "" %>">
           <i class="bi bi-file-earmark-text"></i> Assessments
        </a>
        <a href="<%= tnCtx %>/LecturerDashboardServlet?page=jss"
           class="tab <%= "jss".equals(tnPage) ? "active" : "" %>">
           <i class="bi bi-clipboard-data"></i> JSS
        </a>
      <% } %>
    </nav>

    <%-- Right: notifications + user info + logout --%>
    <div class="nav-right">

      <%-- Bell --%>
      <div class="notif-wrap" id="notifWrap">
        <button class="notif-btn" id="notifBtn" onclick="toggleNotif()" title="Notifications">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
               stroke-linecap="round" stroke-linejoin="round">
            <path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/>
            <path d="M13.73 21a2 2 0 01-3.46 0"/>
          </svg>
          <% if (tnUnread > 0) { %>
          <span class="notif-badge" id="notifBadge"><%= tnUnread > 99 ? "99+" : tnUnread %></span>
          <% } else { %>
          <span class="notif-badge" id="notifBadge" style="display:none">0</span>
          <% } %>
        </button>

        <div class="notif-panel" id="notifPanel">
          <div class="notif-head">
            <span class="notif-head-title">Notifications</span>
            <div class="notif-head-actions">
              <button class="notif-mark-all" onclick="markAllRead()" title="Mark all as read">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
              </button>
            </div>
          </div>
          <div class="notif-scroll" id="notifList">
            <div class="notif-loading">Loading…</div>
          </div>
          <div class="notif-footer">
            <a href="<%= tnCtx %>/NotificationServlet?action=all">See all notifications</a>
          </div>
        </div>
      </div>

      <%-- User --%>
      <a href="<%= tnCtx %>/UserProfileServlet" class="nav-user-link" title="My Profile">
        <div>
          <div class="user-name"><%= tnName %></div>
          <div class="user-role"><%= tnIsLeader ? "Vetting Leader" : tnRole %></div>
        </div>
        <div class="avatar"><%= tnInit %></div>
      </a>
      <a href="<%= tnCtx %>/logout" class="logout-link" title="Sign out">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
             stroke-linecap="round" stroke-linejoin="round" width="16" height="16">
          <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/>
          <polyline points="16 17 21 12 16 7"/>
          <line x1="21" y1="12" x2="9" y2="12"/>
        </svg>
      </a>
    </div>

  </div>
</header>

<script>
(function() {
  var CTX_TN = '<%= tnCtx %>';
  var panelOpen = false;
  var loaded    = false;

  /* Toggle dropdown */
  window.toggleNotif = function() {
    var panel = document.getElementById('notifPanel');
    panelOpen = !panelOpen;
    panel.classList.toggle('open', panelOpen);
    if (panelOpen && !loaded) { loadNotifications(); }
  };

  /* Close when clicking outside */
  document.addEventListener('click', function(e) {
    var wrap = document.getElementById('notifWrap');
    if (wrap && !wrap.contains(e.target) && panelOpen) {
      document.getElementById('notifPanel').classList.remove('open');
      panelOpen = false;
    }
  });

  /* Load notification list via XMLHttpRequest */
  function loadNotifications() {
    var listEl = document.getElementById('notifList');
    listEl.innerHTML = '<div class="notif-loading">Loading…</div>';
    var xhr = new XMLHttpRequest();
    xhr.open('GET', CTX_TN + '/NotificationServlet?action=list', true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        if (xhr.status === 200) {
          listEl.innerHTML = xhr.responseText;
          loaded = true;
        } else {
          listEl.innerHTML = '<div class="notif-empty">Could not load notifications.</div>';
        }
      }
    };
    xhr.send();
  }

  /* Mark single notification as read, then navigate to paper */
  window.markRead = function(nid, paperId) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', CTX_TN + '/NotificationServlet', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        updateBadge(-1);
        if (paperId > 0) {
          window.location.href = CTX_TN + '/LecturerReviewServlet?paperId=' + paperId;
        } else {
          loaded = false;
          loadNotifications();
        }
      }
    };
    xhr.send('action=markRead&id=' + nid);
  };

  /* Mark all as read */
  window.markAllRead = function() {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', CTX_TN + '/NotificationServlet', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        var badge = document.getElementById('notifBadge');
        if (badge) badge.style.display = 'none';
        loaded = false;
        loadNotifications();
      }
    };
    xhr.send('action=markAllRead');
  };

  /* Decrement badge count */
  function updateBadge(delta) {
    var badge = document.getElementById('notifBadge');
    if (!badge) return;
    var cur = parseInt(badge.textContent) || 0;
    var next = Math.max(0, cur + delta);
    if (next === 0) { badge.style.display = 'none'; }
    else { badge.style.display = ''; badge.textContent = next > 99 ? '99+' : next; }
  }
})();
</script>
