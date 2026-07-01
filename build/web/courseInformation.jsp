<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Model.Course" %>
<%@ page import="Model.CourseInfo" %>

<%
    // 1. GET USER SESSION DATA: Check who is logged in
    String userFullName = (String) session.getAttribute("userFullName");
    String role = (String) session.getAttribute("role");
    String userInitial = (String) session.getAttribute("userInitial");

    // 2. SET FALLBACK DATA: If session is missing, provide default values
    if (userFullName == null) {
        userFullName = "Administrator";
    }
    if (role == null) {
        role = "Admin";
    }
    if (userInitial == null || userInitial.trim().isEmpty()) {
        userInitial = "A";
    }

    // 3. GET COURSE DATA: Retrieve the data sent from the Servlet
    Course course = (Course) request.getAttribute("course");
    CourseInfo info = (CourseInfo) request.getAttribute("courseInfo");

    // 4. SECURITY KICKOUT: If no course is found, send them back to the list
    if (course == null) {
        response.sendRedirect(request.getContextPath() + "/admin/courses");
        return;
    }

    // 5. PERMISSION CHECK: Lock the page if the user is a regular Lecturer
    boolean canEdit = "Ketua Panel".equalsIgnoreCase(role) || "Vetting Panel".equalsIgnoreCase(role) || "Admin".equalsIgnoreCase(role);
    String readonly = canEdit ? "" : "readonly";
    String disabled = canEdit ? "" : "disabled";

    // 6. SUCCESS MESSAGE: Check if we just saved the form
    String success = request.getParameter("success");
%>

