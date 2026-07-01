<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Model.User" %>
<%@ page import="java.sql.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%-- 1. Connect to your Database directly --%>
<sql:setDataSource var="db" 
    driver="com.mysql.cj.jdbc.Driver"
    url="jdbc:mysql://localhost:3306/evetting_db"
    user="root"  password="" />

<%-- 2. Pull the info for the currently logged-in user --%>
<sql:query dataSource="${db}" var="result">
    SELECT * FROM users WHERE user_id = ?;
    <sql:param value="${sessionScope.user_id}" />
</sql:query>

<%-- 3. Display the Profile Sidebar --%>
<c:forEach var="row" items="${result.rows}">
  <div class="profile-sidebar" id="profileSidebar">
    <div class="ps-top">
      <div class="ps-avatar">${row.username.substring(0,1).toUpperCase()}</div>
      <div class="ps-name">${row.username}</div>
      <div class="ps-role">System User</div>
    </div>

    <div class="ps-section">
      <div class="ps-label">Contact Info</div>
      <div class="ps-row">
        <span class="ps-row-ico">🆔</span>
        <div>
          <div class="ps-row-key">User ID</div>
          <div class="ps-row-val">${row.user_id}</div>
        </div>
      </div>
      <div class="ps-row">
        <span class="ps-row-ico">✉️</span>
        <div>
          <div class="ps-row-key">Email</div>
          <div class="ps-row-val">${row.email}</div>
        </div>
      </div>
      <div class="ps-row">
        <span class="ps-row-ico">📞</span>
        <div>
          <div class="ps-row-key">Phone</div>
          <div class="ps-row-val">${row.phone_no}</div>
        </div>
      </div>
    </div>

    <div class="ps-actions">
      <form action="logout.jsp" method="post">
          <button class="ps-btn danger" type="submit">
            <span class="ps-btn-ico">↩</span> Log Out
          </button>
      </form>
    </div>
  </div>
</c:forEach>

<%
    session.invalidate(); // Destroy user data
    response.sendRedirect("login.jsp"); // Send them back
%>
<%--
<%
    // Grab the user data that the Servlet just fetched
    User user = (User) request.getAttribute("userProfile");
    String role = (String) session.getAttribute("role");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Profile | E-Vetting</title>
<style>
    body {
        margin: 0;
        font-family: system-ui, -apple-system, sans-serif;
        background: linear-gradient(135deg, #06b6d4, #2563eb);
        min-height: 100vh;
        display: grid;
        place-items: center;
    }

    .card {
        width: 520px;
        max-width: 92vw;
        background: #fff;
        border-radius: 18px;
        padding: 32px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.1);
    }

    /* Profile Avatar Section */
    .profile-header {
        text-align: center;
        margin-bottom: 24px;
    }

    .avatar {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        background: #e0f2fe;
        color: #0284c7;
        display: grid;
        place-items: center;
        margin: 0 auto 16px;
        font-size: 40px;
        font-weight: bold;
        border: 4px solid #f0f9ff;
    }

    h1 {
        margin: 0;
        font-size: 24px;
        color: #111827;
    }

    .subtitle {
        margin: 4px 0 0;
        color: #6b7280;
        font-size: 14px;
    }

    /* Information List */
    .info-group {
        margin-top: 24px;
        border-top: 1px solid #f3f4f6;
    }

    .info-row {
        display: flex;
        justify-content: space-between;
        padding: 16px 0;
        border-bottom: 1px solid #f3f4f6;
    }

    .info-label {
        color: #6b7280;
        font-size: 14px;
        font-weight: 500;
    }

    .info-value {
        color: #111827;
        font-size: 14px;
        font-weight: 600;
    }

    /* Action Buttons */
    .actions {
        margin-top: 24px;
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 12px;
    }

    .btn {
        padding: 12px;
        border-radius: 10px;
        font-weight: 700;
        cursor: pointer;
        text-align: center;
        text-decoration: none;
        font-size: 14px;
        transition: opacity 0.2s;
    }

    .btn:hover {
        opacity: 0.9;
    }

    .btn-primary {
        background: #0284c7;
        color: #fff;
        border: none;
    }

    .btn-outline {
        background: #fff;
        color: #4b5563;
        border: 1px solid #d1d5db;
    }

    .logout-link {
        display: block;
        text-align: center;
        margin-top: 20px;
        color: #ef4444;
        font-size: 13px;
        font-weight: 600;
        text-decoration: none;
    }
</style></head>
<body>

    <main class="profile-container">
        <div class="card" style="padding: 40px;">
            <div style="display: flex; align-items: center; gap: 25px; margin-bottom: 30px;">
                <div class="avatar" style="width: 90px; height: 90px; font-size: 36px; border: 3px solid var(--border);">
                    <%= session.getAttribute("userInitial") %>
                </div>
                <div>
                    <h1 style="margin:0;"><%= user.getFullName() %></h1>
                    <div style="margin-top: 8px;">
                        <span class="role-badge"><%= role %></span>
                    </div>
                </div>
            </div>

            <div class="divider"></div>

            <div class="data-section">
                <div class="data-row">
                    <span class="label">Full Name</span>
                    <span class="value"><%= user.getFullName() %></span>
                </div>
                <div class="data-row">
                    <span class="label">Registered Email</span>
                    <span class="value"><%= user.getEmail() %></span>
                </div>
                <div class="data-row">
                    <span class="label">Contact Number</span>
                    <span class="value"><%= (user.getPhoneNo() != null && !user.getPhoneNo().isEmpty()) ? user.getPhoneNo() : "Not Provided" %></span>
                </div>
            </div>

            <div style="margin-top: 30px; color: var(--muted); font-size: 13px; font-style: italic;">
                Note: Your role are secured and credentials.
            </div>
        </div>
    </main>

</body>
</html>
--%>