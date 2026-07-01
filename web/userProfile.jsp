<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp"); return;
    }
    String sessionRole = (String) sess.getAttribute("role");
    String sessionName = (String) sess.getAttribute("fullName");

    String pFullName = (String) request.getAttribute("pFullName");
    String pEmail    = (String) request.getAttribute("pEmail");
    String pPhone    = (String) request.getAttribute("pPhone");
    String pFaculty  = (String) request.getAttribute("pFaculty");
    String pPosition = (String) request.getAttribute("pPosition");
    String pRole     = (String) request.getAttribute("pRole");

    if (pFullName == null) pFullName = "";
    if (pEmail    == null) pEmail    = "";
    if (pPhone    == null) pPhone    = "";
    if (pFaculty  == null) pFaculty  = "";
    if (pPosition == null) pPosition = "";
    if (pRole     == null) pRole     = sessionRole != null ? sessionRole : "";

    /* Avatar initials */
    String pInit = "U";
    if (!pFullName.trim().isEmpty()) {
        String[] pp = pFullName.trim().split("\\s+");
        int ps2 = (pp.length > 1 && pp[0].endsWith(".")) ? 1 : 0;
        StringBuilder sb = new StringBuilder();
        for (int i = ps2; i < pp.length && sb.length() < 2; i++)
            sb.append(Character.toUpperCase(pp[i].charAt(0)));
        if (sb.length() > 0) pInit = sb.toString();
    }

    boolean saved  = "true".equals(request.getParameter("saved"));
    boolean failed = "false".equals(request.getParameter("saved"));
    String ctx = request.getContextPath();
    String backUrl = "Vetter".equalsIgnoreCase(pRole)
            ? ctx + "/VetterDashboardServlet?page=dashboard"
            : ctx + "/LecturerDashboardServlet";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>My Profile — E-Vetting</title>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;600;700;800&display=swap" rel="stylesheet"/>
