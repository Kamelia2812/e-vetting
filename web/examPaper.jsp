<%--
  FILE:    examPaper.jsp
  SERVLET: NewPaperServlet sends:
           courses (List<Course>), paper (Assessment), questions (List<Question>),
           totalMarks (int), readOnly (Boolean)
  LAYOUT:  Left = Question setup panel | Right = Live paper preview (matches real UMT format)
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, Model.Course, Model.Assessment, Model.Question" %>
<%
    String fullName = (String) session.getAttribute("fullName");
    if (fullName == null) {
        fullName = "Lecturer";
    }
    String initial = String.valueOf(fullName.charAt(0)).toUpperCase();
    String userRole = (String) session.getAttribute("role");
    if (userRole == null) {
        userRole = "Lecturer";
    }
    String ctx = request.getContextPath();

    List<Course> courses = (List<Course>) request.getAttribute("courses");
    Assessment paper = (Assessment) request.getAttribute("paper");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    boolean readOnly = Boolean.TRUE.equals(request.getAttribute("readOnly"));

    boolean saved = "true".equals(request.getParameter("saved"));
    String errorParam = request.getParameter("error");
    String marksParam = request.getParameter("total");

    // Pre-fill from existing paper
    String pCode = paper != null ? paper.getCourseCode() : "";
    String pTitle = paper != null ? paper.getCourseTitle() : "";
    String pType = paper != null ? paper.getPaperType() : "Final Exam";
    String pSession = paper != null ? paper.getAcademicSession() : "";
    String pSem = paper != null ? String.valueOf(paper.getSemester()) : "1";
    String pDeadline = paper != null && paper.getDeadline() != null ? paper.getDeadline() : "";
    int paperId = paper != null ? paper.getPaperId() : 0;

    // Separate questions by section
    java.util.List<Question> secA = new java.util.ArrayList<>();
    java.util.List<Question> secB = new java.util.ArrayList<>();
    java.util.List<Question> secC = new java.util.ArrayList<>();
    if (questions != null) {
        for (Question q : questions) {
            if ("OBJECTIVE".equals(q.getQuestionType())) {
                secA.add(q);
            } else if ("STRUCTURE".equals(q.getQuestionType())) {
                secB.add(q);
            } else if ("ESSAY".equals(q.getQuestionType())) {
                secC.add(q);
            }
        }
    }
