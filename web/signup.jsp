<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!doctype html>
<html>
    <head>
        <meta charset="utf-8"/>
        <title>Sign Up</title>

        <style>
            body{
                margin:0;
                font-family:system-ui;
                background:linear-gradient(135deg,#312e81 0%,#5b21b6 50%,#7c3aed 100%);
                min-height:100vh;
                display:grid;
                place-items:center
            }
            .card{
                width:520px;
                max-width:92vw;
                background:#fff;
                border-radius:18px;
                padding:26px 26px 22px;
                position:relative
            }
            .icon{
                display:flex;
                align-items:center;
                justify-content:center;
            }

            .icon-logo{
                width:70px;
                height:70px;
                object-fit:contain;
            }
            h1{
                margin:0;
                text-align:center;
                font-size:28px
            }
            p{
                margin:8px 0 18px;
                text-align:center;
                color:#6b7280
            }
            label{
                display:block;
                font-weight:800;
                font-size:13px;
                margin:12px 0 6px
            }
            input,select{
                width:100%;
                padding:12px 8px;
                border-radius:10px;
                border:1px solid #e5e7eb;
                background:#f9fafb;
                font-size:14px
            }
            .btn{
                width:100%;
                margin-top:14px;
                padding:12px 14px;
                border:none;
                border-radius:10px;
                background:#6d28d9;
                color:#fff;
                font-weight:900;
                cursor:pointer
            }
            .msg{
                margin:0 0 10px;
                padding:10px 12px;
                border-radius:10px;
                font-size:13px
            }
            .err{
                background:#fef2f2;
                border:1px solid #fecaca;
                color:#991b1b
            }
            .link{
                margin-top:14px;
                text-align:center;
                color:#6b7280
            }
            .link a{
                color:#0284c7;
                font-weight:900;
                text-decoration:none
            }
        </style>
    <body>
    </head>
<body>
    <div class="card">
        <div class="icon">
            <img src="<%= request.getContextPath()%>/images/umt-logo.png"
                 alt="UMT Logo"
                 class="icon-logo">
        </div>
        <h1>Create Account</h1>
        <p>Sign up to access the UMT E-Vetting System</p>



        <form method="post" action="${pageContext.request.contextPath}/RegisterServlet">
            <label>Full Name</label>
            <input type="text" name="fullName" placeholder="Dr Ahmad bin Ali" required/>

            <label>Email</label>
            <input type="email" name="email" placeholder="ahmad@umt.edu.my" required/>

            <label>Phone Number</label>
            <input type="phoneNo" name="phoneNo" placeholder="012-3456-789" required/>

            <label>Password</label>
            <input type="password" name="password" placeholder="Enter password" required/>

            <label>Confirm Password</label>
            <input type="password" name="confirmPassword" placeholder="Re-enter password" required/>

            <label>Role</label>
            <select name="role" required>
                <option value="">— Select Role —</option>
                <option value="Lecturer">Lecturer</option>
                <option value="KP">Ketua Program</option>
            </select>

            <button class="btn" type="submit">Create Account</button>
        </form>

        <div class="link">
            Already have an account? <a href="${pageContext.request.contextPath}/login.jsp">Log In</a>
        </div>
    </div>
  <jsp:include page="footer.jsp"/>
</body>
</html>


<%--
--%>