<style>
:root{
  --navy:#2a1454;--teal:#6d28d9;--teal-soft:#f5f3ff;--teal-b:#ddd6fe;
  --cream:#f7f6fb;--surface:#fff;--border:#e4e9f0;--ink:#1e1133;--muted:#7a8aab;
  --green:#15803d;--green-bg:#f0fdf4;--green-b:#86efac;
  --red:#be123c;--red-bg:#fff1f2;--red-b:#fda4af;
  --r:10px;--sh:0 1px 3px rgba(11,22,40,.06),0 4px 12px rgba(11,22,40,.06);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Sora',system-ui,sans-serif;background:var(--cream);color:var(--ink);font-size:14px;min-height:100vh}
a{color:inherit;text-decoration:none}

/* ── Topnav ── */
.topnav{background:linear-gradient(135deg,#312e81 0%,#4c1d95 55%,#6d28d9 100%);position:sticky;top:0;z-index:100;border-bottom:2px solid #f59e0b}
.nav-inner{max-width:1200px;margin:0 auto;padding:0 24px;height:58px;display:flex;align-items:center}
.brand{display:flex;align-items:center;gap:9px;padding-right:22px;border-right:1px solid rgba(255,255,255,.1);flex-shrink:0;text-decoration:none}
.brand-logo{width:34px;height:34px;object-fit:contain;border-radius:6px}
.brand-name{font-size:13px;font-weight:800;color:#fff}
.brand-sub{font-size:10px;color:rgba(255,255,255,.4)}
.back-link{display:flex;align-items:center;gap:6px;margin-left:18px;font-size:13px;font-weight:600;
           color:rgba(255,255,255,.6);text-decoration:none;transition:.15s}
.back-link:hover{color:#fff}
.back-link svg{width:16px;height:16px}
.nav-right{margin-left:auto;display:flex;align-items:center;gap:10px;padding-left:16px;border-left:1px solid rgba(255,255,255,.1)}
.user-name{font-size:12px;font-weight:700;color:#fff}
.user-role{font-size:10px;color:rgba(255,255,255,.4)}
.avatar{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#f59e0b,#fcd34d);color:#2a1454;display:grid;place-items:center;font-weight:800;font-size:13px}
.logout-link{width:32px;height:32px;border-radius:50%;border:1px solid rgba(255,255,255,.15);background:none;
             color:rgba(255,255,255,.5);display:grid;place-items:center;text-decoration:none;transition:.15s}
.logout-link:hover{background:rgba(190,18,60,.25);color:#fda4af}

/* ── Layout ── */
.page{max-width:760px;margin:40px auto;padding:0 20px 60px}

/* ── Profile card ── */
.profile-card{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);box-shadow:var(--sh);overflow:hidden}
.profile-hero{background:var(--navy);padding:32px 28px;display:flex;align-items:center;gap:22px}
.profile-avatar-lg{width:72px;height:72px;border-radius:50%;background:var(--teal);color:#fff;
                   display:grid;place-items:center;font-size:26px;font-weight:800;flex-shrink:0;
                   border:3px solid rgba(255,255,255,.2)}
.profile-hero-info h1{font-size:22px;font-weight:800;color:#fff}
.profile-hero-info p{font-size:13px;color:rgba(255,255,255,.5);margin-top:4px}
.role-badge{display:inline-block;margin-top:10px;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;
            background:rgba(91,33,182,.25);color:#5eead4;border:1px solid rgba(91,33,182,.3)}

.profile-body{padding:28px}

/* ── Form fields ── */
.field-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px}
@media(max-width:560px){.field-grid{grid-template-columns:1fr}}
.field{display:flex;flex-direction:column;gap:5px}
.field.full{grid-column:1/-1}
label{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--muted)}
input,select{width:100%;padding:10px 12px;border:1px solid var(--border);border-radius:8px;
             font-family:inherit;font-size:14px;color:var(--ink);background:var(--cream);
             transition:.15s;outline:none}
input:focus,select:focus{border-color:var(--teal);box-shadow:0 0 0 3px rgba(91,33,182,.12);background:#fff}
input[readonly]{background:#f4f5f7;color:var(--muted);cursor:default}
.form-divider{border:none;border-top:1px solid var(--border);margin:22px 0}
.form-actions{display:flex;align-items:center;justify-content:flex-end;gap:10px;margin-top:22px}
.btn{display:inline-flex;align-items:center;gap:6px;border:none;border-radius:8px;
     padding:10px 18px;font-family:inherit;font-size:13px;font-weight:700;cursor:pointer;text-decoration:none;transition:.15s}
.btn-teal{background:var(--teal);color:#fff}.btn-teal:hover{background:#4c1d95}
.btn-ghost{background:transparent;color:var(--muted);border:1px solid var(--border)}.btn-ghost:hover{background:var(--cream)}

/* ── Alerts ── */
.alert{border-radius:8px;padding:12px 16px;font-size:13px;font-weight:600;margin-bottom:20px;display:flex;align-items:center;gap:10px}
.alert-success{background:var(--green-bg);border:1px solid var(--green-b);color:var(--green)}
.alert-error  {background:var(--red-bg);border:1px solid var(--red-b);color:var(--red)}
</style>
</head>
<body>

<!-- Topnav -->
<header class="topnav">
  <div class="nav-inner">
    <a href="<%= backUrl %>" class="brand">
      <img src="<%= ctx %>/images/umt-logo.png" alt="UMT Logo" class="brand-logo">
      <div><div class="brand-name">E-Vetting</div><div class="brand-sub">UMT</div></div>
    </a>
    <a href="<%= backUrl %>" class="back-link">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><polyline points="15 18 9 12 15 6"/></svg>
      Dashboard
    </a>
    <div class="nav-right">
      <div><div class="user-name"><%= pFullName.isEmpty() ? sessionName : pFullName %></div><div class="user-role"><%= pRole %></div></div>
      <div class="avatar"><%= pInit %></div>
      <a href="<%= ctx %>/logout" class="logout-link" title="Sign out">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" width="16" height="16"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
      </a>
    </div>
  </div>
</header>

<div class="page">

  <% if (saved) { %>
  <div class="alert alert-success">Profile updated successfully.</div>
  <% } else if (failed) { %>
  <div class="alert alert-error">Failed to save profile. Please try again.</div>
  <% } %>

  <div class="profile-card">
    <!-- Hero -->
    <div class="profile-hero">
      <div class="profile-avatar-lg"><%= pInit %></div>
      <div class="profile-hero-info">
        <h1><%= pFullName.isEmpty() ? "My Profile" : pFullName %></h1>
        <p><%= pEmail %></p>
        <div class="role-badge"><%= pRole %></div>
      </div>
    </div>

    <!-- Form body -->
    <div class="profile-body">
      <form method="POST" action="<%= ctx %>/UserProfileServlet">
        <div class="field-grid">

          <div class="field full">
            <label>Full Name</label>
            <input type="text" value="<%= pFullName %>" readonly>
          </div>

          <div class="field full">
            <label>Email Address</label>
            <input type="email" value="<%= pEmail %>" readonly>
          </div>

          <hr class="form-divider" style="grid-column:1/-1">

          <div class="field">
            <label for="phone">Phone Number</label>
            <input type="tel" id="phone" name="phone" value="<%= pPhone %>"
                   placeholder="e.g. 019-1234567">
          </div>

          <div class="field">
            <label for="position">Position / Role</label>
            <input type="text" id="position" name="position" value="<%= pPosition %>"
                   placeholder="e.g. Senior Lecturer" <%= !"KP".equalsIgnoreCase(sessionRole) && !"KP_ADMIN".equalsIgnoreCase(sessionRole) ? "readonly" : "" %>>
          </div>

          <div class="field full">
            <label for="faculty">Faculty / Department</label>
            <input type="text" id="faculty" name="faculty" value="<%= pFaculty %>"
                   placeholder="e.g. Faculty of Computer Science and Information Technology">
          </div>

        </div>

        <div class="form-actions">
          <a href="<%= backUrl %>" class="btn btn-ghost">Cancel</a>
          <button type="submit" class="btn btn-teal">Save Changes</button>
        </div>
      </form>
    </div>
  </div>

</div>
</body>
</html>