<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width,initial-scale=1"/>
        <title>Course Information - <%= course.getCourseCode()%></title>

        <style>
            :root{
                --bg:#f6f7fb;
                --card:#fff;
                --text:#111827;
                --muted:#6b7280;
                --border:#e5e7eb;
                --primary:#111827;
                --shadow:0 10px 20px rgba(0,0,0,.06);
                --r:14px;
                --umt-blue: #003366;
            }
            *{
                box-sizing:border-box
            }
            body{
                margin:0;
                font-family:system-ui,-apple-system,Segoe UI,Roboto,Arial;
                background:var(--bg);
                color:var(--text)
            }
            header{
                background:#fff;
                border-bottom:1px solid var(--border);
                position:sticky;
                top:0;
                z-index:10
            }
            .bar{
                max-width:1180px;
                margin:0 auto;
                padding:12px 16px;
                display:flex;
                align-items:center;
                gap:12px
            }
            .brand{
                display:flex;
                align-items:center;
                gap:10px;
                min-width:240px
            }
            .logo{
                width:38px;
                height:38px;
                border-radius:12px;
                display:grid;
                place-items:center;
                background:#eef2ff;
                border:1px solid #e0e7ff
            }
            .brand b{
                display:block;
                font-size:14px
            }
            .brand span{
                display:block;
                font-size:12px;
                color:var(--muted)
            }
            nav{
                display:flex;
                gap:8px;
                flex:1;
                overflow:auto
            }
            nav button{
                border:1px solid var(--border);
                background:#fff;
                border-radius:12px;
                padding:9px 11px;
                font-weight:800;
                font-size:13px;
                cursor:pointer;
                white-space:nowrap;
                display:flex;
                align-items:center;
                gap:8px
            }
            nav button.active{
                background:var(--primary);
                border-color:var(--primary);
                color:#fff
            }
            .user{
                min-width:260px;
                display:flex;
                justify-content:flex-end;
                align-items:center;
                gap:10px
            }
            .avatar{
                width:36px;
                height:36px;
                border-radius:50%;
                border:1px solid var(--border);
                display:grid;
                place-items:center;
                background:#f3f4f6;
                font-weight:900
            }
            .user .meta{
                line-height:1.1;
                text-align:right
            }
            .user .meta b{
                font-size:13px
            }
            .user .meta span{
                font-size:12px;
                color:var(--muted)
            }
            .logout{
                width:36px;
                height:36px;
                border-radius:50%;
                border:1px solid var(--border);
                display:grid;
                place-items:center;
                text-decoration:none;
                color:#374151;
                font-weight:900;
                background:#fff;
                transition: all .15s ease;
            }
            .logout:hover{
                background:#fee2e2;
                border-color:#fecaca;
                color:#991b1b;
                transform: translateX(2px);
            }
            main{
                max-width:1180px;
                margin:0 auto;
                padding:18px 16px 60px
            }
            .msg{
                margin-bottom:16px;
                padding:10px 12px;
                border-radius:12px;
                border:1px solid var(--border);
                font-weight:900
            }
            .msg.ok{
                background:#f0fdf4;
                border-color:#bbf7d0;
                color:#166534
            }
            .btn{
                border:none;
                background:var(--primary);
                color:#fff;
                border-radius:12px;
                padding:12px 24px;
                font-weight:900;
                cursor:pointer;
                display:inline-flex;
                gap:8px;
                align-items:center;
                transition: opacity 0.2s;
            }
            .btn:hover {
                opacity: 0.9;
            }
            .btn-outline {
                background: #fff;
                color: var(--text);
                border: 1px solid var(--border);
                padding: 8px 12px;
                border-radius: 8px;
                cursor: pointer;
            }
            .syllabus-container {
                background: var(--card);
                padding: 40px;
                margin: 0 auto;
                max-width: 1000px;
                box-shadow: var(--shadow);
                border-radius: var(--r);
                border-top: 8px solid var(--umt-blue);
            }
            .doc-header {
                text-align: center;
                margin-bottom: 30px;
            }
            .doc-header h3 {
                margin: 10px 0 5px;
                font-size: 22px;
            }
            .doc-header h4 {
                margin: 0;
                color: var(--muted);
                font-size: 14px;
                font-weight: 800;
            }
            .section-header {
                background-color: var(--umt-blue);
                color: white;
                padding: 10px 14px;
                margin-top: 24px;
                font-weight: 800;
                text-transform: uppercase;
                border-radius: 8px 8px 0 0;
                font-size: 14px;
            }
            .doc-table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 20px;
            }
            .doc-table th, .doc-table td {
                border: 1px solid var(--border);
                padding: 12px;
                vertical-align: top;
                font-size: 13px;
            }
            .doc-table th {
                background-color: #f9fafb;
                width: 30%;
                font-weight: 800;
                color: var(--text);
            }
            .doc-table textarea, .doc-table select, .doc-table input[type="text"], .doc-table input[type="number"] {
                width: 100%;
                border: none;
                background: transparent;
                resize: vertical;
                outline: none;
                font-family: inherit;
                font-size: inherit;
                color: inherit;
            }
            .doc-table textarea:focus, .doc-table select:focus, .doc-table input:focus {
                background: #fffde7;
                border-radius: 4px;
            }
            .doc-table textarea[readonly], .doc-table input[readonly] {
                color: var(--muted);
            }
            .bottom-actions {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-top: 30px;
            }

            /*lesson Plan button */
            .course-tabs {
                display: flex;
                justify-content: center;
                gap: 15px;
                margin-bottom: 30px;
                margin-top: 20px;
            }
            .course-tabs a {
                padding: 12px 24px;
                background: #fff;
                border: 1px solid #e5e7eb;
                border-radius: 8px;
                text-decoration: none;
                color: #6b7280;
                font-weight: bold;
                font-size: 14px;
            }
            .course-tabs a:hover {
                background: #f3f4f6;
            }
            .course-tabs a.active-tab {
                background: #003366;
                color: white;
                border-color: #003366;
            }
        </style>
    </head>

    <body>
        <header>
            <div class="bar">
                <div class="brand">
                    <div class="logo">🎓</div>
                    <div><b>E-Vetting System</b><span>Assessment Management</span></div>
                </div>
                <nav>
                    <button class="nav" onclick="location.href = '<%= request.getContextPath()%>/admin/dashboard'">Dashboard</button>
                    <button class="nav active" onclick="location.href = '<%= request.getContextPath()%>/admin/courses'">All Courses</button>
                </nav>
                <div class="user">
                    <div class="meta"><b><%= userFullName%></b><br/><span><%= role%></span></div>
                    <div class="avatar"><%= userInitial%></div>
                    <a class="logout" href="<%= request.getContextPath()%>/logout" title="Logout">➜</a>
                </div>
            </div>
        </header>

        <main>
            <% if ("1".equals(success)) { %>
            <div class="msg ok">Syllabus details saved successfully.</div>
            <% }%>

            <div class="syllabus-container">
                <div class="doc-header">
                    <h3>FACULTY OF COMPUTER SCIENCE AND MATHEMATICS</h3>
                    <h4>Course Information</h4>
                </div>

                <form action="<%= request.getContextPath()%>/admin/course-info" method="post" id="syllabusForm">
                    <input type="hidden" name="courseId" value="<%= course.getCourseId()%>">

                    <div class="section-header">General Information</div>
                    <table class="doc-table">
                        <tr>
                            <th>Course Name</th>
                            <td><strong><%= course.getCourseName()%></strong></td>
                        </tr>
                        <tr>
                            <th>Course Code</th>
                            <td><strong><%= course.getCourseCode()%></strong></td>
                        </tr>
                        <tr>
                            <th>Credit Value</th>
                            <td>
                                <div style="display: flex; gap: 10px; align-items: center;">
                                    <input type="text" value="<%= course.getCredits()%>" readonly style="width: 80px; background: #f3f4f6; border: 1px solid var(--border); padding: 8px; border-radius: 8px;">
                                    <b>Remarks:</b>
                                    <input type="text" name="creditRemarks" <%= readonly%> value="<%= info != null && info.getCreditRemarks() != null ? info.getCreditRemarks() : ""%>" style="flex: 1; border: 1px solid var(--border); padding: 8px; border-radius: 8px;" placeholder="e.g., (2+1)">
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th>Semester and Year Offered</th>
                            <td>
                                <div style="display: flex; flex-direction: column; gap: 10px;">
                                    <div style="display: flex; gap: 10px; align-items: center;">
                                        <b>Year Remarks:</b>
                                        <input type="text" name="yearRemarks" <%= readonly%> value="<%= info != null && info.getYearRemarks() != null ? info.getYearRemarks() : ""%>" style="flex: 1; border: 1px solid var(--border); padding: 8px; border-radius: 8px;" placeholder="e.g. Year 3...">
                                    </div>
                                    <div style="display: flex; gap: 10px; align-items: center;">
                                        <b>Semester:</b>
                                        <input type="text" value="<%= course.getSemester() != null ? course.getSemester() : ""%>" readonly style="width: 120px; background: #f3f4f6; border: 1px solid var(--border); padding: 8px; border-radius: 8px;">
                                        <b>Remarks:</b>
                                        <input type="text" name="semesterRemarks" <%= readonly%> value="<%= info != null && info.getSemesterRemarks() != null ? info.getSemesterRemarks() : ""%>" style="flex: 1; border: 1px solid var(--border); padding: 8px; border-radius: 8px;" placeholder="Remarks for semester...">
                                    </div>
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <th>Name(s) of Academic Staff</th>
                            <td><textarea name="academicStaff" rows="2" <%= readonly%> placeholder="Enter staff names, E.g. lecturers..."><%= info != null && info.getAcademicStaff() != null ? info.getAcademicStaff() : ""%></textarea></td>
                        </tr>
                        <tr>
                            <th>Course Classification</th>
                            <td>
                                <select name="classification" <%= disabled%>>
                                    <option value="Core" <%= (info != null && "Core".equals(info.getClassification())) ? "selected" : ""%>>Core</option>
                                    <option value="Minor" <%= (info != null && "Minor".equals(info.getClassification())) ? "selected" : ""%>>Minor</option>
                                    <option value="Elective" <%= (info != null && "Elective".equals(info.getClassification())) ? "selected" : ""%>>Elective</option>
                                </select>
                                <% if (!canEdit) {%>
                                <input type="hidden" name="classification" value="<%= info != null ? info.getClassification() : ""%>">
                                <% }%>
                            </td>
                        </tr>
                        <tr>
                            <th>Pre-requisite / Co-requisite</th>
                            <td>
                                <textarea name="preRequisites" rows="1" <%= readonly%> placeholder="e.g., None or CSA2013"><%= (info != null && info.getPreRequisites() != null) ? info.getPreRequisites() : ""%></textarea>
                            </td>
                        </tr>
                    </table>

                    <div class="section-header">Synopsis</div>
                    <table class="doc-table">
                        <tr>
                            <td><textarea name="synopsis" rows="5" <%= readonly%> placeholder="Course synopis..."><%= info != null && info.getSynopsis() != null ? info.getSynopsis() : ""%></textarea></td>
                        </tr>
                    </table>

                    <div class="section-header">Course Learning Outcomes (CLO)</div>
                    <table class="doc-table" id="cloTable">
                        <thead>
                            <tr>
                                <th style="width: 10%; text-align: center;">Item</th>
                                <th>Description (Map to PLO e.g., C2, PLO1)</th>
                                <% if (canEdit) { %><th style="width: 10%; text-align: center;">Action</th><% } %>
                            </tr>
                        </thead>
                        <tbody id="cloBody"></tbody>
                    </table>
                    <% if (canEdit) { %>
                    <button type="button" class="btn btn-outline" onclick="addCLORow()" style="margin-bottom: 20px;">➕ Add CLO</button>
                    <% }%>

                    <div class="section-header">Skills & Requirements</div>
                    <table class="doc-table">
                        <tr>
                            <th>Transferable Skills</th>
                            <td><textarea name="transferableSkills" rows="3" <%= readonly%> placeholder="List skills..."><%= info != null && info.getTransferableSkills() != null ? info.getTransferableSkills() : ""%></textarea></td>
                        </tr>
                        <tr>
                            <th>Special Requirements</th>
                            <td><textarea name="specialRequirements" rows="2" <%= readonly%> placeholder="e.g., Software, Computer Lab..."><%= info != null && info.getSpecialRequirements() != null ? info.getSpecialRequirements() : ""%></textarea></td>
                        </tr>
                    </table>

                    <div class="section-header">Mapping of Course Learning Outcomes to Program Learning Outcomes</div>
                    <div style="overflow-x: auto;">
                        <table class="doc-table" id="ploTable">
                            <thead>
                                <tr>
                                    <th rowspan="2" style="width: 5%; text-align: center;">CLO</th>
                                    <th colspan="11" style="text-align: center;">Program Learning Outcomes (PLO)</th>
                                    <th rowspan="2" style="width: 15%; text-align: center;">Teaching Methods</th>
                                    <th rowspan="2" style="width: 15%; text-align: center;">Assessment Methods</th>
                                </tr>
                                <tr>
                                    <th>1</th><th>2</th><th>3</th><th>4</th><th>5</th><th>6</th><th>7</th><th>8</th><th>9</th><th>10</th><th>11</th>
                                </tr>
                            </thead>
                            <tbody id="ploBody"></tbody>
                        </table>
                    </div>

                    <div class="section-header">Distribution of Student Learning Time (SLT)</div>
                    <table class="doc-table" id="sltTable">
                        <thead>
                            <tr>
                                <th rowspan="2">Course Content Outline</th>
                                <th colspan="4" style="text-align: center;">Face to Face (F2F)</th>
                                <th rowspan="2" style="text-align: center;">Non-F2F</th>
                                <th rowspan="2" style="text-align: center;">Total SLT</th>
                                <% if (canEdit) { %><th rowspan="2" style="text-align: center;">Action</th><% }%>
                            </tr>
                            <tr>
                                <th style="text-align: center;">L</th><th style="text-align: center;">T</th><th style="text-align: center;">P</th><th style="text-align: center;">O</th>
                            </tr>
                        </thead>
                        <tbody id="sltBody"></tbody>

                        <tbody>
                            <tr style="background: #f8fafc;"><td colspan="7"><strong>Continuous Assessment</strong></td></tr>
                            <tr>
                                <td style="text-align: right;">Total CA Hours:</td>
                                <td colspan="4"><input type="number" step="0.1" name="caF2f" id="ca_f2f" value="<%= info != null ? info.getCaF2f() : "0"%>" <%= readonly%> oninput="calculateSLT()"></td>
                                <td><input type="number" step="0.1" name="caNf2f" id="ca_nf2f" value="<%= info != null ? info.getCaNf2f() : "0"%>" <%= readonly%> oninput="calculateSLT()"></td>
                                <td></td>
                            </tr>
                            <tr style="background: #f8fafc;"><td colspan="7"><strong>Final Assessment</strong></td></tr>
                            <tr>
                                <td style="text-align: right;">Total Final Hours:</td>
                                <td colspan="4"><input type="number" step="0.1" name="faF2f" id="fa_f2f" value="<%= info != null ? info.getFaF2f() : "0"%>" <%= readonly%> oninput="calculateSLT()"></td>
                                <td><input type="number" step="0.1" name="faNf2f" id="fa_nf2f" value="<%= info != null ? info.getFaNf2f() : "0"%>" <%= readonly%> oninput="calculateSLT()"></td>
                                <td></td>
                            </tr>
                        </tbody>
                        <tfoot>
                            <tr style="background: #e2e8f0; font-size: 15px;">
                                <td colspan="6" style="text-align: right; font-weight: bold;">GRAND TOTAL SLT:</td>
                                <td id="grandTotalSLT" style="text-align: center; font-weight: bold; color: #1e40af;">0.00</td>
                            </tr>
                            <tr style="background: #e2e8f0; font-size: 15px;">
                                <td colspan="6" style="text-align: right; font-weight: bold;">CREDIT VALUE (SLT / 40):</td>
                                <td id="calculatedCredit" style="text-align: center; font-weight: bold; color: #15803d;">0.00</td>
                            </tr>
                        </tfoot>
                    </table>
                    <% if (canEdit) { %>
                    <button type="button" class="btn btn-outline" onclick="addSLTRow()" style="margin-bottom: 8px;">➕ Add Topic</button>
                    <% }%>

                    <div class="bottom-actions" style="margin-top: 40px;">
                        <button type="button" class="btn btn-outline" onclick="location.href = '<%= request.getContextPath()%>/admin/courses'">← Back to Courses</button>
                        <% if (canEdit) {%>
                        <button type="submit" class="btn" style="padding: 15px 30px; font-size: 16px;">Save</button>

                        <% }%>
                    </div>
                </form>
            </div>
        </main>

        <script>
            let cloCounter = 0;
            const canEditUser = <%= canEdit%>;

            // FUNCTION A: Adds a matching row to Section 3 (Descriptions) and Section 8 (Checkboxes)
            function addCLORow() {
                cloCounter++;
                const rowId = "clo-row-" + cloCounter;

                // Create row for Section 3
                const tr3 = document.createElement("tr");
                tr3.id = rowId + "-desc";
                tr3.innerHTML =
                        '<td style="text-align: center; font-weight: bold;" class="clo-index">CLO</td>' +
                        '<td><textarea name="cloDesc[]" rows="2" placeholder="Describe CLO..."></textarea></td>' +
                        (canEditUser ? '<td style="text-align: center;"><button type="button" class="btn btn-outline" onclick="removeCLORow(\'' + rowId + '\')">🗑️</button></td>' : '');
                document.getElementById("cloBody").appendChild(tr3);

                // Create row for Section 8 (Generates 11 hidden inputs and 11 checkboxes)
                const tr8 = document.createElement("tr");
                tr8.id = rowId + "-map";
                let plosStr = '';
                for (let i = 1; i <= 11; i++) {
                    plosStr += '<td style="text-align: center;">' +
                            '<input type="hidden" name="plo' + i + '[]" value="0">' +
                            '<input type="checkbox" onchange="this.previousElementSibling.value = this.checked ? \'1\' : \'0\'" ' + (canEditUser ? '' : 'disabled') + '>' +
                            '</td>';
                }
                tr8.innerHTML =
                        '<td style="text-align: center; font-weight: bold;" class="clo-index">CLO</td>' +
                        plosStr +
                        '<td><textarea name="cloTeaching[]" rows="2" ' + (canEditUser ? '' : 'readonly') + '></textarea></td>' +
                        '<td><textarea name="cloAssessment[]" rows="2" ' + (canEditUser ? '' : 'readonly') + '></textarea></td>';
                document.getElementById("ploBody").appendChild(tr8);

                // Recalculate numbers like CLO 1, CLO 2
                updateCLOIndices();
            }

            // FUNCTION B: Deletes both matching CLO rows when Trash icon is clicked
            function removeCLORow(rowId) {
                document.getElementById(rowId + "-desc").remove();
                document.getElementById(rowId + "-map").remove();
                updateCLOIndices();
            }

            // FUNCTION C: Renumbers the CLO items so they stay in order after deleting
            function updateCLOIndices() {
                const descRows = document.querySelectorAll("#cloBody tr");
                const mapRows = document.querySelectorAll("#ploBody tr");
                descRows.forEach((row, index) => {
                    row.querySelector(".clo-index").innerText = "CLO " + (index + 1);
                });
                mapRows.forEach((row, index) => {
                    row.querySelector(".clo-index").innerText = "CLO " + (index + 1);
                });
            }

            // FUNCTION D: Adds a new blank Topic row into the SLT table
            function addSLTRow() {
                const tbody = document.getElementById("sltBody");
                const row = document.createElement("tr");
                row.innerHTML =
                        '<td><input type="text" name="sltTopic[]" style="width:100%" placeholder="Topic name..." ' + (canEditUser ? '' : 'readonly') + '></td>' +
                        '<td><input type="number" step="0.1" name="sltL[]" value="0" oninput="calculateSLT()" ' + (canEditUser ? '' : 'readonly') + '></td>' +
                        '<td><input type="number" step="0.1" name="sltT[]" value="0" oninput="calculateSLT()" ' + (canEditUser ? '' : 'readonly') + '></td>' +
                        '<td><input type="number" step="0.1" name="sltP[]" value="0" oninput="calculateSLT()" ' + (canEditUser ? '' : 'readonly') + '></td>' +
                        '<td><input type="number" step="0.1" name="sltO[]" value="0" oninput="calculateSLT()" ' + (canEditUser ? '' : 'readonly') + '></td>' +
                        '<td><input type="number" step="0.1" name="sltNf2f[]" value="0" oninput="calculateSLT()" ' + (canEditUser ? '' : 'readonly') + '></td>' +
                        '<td class="row-slt" style="text-align: center; font-weight: bold;">0.00</td>' +
                        (canEditUser ? '<td style="text-align: center;"><button type="button" class="btn btn-outline" onclick="this.closest(\'tr\').remove(); calculateSLT();">🗑️</button></td>' : '');
                tbody.appendChild(row);
            }

            // FUNCTION E: Runs math to add up row totals, then calculates the final Grand Total and Credit Value
            function calculateSLT() {
                let grandTotal = 0;

                // Read every SLT row and add numbers horizontally
                document.querySelectorAll('#sltBody tr').forEach(row => {
                    let l = parseFloat(row.querySelector('[name="sltL[]"]').value) || 0;
                    let t = parseFloat(row.querySelector('[name="sltT[]"]').value) || 0;
                    let p = parseFloat(row.querySelector('[name="sltP[]"]').value) || 0;
                    let o = parseFloat(row.querySelector('[name="sltO[]"]').value) || 0;
                    let nf2f = parseFloat(row.querySelector('[name="sltNf2f[]"]').value) || 0;

                    let rowTotal = l + t + p + o + nf2f;
                    row.querySelector('.row-slt').innerText = rowTotal.toFixed(2);
                    grandTotal += rowTotal;
                });

                // Add Continuous and Final Assessment numbers
                let caF = parseFloat(document.getElementById('ca_f2f').value) || 0;
                let caN = parseFloat(document.getElementById('ca_nf2f').value) || 0;
                let faF = parseFloat(document.getElementById('fa_f2f').value) || 0;
                let faN = parseFloat(document.getElementById('fa_nf2f').value) || 0;
                grandTotal += (caF + caN + faF + faN);

                // Update the visual totals at the very bottom
                document.getElementById('grandTotalSLT').innerText = grandTotal.toFixed(2);
                document.getElementById('calculatedCredit').innerText = (grandTotal / 40).toFixed(2);
            }

            // FUNCTION F: Starts the page off with exactly 1 empty row to type in, then runs calculation math
            document.addEventListener('DOMContentLoaded', () => {
                if (document.getElementById("cloBody").children.length === 0 && canEditUser) {
                    addCLORow();
                }
                if (document.getElementById("sltBody").children.length === 0 && canEditUser) {
                    addSLTRow();
                }
                calculateSLT();
            });
        </script>
    </body>
</html>