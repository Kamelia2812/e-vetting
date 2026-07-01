<%--
  FILE:    skema.jsp
  SERVLET: SchemaServlet sets:
           paper (Assessment), questions (List<Question>), saved (boolean)

 display correct answer only for section A and model answer text area for section B/C for lecturer

  "SKEMA" watermark appear after print
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import=" Model.Assessment"%>
<%@page import=" Model.Question"%>
<%
    String ctx = request.getContextPath();
    Assessment paper = (Assessment) request.getAttribute("paper");
    List questions = (List) request.getAttribute("questions");
    boolean saved = Boolean.TRUE.equals(request.getAttribute("saved"));

    String courseCode = paper.getCourseCode() != null ? paper.getCourseCode() : "";
    String courseTitle = paper.getCourseTitle() != null ? paper.getCourseTitle() : "";
    String sessStr = paper.getAcademicSession() != null ? paper.getAcademicSession() : "";
    String semStr = paper.getSemester() == 2 ? "II" : "I";
    String paperType = paper.getPaperTypeLabel();

    // Separate questions by section
    java.util.List secA = new java.util.ArrayList();
    java.util.List secB = new java.util.ArrayList();
    java.util.List secC = new java.util.ArrayList();

    if (questions != null) {
        for (int i = 0; i < questions.size(); i++) {
            Question q = (Question) questions.get(i);
            if ("OBJECTIVE".equalsIgnoreCase(q.getQuestionType())) {
                secA.add(q);
            } else if ("STRUCTURE".equalsIgnoreCase(q.getQuestionType())) {
                secB.add(q);
            } else {
                secC.add(q);
            }
        }
    }

    int totalMarks = 0;
    if (questions != null) {
        for (int i = 0; i < questions.size(); i++) {
            totalMarks += ((Question) questions.get(i)).getMarks();
        }
    }