%>
<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width,initial-scale=1"/>
        <title>Exam Paper  E-Vetting UMT</title>
        <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500&family=Crimson+Pro:ital,wght@0,400;0,600;1,400;1,600&display=swap" rel="stylesheet"/>
        <style>
            /* ── TOKENS ── */
            :root{
                --navy:#2a1454;
                --gold:#f0a500;
                --cream:#f7f6fb;
                --surface:#fff;
                --border:#e4e9f0;
                --ink:#1e1133;
                --ink2:#364560;
                --muted:#7a8aab;
                --blue:#2563eb;
                --blue-soft:#eff4ff;
                --blue-b:#c7d9fd;
                --green:#15803d;
                --green-bg:#f0fdf4;
                --green-b:#86efac;
                --amber:#b45309;
                --amber-bg:#fffbeb;
                --amber-b:#fcd34d;
                --red:#be123c;
                --red-bg:#fff1f2;
                --red-b:#fda4af;
                --violet:#6d28d9;
                --violet-soft:#f5f3ff;
                --violet-b:#ddd6fe;
                --r:10px;
                --sh:0 1px 3px rgba(11,22,40,.06),0 4px 12px rgba(11,22,40,.06);
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
                font-size:14px;
                height:100vh;
                display:flex;
                flex-direction:column;
                overflow:hidden;
                margin:0
            }

            /* ── TOPNAV ── */
            .topnav{
                background:var(--navy);
                height:52px;
                display:flex;
                align-items:center;
                padding:0 20px;
                gap:0;
                flex-shrink:0;
                border-bottom:1px solid rgba(255,255,255,.07);
                z-index:100
            }
            .brand{
                display:flex;
                align-items:center;
                gap:8px;
                padding-right:20px;
                border-right:1px solid rgba(255,255,255,.1);
                flex-shrink:0;
                text-decoration:none
            }
            .brand-logo{
                width:30px;
                height:30px;
                object-fit:contain;
                flex-shrink:0
            }
            .brand-name{
                font-size:13px;
                font-weight:800;
                color:#fff
            }
            .brand-sub{
                font-size:9px;
                color:rgba(255,255,255,.4)
            }
            .back-link{
                display:flex;
                align-items:center;
                gap:5px;
                font-size:12px;
                font-weight:600;
                color:rgba(255,255,255,.5);
                text-decoration:none;
                padding:5px 9px;
                border-radius:7px;
                margin-left:16px;
                transition:.15s
            }
            .back-link:hover{
                background:rgba(255,255,255,.07);
                color:#fff
            }
            .nav-right{
                margin-left:auto;
                display:flex;
                align-items:center;
                gap:10px;
                padding-left:16px;
                border-left:1px solid rgba(255,255,255,.1)
            }
            .user-name{
                font-size:12px;
                font-weight:700;
                color:#fff
            }
            .user-role{
                font-size:9px;
                color:rgba(255,255,255,.4)
            }
            .avatar{
                width:30px;
                height:30px;
                border-radius:50%;
                background:var(--gold);
                color:var(--navy);
                display:grid;
                place-items:center;
                font-weight:800;
                font-size:12px
            }

            /* ── WORKSPACE: two-panel split ── */
            .workspace{
                display:flex;
                flex:1;
                overflow:hidden;
                min-height:0
            }

            /* ── LEFT PANEL: setup form ── */
            .setup-panel{
                width:420px;
                flex-shrink:0;
                background:var(--surface);
                border-right:1px solid var(--border);
                display:flex;
                flex-direction:column;
                overflow:hidden
            }
            .setup-header{
                padding:14px 16px;
                border-bottom:1px solid var(--border);
                background:#f8f9fc;
                display:flex;
                align-items:center;
                justify-content:space-between;
                flex-shrink:0
            }
            .setup-header h2{
                font-size:13px;
                font-weight:800
            }
            .setup-scroll{
                flex:1;
                overflow-y:auto;
                padding:16px
            }
            .setup-scroll::-webkit-scrollbar{
                width:4px
            }
            .setup-scroll::-webkit-scrollbar-thumb{
                background:var(--border);
                border-radius:4px
            }
            .setup-footer{
                padding:12px 16px;
                border-top:1px solid var(--border);
                background:#f8f9fc;
                display:flex;
                gap:8px;
                flex-shrink:0
            }

            /* ── FORM ELEMENTS ── */
            .field-group{
                margin-bottom:14px
            }
            .field-group label{
                display:block;
                font-size:11px;
                font-weight:700;
                color:var(--muted);
                text-transform:uppercase;
                letter-spacing:.4px;
                margin-bottom:5px
            }
            input,select,textarea{
                width:100%;
                border:1px solid var(--border);
                border-radius:7px;
                padding:7px 10px;
                font-family:'Sora',sans-serif;
                font-size:12px;
                color:var(--ink);
                background:#fafbfc;
                outline:none;
                transition:.15s
            }
            input:focus,select:focus,textarea:focus{
                border-color:var(--blue);
                background:#fff;
                box-shadow:0 0 0 3px var(--blue-soft)
            }
            .field-row-2{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:10px
            }
            .field-row-3{
                display:grid;
                grid-template-columns:1fr 1fr 1fr;
                gap:8px
            }

            /* ── SECTION CONFIG CARDS ── */
            .section-config{
                background:var(--cream);
                border:1px solid var(--border);
                border-radius:var(--r);
                padding:12px;
                margin-bottom:10px
            }
            .sc-header{
                display:flex;
                align-items:center;
                gap:8px;
                margin-bottom:10px
            }
            .sc-letter{
                width:24px;
                height:24px;
                border-radius:7px;
                display:grid;
                place-items:center;
                font-weight:800;
                font-size:12px;
                color:#fff;
                flex-shrink:0
            }
            .sc-letter.obj{
                background:var(--violet)
            }
            .sc-letter.str{
                background:var(--amber)
            }
            .sc-letter.ess{
                background:var(--green)
            }
            .sc-title{
                font-size:12px;
                font-weight:800;
                flex:1
            }
            .sc-marks{
                font-size:11px;
                font-weight:700;
                font-family:'JetBrains Mono',monospace;
                color:var(--muted)
            }

            /* ── QUESTION CONFIG ROWS ── */
            .q-config-list{
                display:flex;
                flex-direction:column;
                gap:8px
            }
            .q-config-item{
                background:#fff;
                border:1px solid var(--border);
                border-radius:8px;
                padding:10px
            }
            .q-config-top{
                display:flex;
                align-items:center;
                gap:8px;
                margin-bottom:8px
            }
            .q-config-num{
                font-family:'JetBrains Mono',monospace;
                font-size:10px;
                font-weight:700;
                color:var(--blue);
                background:var(--blue-soft);
                border:1px solid var(--blue-b);
                border-radius:4px;
                padding:2px 6px;
                flex-shrink:0
            }
            .q-config-del{
                margin-left:auto;
                background:none;
                border:none;
                cursor:pointer;
                color:var(--muted);
                font-size:13px;
                padding:2px 5px;
                border-radius:4px;
                transition:.15s
            }
            .q-config-del:hover{
                background:var(--red-bg);
                color:var(--red)
            }
            .q-config-fields{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:7px
            }
            .q-config-fields-3{
                display:grid;
                grid-template-columns:1fr 1fr 1fr;
                gap:6px
            }
            /* MCQ choices */
            .mcq-choices{
                margin-top:8px;
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:5px
            }
            .choice-row{
                display:flex;
                align-items:center;
                gap:5px
            }
            .choice-ltr{
                width:18px;
                height:18px;
                border-radius:50%;
                background:var(--blue-soft);
                border:1px solid var(--blue-b);
                display:grid;
                place-items:center;
                font-size:9px;
                font-weight:800;
                color:var(--blue);
                flex-shrink:0
            }
            .choice-inp{
                font-size:11px;
                padding:4px 7px
            }
            /* add q button */
            .add-q-btn{
                width:100%;
                border:2px dashed var(--border);
                background:transparent;
                border-radius:8px;
                padding:7px;
                font-family:'Sora',sans-serif;
                font-size:11px;
                font-weight:700;
                color:var(--muted);
                cursor:pointer;
                transition:.15s;
                margin-top:6px
            }
            .add-q-btn:hover{
                border-color:var(--blue);
                color:var(--blue);
                background:var(--blue-soft)
            }

            /* ── MARKS METER ── */
            .marks-meter{
                border-radius:10px;
                padding:12px 14px;
                margin-bottom:14px;
                border:2px solid var(--navy);
                background:var(--navy);
                transition:border-color .3s,background .3s
            }
            .marks-meter.state-ok{
                border-color:var(--green);
                background:var(--green-bg)
            }
            .marks-meter.state-over{
                border-color:var(--red);
                background:var(--red-bg)
            }
            /* Big fraction: X / 100 */
            .mm-fraction{
                display:flex;
                align-items:baseline;
                gap:4px;
                margin-bottom:8px
            }
            .mm-current{
                font-size:36px;
                font-weight:800;
                font-family:'JetBrains Mono',monospace;
                color:#fff;
                letter-spacing:-2px;
                line-height:1;
                transition:color .3s
            }
            .marks-meter.state-ok .mm-current{
                color:var(--green)
            }
            .marks-meter.state-over .mm-current{
                color:var(--red)
            }
            .mm-sep{
                font-size:22px;
                font-weight:700;
                color:rgba(255,255,255,.4);
                font-family:'JetBrains Mono',monospace
            }
            .marks-meter.state-ok .mm-sep,.marks-meter.state-ok .mm-denom{
                color:var(--green)
            }
            .marks-meter.state-over .mm-sep,.marks-meter.state-over .mm-denom{
                color:var(--red)
            }
            .mm-denom{
                font-size:22px;
                font-weight:800;
                font-family:'JetBrains Mono',monospace;
                color:rgba(255,255,255,.5);
                line-height:1;
                transition:color .3s
            }
            .mm-label{
                font-size:10px;
                font-weight:700;
                color:rgba(255,255,255,.5);
                margin-bottom:8px
            }
            .marks-meter.state-ok .mm-label,.marks-meter.state-over .mm-label{
                color:var(--ink2)
            }
            /* Bar */
            .mm-bar-wrap{
                height:8px;
                background:rgba(255,255,255,.15);
                border-radius:999px;
                overflow:hidden;
                margin-bottom:8px
            }
            .marks-meter.state-ok .mm-bar-wrap,.marks-meter.state-over .mm-bar-wrap{
                background:rgba(0,0,0,.1)
            }
            .mm-bar{
                height:100%;
                border-radius:999px;
                transition:width .3s,background .3s
            }
            /* Section breakdown */
            .mm-breakdown{
                display:flex;
                justify-content:space-between
            }
            .mm-sec{
                font-size:10px;
                font-weight:700;
                color:rgba(255,255,255,.5)
            }
            .marks-meter.state-ok .mm-sec,.marks-meter.state-over .mm-sec{
                color:var(--ink2)
            }
            /* Status text */
            .mm-status{
                font-size:11px;
                font-weight:800;
                margin-top:8px;
                padding:6px 10px;
                border-radius:7px;
                text-align:center;
                background:rgba(255,255,255,.1)
            }
            .marks-meter.state-ok .mm-status{
                background:var(--green);
                color:#fff
            }
            .marks-meter.state-over .mm-status{
                background:var(--red);
                color:#fff
            }



            /* ── BUTTONS ── */
            .btn{
                display:inline-flex;
                align-items:center;
                gap:5px;
                border:none;
                border-radius:7px;
                padding:8px 14px;
                font-family:'Sora',sans-serif;
                font-size:12px;
                font-weight:700;
                cursor:pointer;
                text-decoration:none;
                transition:.15s;
                flex-shrink:0
            }
            .btn-navy{
                background:var(--navy);
                color:#fff
            }
            .btn-navy:hover{
                background:#132240
            }
            .btn-gold{
                background:var(--gold);
                color:var(--navy)
            }
            .btn-gold:hover{
                background:#d99200
            }
            .btn-ghost{
                background:transparent;
                color:var(--ink2);
                border:1px solid var(--border)
            }
            .btn-ghost:hover{
                background:var(--cream)
            }
            .btn-danger{
                background:var(--red-bg);
                color:var(--red);
                border:1px solid var(--red-b)
            }
            .btn-full{
                width:100%;
                justify-content:center
            }
            .btn-sm{
                padding:5px 10px;
                font-size:11px
            }

            /* ── ALERT ── */
            .alert{
                border-radius:8px;
                padding:10px 14px;
                font-size:12px;
                font-weight:600;
                margin-bottom:12px;
                display:flex;
                gap:8px;
                align-items:flex-start
            }
            .alert-ok{
                background:var(--green-bg);
                border:1px solid var(--green-b);
                color:var(--green)
            }
            .alert-err{
                background:var(--red-bg);
                border:1px solid var(--red-b);
                color:var(--red)
            }

            /* ── RIGHT PANEL: paper preview ── */
            .preview-panel{
                flex:1;
                display:flex;
                flex-direction:column;
                overflow:hidden;
                background:#d0cfc9
            }
            .bloom-clo-tag{ display:block }

            /* Zero @page margin removes browser timestamp header and URL footer */
            @page{ size:A4; margin:0 }
            html{ -webkit-print-color-adjust:exact; print-color-adjust:exact }

            /* When printPaper() is running — hide everything except the print container */
            @media print{
              body.printing > *:not(#printWrap){ display:none!important }
              #printWrap .paper-page,
              #printWrap .paper-page-cont{
                box-shadow:none!important;
                margin:0!important;
                page-break-after:always;
                break-after:page;
                width:210mm!important;
                min-height:297mm!important;
                padding:18mm 22mm!important;
                position:relative;
              }
              #printWrap .paper-page:last-child,
              #printWrap .paper-page-cont:last-child{
                page-break-after:auto;
                break-after:auto;
              }
              #printWrap .bloom-clo-tag{ display:none!important }
            }

            /* Fallback @media print for direct window.print() */
            @media print{
              /* Hide all UI — only paper pages show */
              .setup-panel,.topnav,.page-header,
              .preview-header,.bloom-clo-tag,
              .footer-bar{ display:none!important }

              body{ background:#fff!important; margin:0!important; padding:0!important }

              /* Make the app layout a simple block flow */
              .app-layout{ display:block!important; height:auto!important }

              /* Preview panel expands to show all pages */
              .preview-panel{
                overflow:visible!important;
                background:#fff!important;
                display:block!important;
                width:100%!important;
                height:auto!important;
              }

              /* Preview scroll must be visible so all pages render */
              .preview-scroll{
                overflow:visible!important;
                padding:0!important;
                display:block!important;
                height:auto!important;
                gap:0!important;
              }

              /* Force page-questions visible — rebuildPreview hides it on screen */
              #page-questions{ display:block!important }

              /* Each paper-page = one printed A4 sheet */
              .paper-page,.paper-page-cont{
                box-shadow:none!important;
                margin:0!important;
                page-break-after:always;
                break-after:page;
                width:210mm!important;
                min-height:297mm!important;
                padding:18mm 22mm!important;
                overflow:visible!important;
              }
              .paper-page:last-child,
              .paper-page-cont:last-child{
                page-break-after:auto;
                break-after:auto;
              }
            }
            .preview-header{
                background:#f0eeea;
                border-bottom:1px solid #c5c3bc;
                padding:10px 16px;
                display:flex;
                align-items:center;
                justify-content:space-between;
                flex-shrink:0
            }
            .preview-header span{
                font-size:12px;
                font-weight:700;
                color:var(--muted)
            }
            .preview-scroll{
                flex:1;
                overflow-y:auto;
                padding:24px;
                display:flex;
                flex-direction:column;
                align-items:center;
                gap:0
            }
            .preview-scroll::-webkit-scrollbar{
                width:6px
            }
            .preview-scroll::-webkit-scrollbar-thumb{
                background:#b0ada5;
                border-radius:4px
            }

            /* ── PAPER PAGES (A4 look) ── */
            .paper-page{
                width:794px;
                min-height:1123px;
                background:#fff;
                box-shadow:0 4px 20px rgba(0,0,0,.2);
                padding:72px 80px;
                font-family:'Crimson Pro',Georgia,serif;
                font-size:12pt;
                color:#000;
                position:relative;
                margin-bottom:16px;
                break-inside:avoid;
            }
            /* Continuation pages generated by JS paginatePreview() */
            .paper-page-cont{
                width:794px;
                min-height:1123px;
                background:#fff;
                box-shadow:0 4px 20px rgba(0,0,0,.2);
                padding:72px 80px 60px 80px;
                font-family:'Crimson Pro',Georgia,serif;
                font-size:12pt;
                color:#000;
                position:relative;
                margin-bottom:16px;
                break-inside:avoid;
            }
            /* Running header on each page */
            .page-running-header{
                position:absolute;
                top:32px;
                left:80px;
                right:80px;
                display:flex;
                justify-content:space-between;
                align-items:flex-start;
                font-family:'Crimson Pro',serif;
                font-size:11pt;
                font-weight:600;
            }
            .page-running-header .course-code-hdr{
                font-weight:700
            }
            .page-confidential{
                text-align:right;
                line-height:1.3
            }
            .page-confidential b{
                display:block;
                font-size:11pt;
                font-weight:700
            }
            .page-confidential i{
                display:block;
                font-size:11pt;
                font-style:italic;
                font-weight:700
            }
            /* Page number bottom right */
            .page-num{
                position:absolute;
                bottom:32px;
                right:80px;
                font-family:'Crimson Pro',serif;
                font-size:10pt
            }

            /* ── COVER PAGE ── */
            .cover-logo-area{
                text-align:center;
                margin-bottom:16px
            }
            .cover-logo{
                font-size:48px
            }
            .cover-uni{
                font-size:14pt;
                font-weight:700;
                text-align:center;
                margin-bottom:8px;
                font-family:'Crimson Pro',serif
            }
            .cover-exam-type{
                text-align:center;
                margin-bottom:4px
            }
            .cover-exam-type b{
                display:block;
                font-size:14pt;
                font-weight:700;
                font-family:'Crimson Pro',serif
            }
            .cover-exam-type i{
                display:block;
                font-size:13pt;
                font-style:italic;
                font-weight:600;
                font-family:'Crimson Pro',serif
            }
            .cover-session{
                text-align:center;
                margin-bottom:20px
            }
            .cover-session b{
                display:block;
                font-size:12pt;
                font-weight:700;
                font-family:'Crimson Pro',serif
            }
            .cover-session i{
                display:block;
                font-size:11pt;
                font-style:italic;
                font-weight:600;
                font-family:'Crimson Pro',serif
            }

            /* Info table */
            .info-table{
                width:100%;
                border-collapse:collapse;
                border:2px solid #000;
                margin-bottom:14px;
                font-family:'Crimson Pro',serif
            }
            .info-table td{
                padding:6px 10px;
                vertical-align:top;
                border-bottom:1px solid #555;
                font-size:11pt
            }
            .info-table td:first-child{
                white-space:nowrap;
                width:140px
            }
            .info-table tr:last-child td{
                border-bottom:none
            }
            .info-table .label-en{
                font-weight:700;
                display:block
            }
            .info-table .label-ms{
                font-style:italic;
                display:block;
                font-size:10pt
            }
            .info-table .val-en{
                font-weight:700;
                display:block
            }
            .info-table .val-ms{
                font-style:italic;
                display:block;
                font-size:10pt
            }

            /* Student info table */
            .student-table{
                width:100%;
                border-collapse:collapse;
                border:2px solid #000;
                margin-bottom:14px;
                font-family:'Crimson Pro',serif
            }
            .student-table td{
                padding:10px;
                border-bottom:1px solid #555;
                font-size:11pt
            }
            .student-table tr:last-child td{
                border-bottom:none
            }
            .student-table .label-en{
                font-weight:700
            }
            .student-table .label-ms{
                font-style:italic;
                font-size:10pt
            }
            .student-fill{
                border:none;
                border-bottom:1px solid #000;
                flex:1;
                display:inline-block;
                width:60%;
                margin-left:8px
            }

            /* Instructions */
            .instructions{
                text-align:center;
                margin-bottom:14px;
                font-family:'Crimson Pro',serif
            }
            .instructions h3{
                font-size:12pt;
                font-weight:700;
                text-decoration:underline;
                margin-bottom:2px
            }
            .instructions h3 i{
                font-style:italic
            }
            .instructions ol{
                text-align:left;
                display:inline-block;
                margin-top:8px
            }
            .instructions ol li{
                font-size:11pt;
                margin-bottom:6px
            }
            .instructions ol li i{
                font-style:italic;
                display:block;
                font-size:10.5pt
            }
            .cover-warning{
                text-align:center;
                font-family:'Crimson Pro',serif;
                margin:12px 0
            }
            .cover-warning b{
                display:block;
                font-size:12pt;
                font-weight:700
            }
            .cover-warning i{
                display:block;
                font-style:italic;
                font-size:11pt
            }
            .cover-pages{
                text-align:center;
                font-family:'Crimson Pro',serif;
                margin-top:10px;
                font-size:11pt;
                font-style:italic
            }

            /* ── SECTION HEADERS IN PAPER ── */
            .paper-section-header{
                margin:0 0 14px 0;
                font-family:'Crimson Pro',serif
            }
            .paper-section-header .part-title{
                font-size:12pt;
                font-weight:700;
                margin-bottom:2px
            }
            .paper-section-header .part-instruction{
                font-size:11.5pt;
                font-weight:700;
                margin-bottom:2px
            }
            .paper-section-header .part-instruction i{
                font-style:italic;
                display:block;
                font-size:11pt
            }

            /* ── QUESTIONS IN PAPER ── */
            .paper-question{
                margin-bottom:18px;
                font-family:'Crimson Pro',serif
            }
            .pq-stem{
                display:flex;
                gap:10px;
                margin-bottom:8px
            }
            .pq-num{
                font-size:11.5pt;
                font-weight:700;
                flex-shrink:0;
                min-width:24px
            }
            .pq-text{
                font-size:11.5pt;
                line-height:1.5;
                flex:1
            }
            .pq-text-ms{
                font-size:11pt;
                font-style:italic;
                display:block;
                margin-top:2px
            }
            .pq-marks{
                font-size:10.5pt;
                font-style:italic;
                color:#444
            }

            /* MCQ options */
            .pq-options{
                margin-left:34px;
                margin-top:6px
            }
            .pq-opt{
                display:flex;
                gap:10px;
                margin-bottom:5px;
                font-size:11pt
            }
            .pq-opt-ltr{
                font-weight:600;
                min-width:18px
            }
            .pq-opt-text{
                flex:1;
                line-height:1.4
            }
            .pq-opt-ms{
                font-style:italic;
                font-size:10.5pt;
                display:block;
                margin-top:1px
            }

            /* Roman numeral statement list I. II. III. IV. inside a question */
            .pq-stmts{
                margin:6px 0 8px 34px;
                display:flex;
                flex-direction:column;
                gap:4px
            }
            .pq-stmt{
                display:flex;
                gap:8px;
                font-size:11pt;
                line-height:1.5
            }
            .pq-stmt-num{
                font-weight:700;
                min-width:28px;
                flex-shrink:0
            }

            /* Structured sub-questions */
            .pq-sub{
                margin-left:34px;
                margin-top:6px;
                font-size:11pt
            }
            .pq-sub-item{
                display:flex;
                gap:8px;
                margin-bottom:8px
            }
            .pq-sub-ltr{
                font-weight:600;
                min-width:20px
            }

            /* Answer space lines (for structure/essay) */
            .answer-lines{
                margin-left:34px;
                margin-top:8px
            }
            .answer-line{
                border-bottom:1px solid #ccc;
                height:22px;
                margin-bottom:4px
            }

            /* Code block in paper */
            .code-block{
                background:#f5f5f5;
                border:1px solid #ccc;
                padding:8px 12px;
                font-family:'JetBrains Mono',monospace;
                font-size:10pt;
                margin:8px 34px;
                white-space:pre-wrap
            }

            /* End of paper */
            .end-of-paper{
                text-align:center;
                margin-top:40px;
                font-family:'Crimson Pro',serif
            }
            .end-of-paper b{
                font-size:12pt;
                font-weight:700
            }
            .end-of-paper i{
                display:block;
                font-style:italic;
                font-size:11pt
            }

            /* Divider between sections */
            .section-divider{
                border:none;
                border-top:1px solid #999;
                margin:24px 0
            }

            .skema-logo-row{
                display:flex;
                margin-bottom:14px;
                align-items: center;
                justify-content: center
            }
            .skema-logo-row img{
                width:250px;
                height:auto
            }

        </style>
    </head>
    <body>

        <!-- TOPNAV -->
        <div class="topnav">
            <a href="<%= ctx%>/LecturerDashboardServlet" class="brand">
                <img src="<%= ctx%>/images/umt-logo.png" alt="Logo" class="brand-logo">
                <div><div class="brand-name">E-Vetting</div><div class="brand-sub">UMT</div></div>
            </a>
            <a href="<%= ctx%>/LecturerDashboardServlet?page=assessments" class="back-link"> Back</a>
            <div style="margin-left:16px;font-size:12px;font-weight:700;color:rgba(255,255,255,.6)">
                Exam Paper<%= pCode.isEmpty() ? "" : pCode%>
            </div>
            <div class="nav-right">
                <div><div class="user-name"><%= fullName%></div><div class="user-role"><%= userRole%></div></div>
                <div class="avatar"><%= initial%></div>
            </div>
        </div>

        <div class="workspace">

            <!-- ═══════════════════════════════════
                 LEFT: SETUP PANEL
            ════════════════════════════════════ -->
            <div class="setup-panel">
                <div class="setup-header">
                    <h2>️ Paper Setup</h2>
                    <% if (paper != null) {%><span style="font-family:'JetBrains Mono',monospace;font-size:10px;color:var(--muted)">ID: <%= paperId%></span><% } %>
                </div>


                <div class="setup-scroll">

                    <% if (saved) { %><div class="alert alert-ok">Draft saved.</div><% } %>
                    <% if ("marks".equals(errorParam)) {%><div class="alert alert-err">Total marks is <b><%= marksParam%></b>  must be exactly 100.</div><% } %>
                    <% if (readOnly) {%><div class="alert" style="background:var(--amber-bg);border:1px solid var(--amber-b);color:var(--amber)">View only, paper is <%= paper != null ? paper.getStatusLabel() : ""%></div><% } %>
                    <% if (paper != null && "REJECTED".equals(paper.getStatus()) && paper.getRemarks() != null) {%>
                    <div class="alert alert-err"><b>Rejected:</b> <%= paper.getRemarks()%></div>
                    <% }%>
                    <% if (paper != null && "NEEDS_IMPROVEMENT".equals(paper.getStatus())) {%>
                    <div class="alert" style="background:#fff7ed;border:1px solid #fed7aa;color:#9a3412">
                      <b>Needs Improvement</b>  Vetters have flagged issues with this paper.
                      Please review the feedback on the feedback page, make the required corrections, then click <b>Resubmit to Vetter</b>.
                    </div>
                    <% }%>

                    <!-- Marks Meter — shows X / 100 prominently -->
                    <div class="marks-meter" id="marksMeter">
                        <!-- Big X / 100 fraction -->
                        <div class="mm-fraction">
                            <span class="mm-current" id="totalMarksDisplay">0</span>
                            <span class="mm-sep">/</span>
                            <span class="mm-denom">100</span>
                        </div>
                        <div class="mm-label">Total marks used out of 100</div>
                        <!-- Progress bar -->
                        <div class="mm-bar-wrap">
                            <div class="mm-bar" id="mmBar" style="width:0%;background:#f0a500"></div>
                        </div>
                        <!-- Per-section breakdown -->
                        <div class="mm-breakdown">
                            <span class="mm-sec">A: <span id="mA">0</span>m</span>
                            <span class="mm-sec">B: <span id="mB">0</span>m</span>
                            <span class="mm-sec">C: <span id="mC">0</span>m</span>
                        </div>
                        <!-- Status message -->
                        <div class="mm-status" id="mmStatus">Add questions to begin</div>
                    </div>

                    <form method="post" action="<%= ctx%>/NewPaperServlet" id="paperForm" enctype="multipart/form-data">
                        <input type="hidden" name="paperId" value="<%= paperId%>"/>

                        <!-- ── Paper Details ── -->
                        <div style="font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);margin-bottom:10px">Paper Details</div>

                        <div class="field-group">
                            <label>Course *</label>
                            <select name="courseCode" id="courseCodeSel" required <%= readOnly ? "disabled" : ""%> onchange="onCourseChange(this)">
                                <option value="">— Select course —</option>
                                <% if (courses != null) {
                  for (Course c : courses) {%>
                                <option value="<%= c.getCourseCode()%>" data-title="<%= c.getCourseName()%>"
                                        data-hours="<%= c.getExamHour()%>"
                                        <%= c.getCourseCode().equals(pCode) ? "selected" : ""%>>
                                    <%= c.getCourseCode()%> — <%= c.getCourseName()%>
                                </option>
                                <% }
              }%>
                            </select>
                        </div>
                        <div class="field-group">
                            <label>Course Title</label>
                            <input type="text" name="courseTitle" id="courseTitleInp" value="<%= pTitle%>" <%= readOnly ? "disabled" : ""%> placeholder="Auto-filled"/>
                        </div>
                        <div class="field-row-3">
                            <div class="field-group">
                                <label>Session</label>
                                <input type="text" name="academicSession" id="sessionInp" value="<%= pSession%>" <%= readOnly ? "disabled" : ""%> placeholder="2024/2025" onchange="updatePreview()"/>
                            </div>
                            <div class="field-group">
                                <label>Semester</label>
                                <select name="semester" id="semSel" <%= readOnly ? "disabled" : ""%> onchange="updatePreview()">
                                    <% for (int i = 1; i <= 2; i++) {%>
                                    <option value="<%= i%>" <%= String.valueOf(i).equals(pSem) ? "selected" : ""%>>Sem <%= i%></option>
                                    <% }%>
                                </select>
                            </div>
                            <div class="field-group">
                                <label>Duration</label>
                                <input type="text" name="examDuration" id="durationInp" value="<%= paper == null ? "2" : paper.getPaperType()%>" <%= readOnly ? "disabled" : ""%> placeholder="2 hours"/>
                            </div>
                        </div>
                        <div class="field-row-2">
                            <div class="field-group" style="grid-column:1/-1">
                                <label>Assessment Type *</label>
                                <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px">
                                    <!-- Step 1: pick category -->
                                    <select id="assessCategory" onchange="onCategoryChange(this)" <%= readOnly ? "disabled" : ""%>>
                                        <option value="">— Category —</option>
                                        <option value="final"      <%= pType != null && (pType.startsWith("Final") || pType.equals("Supplementary Exam")) ? "selected" : ""%>>Final Assessment</option>
                                        <option value="continuous" <%= pType != null && !pType.startsWith("Final") && !pType.equals("Supplementary Exam") && !pType.isEmpty() ? "selected" : ""%>>Continuous Assessment</option>
                                    </select>
                                    <!-- Step 2: specific type (filtered by category) -->
                                    <select name="paperType" id="assessType" required <%= readOnly ? "disabled" : ""%>>
                                        <option value="">Type </option>
                                    </select>
                                </div>
                                <!-- Hidden to show selected value when read-only -->
                                <input type="hidden" id="pTypeDefault" value="<%= pType%>"/>
                                <%-- Hidden pre-selected value for edit mode --%>
                                <input type="hidden" id="preselectedType" value="<%= pType%>"/>
                            </div>
                            <div class="field-group">
                                <label>Deadline</label>
                                <input type="date" name="deadline" value="<%= pDeadline%>" <%= readOnly ? "disabled" : ""%>/>
                            </div>
                        </div>
                        <div class="field-group">
                            <label>Instructions to Candidates</label>
                            <textarea name="instructions" id="instructionsInp" rows="3" <%= readOnly ? "disabled" : ""%> placeholder="e.g. Answer all questions. / Sila jawab semua soalan." onchange="updatePreview()"><%= paper != null && paper.getRemarks() != null ? "" : "i. Answer all questions.\n   Sila jawab semua soalan.\nii. All answers must be written in the answer booklet.\n    Semua jawapan hendaklah ditulis dalam buku jawapan yang disediakan."%></textarea>
                        </div>
                        <input type="hidden" name="faculty" value="FSKM"/>

                        <!-- ── SECTION A: Objective ── -->
                        <hr style="border:none;border-top:1px solid var(--border);margin:16px 0 14px"/>
                        <div class="section-config">
                            <div class="sc-header">
                                <div class="sc-letter obj">A</div>
                                <div class="sc-title">Section A(Objective)</div>
                                <div class="sc-marks" id="scA-marks">0 marks</div>
                            </div>
                            <div class="q-config-list" id="listA">
                                <% int qNumA = 1;
              for (Question q : secA) {%>
                                <div class="q-config-item" id="qi-<%= q.getQuestionId()%>">
                                    <div class="q-config-top">
                                        <span class="q-config-num">Q<%= qNumA++%></span>
                                        <% if (!readOnly) {%><button type="button" class="q-config-del" onclick="delQ('A', this, '<%= q.getQuestionId()%>')">✕</button><% }%>
                                    </div>
                                    <input type="hidden" name="questionId"   value="<%= q.getQuestionId()%>"/>
                                    <input type="hidden" name="questionType" value="OBJECTIVE"/>
                                    <% String qFmt = q.isComplex() ? "COMPLEX" : "SIMPLE";
                                       String imgPart = "img_" + q.getQuestionId(); %>
                                    <input type="hidden" name="questionFormat" class="q-format-input" value="<%= qFmt %>"/>
                                    <input type="hidden" name="existingImageUrl" value="<%= q.getImageUrl() != null ? q.getImageUrl() : "" %>"/>
                                    <input type="hidden" name="imagePartName"    value="<%= imgPart %>"/>
                                    <!-- Format toggle -->
                                    <% if (!readOnly) { %>
                                    <div style="display:flex;gap:6px;margin-bottom:8px">
                                        <button type="button" class="fmt-btn<%= "SIMPLE".equals(qFmt) ? " fmt-active" : "" %>"
                                                onclick="setQFormat(this,'SIMPLE')" style="flex:1;padding:4px 0;border-radius:6px;border:1px solid var(--border);background:<%= "SIMPLE".equals(qFmt) ? "var(--navy)" : "var(--surface)" %>;color:<%= "SIMPLE".equals(qFmt) ? "#fff" : "var(--ink2)" %>;font-size:11px;font-weight:600;cursor:pointer">Simple MCQ</button>
                                        <button type="button" class="fmt-btn<%= "COMPLEX".equals(qFmt) ? " fmt-active" : "" %>"
                                                onclick="setQFormat(this,'COMPLEX')" style="flex:1;padding:4px 0;border-radius:6px;border:1px solid var(--border);background:<%= "COMPLEX".equals(qFmt) ? "var(--navy)" : "var(--surface)" %>;color:<%= "COMPLEX".equals(qFmt) ? "#fff" : "var(--ink2)" %>;font-size:11px;font-weight:600;cursor:pointer">Complex MCQ (I-IV)</button>
                                    </div>
                                    <% } %>
                                    <!-- Statements box (shown only for COMPLEX) -->
                                    <div class="stmt-box" style="display:<%= "COMPLEX".equals(qFmt) ? "block" : "none" %>;background:var(--blue-soft);border:1px solid var(--blue-b);border-radius:8px;padding:10px;margin-bottom:8px">
                                        <label style="font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:6px;display:block">Statements</label>
                                        <% String[] romans2 = {"I","II","III","IV"};
                                           String[] stmtV = {
                                               q.getStatement1() != null ? q.getStatement1() : "",
                                               q.getStatement2() != null ? q.getStatement2() : "",
                                               q.getStatement3() != null ? q.getStatement3() : "",
                                               q.getStatement4() != null ? q.getStatement4() : ""
                                           };
                                           String[] stmtNames = {"statement1","statement2","statement3","statement4"};
                                           for (int si = 0; si < 4; si++) { %>
                                        <div style="display:flex;align-items:center;gap:6px;margin-bottom:5px">
                                            <span style="width:22px;font-weight:700;font-size:12px;color:var(--blue);flex-shrink:0"><%= romans2[si] %>.</span>
                                            <input type="text" name="<%= stmtNames[si] %>" value="<%= stmtV[si] %>"
                                                   placeholder="Statement <%= romans2[si] %>"
                                                   style="flex:1;padding:5px 8px;border:1px solid var(--blue-b);border-radius:5px;font-size:12px"
                                                   <%= readOnly ? "disabled" : "" %>/>
                                        </div>
                                        <% } %>
                                    </div>
                                    <!-- Media row: image upload + table HTML -->
                                    <% if (!readOnly) { %>
                                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:8px">
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>Image (optional)</label>
                                            <% if (q.getImageUrl() != null && !q.getImageUrl().isEmpty()) { %>
                                            <div style="margin-bottom:4px"><img src="<%= q.getImageUrl() %>" alt="Q image" style="max-height:60px;border-radius:4px;border:1px solid var(--border)"/></div>
                                            <% } %>
                                            <input type="file" name="<%= imgPart %>" accept="image/png,image/jpeg,image/gif,image/webp"
                                                   style="font-size:11px" onchange="this.nextElementSibling.style.display=this.files.length?'block':'none'"/>
                                            <div style="display:none;font-size:10px;color:var(--green);margin-top:2px">✓ New image selected</div>
                                        </div>
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>Table HTML (optional)</label>
                                            <textarea name="tableData" rows="2" placeholder="&lt;table&gt;...&lt;/table&gt;"
                                                      style="font-size:11px;font-family:monospace;width:100%;padding:5px;border:1px solid var(--border);border-radius:5px"><%= q.getTableData() != null ? q.getTableData() : "" %></textarea>
                                        </div>
                                    </div>
                                    <% } else if ((q.getImageUrl() != null && !q.getImageUrl().isEmpty()) || (q.getTableData() != null && !q.getTableData().trim().isEmpty())) { %>
                                    <div style="margin-bottom:8px">
                                        <% if (q.getImageUrl() != null && !q.getImageUrl().isEmpty()) { %>
                                        <img src="<%= q.getImageUrl() %>" alt="Question media" style="max-width:100%;border-radius:6px;margin-bottom:4px"/>
                                        <% } %>
                                        <% if (q.getTableData() != null && !q.getTableData().trim().isEmpty()) { %>
                                        <div style="overflow-x:auto"><%= q.getTableData() %></div>
                                        <% } %>
                                    </div>
                                    <% } %>
                                    <div class="field-group" style="margin-bottom:7px">
                                        <label>Question Text (English) *</label>
                                        <textarea name="questionText" rows="2" class="q-stem-en" data-section="A" oninput="onQInput(this)" <%= readOnly ? "disabled" : ""%> required><%= q.getQuestionText()%></textarea>
                                    </div>
                                    <div class="field-group" style="margin-bottom:7px">
                                        <label>Terjemahan (Bahasa Melayu)</label>
                                        <textarea name="questionTextMs" rows="1" class="q-stem-ms" data-section="A" oninput="onQInput(this)" <%= readOnly ? "disabled" : ""%> placeholder="(optional Malay translation)"><%= q.getQuestionTextMs() != null ? q.getQuestionTextMs() : ""%></textarea>
                                    </div>
                                    <div class="q-config-fields">
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>Chapter / Topic</label>
                                            <input type="text" name="chapter" value="<%= q.getChapter() != null ? q.getChapter() : ""%>" class="q-chapter" data-section="A" oninput="onQInput(this)" <%= readOnly ? "disabled" : ""%> placeholder="e.g. Chapter 3"/>
                                        </div>
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>Marks *</label>
                                            <input type="number" name="marks" value="<%= q.getMarks()%>" min="1" max="20" class="q-marks" data-section="A" onchange="updateMarks()" required <%= readOnly ? "disabled" : ""%>/>
                                        </div>
                                    </div>
                                    <div class="q-config-fields" style="margin-top:7px">
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>Bloom's Taxonomy</label>
                                            <select name="taxonomyLevel" class="q-bloom" data-section="A" onchange="onQInput(this)" <%= readOnly ? "disabled" : ""%>>
                                                <% for (String[] bl : new String[][]{{"C1", "C1 — Remember"}, {"C2", "C2 — Understand"}, {"C3", "C3 — Apply"}, {"C4", "C4 — Analyse"}, {"C5", "C5 — Evaluate"}, {"C6", "C6 — Create"}}) {%>
                                                <option value="<%= bl[0]%>" <%= bl[0].equals(q.getTaxonomyLevel() != null ? q.getTaxonomyLevel() : "C1") ? "selected" : ""%>><%= bl[1]%></option>
                                                <% }%>
                                            </select>
                                        </div>
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>CLO</label>
                                            <select name="cloMapping" class="q-clo" data-section="A" onchange="onQInput(this)" <%= readOnly ? "disabled" : ""%>>
                                                <% for (int ci = 1; ci <= 5; ci++) {%><option value="CLO<%= ci%>" <%= ("CLO" + ci).equals(q.getCloMapping() != null ? q.getCloMapping() : "CLO1") ? "selected" : ""%>>CLO <%= ci%></option><% } %>
                                            </select>
                                        </div>
                                    </div>
                                    <!-- MCQ Choices + Correct Answer -->
                                    <div style="margin-top:8px">
                                        <label style="font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:6px;display:block">Answer Choices <span style="color:var(--green);font-size:9px">(● Correct Answer)</span></label>
                                        <% String[] choiceLabels = {"A", "B", "C", "D"};
                                            String[] choiceVals = {
                                                q.getChoiceA() != null ? q.getChoiceA() : "",
                                                q.getChoiceB() != null ? q.getChoiceB() : "",
                                                q.getChoiceC() != null ? q.getChoiceC() : "",
                                                q.getChoiceD() != null ? q.getChoiceD() : ""
                                            };
                                            String savedCorrect = q.getCorrectAnswer() != null ? q.getCorrectAnswer() : "";
                                            for (int ci = 0; ci < choiceLabels.length; ci++) {
                      String cl = choiceLabels[ci];%>
                                        <div style="display:flex;align-items:center;gap:6px;margin-bottom:5px">
                                            <%-- Radio button to mark correct answer --%>
                                            <input type="radio" name="correctAnswer_<%= q.getQuestionId() %>" value="<%= cl%>"
                                                   <%= cl.equals(savedCorrect) ? "checked" : ""%>
                                                   style="width:14px;flex-shrink:0;accent-color:var(--green)"
                                                   title="Mark as correct answer" <%= readOnly ? "disabled" : ""%>/>
                                            <div style="width:18px;height:18px;border-radius:50%;background:var(--blue-soft);border:1px solid var(--blue-b);display:grid;place-items:center;font-size:9px;font-weight:800;color:var(--blue);flex-shrink:0"><%= cl%></div>
                                            <input type="text" name="choice<%= cl%>" class="choice-inp q-choice"
                                                   value="<%= choiceVals[ci]%>"
                                                   data-section="A" oninput="onQInput(this)"
                                                   placeholder="Option <%= cl%>" <%= readOnly ? "disabled" : ""%>/>
                                        </div>
                                        <% } %>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                            <% if (!readOnly) { %>
                            <button type="button" class="add-q-btn" onclick="addQ('A')">＋ Add Objective Question</button>
                            <% } %>
                        </div>

                        <!-- ── SECTION B: Structured ── -->
                        <div class="section-config">
                            <div class="sc-header">
                                <div class="sc-letter str">B</div>
                                <div class="sc-title">Section B(Structured)</div>
                                <div class="sc-marks" id="scB-marks">0 marks</div>
                            </div>
                            <div class="q-config-list" id="listB">
                                <% int qNumB = 1;
              for (Question q : secB) {%>
                                <div class="q-config-item">
                                    <div class="q-config-top">
                                        <span class="q-config-num">Q<%= qNumB++%></span>
                                        <% if (!readOnly) {%><button type="button" class="q-config-del" onclick="delQ('B', this, '<%= q.getQuestionId()%>')">✕</button><% }%>
                                    </div>
                                    <input type="hidden" name="questionId"   value="<%= q.getQuestionId()%>"/>
                                    <input type="hidden" name="questionType" value="STRUCTURE"/>
                                    <% String imgPart = "img_" + q.getQuestionId(); %>
                                    <input type="hidden" name="existingImageUrl" value="<%= q.getImageUrl() != null ? q.getImageUrl() : "" %>"/>
                                    <input type="hidden" name="imagePartName"    value="<%= imgPart %>"/>
<!-- Media row: image upload + table HTML -->
                                    <% if (!readOnly) { %>
                                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:8px">
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>Image (optional)</label>
                                            <% if (q.getImageUrl() != null && !q.getImageUrl().isEmpty()) { %>
                                            <div style="margin-bottom:4px"><img src="<%= q.getImageUrl() %>" alt="Q image" style="max-height:60px;border-radius:4px;border:1px solid var(--border)"/></div>
                                            <% } %>
                                            <input type="file" name="<%= imgPart %>" accept="image/png,image/jpeg,image/gif,image/webp"
                                                   style="font-size:11px" onchange="this.nextElementSibling.style.display=this.files.length?'block':'none'"/>
                                            <div style="display:none;font-size:10px;color:var(--green);margin-top:2px">✓ New image selected</div>
                                        </div>
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>Table HTML (optional)</label>
                                            <textarea name="tableData" rows="2" placeholder="&lt;table&gt;...&lt;/table&gt;"
                                                      style="font-size:11px;font-family:monospace;width:100%;padding:5px;border:1px solid var(--border);border-radius:5px"><%= q.getTableData() != null ? q.getTableData() : "" %></textarea>
                                        </div>
                                    </div>
                                    <% } else if ((q.getImageUrl() != null && !q.getImageUrl().isEmpty()) || (q.getTableData() != null && !q.getTableData().trim().isEmpty())) { %>
                                    <div style="margin-bottom:8px">
                                        <% if (q.getImageUrl() != null && !q.getImageUrl().isEmpty()) { %>
                                        <img src="<%= q.getImageUrl() %>" alt="Question media" style="max-width:100%;border-radius:6px;margin-bottom:4px"/>
                                        <% } %>
                                        <% if (q.getTableData() != null && !q.getTableData().trim().isEmpty()) { %>
                                        <div style="overflow-x:auto"><%= q.getTableData() %></div>
                                        <% } %>
                                    </div>
                                    <% } %>
                                    <div class="field-group" style="margin-bottom:7px">
                                        <label>Question Text *</label>
                                        <textarea name="questionText" rows="2" class="q-stem-en" data-section="B" oninput="onQInput(this)" <%= readOnly ? "disabled" : ""%> required><%= q.getQuestionText()%></textarea>
                                    </div>
                                    <div class="field-group" style="margin-bottom:7px">
                                        <label>Terjemahan BM</label>
                                        <textarea name="questionTextMs" rows="1" class="q-stem-ms" data-section="B" oninput="onQInput(this)" <%= readOnly ? "disabled" : ""%> placeholder="(optional)"></textarea>
                                    </div>
                                    <div class="q-config-fields">
                                        <div class="field-group" style="margin-bottom:0"><label>Chapter</label><input type="text" name="chapter" value="<%= q.getChapter() != null ? q.getChapter() : ""%>" class="q-chapter" <%= readOnly ? "disabled" : ""%>/></div>
                                        <div class="field-group" style="margin-bottom:0"><label>Marks *</label><input type="number" name="marks" value="<%= q.getMarks()%>" min="1" max="50" class="q-marks" data-section="B" onchange="updateMarks()" required <%= readOnly ? "disabled" : ""%>/></div>
                                    </div>
                                    <div class="q-config-fields" style="margin-top:7px">
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>Bloom's</label>
                                            <select name="taxonomyLevel" class="q-bloom" data-section="B" <%= readOnly ? "disabled" : ""%>>
                                                <% for (String[] bl : new String[][]{{"C1", "C1 — Remember"}, {"C2", "C2 — Understand"}, {"C3", "C3 — Apply"}, {"C4", "C4 — Analyse"}, {"C5", "C5 — Evaluate"}, {"C6", "C6 — Create"}}) {%>
                                                <option value="<%= bl[0]%>" <%= bl[0].equals(q.getTaxonomyLevel() != null ? q.getTaxonomyLevel() : "C1") ? "selected" : ""%>><%= bl[1]%></option>
                                                <% }%>
                                            </select>
                                        </div>
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>CLO</label>
                                            <select name="cloMapping" class="q-clo" data-section="B" <%= readOnly ? "disabled" : ""%>>
                                                <% for (int ci = 1; ci <= 5; ci++) {%><option value="CLO<%= ci%>" <%= ("CLO" + ci).equals(q.getCloMapping() != null ? q.getCloMapping() : "CLO1") ? "selected" : ""%>>CLO <%= ci%></option><% }%>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="field-group" style="margin-top:7px;margin-bottom:0">
                                        <label>Answer Lines (count)</label>
                                        <input type="number" name="answerLines" value="6" min="2" max="30" style="width:70px" class="q-lines" data-section="B" onchange="onQInput(this)" <%= readOnly ? "disabled" : ""%>/>
                                    </div>
                                    <div class="parts-container" style="margin-top:10px; border:1px solid var(--border); padding:10px; border-radius:5px; background:var(--cream)">
                                        <label style="font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;">Parts (Optional)</label>
                                        <div class="parts-list">
                                            <% if (q.getParts() != null) { 
                                                 for (Model.QuestionPart p : q.getParts()) { %>
                                            <div class="part-item" style="display:flex; gap:5px; margin-top:5px; align-items:center;">
                                                <input type="text" name="partLabel_<%= qNumB - 1 %>" value="<%= p.getPartLabel() %>" placeholder="e.g. (a)" style="width:50px" <%= readOnly ? "disabled" : "" %>/>
                                                <input type="text" name="partText_<%= qNumB - 1 %>" value="<%= p.getPartQuestionText() %>" placeholder="Part text" style="flex:1" <%= readOnly ? "disabled" : "" %>/>
                                                <input type="number" name="partMarks_<%= qNumB - 1 %>" value="<%= p.getPartMarks() %>" placeholder="Marks" style="width:60px" <%= readOnly ? "disabled" : "" %>/>
                                                <% if (!readOnly) { %><button type="button" onclick="this.parentElement.remove()" style="color:red;border:none;background:none;cursor:pointer">✕</button><% } %>
                                            </div>
                                            <%   } 
                                               } %>
                                        </div>
                                        <% if (!readOnly) { %>
                                        <button type="button" class="btn btn-ghost btn-sm" style="margin-top:5px" onclick="addPartToQ(this, <%= qNumB - 1 %>)">+ Add Part</button>
                                        <% } %>
                                    </div>
                                </div>

                                <% } %>
                            </div>
                            <% if (!readOnly) { %>
                            <button type="button" class="add-q-btn" onclick="addQ('B')">＋ Add Structured Question</button>
                            <% } %>
                        </div>

                        <!-- ── SECTION C: Essay ── -->
                        <div class="section-config">
                            <div class="sc-header">
                                <div class="sc-letter ess">C</div>
                                <div class="sc-title">Section C(Essay)</div>
                                <div class="sc-marks" id="scC-marks">0 marks</div>
                            </div>
                            <div class="q-config-list" id="listC">
                                <% int qNumC = 1;
              for (Question q : secC) {%>
                                <div class="q-config-item">
                                    <div class="q-config-top">
                                        <span class="q-config-num">Q<%= qNumC++%></span>
                                        <% if (!readOnly) {%><button type="button" class="q-config-del" onclick="delQ('C', this, '<%= q.getQuestionId()%>')">✕</button><% }%>
                                    </div>
                                    <input type="hidden" name="questionId"   value="<%= q.getQuestionId()%>"/>
                                    <input type="hidden" name="questionType" value="ESSAY"/>
                                    <% String imgPart = "img_" + q.getQuestionId(); %>
                                    <input type="hidden" name="existingImageUrl" value="<%= q.getImageUrl() != null ? q.getImageUrl() : "" %>"/>
                                    <input type="hidden" name="imagePartName"    value="<%= imgPart %>"/>
<!-- Media row: image upload + table HTML -->
                                    <% if (!readOnly) { %>
                                    <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:8px">
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>Image (optional)</label>
                                            <% if (q.getImageUrl() != null && !q.getImageUrl().isEmpty()) { %>
                                            <div style="margin-bottom:4px"><img src="<%= q.getImageUrl() %>" alt="Q image" style="max-height:60px;border-radius:4px;border:1px solid var(--border)"/></div>
                                            <% } %>
                                            <input type="file" name="<%= imgPart %>" accept="image/png,image/jpeg,image/gif,image/webp"
                                                   style="font-size:11px" onchange="this.nextElementSibling.style.display=this.files.length?'block':'none'"/>
                                            <div style="display:none;font-size:10px;color:var(--green);margin-top:2px">✓ New image selected</div>
                                        </div>
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>Table HTML (optional)</label>
                                            <textarea name="tableData" rows="2" placeholder="&lt;table&gt;...&lt;/table&gt;"
                                                      style="font-size:11px;font-family:monospace;width:100%;padding:5px;border:1px solid var(--border);border-radius:5px"><%= q.getTableData() != null ? q.getTableData() : "" %></textarea>
                                        </div>
                                    </div>
                                    <% } else if ((q.getImageUrl() != null && !q.getImageUrl().isEmpty()) || (q.getTableData() != null && !q.getTableData().trim().isEmpty())) { %>
                                    <div style="margin-bottom:8px">
                                        <% if (q.getImageUrl() != null && !q.getImageUrl().isEmpty()) { %>
                                        <img src="<%= q.getImageUrl() %>" alt="Question media" style="max-width:100%;border-radius:6px;margin-bottom:4px"/>
                                        <% } %>
                                        <% if (q.getTableData() != null && !q.getTableData().trim().isEmpty()) { %>
                                        <div style="overflow-x:auto"><%= q.getTableData() %></div>
                                        <% } %>
                                    </div>
                                    <% } %>
                                    <div class="field-group" style="margin-bottom:7px">
                                        <label>Question Text *</label>
                                        <textarea name="questionText" rows="3" class="q-stem-en" data-section="C" oninput="onQInput(this)" <%= readOnly ? "disabled" : ""%> required><%= q.getQuestionText()%></textarea>
                                    </div>
                                    <div class="field-group" style="margin-bottom:7px">
                                        <label>Terjemahan BM</label>
                                        <textarea name="questionTextMs" rows="1" class="q-stem-ms" data-section="C" oninput="onQInput(this)" <%= readOnly ? "disabled" : ""%> placeholder="(optional)"></textarea>
                                    </div>
                                    <div class="q-config-fields">
                                        <div class="field-group" style="margin-bottom:0"><label>Chapter</label><input type="text" name="chapter" value="<%= q.getChapter() != null ? q.getChapter() : ""%>" <%= readOnly ? "disabled" : ""%>/></div>
                                        <div class="field-group" style="margin-bottom:0"><label>Marks *</label><input type="number" name="marks" value="<%= q.getMarks()%>" min="1" max="50" class="q-marks" data-section="C" onchange="updateMarks()" required <%= readOnly ? "disabled" : ""%>/></div>
                                    </div>
                                    <div class="q-config-fields" style="margin-top:7px">
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>Bloom's</label>
                                            <select name="taxonomyLevel" class="q-bloom" data-section="C" <%= readOnly ? "disabled" : ""%>>
                                                <% for (String[] bl : new String[][]{{"C1", "C1 — Remember"}, {"C2", "C2 — Understand"}, {"C3", "C3 — Apply"}, {"C4", "C4 — Analyse"}, {"C5", "C5 — Evaluate"}, {"C6", "C6 — Create"}}) {%>
                                                <option value="<%= bl[0]%>" <%= bl[0].equals(q.getTaxonomyLevel() != null ? q.getTaxonomyLevel() : "C1") ? "selected" : ""%>><%= bl[1]%></option>
                                                <% }%>
                                            </select>
                                        </div>
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>CLO</label>
                                            <select name="cloMapping" class="q-clo" data-section="C" <%= readOnly ? "disabled" : ""%>>
                                                <% for (int ci = 1; ci <= 5; ci++) {%><option value="CLO<%= ci%>" <%= ("CLO" + ci).equals(q.getCloMapping() != null ? q.getCloMapping() : "CLO1") ? "selected" : ""%>>CLO <%= ci%></option><% }%>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="q-config-fields" style="margin-top:7px">
                                        <div class="field-group" style="margin-bottom:0">
                                            <label>Answer Lines</label>
                                            <input type="number" name="answerLines" value="12" min="4" max="40" style="width:70px"
                                                   class="q-lines" data-section="C" onchange="onQInput(this)" <%= readOnly ? "disabled" : ""%>/>
                                        </div>
                                    </div>
                                    <div class="parts-container" style="margin-top:10px; border:1px solid var(--border); padding:10px; border-radius:5px; background:var(--cream)">
                                        <label style="font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;">Parts (Optional)</label>
                                        <div class="parts-list">
                                            <% if (q.getParts() != null) { 
                                                 for (Model.QuestionPart p : q.getParts()) { %>
                                            <div class="part-item" style="display:flex; gap:5px; margin-top:5px; align-items:center;">
                                                <input type="text" name="partLabel_<%= qNumC - 1 + secB.size() + secA.size() %>" value="<%= p.getPartLabel() %>" placeholder="e.g. (a)" style="width:50px" <%= readOnly ? "disabled" : "" %>/>
                                                <input type="text" name="partText_<%= qNumC - 1 + secB.size() + secA.size() %>" value="<%= p.getPartQuestionText() %>" placeholder="Part text" style="flex:1" <%= readOnly ? "disabled" : "" %>/>
                                                <input type="number" name="partMarks_<%= qNumC - 1 + secB.size() + secA.size() %>" value="<%= p.getPartMarks() %>" placeholder="Marks" style="width:60px" <%= readOnly ? "disabled" : "" %>/>
                                                <% if (!readOnly) { %><button type="button" onclick="this.parentElement.remove()" style="color:red;border:none;background:none;cursor:pointer">✕</button><% } %>
                                            </div>
                                            <%   } 
                                               } %>
                                        </div>
                                        <% if (!readOnly) { %>
                                        <button type="button" class="btn btn-ghost btn-sm" style="margin-top:5px" onclick="addPartToQ(this, <%= qNumC - 1 + secB.size() + secA.size() %>)">+ Add Part</button>
                                        <% } %>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                            <% if (!readOnly) { %>
                            <button type="button" class="add-q-btn" onclick="addQ('C')">＋ Add Essay Question</button>
                            <% } %>
                        </div>


                    </form><!-- end form -->

                </div><!-- end setup-scroll -->

                <!-- Footer action buttons -->
                <% if (!readOnly) {
                   boolean _isNI = paper != null && "NEEDS_IMPROVEMENT".equals(paper.getStatus());
                %>
                <div class="setup-footer">
                    <button type="button" class="btn btn-navy" onclick="submitForm('saveDraft')" style="flex:1">Save Draft</button>
                    <% if (_isNI) { %>
                    <button type="button" class="btn btn-gold" onclick="submitForm('resubmit')" style="flex:1">Resubmit to Vetter</button>
                    <% } else { %>
                    <button type="button" class="btn btn-gold" onclick="submitForm('submit')" style="flex:1">Submit</button>
                    <% } %>
                    <% if (paper != null && paper.getPaperId() > 0) {%>
                    <a href="<%= ctx%>/SchemaServlet?paperId=<%= paper.getPaperId()%>" target="_blank"
                       class="btn btn-sm" style="background:#7c3aed;color:#fff;padding:8px 10px;font-size:11px;" title="View Schema">Schema</a>
                    <% }%>
                    <a href="<%= ctx%>/LecturerDashboardServlet?page=assessments" class="btn btn-ghost">✕</a>
                </div>
                <% }%>
            </div>

            <!-- ═══════════════════════════════════
                 RIGHT: PAPER PREVIEW
            ════════════════════════════════════ -->
            <div class="preview-panel">
                <div class="preview-header">
                    <span>Paper Preview</span>
                    <span style="display:flex;align-items:center;gap:8px">
                      <span id="previewTotalMarks" style="font-size:13px;font-family:'JetBrains Mono',monospace;color:var(--amber)">0 / 100 marks</span>
                      <button onclick="printPaper()" title="Print or Save as PDF"
                        style="background:#2563eb;color:#fff;border:none;border-radius:6px;
                               padding:5px 12px;font-size:11px;font-weight:700;
                               font-family:Sora,sans-serif;cursor:pointer;display:flex;
                               align-items:center;gap:4px;transition:.15s"
                        onmouseover="this.style.background='#1d4ed8'"
                        onmouseout="this.style.background='#2563eb'">
                        &#128424; Print / PDF
                      </button>
                    </span>
                </div>
                <div class="preview-scroll" id="previewScroll">

                    <!-- ── PAGE 1: COVER ── -->
                    <div class="paper-page" id="page-cover">
                        <div class="page-running-header">
                            <span class="course-code-hdr" id="ph-code"><%= pCode.isEmpty() ? "COURSE CODE" : pCode%></span>
                            <div class="page-confidential"><b>CONFIDENTIAL</b><i>SULIT</i></div>
                        </div>

                        <div style="margin-top:40px">
                            <!-- UMT Logo placeholder -->
                            <div class="skema-logo-row">
                                <img src="<%= ctx%>/images/umt-logo.png" alt="UMT"
                                     onerror="this.style.display='none';document.getElementById('logoFallback').style.display='flex'"/>

                                <div id="logoFallback" class="skema-logo-placeholder" style="display:none">
                                    UMT
                                </div>
                            </div>
                            <div class="cover-uni">UNIVERSITI MALAYSIA TERENGGANU</div>

                            <div class="cover-exam-type" style="margin-bottom:10px">
                                <b>FINAL EXAMINATION</b>
                                <i>PEPERIKSAAN AKHIR</i>
                            </div>

                            <div class="cover-session" style="margin-bottom:20px">
                                <b id="cv-session">SEMESTER 1 SESSION (DEGREE PROGRAMME)</b>
                                <i id="cv-session-ms">SEMESTER I SESI (SARJANA MUDA)</i>
                            </div>

                            <!-- Course info table -->
                            <table class="info-table">
                                <tr>
                                    <td><span class="label-en">COURSE</span><span class="label-ms">KURSUS</span></td>
                                    <td>:</td>
                                    <td><span class="val-en" id="cv-course"><%= pTitle.isEmpty() ? "COURSE NAME" : pTitle.toUpperCase()%></span><span class="val-ms" id="cv-course-ms" style="font-style:italic;font-size:10pt"><%= pTitle.isEmpty() ? "NAMA KURSUS" : pTitle%></span></td>
                                </tr>
                                <tr>
                                    <td><span class="label-en">COURSE CODE</span><span class="label-ms">KOD KURSUS</span></td>
                                    <td>:</td>
                                    <td><span class="val-en" id="cv-code"><%= pCode.isEmpty() ? "—" : pCode%></span></td>
                                </tr>
                                <tr>
                                    <td><span class="label-en">DATE</span><span class="label-ms">TARIKH</span></td>
                                    <td>:</td>
                                    <td><span class="val-en">_______________________</span></td>
                                </tr>
                                <tr>
                                    <td><span class="label-en">VENUE</span><span class="label-ms">TEMPAT</span></td>
                                    <td>:</td>
                                    <td><span class="val-en">_______________________</span></td>
                                </tr>
                                <tr>
                                    <td><span class="label-en">TIME</span><span class="label-ms">MASA</span></td>
                                    <td>:</td>
                                    <td><span class="val-en" id="cv-time">_____ AM/PM — _____ AM/PM (<span id="cv-dur">2</span> HOURS)</span><span class="val-ms" style="font-style:italic;font-size:10pt">___ PAGI/PETANG — ___ PAGI/PETANG (<span class="cv-dur">2</span> JAM)</span></td>
                                </tr>
                            </table>

                            <!-- Student info table -->
                            <table class="student-table">
                                <tr><td><span class="label-en">MATRIC NO.</span><span class="label-ms">NO. MATRIK</span></td><td>: <span class="student-fill"></span></td></tr>
                                <tr><td><span class="label-en">PROGRAMME</span><span class="label-ms">NAMA PROGRAM</span></td><td>: <span class="student-fill"></span></td></tr>
                                <tr><td><span class="label-en">SEAT NO.</span><span class="label-ms">NO. MEJA</span></td><td>: <span class="student-fill"></span></td></tr>
                            </table>

                            <!-- Instructions -->
                            <div class="instructions">
                                <h3>INSTRUCTIONS TO CANDIDATES<br/><i>ARAHAN KEPADA CALON</i></h3>
                                <ol id="cv-instructions">
                                    <li>Answer all questions.<br/><i>Sila jawab semua soalan.</i></li>
                                    <li>All answers must be written in the answer booklet provided.<br/><i>Semua jawapan hendaklah ditulis dalam buku jawapan yang disediakan.</i></li>
                                </ol>
                            </div>

                            <div class="cover-warning">
                                <b>DO NOT OPEN THE QUESTION PAPER UNTIL INSTRUCTED</b>
                                <i>JANGAN BUKA KERTAS SOALAN INI SEHINGGA DIBERITAHU</i>
                            </div>
                            <div class="cover-pages" id="cv-pages">
                                THIS QUESTION PAPER CONSISTS OF <b id="totalPagesCount">—</b> PRINTED PAGES<br/>
                                <i>KERTAS SOALAN INI MENGANDUNGI <b id="totalPagesCountMs">—</b> MUKA SURAT BERCETAK</i>
                            </div>
                        </div>
                        <div class="page-num">1</div>
                    </div>

                    <!-- ── PAGE 2: QUESTIONS ── -->
                    <div class="paper-page" id="page-questions">
                        <div class="page-running-header">
                            <span class="course-code-hdr" id="ph-code2"><%= pCode.isEmpty() ? "COURSE CODE" : pCode%></span>
                            <div class="page-confidential"><b>CONFIDENTIAL</b><i>SULIT</i></div>
                        </div>
                        <div style="margin-top:40px" id="questionsPreview">
                            <!-- Questions rendered by JS -->
                            <div style="text-align:center;color:#999;font-family:'Crimson Pro',serif;font-size:13pt;margin-top:60px">
                                Add questions on the left to see them here.
                            </div>
                        </div>
                        <div class="page-num" id="lastPageNum">2</div>
                    </div>

                </div><!-- end preview-scroll -->
            </div>

        </div><!-- end workspace -->

        <!-- Hidden delete form -->
        <form method="post" action="<%= ctx%>/NewPaperServlet" id="deleteForm" style="display:none">
            <input type="hidden" name="action"     value="deleteQuestion"/>
            <input type="hidden" name="paperId"    id="dfPaperId" value="<%= paperId%>"/>
            <input type="hidden" name="questionId" id="dfQuestionId"/>
        </form>

        <script>
    const CTX = '<%= ctx%>';
    const PAPER_ID = <%= paperId%>;
    const READONLY = <%= readOnly%>;
    let rowCtr = 9000;
    const BLOOMS_LABEL = {C1: 'C1 — Remember', C2: 'C2 — Understand', C3: 'C3 — Apply', C4: 'C4 — Analyse', C5: 'C5 — Evaluate', C6: 'C6 — Create'};

    /* ── Course dropdown auto-fill ── */
    function onCourseChange(sel) {
        const opt = sel.options[sel.selectedIndex];
        document.getElementById('courseTitleInp').value = opt.dataset.title || '';
        document.getElementById('durationInp').value = opt.dataset.hours ? opt.dataset.hours : '2';
        /* Also update cover duration display immediately */
        var cvDurEl2 = document.getElementById('cv-dur');
        if (cvDurEl2)
            cvDurEl2.textContent = (opt.dataset.hours || '2') + ' Hour(s)';
        updatePreview();
    }

    /* ── Add new question row ── */
    function addQ(section) {
        var list = document.getElementById('list' + section);
        if (!list) {
            alert('Error: list' + section + ' not found. Please refresh the page.');
            return;
        }
        var count = list.querySelectorAll('.q-config-item').length + 1;
        const id = 'new' + rowCtr++;
        const rowTs = id; /* unique key for radio group and file input names */
        const isObj = section === 'A';
        const isStr = section === 'B';

        const bloomOpts = Object.entries(BLOOMS_LABEL).map(function (e) {
            return '<option value="' + e[0] + '">' + e[1] + '</option>';
        }).join('');
        const cloOpts = [1, 2, 3, 4, 5].map(n => '<option value="CLO' + n + '">CLO ' + n + '</option>').join('');

        // Build MCQ choices using string concat (avoids nested template literal issues)
        var choicesHtml = '';
        if (isObj) {
            choicesHtml = '<div style="margin-top:8px">';
            choicesHtml += '<label style="font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:6px;display:block">';
            choicesHtml += 'Answer Choices <span style="color:var(--green);font-size:9px">( ● = Correct Answer)</span></label>';
            ['A', 'B', 'C', 'D'].forEach(function (l) {
                choicesHtml += '<div style="display:flex;align-items:center;gap:6px;margin-bottom:5px">';
                choicesHtml += '<input type="radio" name="correctAnswer_new_' + rowTs + '" value="' + l + '" style="width:14px;flex-shrink:0;accent-color:var(--green)" title="Mark as correct answer"/>';
                choicesHtml += '<div style="width:18px;height:18px;border-radius:50%;background:var(--blue-soft);border:1px solid var(--blue-b);display:grid;place-items:center;font-size:9px;font-weight:800;color:var(--blue);flex-shrink:0">' + l + '</div>';
                choicesHtml += '<input type="text" name="choice' + l + '" class="choice-inp q-choice" placeholder="Option ' + l + '" oninput="onQInput(this)"/>';
                choicesHtml += '</div>';
            });
            choicesHtml += '</div>';
        }

        // Answer lines for structured questions (also avoid template literals)
        var ansLinesHtml = '';
        if (isStr) {
            ansLinesHtml = '<div class="field-group" style="margin-top:7px;margin-bottom:0">';
            ansLinesHtml += '<label>Answer Lines</label>';
            ansLinesHtml += '<input type="number" name="answerLines" value="6" min="2" max="30" style="width:70px" class="q-lines" data-section="' + section + '" onchange="onQInput(this)"/>';
            ansLinesHtml += '</div>';
        }

        // Build HTML using string concatenation — no template literals (JSP conflict)
        var qType = section === 'A' ? 'OBJECTIVE' : section === 'B' ? 'STRUCTURE' : 'ESSAY';
        var html = '';
        html += '<div class="q-config-item" id="qi-' + id + '">';
        html += '<div class="q-config-top">';
        html += '<span class="q-config-num">Q' + count + '</span>';
        html += '<button type="button" class="q-config-del" onclick="delQ(\'' + section + '\',this,\'' + id + '\')">✕</button>';
        html += '</div>';
        html += '<input type="hidden" name="questionId" value=""/>';
        /* Store the radio group key alongside so servlet can find the right answer */
        html += '<input type="hidden" name="correctAnswerKey" value="correctAnswer_new_' + rowTs + '"/>';
        html += '<input type="hidden" name="questionType" value="' + qType + '"/>';
        html += '<input type="hidden" name="existingImageUrl" value=""/>';
        html += '<input type="hidden" name="imagePartName" value="img_new_' + rowTs + '"/>';
        /* Format toggle + complex fields — only for Section A */
        if (isObj) {
            html += '<input type="hidden" name="questionFormat" class="q-format-input" value="SIMPLE"/>';
            html += '<div style="display:flex;gap:6px;margin-bottom:8px">';
            html += '<button type="button" class="fmt-btn fmt-active" onclick="setQFormat(this,\'SIMPLE\')" style="flex:1;padding:4px 0;border-radius:6px;border:1px solid var(--border);background:var(--navy);color:#fff;font-size:11px;font-weight:600;cursor:pointer">Simple MCQ</button>';
            html += '<button type="button" class="fmt-btn" onclick="setQFormat(this,\'COMPLEX\')" style="flex:1;padding:4px 0;border-radius:6px;border:1px solid var(--border);background:var(--surface);color:var(--ink2);font-size:11px;font-weight:600;cursor:pointer">Complex MCQ (I-IV)</button>';
            html += '</div>';
            /* Statements box (hidden until COMPLEX selected) */
            html += '<div class="stmt-box" style="display:none;background:var(--blue-soft);border:1px solid var(--blue-b);border-radius:8px;padding:10px;margin-bottom:8px">';
            html += '<label style="font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:6px;display:block">Statements</label>';
            ['I','II','III','IV'].forEach(function(r, si) {
                var sName = ['statement1','statement2','statement3','statement4'][si];
                html += '<div style="display:flex;align-items:center;gap:6px;margin-bottom:5px">';
                html += '<span style="width:22px;font-weight:700;font-size:12px;color:var(--blue);flex-shrink:0">' + r + '.</span>';
                html += '<input type="text" name="' + sName + '" placeholder="Statement ' + r + '" style="flex:1;padding:5px 8px;border:1px solid var(--blue-b);border-radius:5px;font-size:12px"/>';
                html += '</div>';
            });
            html += '</div>';
        } else {
            /* Non-objective sections still need these hidden fields for array alignment */
            html += '<input type="hidden" name="questionFormat" value="SIMPLE"/>';
            html += '<input type="hidden" name="statement1" value=""/>';
            html += '<input type="hidden" name="statement2" value=""/>';
            html += '<input type="hidden" name="statement3" value=""/>';
            html += '<input type="hidden" name="statement4" value=""/>';
        }
        /* Media row */
        html += '<div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:8px">';
        html += '<div class="field-group" style="margin-bottom:0"><label>Image (optional)</label>';
        html += '<input type="file" name="img_new_' + rowTs + '" accept="image/png,image/jpeg,image/gif,image/webp" style="font-size:11px"/></div>';
        html += '<div class="field-group" style="margin-bottom:0"><label>Table HTML (optional)</label>';
        html += '<textarea name="tableData" rows="2" placeholder="&lt;table&gt;...&lt;/table&gt;" style="font-size:11px;font-family:monospace;width:100%;padding:5px;border:1px solid var(--border);border-radius:5px"></textarea></div>';
        html += '</div>';
        html += '<div class="field-group" style="margin-bottom:7px">';
        html += '<label>Question Text (English) *</label>';
        html += '<textarea name="questionText" rows="2" class="q-stem-en" data-section="' + section + '" oninput="onQInput(this)" required placeholder="Type question here…"></textarea>';
        html += '</div>';
        html += '<div class="field-group" style="margin-bottom:7px">';
        html += '<label>Terjemahan BM</label>';
        html += '<textarea name="questionTextMs" rows="1" class="q-stem-ms" data-section="' + section + '" oninput="onQInput(this)" placeholder="(optional Malay translation)"></textarea>';
        html += '</div>';
        html += '<div class="q-config-fields">';
        html += '<div class="field-group" style="margin-bottom:0"><label>Chapter / Topic</label><input type="text" name="chapter" class="q-chapter" placeholder="e.g. Chapter 3"/></div>';
        html += '<div class="field-group" style="margin-bottom:0"><label>Marks *</label><input type="number" name="marks" value="2" min="1" max="50" class="q-marks" data-section="' + section + '" onchange="updateMarks()" required/></div>';
        html += '</div>';
        html += '<div class="q-config-fields" style="margin-top:7px">';
        html += '<div class="field-group" style="margin-bottom:0"><label>Bloom\'s</label>';
        html += '<select name="taxonomyLevel" class="q-bloom" data-section="' + section + '" onchange="onQInput(this)">' + bloomOpts + '</select>';
        html += '</div>';
        html += '<div class="field-group" style="margin-bottom:0"><label>CLO</label>';
        html += '<select name="cloMapping" class="q-clo" data-section="' + section + '" onchange="onQInput(this)">' + cloOpts + '</select>';
        html += '</div>';
        html += '</div>';
        html += choicesHtml;
        html += ansLinesHtml;
        html += '<div class="parts-container" style="margin-top:10px; border:1px solid var(--border); padding:10px; border-radius:5px; background:var(--cream); display:' + (isObj ? 'none' : 'block') + '">';
        html += '<label style="font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;">Parts (Optional)</label>';
        html += '<div class="parts-list"></div>';
        html += '<button type="button" class="btn btn-ghost btn-sm" style="margin-top:5px" onclick="addPartToQ(this, ' + (rowCtr - 1) + ')">+ Add Part</button>';
        html += '</div>';

        html += '</div>';

        list.insertAdjacentHTML('beforeend', html);
        updateMarks();
        rebuildPreview();
    }

    /* ── Toggle Simple/Complex MCQ format ── */
    function setQFormat(btn, fmt) {
        var card = btn.closest('.q-config-item');
        if (!card) return;
        /* Update hidden input */
        var inp = card.querySelector('.q-format-input');
        if (inp) inp.value = fmt;
        /* Toggle button styles */
        card.querySelectorAll('.fmt-btn').forEach(function(b) {
            var isMine = b.textContent.indexOf(fmt === 'SIMPLE' ? 'Simple' : 'Complex') >= 0;
            b.style.background = isMine ? 'var(--navy)' : 'var(--surface)';
            b.style.color      = isMine ? '#fff' : 'var(--ink2)';
        });
        /* Show/hide statements box */
        var stmtBox = card.querySelector('.stmt-box');
        if (stmtBox) stmtBox.style.display = fmt === 'COMPLEX' ? 'block' : 'none';
    }

    /* ── Delete question row ── */
    function delQ(section, btn, qId) {
        const item = btn.closest('.q-config-item');
        // If it's a saved Q (numeric id), submit delete form
        if (qId && !qId.startsWith('new') && PAPER_ID > 0) {
            if (!confirm('Delete this question?'))
                return;
            document.getElementById('dfQuestionId').value = qId;
            document.getElementById('deleteForm').submit();
            return;
        }
        item.remove();
        renumberSection(section);
        updateMarks();
        rebuildPreview();
    }

    function renumberSection(sec) {
        let n = 1;
        document.querySelectorAll('#list' + sec + ' .q-config-num').forEach(el => el.textContent = 'Q' + n++);
    }

    function addPartToQ(btn, index) {
        var list = btn.previousElementSibling;
        var html = '<div class="part-item" style="display:flex; gap:5px; margin-top:5px; align-items:center;">';
        html += '<input type="text" name="partLabel_' + index + '" placeholder="e.g. (a)" style="width:50px" />';
        html += '<input type="text" name="partText_' + index + '" placeholder="Part text" style="flex:1" />';
        html += '<input type="number" name="partMarks_' + index + '" placeholder="Marks" style="width:60px" />';
        html += '<button type="button" onclick="this.parentElement.remove()" style="color:red;border:none;background:none;cursor:pointer">✕</button>';
        html += '</div>';
        list.insertAdjacentHTML('beforeend', html);
    }

    /* ── Marks calculation ── */
    function sectionMarks(sec) {
        let sum = 0;
        document.querySelectorAll('#list' + sec + ' .q-marks').forEach(el => sum += parseInt(el.value) || 0);
        return sum;
    }
    function updateMarks() {
        const a = sectionMarks('A'), b = sectionMarks('B'), c = sectionMarks('C');
        const total = a + b + c;
        const pct = Math.min(100, total);
        const isOk = total === 100;
        const isOver = total > 100;
        const barCol = isOk ? '#15803d' : isOver ? '#be123c' : '#f0a500';

        // Update fraction display
        document.getElementById('totalMarksDisplay').textContent = total;
        document.getElementById('mA').textContent = a;
        document.getElementById('mB').textContent = b;
        document.getElementById('mC').textContent = c;

        // Update progress bar
        document.getElementById('mmBar').style.width = pct + '%';
        document.getElementById('mmBar').style.background = barCol;

        // Update status message
        const statusEl = document.getElementById('mmStatus');
        if (isOk) {
            statusEl.textContent = ' Total is 100 ready to submit!';
        } else if (isOver) {
            statusEl.textContent = `⚠️ Over by ${total - 100} marks — reduce before submitting`;
        } else {
            statusEl.textContent = `${100 - total} marks remaining to reach 100`;
        }

        // Swap meter CSS class to change background/border colour
        const meter = document.getElementById('marksMeter');
        meter.classList.remove('state-ok', 'state-over');
        if (isOk)
            meter.classList.add('state-ok');
        if (isOver)
            meter.classList.add('state-over');

        // Update section mark labels
        document.getElementById('scA-marks').textContent = a + ' marks';
        document.getElementById('scB-marks').textContent = b + ' marks';
        document.getElementById('scC-marks').textContent = c + ' marks';

        // Also update the preview header running total
        const previewTotal = document.getElementById('previewTotalMarks');
        if (previewTotal) {
            previewTotal.textContent = `${total} / 100 marks`;
            previewTotal.style.color = isOk ? '#15803d' : isOver ? '#be123c' : '#b45309';
            previewTotal.style.fontWeight = '800';
        }

        rebuildPreview();
    }

    /* ── Live preview rebuild ── */
    function onQInput(el) {
        rebuildPreview();
    }

    function updatePreview() {
        // Cover page fields
        const code = document.getElementById('courseCodeSel')?.options[document.getElementById('courseCodeSel').selectedIndex]?.value || '';
                const title = document.getElementById('courseTitleInp')?.value || '';
                const sess = document.getElementById('sessionInp')?.value || '';
                const sem = document.getElementById('semSel')?.value || '';
                const dur = document.getElementById('durationInp')?.value || '2';

        // Update running header
        document.querySelectorAll('.course-code-hdr').forEach(el => el.textContent = code || 'COURSE CODE');
        // Cover course
        const cvCourse = document.getElementById('cv-course');
        if (cvCourse)
            cvCourse.textContent = title ? title.toUpperCase() : 'COURSE NAME';
        var cvCourseMs = document.getElementById('cv-course-ms');
        if (cvCourseMs)
            cvCourseMs.textContent = title || 'NAMA KURSUS';
        const cvCode = document.getElementById('cv-code');
        if (cvCode)
            cvCode.textContent = code || '—';
        const cvSession = document.getElementById('cv-session');
        if (cvSession && sess)
            cvSession.textContent = `SEMESTER ${sem} ${sess} SESSION (DEGREE PROGRAMME)`;
        const cvSessionMs = document.getElementById('cv-session-ms');
        if (cvSessionMs && sess)
            cvSessionMs.textContent = `SEMESTER ${sem} SESI ${sess} (SARJANA MUDA)`;
        const cvDur = document.querySelectorAll('#cv-time .cv-dur, #cv-time span');
        var cvDurEl = document.getElementById('cv-dur');
        if (cvDurEl)
            cvDurEl.textContent = dur ? dur + ' Hour(s)' : '2 Hour(s)';
        rebuildPreview();
    }

    function getCourseCodeDisplay() {
        var sel = document.getElementById('courseCodeSel');
        if (!sel || !sel.value)
            return 'COURSE CODE';
        var opt = sel.options[sel.selectedIndex];
        if (!opt)
            return 'COURSE CODE';
        return opt.text.split(' ')[0] || 'COURSE CODE';
    }

    function makePageDiv(pageNum, content) {
        var code = getCourseCodeDisplay();
        return '<div class="paper-page">'
                + '<div class="page-running-header">'
                + '<span class="course-code-hdr">' + code + '</span>'
                + '<div class="page-confidential"><b>CONFIDENTIAL</b><i>SULIT</i></div>'
                + '</div>'
                + '<div style="margin-top:40px">' + content + '</div>'
                + '<div class="page-num">' + pageNum + '</div>'
                + '</div>';
    }

    function rebuildPreview() {
        var scroll = document.getElementById('previewScroll');
        if (!scroll)
            return;

        /* Hide the static placeholder page immediately — generated pages replace it */
        var pageQ = document.getElementById('page-questions');
        if (pageQ)
            pageQ.style.display = 'none';

        /* Remove previously generated question pages (keep cover = page-cover) */
        var old = scroll.querySelectorAll('.paper-page:not(#page-cover):not(#page-questions)');
        old.forEach(function (el) {
            el.parentNode.removeChild(el);
        });

        var totalQs = 0;
        var pageNum = 2;
        var hasAny = false;

        // ── Section A: Objective ────────────────────────────────────────────────
        var rowsA = document.querySelectorAll('#listA .q-config-item');
        if (rowsA.length > 0) {
            var marksA = sectionMarks('A');
            var html = '';
            html += '<div class="paper-section-header">';
            html += '<div class="part-title">PART A / <i>BAHAGIAN A</i> (' + marksA + ' Marks / ' + marksA + ' Markah)</div>';
            html += '<div class="part-instruction">Please choose the most appropriate answer for each question in this part.<br/>';
            html += '<i>Sila pilih jawapan yang paling tepat bagi setiap soalan dalam bahagian ini.</i></div>';
            html += '</div>';
            var qNumA = 1;
            rowsA.forEach(function (row) {
                var text = row.querySelector('.q-stem-en') ? row.querySelector('.q-stem-en').value : '[Question text]';
                var textMs = row.querySelector('.q-stem-ms') ? row.querySelector('.q-stem-ms').value : '';
                var marks = parseInt(row.querySelector('.q-marks') ? row.querySelector('.q-marks').value : 0) || 0;
                var bloom = row.querySelector('.q-bloom') ? row.querySelector('.q-bloom').value : '';
                var clo = row.querySelector('.q-clo') ? row.querySelector('.q-clo').value : '';
                var choices = row.querySelectorAll('.q-choice');

                html += '<div class="paper-question">';
                html += '<div class="pq-stem">';
                html += '<span class="pq-num">' + qNumA + '.</span>';
                html += '<div class="pq-text">' + renderQuestionText(text);
                if (textMs)
                    html += '<span class="pq-text-ms">' + escHtml(textMs) + '</span>';
                html += '</div></div>';

                if (choices.length >= 4) {
                    html += '<div class="pq-options">';
                    ['A', 'B', 'C', 'D'].forEach(function (l, i) {
                        var val = choices[i] ? choices[i].value : '';
                        html += '<div class="pq-opt"><span class="pq-opt-ltr">' + l + '.</span>';
                        html += '<div class="pq-opt-text">' + (escHtml(val) || '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;') + '</div></div>';
                    });
                    html += '</div>';
                }
                if (bloom || clo) {
                    html += '<div class="bloom-clo-tag" style="margin-left:34px;margin-top:4px;font-size:9pt;color:#888;font-family:JetBrains Mono,monospace">';
                    html += [bloom, clo].filter(Boolean).join(' · ') + '</div>';
                }
                html += '</div>';
                qNumA++;
                totalQs++;
            });

            scroll.appendChild(document.createRange().createContextualFragment(makePageDiv(pageNum, html)));
            pageNum++;
            hasAny = true;
        }

        // ── Section B: Structured ───────────────────────────────────────────────
        var rowsB = document.querySelectorAll('#listB .q-config-item');
        if (rowsB.length > 0) {
            var marksB = sectionMarks('B');
            var html = '';
            html += '<div class="paper-section-header">';
            html += '<div class="part-title">PART B / <i>BAHAGIAN B</i> (' + marksB + ' Marks / ' + marksB + ' Markah)</div>';
            html += '<div class="part-instruction">Please answer all questions.<br/><i>Sila jawab semua soalan.</i></div>';
            html += '</div>';
            var qNumB = 1;
            rowsB.forEach(function (row) {
                var text = row.querySelector('.q-stem-en') ? row.querySelector('.q-stem-en').value : '[Question text]';
                var textMs = row.querySelector('.q-stem-ms') ? row.querySelector('.q-stem-ms').value : '';
                var marks = parseInt(row.querySelector('.q-marks') ? row.querySelector('.q-marks').value : 0) || 0;
                var bloom = row.querySelector('.q-bloom') ? row.querySelector('.q-bloom').value : '';
                var clo = row.querySelector('.q-clo') ? row.querySelector('.q-clo').value : '';
                var lines = parseInt(row.querySelector('.q-lines') ? row.querySelector('.q-lines').value : 6) || 6;

                html += '<div class="paper-question">';
                html += '<div class="pq-stem">';
                html += '<span class="pq-num">' + qNumB + '.</span>';
                html += '<div class="pq-text">' + renderQuestionText(text);
                if (textMs)
                    html += '<span class="pq-text-ms">' + escHtml(textMs) + '</span>';
                html += ' <span class="pq-marks">(' + marks + ' Marks / ' + marks + ' Markah)</span>';
                html += '</div></div>';
                if (bloom || clo) {
                    html += '<div class="bloom-clo-tag" style="margin-left:34px;margin-top:4px;font-size:9pt;color:#888;font-family:JetBrains Mono,monospace">';
                    html += [bloom, clo].filter(Boolean).join(' · ') + '</div>';
                }
                
                var parts = row.querySelectorAll('.part-item');
                if (parts.length > 0) {
                    parts.forEach(function(p) {
                        var pLabel = p.querySelector('input[name^="partLabel_"]').value || '';
                        var pText = p.querySelector('input[name^="partText_"]').value || '';
                        var pMarks = p.querySelector('input[name^="partMarks_"]').value || '';
                        html += '<div class="pq-sub-item" style="margin-left:34px; margin-top:8px;">';
                        html += '<span class="pq-sub-ltr" style="font-weight:bold">' + escHtml(pLabel) + '</span>';
                        html += '<div style="flex:1">' + escHtml(pText) + '</div>';
                        html += '<span class="pq-marks">(' + pMarks + ' Marks / ' + pMarks + ' Markah)</span>';
                        html += '</div>';
                        html += '<div class="answer-lines" style="margin-left:60px">';
                        for (var i = 0; i < lines; i++) html += '<div class="answer-line"></div>';
                        html += '</div>';
                    });
                    html += '</div>'; // close paper-question
                } else {
                    html += '<div class="answer-lines">';
                    for (var i = 0; i < lines; i++)
                        html += '<div class="answer-line"></div>';
                    html += '</div></div>';
                }
                qNumB++;
                totalQs++;
            });

            scroll.appendChild(document.createRange().createContextualFragment(makePageDiv(pageNum, html)));
            pageNum++;
            hasAny = true;
        }

        // ── Section C: Essay ────────────────────────────────────────────────────
        var rowsC = document.querySelectorAll('#listC .q-config-item');
        if (rowsC.length > 0) {
            var marksC = sectionMarks('C');
            var html = '';
            html += '<div class="paper-section-header">';
            html += '<div class="part-title">PART C / <i>BAHAGIAN C</i> (' + marksC + ' Marks / ' + marksC + ' Markah)</div>';
            html += '<div class="part-instruction">Answer any questions as instructed.<br/><i>Jawab soalan seperti yang diarahkan.</i></div>';
            html += '</div>';
            var qNumC = 1;
            rowsC.forEach(function (row) {
                var text = row.querySelector('.q-stem-en') ? row.querySelector('.q-stem-en').value : '[Question text]';
                var textMs = row.querySelector('.q-stem-ms') ? row.querySelector('.q-stem-ms').value : '';
                var marks = parseInt(row.querySelector('.q-marks') ? row.querySelector('.q-marks').value : 0) || 0;
                var bloom = row.querySelector('.q-bloom') ? row.querySelector('.q-bloom').value : '';
                var clo = row.querySelector('.q-clo') ? row.querySelector('.q-clo').value : '';
                var linesC = parseInt(row.querySelector('.q-lines') ? row.querySelector('.q-lines').value : 12) || 12;

                html += '<div class="paper-question">';
                html += '<div class="pq-stem">';
                html += '<span class="pq-num">' + qNumC + '.</span>';
                html += '<div class="pq-text">' + renderQuestionText(text);
                if (textMs)
                    html += '<span class="pq-text-ms">' + escHtml(textMs) + '</span>';
                html += ' <span class="pq-marks">(' + marks + ' Marks / ' + marks + ' Markah)</span>';
                html += '</div></div>';
                if (bloom || clo) {
                    html += '<div class="bloom-clo-tag" style="margin-left:34px;margin-top:4px;font-size:9pt;color:#888;font-family:JetBrains Mono,monospace">';
                    html += [bloom, clo].filter(Boolean).join(' · ') + '</div>';
                }
                var partsC = row.querySelectorAll('.part-item');
                if (partsC.length > 0) {
                    partsC.forEach(function(p) {
                        var pLabel = p.querySelector('input[name^="partLabel_"]').value || '';
                        var pText = p.querySelector('input[name^="partText_"]').value || '';
                        var pMarks = p.querySelector('input[name^="partMarks_"]').value || '';
                        html += '<div class="pq-sub-item" style="margin-left:34px; margin-top:8px;">';
                        html += '<span class="pq-sub-ltr" style="font-weight:bold">' + escHtml(pLabel) + '</span>';
                        html += '<div style="flex:1">' + escHtml(pText) + '</div>';
                        html += '<span class="pq-marks">(' + pMarks + ' Marks / ' + pMarks + ' Markah)</span>';
                        html += '</div>';
                        html += '<div class="answer-lines" style="margin-left:60px">';
                        for (var ic = 0; ic < linesC; ic++) html += '<div class="answer-line"></div>';
                        html += '</div>';
                    });
                    html += '</div>'; // close paper-question
                } else {
                    html += '<div class="answer-lines">';
                    for (var ic = 0; ic < linesC; ic++)
                        html += '<div class="answer-line"></div>';
                    html += '</div></div>';
                }
                qNumC++;
                totalQs++;
            });

            /* End of paper on the last section page */
            html += '<div class="end-of-paper"><b>End of Question Paper</b><i>Kertas Soalan Tamat</i></div>';
            scroll.appendChild(document.createRange().createContextualFragment(makePageDiv(pageNum, html)));
            pageNum++;
            hasAny = true;
        }

        /* If no questions at all, show placeholder page */
        var pageQ2 = document.getElementById('page-questions');
        if (pageQ2 && !hasAny) {
            pageQ2.style.display = '';
            var qp = pageQ2.querySelector('#questionsPreview');
            if (qp)
                qp.innerHTML = '<div style="text-align:center;color:#999;font-family:Crimson Pro,serif;font-size:13pt;margin-top:60px">Add questions on the left to see them here.</div>';
        }

        /* Update page count on cover */
        var total = pageNum - 1;
        var pgEl = document.getElementById('totalPagesCount');
        var pgElMs = document.getElementById('totalPagesCountMs');
        if (pgEl)
            pgEl.textContent = toWords(total);
        if (pgElMs)
            pgElMs.textContent = toWordsBM(total);
    }



    /* HTML-escape without newline conversion — for use inside renderQuestionText */
    function esc(s) {
        return (s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    /**
     * Smart question text renderer for the A4 preview.
     * Detects roman numeral statement lines (I. II. III. IV.) and renders
     * them as a styled indented list separate from the question stem.
     * Falls back to plain escaped text for regular questions.
     */
    function renderQuestionText(raw) {
        if (!raw)
            return '';
        var lines = raw.split('\n');
        var stemLines = [], stmtLines = [], tailLines = [];
        var inStmts = false, stmtsDone = false;
        var romanRe = /^(I{1,3}|IV|VI{0,3}|IX|XI{0,2}|XII)\. /;

        for (var li = 0; li < lines.length; li++) {
            var ln = lines[li].trim();
            if (!ln)
                continue;
            if (romanRe.test(ln) && !stmtsDone) {
                inStmts = true;
                var dot = ln.indexOf('.');
                var num = esc(ln.substring(0, dot).trim());
                var body = esc(ln.substring(dot + 1).trim());
                stmtLines.push('<div class="pq-stmt"><span class="pq-stmt-num">' + num + '.</span><span>' + body + '</span></div>');
            } else if (inStmts && !stmtsDone) {
                stmtsDone = true;
                tailLines.push(ln);
            } else if (!inStmts) {
                stemLines.push(ln);
            } else {
                tailLines.push(ln);
            }
        }

        var html = '';
        if (stemLines.length)
            html += esc(stemLines.join(' '));
        if (stmtLines.length)
            html += '<div class="pq-stmts">' + stmtLines.join('') + '</div>';
        if (tailLines.length)
            html += '<span style="display:block;margin-top:4px;font-weight:600;">' + esc(tailLines.join(' ')) + '</span>';
        return html || esc(raw);
    }

    function escHtml(s) {
        return (s || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/\n/g, '<br/>');
    }
    const WORDS_EN = ['', 'ONE', 'TWO', 'THREE', 'FOUR', 'FIVE', 'SIX', 'SEVEN', 'EIGHT', 'NINE', 'TEN', 'ELEVEN', 'TWELVE', 'THIRTEEN', 'FOURTEEN', 'FIFTEEN', 'SIXTEEN', 'SEVENTEEN', 'EIGHTEEN', 'NINETEEN', 'TWENTY'];
    const WORDS_BM = ['', 'SATU', 'DUA', 'TIGA', 'EMPAT', 'LIMA', 'ENAM', 'TUJUH', 'LAPAN', 'SEMBILAN', 'SEPULUH', 'SEBELAS', 'DUA BELAS', 'TIGA BELAS', 'EMPAT BELAS', 'LIMA BELAS', 'ENAM BELAS', 'TUJUH BELAS', 'LAPAN BELAS', 'SEMBILAN BELAS', 'DUA PULUH'];
    function toWords(n) {
        return (n <= 20 ? WORDS_EN[n] : n) + ' (' + n + ')';
    }
    function toWordsBM(n) {
        return (n <= 20 ? WORDS_BM[n] : n) + ' (' + n + ')';
    }

    /* ── Assessment type two-step dropdown ── */
    var ASSESS_TYPES = {
        final: [
            'Final Exam', 'Supplementary Exam',
            'Final Case Study Report', 'Final Practical Assessment',
            'Final Practical Laboratory Assessment', 'Final Presentation',
            'Final Project Report', 'Final Report Assignment', 'Final Video Presentation'
        ],
        continuous: [
            'Group Assignment', 'Group Presentation', 'Individual Assignment', 'Individual Presentation',
            'Lab Report', 'Lab Test', 'Mid Semester Exam', 'Observation', 'Peer Evaluation',
            'Practical Test', 'Project', 'Quiz', 'Test 1', 'Test 2',
            'Video Assignment', 'Written Report', 'Exercise', 'Others'
        ]
    };

    /* ── Populate type dropdown based on category ── */
    function onCategoryChange(sel) {
        var cat = sel ? sel.value : '';
        var typesSel = document.getElementById('assessType');
        if (!typesSel)
            return;
        typesSel.innerHTML = '<option value="">— Select type —</option>';
        if (!cat || !ASSESS_TYPES[cat])
            return;
        ASSESS_TYPES[cat].forEach(function (t) {
            var opt = document.createElement('option');
            opt.value = t;
            opt.textContent = t;
            typesSel.appendChild(opt);
        });
        var prev = document.getElementById('pTypeDefault') ? document.getElementById('pTypeDefault').value : '';
        if (prev)
            typesSel.value = prev;
    }

// Restore saved paper type on page load
    (function () {
        var el = document.getElementById('pTypeDefault');
        if (!el)
            return;
        var prev = el.value || 'Final Exam';
        // Handle old ENUM values
        if (prev === 'FINAL')
            prev = 'Final Exam';
        if (prev === 'SUPPLEMENTARY')
            prev = 'Supplementary Exam';
        var catSel = document.getElementById('assessCategory');
        if (!catSel)
            return;
        if (ASSESS_TYPES.final.indexOf(prev) !== -1)
            catSel.value = 'final';
        else if (ASSESS_TYPES.continuous.indexOf(prev) !== -1)
            catSel.value = 'continuous';
        else
            catSel.value = 'final';
        onCategoryChange(catSel);
    })();

    /* ── Init ── */
    updateMarks();
    updatePreview();
// Also trigger preview rebuild after short delay to ensure DOM is fully ready
    setTimeout(function () {
        rebuildPreview();
        updatePreview();
    }, 100);

    /**
     * submitForm — adds the action input to paperForm and submits.
     * action: "saveDraft" | "submit"
     * For "submit": validates that course and paper type are selected first.
     */
    /**
 * printPaper — clones all paper-page divs into a hidden print container,
 * triggers print, then removes the container.
 *
 * This is needed because the paper-page divs live inside a scrollable
 * overflow:hidden container on screen. The browser clips that container
 * during print even with overflow:visible in @media print.
 * Moving clones to <body> level bypasses the clip entirely.
 */
function printPaper() {
  /* Collect all visible paper pages in order */
  var pages = document.querySelectorAll(
    '#previewScroll .paper-page, #previewScroll .paper-page-cont'
  );

  if (!pages.length) {
    alert('No paper pages found. Please add questions first.');
    return;
  }

  /* Build a temporary print container at <body> level */
  var printWrap = document.createElement('div');
  printWrap.id = 'printWrap';
  printWrap.style.cssText = 'position:fixed;top:0;left:0;width:100%;z-index:99999;background:#fff';

  for (var i = 0; i < pages.length; i++) {
    /* Skip the static placeholder page if it's hidden (has no content) */
    if (pages[i].id === 'page-questions' &&
        pages[i].style.display === 'none') continue;
    var clone = pages[i].cloneNode(true);
    /* Remove any inline display:none from the clone */
    clone.style.display = '';
    clone.style.boxShadow = 'none';
    clone.style.margin = '0';
    clone.style.pageBreakAfter = 'always';
    printWrap.appendChild(clone);
  }

  /* Last clone: no page break after */
  var last = printWrap.lastElementChild;
  if (last) last.style.pageBreakAfter = 'auto';

  document.body.appendChild(printWrap);

  /* Hide everything else during print */
  document.body.classList.add('printing');

  window.print();

  /* Clean up after print dialog closes */
  document.body.removeChild(printWrap);
  document.body.classList.remove('printing');
}

function submitForm(action) {
        var form = document.getElementById('paperForm');
        if (!form) {
            alert('Form not found.');
            return;
        }

        /* Validate required fields before submit */
        if (action === 'submit' || action === 'resubmit') {
            var courseEl = document.getElementById('courseCodeSel');
            var typeEl = document.getElementById('assessType');
            if (!courseEl || !courseEl.value) {
                alert('Please select a course before submitting.');
                if (courseEl)
                    courseEl.focus();
                return;
            }
            if (!typeEl || !typeEl.value) {
                alert('Please select an assessment type before submitting.');
                if (typeEl)
                    typeEl.focus();
                return;
            }
            var confirmMsg = action === 'resubmit'
                ? 'Resubmit this paper to the vetting panel? The vetters will be notified to review your revised paper.'
                : 'Submit this paper for vetting? You will not be able to edit it after submission.';
            if (!confirm(confirmMsg))
                return;
        }

        /* Remove any previous action input to avoid duplicates */
        var old = form.querySelector('input[name="action"]');
        if (old)
            old.parentNode.removeChild(old);

        /* Add action input and submit */
        var inp = document.createElement('input');
        inp.type = 'hidden';
        inp.name = 'action';
        inp.value = action;
        form.appendChild(inp);
        form.submit();
    }
        </script>
    </body>
</html>