import os

base_dir = r"C:\Users\Amelia\OneDrive\Documents\NetBeansProjects\assessmentvetting\web"

# 1. Patch KPDashboard.jsp avatar link
kp_file = os.path.join(base_dir, "KPDashboard.jsp")
with open(kp_file, "r", encoding="utf-8") as f:
    kp_content = f.read()

target = """      <div class="d-none d-md-block text-end">
        <div class="user-name"><%= fullName %></div>
        <div class="user-role">Ketua Program</div>
      </div>
      <div class="avatar"><%= kpInit %></div>"""

replacement = """      <a href="<%= ctx %>/UserProfileServlet" style="text-decoration:none; display:flex; align-items:center; gap:12px; color:inherit;" title="My Profile">
        <div class="d-none d-md-block text-end">
          <div class="user-name"><%= fullName %></div>
          <div class="user-role">Ketua Program</div>
        </div>
        <div class="avatar"><%= kpInit %></div>
      </a>"""

if target in kp_content:
    kp_content = kp_content.replace(target, replacement)
    with open(kp_file, "w", encoding="utf-8") as f:
        f.write(kp_content)
    print("Patched KPDashboard.jsp avatar link.")
else:
    print("Could not find target in KPDashboard.jsp (or already patched).")

# 2. Add footer to JSPs
jsps = ["KPDashboard.jsp", "lecturerDashboard.jsp", "vetterDashboard.jsp", "login.jsp", "signup.jsp", "adminAssignCourses.jsp"]

for jsp in jsps:
    jsp_path = os.path.join(base_dir, jsp)
    if os.path.exists(jsp_path):
        with open(jsp_path, "r", encoding="utf-8") as f:
            content = f.read()
            
        if "<jsp:include page=\"footer.jsp\"" not in content:
            # We insert it right before </body>
            # Or if body tag is missing, at the very end
            if "</body>" in content:
                content = content.replace("</body>", "  <jsp:include page=\"footer.jsp\"/>\n</body>")
            else:
                content += "\n  <jsp:include page=\"footer.jsp\"/>"
            
            with open(jsp_path, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"Added footer to {jsp}.")