%>
<!doctype html>
<html lang="ms">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width,initial-scale=1"/>
        <title>Skema Jawapan<%= courseCode%></title>
        <link href="https://fonts.googleapis.com/css2?family=Crimson+Pro:ital,wght@0,400;0,600;0,700;1,400&family=Sora:wght@400;600;700;800&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet"/>
        <style>
            /* ── SCREEN TOKENS ────────────────────────────────── */
            :root{
                --navy:#2a1454;
                --teal:#6d28d9;
                --teal-soft:#f5f3ff;
                --teal-b:#ddd6fe;
                --cream:#f7f6fb;
                --surface:#fff;
                --border:#e4e9f0;
                --ink:#1e1133;
                --muted:#7a8aab;
                --green:#15803d;
                --green-bg:#f0fdf4;
                --green-b:#86efac;
                --blue:#2563eb;
                --blue-soft:#eff4ff;
                --blue-b:#c7d9fd;
                --amber:#b45309;
                --amber-bg:#fffbeb;
                --amber-b:#fcd34d;
                --r:10px;
            }
            *,*::before,*::after{
                box-sizing:border-box;
                margin:0;
                padding:0
            }
            body{
                font-family:'Sora',sans-serif;
                background:var(--cream);
                color:var(--ink);
                font-size:14px
            }

            /* ── TOPNAV ────────────────────────────────────────── */
            .topnav{
                background:var(--navy);
                height:56px;
                display:flex;
                align-items:center;
                padding:0 24px;
                gap:12px;
                position:sticky;
                top:0;
                z-index:100
            }
            .icon{
                display:flex;
                align-items:center;
                justify-content:center;
            }

            .icon-logo{
                width:45px;
                height:45px;
                object-fit:contain;
            }
            .back-link{
                font-size:12px;
                font-weight:600;
                color:rgba(255,255,255,.5);
                text-decoration:none;
                padding:5px 10px;
                border-radius:7px;
                transition:.15s
            }
            .back-link:hover{
                background:rgba(255,255,255,.07);
                color:#fff
            }
            .nav-right{
                margin-left:auto;
                display:flex;
                gap:8px
            }
            .btn{
                display:inline-flex;
                align-items:center;
                gap:5px;
                border:none;
                border-radius:7px;
                padding:7px 14px;
                font-family:'Sora',sans-serif;
                font-size:12px;
                font-weight:700;
                cursor:pointer;
                text-decoration:none;
                transition:.15s
            }
            .btn-teal {
                background:var(--teal);
                color:#fff
            }
            .btn-teal:hover{
                background:#4c1d95
            }
            .btn-navy {
                background:var(--navy);
                color:#fff;
                border:1px solid rgba(255,255,255,.15)
            }
            .btn-navy:hover{
                background:#132240
            }
            .btn-ghost{
                background:rgba(255,255,255,.08);
                color:#fff;
                border:1px solid rgba(255,255,255,.15)
            }
            .btn-ghost:hover{
                background:rgba(255,255,255,.15)
            }

            /* ── SCREEN LAYOUT ─────────────────────────────────── */
            .screen-wrap{
                max-width:900px;
                margin:22px auto;
                padding:0 24px 80px
            }
            .info-bar{
                background:var(--surface);
                border:1px solid var(--border);
                border-radius:var(--r);
                padding:14px 18px;
                margin-bottom:14px;
                display:flex;
                align-items:center;
                justify-content:space-between;
                flex-wrap:wrap;
                gap:10px
            }
            .info-bar h2{
                font-size:15px;
                font-weight:800
            }
            .info-bar p {
                font-size:12px;
                color:var(--muted);
                margin-top:2px
            }
            .alert-ok{
                background:var(--green-bg);
                border:1px solid var(--green-b);
                color:var(--green);
                border-radius:var(--r);
                padding:10px 14px;
                font-size:13px;
                font-weight:700;
                margin-bottom:14px
            }
            .alert-warn{
                background:var(--amber-bg);
                border:1px solid var(--amber-b);
                color:var(--amber);
                border-radius:var(--r);
                padding:10px 14px;
                font-size:13px;
                font-weight:600;
                margin-bottom:14px
            }
            .print-note{
                background:var(--blue-soft);
                border:1px solid var(--blue-b);
                border-radius:8px;
                padding:10px 14px;
                font-size:12px;
                color:var(--blue);
                margin-bottom:14px;
                display:flex;
                align-items:center;
                gap:8px
            }

            /* ── A4 PAGE ───────────────────────────────────────── */
            .a4-page{
                width:794px;
                min-height:1123px;
                background:#fff;
                box-shadow:0 4px 20px rgba(0,0,0,.15);
                margin:0 auto 24px;
                padding:60px 72px;
                font-family:'Crimson Pro',Georgia,serif;
                font-size:12pt;
                color:#000;
                position:relative;
                overflow:hidden;
            }
            /* SKEMA watermark — absolute inside page, above ALL content */
            .a4-page{
                isolation:isolate;
            }
            .a4-page::after{
                content:'SKEMA';
                position:absolute;
                top:50%;
                left:50%;
                transform:translate(-50%,-50%) rotate(-35deg);
                font-family:'Sora',sans-serif;
                font-size:110pt;
                font-weight:900;
                color:rgba(220,38,38,.10);
                pointer-events:none;
                white-space:nowrap;
                letter-spacing:8px;
                z-index:999;
                user-select:none;
            }
            .a4-page > *{
                position:relative;
                z-index:1;
            }

            /* Header — centered with SULIT badge */
            .doc-header{
                display:flex;
                align-items:center;
                justify-content:center;
                gap:16px;
                margin-bottom:12px;
                padding-bottom:10px;
                border-bottom:2px solid #000;
                position:relative;
                text-align:center;
            }
            .doc-logo{
                width:85px;
                height:auto
            }
            .doc-logo-placeholder{
                width:85px;
                height:85px;
                border:2px solid #000;
                border-radius:50%;
                display:flex;
                align-items:center;
                justify-content:center;
                font-family:'Sora',sans-serif;
                font-size:14px;
                font-weight:900;
                flex-shrink:0
            }
            .doc-header-text{
                text-align:center
            }
            .doc-uni{
                font-size:14pt;
                font-weight:800;
                text-transform:uppercase;
                letter-spacing:.3px
            }
            .doc-fac{
                font-size:11pt;
                color:#333
            }
            /* SULIT badge — top right corner */
            .sulit-badge{
                position:absolute;
                top:0;
                right:0;
                font-family:'Sora',sans-serif;
                font-size:11pt;
                font-weight:900;
                color:#be123c;
                border:2px solid #be123c;
                padding:3px 10px;
                letter-spacing:2px;
            }
            .doc-title-box{
                border:2px solid #000;
                text-align:center;
                padding:9px 14px;
                margin:10px 0
            }
            .doc-title-box b{
                font-size:14pt;
                text-transform:uppercase;
                letter-spacing:.5px;
                display:block
            }
            .doc-title-box i{
                font-size:11pt
            }

            /* Course info */
            /* Course info grid: clean bordered rows, 2 key-value pairs per row */
            .ci-table{
                width:100%;
                border-collapse:collapse;
                font-size:11pt;
                margin-bottom:14px;
                table-layout:fixed;
                border:1px solid #000
            }
            .ci-table td{
                padding:5px 8px;
                vertical-align:middle;
                border:1px solid #000;
                overflow:hidden
            }
            .ci-table .lbl{
                font-weight:700;
                background:#f5f5f5;
                white-space:nowrap
            }
            .ci-table .sep{
                width:16px;
                text-align:center;
                background:#f5f5f5
            }
            .ci-table .val{
            }

            /* Course info box */
            .ci-box{
                width:100%;
                border-collapse:collapse;
                font-size:11pt;
                margin-bottom:14px
            }
            .ci-box tr{
                border-bottom:1px solid #e8e8e8
            }
            .ci-box tr:last-child{
                border-bottom:none
            }
            .ci-box .cl{
                width:30%;
                font-weight:700;
                padding:5px 8px;
                white-space:nowrap;
                vertical-align:middle
            }
            .ci-box .cs{
                width:12px;
                text-align:center;
                padding:5px 2px;
                vertical-align:middle;
                color:#555
            }
            .ci-box .cv{
                width:18%;
                padding:5px 8px;
                vertical-align:middle
            }
            .ci-box .cr{
                width:26%;
                font-weight:700;
                padding:5px 8px 5px 24px;
                white-space:nowrap;
                vertical-align:middle
            }
            .ci-box .crv{
                padding:5px 8px;
                vertical-align:middle
            }

            /* Section header */
            .sec-hdr{
                background:#000;
                color:#fff;
                padding:5px 10px;
                font-size:11pt;
                font-weight:700;
                margin-top:14px;
                margin-bottom:6px;
                letter-spacing:.3px
            }

            /* ── SECTION A — MCQ answer table ──────────────────── */
            .mcq-table{
                width:100%;
                border-collapse:collapse;
                font-size:10.5pt;
                margin-bottom:10px
            }
            .mcq-table th{
                border:1px solid #000;
                padding:5px 8px;
                background:#f0f0f0;
                font-weight:700;
                text-align:center;
                font-size:10pt
            }
            .mcq-table td{
                border:1px solid #000;
                padding:6px 8px;
                vertical-align:middle
            }
            .mcq-table td.c-num  {
                text-align:center;
                font-weight:700;
                font-family:'JetBrains Mono',monospace;
                width:7%
            }
            .mcq-table td.c-ans  {
                text-align:center;
                font-weight:800;
                font-family:'JetBrains Mono',monospace;
                width:12%;
                font-size:12pt
            }
            .mcq-table td.c-marks{
                text-align:center;
                font-family:'JetBrains Mono',monospace;
                width:10%
            }
            .mcq-table td.c-full {
                font-size:10.5pt
            }
            .ans-correct{
                color:var(--green);
                font-size:13pt;
                font-weight:800
            }

            /* MCQ full answer breakdown */
            .mcq-choices{
                display:flex;
                flex-direction:column;
                gap:2px
            }
            .mcq-opt{
                display:flex;
                gap:6px;
                font-size:10pt;
                padding:1px 0
            }
            .mcq-opt.correct{
                font-weight:700;
                color:#15803d
            }
            .mcq-opt.correct::before{
                content:'✓ '
            }

            /* ── SECTION B/C — FORM answer fields ─────────────── */
            .q-block{
                margin-bottom:14px;
                padding:12px;
                border:1px solid #ccc;
                border-radius:6px;
                background:#fafafa
            }
            .q-stem{
                font-size:11pt;
                font-weight:600;
                line-height:1.55;
                margin-bottom:8px
            }
            .q-stem-meta{
                display:flex;
                gap:10px;
                flex-wrap:wrap;
                margin-bottom:8px
            }
            .q-meta-pill{
                font-size:9pt;
                border:1px solid #ccc;
                border-radius:4px;
                padding:1px 6px;
                color:#555;
                font-family:'JetBrains Mono',monospace
            }
            .q-ans-label{
                font-size:9pt;
                font-weight:700;
                text-transform:uppercase;
                letter-spacing:.4px;
                color:#555;
                margin-bottom:4px
            }
            textarea.model-ans{
                width:100%;
                min-height:100px;
                resize:vertical;
                border:1px solid #bbb;
                border-radius:6px;
                padding:8px 10px;
                font-family:'Crimson Pro',Georgia,serif;
                font-size:11.5pt;
                line-height:1.6;
                color:#000;
                background:#fff;
                outline:none;
            }
            textarea.model-ans:focus{
                border-color:#5b21b6;
                box-shadow:0 0 0 2px rgba(91,33,182,.15)
            }
            .marks-pill{
                display:inline-block;
                background:#000;
                color:#fff;
                font-family:'JetBrains Mono',monospace;
                font-size:9pt;
                padding:2px 8px;
                border-radius:3px;
                margin-left:8px
            }
            .empty-note{
                font-size:10pt;
                color:#aaa;
                font-style:italic;
                padding:8px
            }

            /* Total marks row */
            .total-row{
                border-top:2px solid #000;
                padding-top:8px;
                margin-top:10px;
                font-weight:700;
                font-size:11pt;
                text-align:right
            }

            /* Signature */
            .sig-grid{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:28px;
                margin-top:24px
            }
            .sig-item{
                border-top:1px solid #000;
                padding-top:6px;
                font-size:10pt
            }
            .sig-lbl{
                font-size:9pt;
                color:#555
            }

            /* Clean footer bar */
            .doc-footer{
                display:flex;
                align-items:center;
                justify-content:space-between;
                border-top:1.5px solid #000;
                padding-top:6px;
                margin-top:24px;
                font-family:'Sora',sans-serif;
                font-size:9pt;
            }
            .doc-footer-sulit{
                color:#be123c;
                font-weight:900;
                letter-spacing:2px;
            }
            .doc-footer-title{
                color:#555;
                font-style:italic;
                font-size:8.5pt;
            }
            .doc-footer-page{
                font-family:'JetBrains Mono',monospace;
                color:#555;
            }
            /* Page num */
            .pg-num{
                position:absolute;
                bottom:32px;
                right:72px;
                font-size:9pt;
                color:#888;
                font-family:'JetBrains Mono',monospace
            }

            /* ── PRINT ─────────────────────────────────────────── */
            @page{
                size:A4;
                margin:0;  /* Zero margin suppresses browser timestamp/URL header+footer */
            }
            html{
                -webkit-print-color-adjust:exact;
                print-color-adjust:exact
            }
            @media print{
                .topnav,.screen-wrap > .info-bar,.screen-wrap > .alert-ok,
                .screen-wrap > .alert-warn,.screen-wrap > .print-note,
                .nav-right,.back-link,button[type="submit"]{
                    display:none!important
                }
                body{
                    background:#fff;
                    margin:0;
                    padding:0
                }
                .screen-wrap{
                    max-width:none;
                    margin:0;
                    padding:0
                }
                .a4-page{
                    box-shadow:none;
                    margin:0;
                    page-break-after:always;
                    width:210mm;
                    min-height:297mm;
                    padding:20mm 22mm 28mm 22mm; /* bottom 28mm leaves room for footer */
                }
                .a4-page:last-child{
                    page-break-after:auto
                }
                /* Textarea auto-sizes to content on print */
                textarea.model-ans{
                    border:none;
                    resize:none;
                    background:transparent;
                    padding:0;
                    height:auto;
                    overflow:visible;
                    min-height:0;
                }
                /* SKEMA watermark fully visible on print via ::after */
                .a4-page::after{
                    color:rgba(220,38,38,.15);
                    font-size:120pt;
                }
            }
        </style>
    </head>
    <body>

        <%-- ── TOPNAV ── --%>
        <div class="topnav">
            <div class="icon">
                <img src="<%= request.getContextPath()%>/images/umt-logo.png"
                     alt="UMT Logo"
                     class="icon-logo">
            </div>
            <div class="brand-name">E-Vetting</div>
            <a href="<%= request.getContextPath()%>/NewPaperServlet?action=edit&amp;paperId=<%= paper.getPaperId()%>" class="back-link">Back</a>
            <div class="nav-right">
                <button type="button" class="btn btn-ghost" onclick="window.print()">
                    Print / PDF
                </button>
            </div>
        </div>

        <div class="screen-wrap">

            <% if (saved) { %>
            <div class="alert-ok">Answer Schema saved successfully.</div>
            <% }%>

            <div class="info-bar">
                <div>
                    <h2>Answer Schema <%= courseCode%></h2>
                    <p><%= courseTitle%> | <%= paperType%> | Semester <%= semStr%> <%= sessStr%></p>
                </div>
            </div>

            <div class="print-note">
                <b>Note:</b> Fill in model answers for Section B and C below, then Save.
                Use <b>Print / PDF</b> to generate 2 printed copies with the "SKEMA" watermark as required by FSKM SS02.
            </div>

            <%-- Form wraps the entire A4 page so all model answers are submitted together --%>
            <form method="post" action="<%= ctx%>/SchemaServlet">
                <input type="hidden" name="paperId" value="<%= paper.getPaperId()%>"/>

                <div class="a4-page">

                    <%-- Top strip: course code left, SULIT right --%>
                    <div style="display:flex;justify-content:space-between;align-items:center;
                         margin-bottom:10px;padding-bottom:4px;">
                        <span style="font-family:'JetBrains Mono',monospace;font-size:9.5pt;
                              font-weight:700;color:#444;letter-spacing:.5px">
                            <%= courseCode%>
                        </span>
                        <span style="font-family:'Sora',sans-serif;font-size:11pt;
                              font-weight:900;color:#be123c;
                              border:2px solid #be123c;padding:2px 10px;
                              letter-spacing:2px;">
                            SULIT
                        </span>
                    </div>

                    <%-- Document header --%>
                    <div class="doc-header">
                        <img src="<%= ctx%>/images/umt-logo.png" alt="UMT" class="doc-logo"
                             onerror="this.style.display='none';document.getElementById('logoFb').style.display='flex'"/>
                        <div id="logoFb" class="doc-logo-placeholder" style="display:none">UMT</div>
                        <div class="doc-header-text">
                            <div class="doc-uni">Universiti Malaysia Terengganu</div>
                            <div class="doc-fac">Fakulti Sains Komputer dan Matematik (FSKM)</div>
                        </div>
                    </div>

                    <div class="doc-title-box">
                        <b>Skema Jawapan / <i>Answer Schema</i></b>
                        <i><%= paperType%></i>
                    </div>

                    <table class="ci-box">
                        <tr>
                            <td class="cl">Kod Kursus / <i>Course Code</i></td>
                            <td class="cs">:</td>
                            <td class="cv"><b><%= courseCode%></b></td>
                            <td class="cr">Sesi / <i>Session</i></td>
                            <td class="cs">:</td>
                            <td class="crv"><b><%= sessStr.isEmpty() ? "&mdash;" : sessStr%></b></td>
                        </tr>
                        <tr>
                            <td class="cl">Nama Kursus / <i>Course Title</i></td>
                            <td class="cs">:</td>
                            <td colspan="4"><b><%= courseTitle%></b></td>
                        </tr>
                        <tr>
                            <td class="cl">Semester</td>
                            <td class="cs">:</td>
                            <td class="cv"><b>Semester <%= semStr%></b></td>
                            <td class="cr">Jumlah Markah / <i>Total Marks</i></td>
                            <td class="cs">:</td>
                            <td class="crv"><b><%= totalMarks%></b></td>
                        </tr>
                        <tr>
                            <td class="cl">Jenis Pentaksiran / <i>Assessment Type</i></td>
                            <td class="cs">:</td>
                            <td colspan="4"><b><%= paperType%></b></td>
                        </tr>
                    </table>

                    <%-- ════════════════════════════════════════════
                         SECTION A — Objective: show correct answer only
                    ════════════════════════════════════════════ --%>
                    <% if (!secA.isEmpty()) { %>
                    <div class="sec-hdr">BAHAGIAN A / <i>SECTION A</i> &mdash; Soalan Objektif</div>
                    <table class="mcq-table">
                        <thead>
                            <tr>
                                <th>No.</th>
                                <th>Jawapan / Answer</th>
                                <th>Markah</th>
                                <th>CLO</th>
                                <th>Bloom's</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (int i = 0; i < secA.size(); i++) {
                                    Question q = (Question) secA.get(i);%>
                            <tr>
                                <td class="c-num"><%= q.getQuestionNo()%></td>
                                <td class="c-ans">
                                    <%
                                        String ca = q.getCorrectAnswer();
                                        String cTxt = "";
                                        if ("A".equals(ca) && q.getChoiceA() != null)
                                            cTxt = q.getChoiceA();
                                        else if ("B".equals(ca) && q.getChoiceB() != null)
                                            cTxt = q.getChoiceB();
                                        else if ("C".equals(ca) && q.getChoiceC() != null)
                                            cTxt = q.getChoiceC();
                                        else if ("D".equals(ca) && q.getChoiceD() != null)
                                            cTxt = q.getChoiceD();
                                    %>
                                    <% if (ca != null && !ca.trim().isEmpty()) {%>
                                    <b class="ans-correct"><%= ca%></b>
                                    <% if (!cTxt.isEmpty()) {%>
                                    <div style="font-size:9pt;color:#444;margin-top:2px;font-family:'Crimson Pro',serif;font-weight:normal;text-align:left"><%= cTxt%></div>
                                    <% } %>
                                    <% } else { %>
                                    <span style="color:#bbb;font-size:9pt;font-style:italic">Not set</span>
                                    <% }%>
                                </td>
                                <td class="c-marks"><%= q.getMarks()%></td>
                                <td style="text-align:center;font-size:10pt"><%= q.getCloMapping() != null ? q.getCloMapping() : ""%></td>
                                <td style="text-align:center;font-size:10pt"><%= q.getTaxonomyLevel() != null ? q.getTaxonomyLevel() : ""%></td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <% } %>

                    <%-- ════════════════════════════════════════════
                         SECTION B — Structure: editable model answer
                    ════════════════════════════════════════════ --%>
                    <% if (!secB.isEmpty()) { %>
                    <div class="sec-hdr">BAHAGIAN B / <i>SECTION B</i> &mdash; Soalan Struktur</div>
                    <% for (int i = 0; i < secB.size(); i++) {
                            Question q = (Question) secB.get(i);%>
                    <div class="q-block">
                        <%-- Hidden input so the servlet knows which question this answer belongs to --%>
                        <input type="hidden" name="questionId" value="<%= q.getQuestionId()%>"/>

                        <div class="q-stem">
                            <b>Soalan <%= q.getQuestionNo()%>.</b>
                            <span class="marks-pill"><%= q.getMarks()%> marks</span>
                            <%= q.getQuestionText()%>
                        </div>
                        <div class="q-stem-meta">
                            <% if (q.getCloMapping() != null && !q.getCloMapping().trim().isEmpty()) {%>
                            <span class="q-meta-pill"><%= q.getCloMapping()%></span>
                            <% } %>
                            <% if (q.getTaxonomyLevel() != null && !q.getTaxonomyLevel().trim().isEmpty()) {%>
                            <span class="q-meta-pill"><%= q.getTaxonomyLevel()%></span>
                            <% }%>
                        </div>
                        <% if (q.getParts() != null && !q.getParts().isEmpty()) { 
                              for (Model.QuestionPart p : q.getParts()) { %>
                        <div class="q-ans-label">Jawapan Model <%= p.getPartLabel() %> / Model Answer <%= p.getPartLabel() %></div>
                        <textarea name="modelAnswer_part_<%= p.getPartId() %>" class="model-ans"
                                  placeholder="Taip jawapan model di sini... / Type model answer here..."
                                  oninput="autoResize(this)"
                                  rows="2"><%= p.getModelAnswer() != null ? p.getModelAnswer() : "" %></textarea>
                        <%    }
                           } else { %>
                        <div class="q-ans-label">Jawapan Model / Model Answer</div>
                        <textarea name="modelAnswer" class="model-ans"
                                  placeholder="Taip jawapan model di sini... / Type model answer here..."
                                  oninput="autoResize(this)"
                                  rows="4"><%= q.getModelAnswer() != null ? q.getModelAnswer() : ""%></textarea>
                        <% } %>
                    </div>
                    <% } %>
                    <% } %>

                    <%-- ════════════════════════════════════════════
                         SECTION C — Essay: editable model answer
                    ════════════════════════════════════════════ --%>
                    <% if (!secC.isEmpty()) { %>
                    <div class="sec-hdr">BAHAGIAN C / <i>SECTION C</i> &mdash; Soalan Esei</div>
                    <% for (int i = 0; i < secC.size(); i++) {
                            Question q = (Question) secC.get(i);%>
                    <div class="q-block">
                        <input type="hidden" name="questionId" value="<%= q.getQuestionId()%>"/>

                        <div class="q-stem">
                            <b>Soalan <%= q.getQuestionNo()%>.</b>
                            <span class="marks-pill"><%= q.getMarks()%> marks</span>
                            <%= q.getQuestionText()%>
                        </div>
                        <div class="q-stem-meta">
                            <% if (q.getCloMapping() != null && !q.getCloMapping().trim().isEmpty()) {%>
                            <span class="q-meta-pill"><%= q.getCloMapping()%></span>
                            <% } %>
                            <% if (q.getTaxonomyLevel() != null && !q.getTaxonomyLevel().trim().isEmpty()) {%>
                            <span class="q-meta-pill"><%= q.getTaxonomyLevel()%></span>
                            <% }%>
                        </div>
                        <% if (q.getParts() != null && !q.getParts().isEmpty()) { 
                              for (Model.QuestionPart p : q.getParts()) { %>
                        <div class="q-ans-label">Jawapan Model <%= p.getPartLabel() %> / Model Answer <%= p.getPartLabel() %></div>
                        <textarea name="modelAnswer_part_<%= p.getPartId() %>" class="model-ans"
                                  placeholder="Taip jawapan model di sini... / Type model answer here..."
                                  oninput="autoResize(this)"
                                  rows="3"><%= p.getModelAnswer() != null ? p.getModelAnswer() : "" %></textarea>
                        <%    }
                           } else { %>
                        <div class="q-ans-label">Jawapan Model / Model Answer</div>
                        <textarea name="modelAnswer" class="model-ans"
                                  placeholder="Taip jawapan model di sini... / Type model answer here..."
                                  oninput="autoResize(this)"
                                  rows="5"><%= q.getModelAnswer() != null ? q.getModelAnswer() : ""%></textarea>
                        <% } %>
                    </div>
                    <% } %>
                    <% } %>

                    <% if (questions == null || questions.isEmpty()) { %>
                    <div class="empty-note">No questions found. Add questions in the exam paper first.</div>
                    <% }%>

                    <%-- Total marks --%>
                    <div class="total-row">Jumlah Markah Penuh / Total Marks: <%= totalMarks%></div>

                    <%-- Signature block --%>
                    <div class="sig-grid">
                        <div class="sig-item">
                            <div style="margin-bottom:32px">&nbsp;</div>
                            <div style="font-weight:700">______________________________</div>
                            <div class="sig-lbl">Pensyarah Kursus / <i>Course Lecturer</i></div>
                            <div class="sig-lbl">Tarikh: _________________</div>
                        </div>
                        <div class="sig-item">
                            <div style="margin-bottom:32px">&nbsp;</div>
                            <div style="font-weight:700">______________________________</div>
                            <div class="sig-lbl">Ketua Panel Penyemak / <i>Lead Vetter</i></div>
                            <div class="sig-lbl">Tarikh: _________________</div>
                        </div>
                    </div>

                    <%-- Footer bar: sits at bottom of a4-page content flow --%>
                    <div class="doc-footer">
                        <span class="doc-footer-sulit">SULIT</span>
                        <span class="doc-footer-title">
                            Skema Jawapan &mdash; <%= courseCode%>
                        </span>
                        <span class="doc-footer-page">1</span>
                    </div>

                </div><%-- end display live exam paper page --%>

                <%-- Save button below the paper --%>
                <div style="display:flex;justify-content:flex-end;gap:10px;margin-top:8px">
                    <a href="<%= ctx%>/LecturerDashboardServlet?page=assessments" class="btn btn-navy btn-sm"
                       style="font-size:13px;padding:10px 18px">Cancel</a>
                    <button type="submit" class="btn btn-teal"
                            style="font-size:13px;padding:10px 24px">
                        Save Answer Schema
                    </button>
                </div>

            </form>
        </div>

        <script>
            /* Auto-resize textarea to fit content on load and input */
            function autoResize(el) {
                el.style.height = "auto";
                el.style.height = (el.scrollHeight) + "px";
            }
            /* Run on page load for pre-filled answers */
            window.addEventListener("load", function () {
                document.querySelectorAll("textarea.model-ans").forEach(function (ta) {
                    autoResize(ta);
                });
            });
        </script>
    </body>
</html>