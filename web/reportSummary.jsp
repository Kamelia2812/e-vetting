<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%
    String ctx = request.getContextPath();

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> papers = (List<Map<String,Object>>) request.getAttribute("papers");
    @SuppressWarnings("unchecked")
    Map<String,Integer> statusCounts = (Map<String,Integer>) request.getAttribute("statusCounts");

    int total = papers != null ? papers.size() : 0;
    java.util.Date generatedAt = (java.util.Date) request.getAttribute("generatedAt");
    SimpleDateFormat dtFmt  = new SimpleDateFormat("dd MMM yyyy, HH:mm");
    SimpleDateFormat dtDate = new SimpleDateFormat("dd MMMM yyyy");

    int cntIP = 0, cntNI = 0, cntAppr = 0, cntFinal = 0;
    if (statusCounts != null) {
        cntIP    = statusCounts.getOrDefault("SUBMITTED",0)
                 + statusCounts.getOrDefault("UNDER_REVIEW",0)
                 + statusCounts.getOrDefault("PENDING_LEADER_SIGN",0)
                 + statusCounts.getOrDefault("LEADER_APPROVED",0)
                 + statusCounts.getOrDefault("SENT_TO_FAKULTI",0);
        cntNI    = statusCounts.getOrDefault("NEEDS_IMPROVEMENT",0);
        cntAppr  = statusCounts.getOrDefault("APPROVED",0);
        cntFinal = statusCounts.getOrDefault("FINALIZED",0);
    }

    // Separate into Final Exam and Final Assessment (non-exam) groups
    List<Map<String,Object>> finalExamPapers = new ArrayList<>();
    List<Map<String,Object>> finalAssessmentPapers = new ArrayList<>();
    if (papers != null) {
        for (Map<String,Object> p : papers) {
            String pt = (String) p.get("paperType");
            if (pt != null && pt.toLowerCase().contains("examination")) {
                finalExamPapers.add(p);
            } else {
                finalAssessmentPapers.add(p);
            }
        }
    }

    // Helper: get criterion result — returns Object[]{isOk, comment} or null
    // Criteria keys used in system
    // QUESTION: q_taxonomy, q_content, q_marks, q_answer, q_clarity
    // JSS:      jss_bloom, jss_clo, jss_marks, jss_coverage
    // SCHEME:   scheme_complete, scheme_partial, scheme_rubric, scheme_answer
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Assessment Report | E-Vetting UMT</title>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&display=swap" rel="stylesheet">
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
body{font-family:'Sora',sans-serif;background:#f4f6fb;color:#1a2435;min-height:100vh;font-size:13px}

/* ── Topnav ── */
.topnav{background:linear-gradient(135deg,#312e81 0%,#6d28d9 100%);
  box-shadow:0 2px 12px rgba(49,46,129,.25);position:sticky;top:0;z-index:100}
.nav-inner{max-width:1400px;margin:0 auto;padding:0 28px;height:58px;
  display:flex;align-items:center;gap:28px}
.brand{display:flex;align-items:center;gap:10px;text-decoration:none;flex-shrink:0}
.brand-logo{width:34px;height:34px;object-fit:contain;border-radius:6px}
.brand-name{font-size:15px;font-weight:700;color:#fff;line-height:1}
.brand-sub{font-size:10px;color:rgba(255,255,255,.55);letter-spacing:.8px;text-transform:uppercase;margin-top:2px}
.nav-tabs{display:flex;gap:4px;flex:1}
.tab{color:rgba(255,255,255,.65);text-decoration:none;font-size:13px;font-weight:500;
  padding:6px 14px;border-radius:7px;transition:.15s;white-space:nowrap}
.tab:hover{color:#fff;background:rgba(255,255,255,.1)}
.tab.active{background:rgba(255,255,255,.15);color:#fff;font-weight:600}
.nav-right{display:flex;align-items:center;gap:12px;margin-left:auto;flex-shrink:0}
.nav-user-link{display:flex;align-items:center;gap:9px;text-decoration:none;
  padding:5px 10px 5px 5px;border-radius:10px;transition:.15s}
.nav-user-link:hover{background:rgba(255,255,255,.08)}
.user-name{font-size:13px;font-weight:600;color:#fff;line-height:1.2;text-align:right}
.user-role{font-size:10px;color:rgba(255,255,255,.55);text-align:right}
.avatar{width:34px;height:34px;border-radius:50%;background:linear-gradient(135deg,#f59e0b,#d97706);
  color:#fff;font-size:13px;font-weight:700;display:grid;place-items:center;flex-shrink:0}
.logout-link{width:32px;height:32px;border-radius:8px;display:grid;place-items:center;
  color:rgba(255,255,255,.55);transition:.15s;text-decoration:none}
.logout-link:hover{background:rgba(255,255,255,.1);color:#fff}

/* ── Screen wrapper ── */
.page-wrap{max-width:1400px;margin:0 auto;padding:24px 28px 60px}
.screen-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:20px;gap:16px;flex-wrap:wrap}
.screen-title{font-size:20px;font-weight:700;color:#1a2435}
.screen-meta{font-size:11px;color:#6b7a99;margin-top:3px}
.btn-print{display:inline-flex;align-items:center;gap:7px;padding:9px 20px;
  background:linear-gradient(135deg,#312e81,#6d28d9);color:#fff;border:none;
  border-radius:8px;font-size:13px;font-weight:600;cursor:pointer;font-family:'Sora',sans-serif;transition:.15s}
.btn-print:hover{opacity:.88}

/* ── Stats ── */
.stat-row{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;margin-bottom:24px}
.stat-card{background:#fff;border-radius:10px;padding:14px 16px;border:1px solid #e8ecf4;text-align:center}
.stat-num{font-size:24px;font-weight:700;line-height:1;margin-bottom:3px}
.stat-lbl{font-size:10px;font-weight:600;text-transform:uppercase;letter-spacing:.6px;color:#6b7a99}
.s-total .stat-num{color:#312e81} .s-prog .stat-num{color:#4338ca}
.s-ni .stat-num{color:#d97706}    .s-appr .stat-num{color:#059669}
.s-fin .stat-num{color:#0e7490}

/* ── FAP03 Report document ── */
.fap-doc{background:#fff;border:1px solid #e8ecf4;border-radius:12px;overflow:hidden;margin-bottom:20px}

/* Form header */
.fap-header{padding:18px 24px 14px;border-bottom:2px solid #312e81}
.fap-formno{font-size:10px;font-weight:700;color:#6b7a99;text-align:right;margin-bottom:8px}
.fap-title-en{font-size:15px;font-weight:700;color:#312e81;text-transform:uppercase;line-height:1.3}
.fap-title-bm{font-size:12px;color:#4b5563;margin-top:2px;line-height:1.3}
.fap-umt{font-size:11px;color:#6b7a99;margin-top:4px}

/* Info fields */
.fap-info{display:grid;grid-template-columns:repeat(4,1fr);gap:0;border-bottom:1px solid #e8ecf4}
.fap-info-cell{padding:10px 16px;border-right:1px solid #e8ecf4}
.fap-info-cell:last-child{border-right:none}
.fap-info-label{font-size:9px;font-weight:700;text-transform:uppercase;letter-spacing:.6px;color:#6b7a99;margin-bottom:3px}
.fap-info-label span{display:block;font-weight:400;text-transform:none;letter-spacing:0;color:#9ca3af;font-size:9px}
.fap-info-value{font-size:12px;font-weight:600;color:#1a2435}

/* Section heading */
.fap-section{padding:10px 16px;background:#f8f9ff;border-bottom:1px solid #e8ecf4;
  font-size:11px;font-weight:700;color:#312e81;text-transform:uppercase;letter-spacing:.5px}
.fap-section span{font-weight:400;text-transform:none;letter-spacing:0;color:#6b7a99;font-size:10px;margin-left:6px}

/* ── Main table ── */
.fap-table-wrap{overflow-x:auto}
table.fap{width:100%;border-collapse:collapse;min-width:1100px}
table.fap th,table.fap td{border:1px solid #e2e8f0;padding:0;vertical-align:top;font-size:11px}

/* Header rows */
table.fap .th-top{background:#312e81;color:#fff;font-weight:700;font-size:10px;
  text-align:center;padding:8px 6px;line-height:1.3}
table.fap .th-top span{display:block;font-weight:400;font-size:9px;color:rgba(255,255,255,.7);margin-top:2px}
table.fap .th-group{background:#eef2ff;color:#312e81;font-weight:700;font-size:9px;
  text-align:center;padding:6px 4px;border-bottom:1px solid #c7d2fe;text-transform:uppercase;letter-spacing:.3px}
table.fap .th-sub{background:#f8f9ff;color:#4b5563;font-size:9px;font-weight:600;
  text-align:center;padding:5px 4px;line-height:1.3}

/* Data cells */
table.fap .td-no{width:32px;text-align:center;font-weight:700;color:#312e81;padding:10px 4px;background:#fafbff}
table.fap .td-code{width:80px;padding:8px;font-weight:700;color:#312e81;font-size:11px}
table.fap .td-name{width:140px;padding:8px;font-size:11px;line-height:1.4}
table.fap .td-lecturer{width:110px;padding:8px;font-size:10px}
table.fap .td-vetter{width:110px;padding:8px;font-size:10px}
table.fap .td-comment{width:160px;padding:8px;font-size:10px;line-height:1.4}
table.fap .td-cl{width:56px;text-align:center;padding:6px 3px;vertical-align:middle}
table.fap .td-impr{padding:8px;font-size:10px;line-height:1.4}

/* PI / TPI chips */
.pi {display:inline-block;background:#fef2f2;color:#dc2626;border:1px solid #fecaca;
  font-size:9px;font-weight:700;padding:2px 5px;border-radius:4px;white-space:nowrap}
.tpi{display:inline-block;background:#f0fdf4;color:#16a34a;border:1px solid #bbf7d0;
  font-size:9px;font-weight:700;padding:2px 5px;border-radius:4px;white-space:nowrap}
.na {display:inline-block;background:#f9fafb;color:#9ca3af;border:1px solid #e5e7eb;
  font-size:9px;font-weight:700;padding:2px 5px;border-radius:4px}

.cl-note{font-size:9px;color:#6b7a99;margin-top:3px;line-height:1.3;white-space:pre-line}

/* Status badge */
.badge{display:inline-flex;align-items:center;gap:3px;padding:2px 7px;border-radius:12px;font-size:9px;font-weight:700}
.b-draft{background:#f1f5f9;color:#64748b} .b-review{background:#eef2ff;color:#4338ca}
.b-ni{background:#fff7ed;color:#c2410c}    .b-appr{background:#f0fdf4;color:#15803d}
.b-fin{background:#ecfeff;color:#0e7490}   .b-rej{background:#fff1f2;color:#be123c}
.b-sub{background:#ede9fe;color:#5b21b6}

/* Empty state */
.empty{padding:32px;text-align:center;color:#9ca3af;font-size:12px}

/* Signature area */
.fap-sig{display:grid;grid-template-columns:1fr 1fr 1fr;gap:0;border-top:2px solid #312e81}
.sig-cell{padding:16px 20px;border-right:1px solid #e8ecf4;min-height:90px}
.sig-cell:last-child{border-right:none}
.sig-label{font-size:10px;font-weight:700;color:#312e81;margin-bottom:4px}
.sig-sub{font-size:9px;color:#6b7a99}
.sig-line{border-bottom:1px solid #374151;margin-top:40px;margin-bottom:6px}
.sig-name{font-size:10px;font-weight:600;color:#1a2435}
.sig-date{font-size:9px;color:#6b7a99}

/* ═══ PRINT ═══════════════════════════════════════════════ */
@media print {
  @page{size:A4 landscape;margin:12mm 10mm}
  *{-webkit-print-color-adjust:exact!important;print-color-adjust:exact!important}
  body{background:#fff;font-size:7.5pt}
  .topnav,.btn-print{display:none!important}
  .page-wrap{max-width:100%;padding:0;margin:0}

  .stat-row{display:none}
  .screen-header{display:none}

  /* Print header */
  .print-cover{display:block!important;margin-bottom:8pt}

  .fap-doc{border:1pt solid #999;border-radius:0;margin-bottom:10pt;page-break-inside:avoid}
  .fap-header{padding:8pt 10pt 6pt;border-bottom:1.5pt solid #312e81}
  .fap-formno{font-size:7pt}
  .fap-title-en{font-size:10pt}
  .fap-title-bm{font-size:8pt}
  .fap-umt{font-size:7pt}

  .fap-info{grid-template-columns:repeat(4,1fr)}
  .fap-info-cell{padding:5pt 8pt}
  .fap-info-label{font-size:7pt}
  .fap-info-value{font-size:8pt}

  .fap-section{padding:4pt 8pt;font-size:8pt}

  table.fap{min-width:unset;width:100%}
  table.fap th,table.fap td{font-size:7pt;border-color:#aaa}
  table.fap .th-top{padding:4pt 3pt;font-size:7pt}
  table.fap .th-top span{font-size:6.5pt}
  table.fap .th-group{padding:3pt;font-size:7pt}
  table.fap .th-sub{padding:3pt;font-size:6.5pt}
  table.fap .td-no{padding:4pt 2pt;font-size:7pt}
  table.fap .td-code{padding:4pt 5pt;font-size:8pt;width:60pt}
  table.fap .td-name{padding:4pt 5pt;width:90pt}
  table.fap .td-lecturer,.td-vetter{padding:4pt 5pt;width:70pt}
  table.fap .td-comment{width:100pt;padding:4pt 5pt}
  table.fap .td-cl{width:36pt;padding:3pt 2pt}
  .pi,.tpi,.na{font-size:6.5pt;padding:1pt 3pt}
  .cl-note{font-size:6pt}

  .fap-sig{grid-template-columns:repeat(3,1fr)}
  .sig-cell{padding:8pt 10pt;min-height:60pt}
  .sig-label{font-size:8pt}
  .sig-sub{font-size:7pt}
  .sig-line{margin-top:30pt}
  .sig-name{font-size:8pt}
  .sig-date{font-size:7pt}
}
.print-cover{display:none}
</style>
</head>
<body>

<jsp:include page="topnav.jsp"/>

<div class="page-wrap">

  <%-- Print cover --%>
  <div class="print-cover">
    <table style="width:100%;border-collapse:collapse;margin-bottom:8pt">
      <tr>
        <td style="vertical-align:middle">
          <div style="font-size:14pt;font-weight:700;color:#312e81">E-Vetting UMT</div>
          <div style="font-size:8pt;color:#555;margin-top:2pt">Universiti Malaysia Terengganu</div>
        </td>
        <td style="text-align:right;vertical-align:middle">
          <div style="font-size:10pt;font-weight:700">Assessment Summary Report</div>
          <div style="font-size:7pt;color:#555;margin-top:3pt">Generated: <%= generatedAt != null ? dtFmt.format(generatedAt) : "" %></div>
          <div style="font-size:7pt;color:#888;margin-top:1pt">CONFIDENTIAL — Ketua Program Use Only</div>
        </td>
      </tr>
    </table>
    <hr style="border:1pt solid #312e81;margin-bottom:8pt">
  </div>

  <%-- Screen header --%>
  <div class="screen-header">
    <div>
      <div class="screen-title">Assessment Report</div>
      <div class="screen-meta">Generated: <%= generatedAt != null ? dtFmt.format(generatedAt) : "" %> &nbsp;&middot;&nbsp; <%= total %> paper<%= total!=1?"s":"" %></div>
    </div>
    <button class="btn-print" onclick="window.print()">
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
        <polyline points="6 9 6 2 18 2 18 9"/>
        <path d="M6 18H4a2 2 0 01-2-2v-5a2 2 0 012-2h16a2 2 0 012 2v5a2 2 0 01-2 2h-2"/>
        <rect x="6" y="14" width="12" height="8"/>
      </svg>
      Print / Export PDF
    </button>
  </div>

  <%-- Stats (screen only) --%>
  <div class="stat-row">
    <div class="stat-card s-total"><div class="stat-num"><%= total %></div><div class="stat-lbl">Total</div></div>
    <div class="stat-card s-prog"><div class="stat-num"><%= cntIP %></div><div class="stat-lbl">In Progress</div></div>
    <div class="stat-card s-ni"><div class="stat-num"><%= cntNI %></div><div class="stat-lbl">Needs Revision</div></div>
    <div class="stat-card s-appr"><div class="stat-num"><%= cntAppr %></div><div class="stat-lbl">Approved</div></div>
    <div class="stat-card s-fin"><div class="stat-num"><%= cntFinal %></div><div class="stat-lbl">Finalized</div></div>
  </div>

<%
// Helper to render PI/TPI/NA cell
// criteria: Map<String, Object[]>  key -> {boolean isOk, String comment}

// ── Render a report section ──────────────────────────────────────────────────
// sectionType: "exam" or "assessment"
List<Map<String,Object>> examList = finalExamPapers;
List<Map<String,Object>> asmtList = finalAssessmentPapers;

for (int sec = 0; sec < 2; sec++) {
    List<Map<String,Object>> secPapers = sec == 0 ? examList : asmtList;
    String secFormNo = sec == 0 ? "UMT/B/FAP/03(a) (Pind.1/2023)" : "UMT/B/FAP/03(b) (Pind.1/2023)";
    String secTitleEn = sec == 0
        ? "SUMMARY OF VETTING FEEDBACK ON FINAL EXAMINATION QUESTION"
        : "SUMMARY OF VETTING FEEDBACK ON FINAL ASSESSMENT QUESTION";
    String secTitleBm = sec == 0
        ? "RUMUSAN MAKLUM BALAS SEMAKAN SOALAN PEPERIKSAAN AKHIR"
        : "RUMUSAN MAKLUM BALAS SEMAKAN SOALAN PENILAIAN AKHIR";
    String secTypeLabel = sec == 0 ? "Peperiksaan Akhir / Final Examination" : "Penilaian Akhir / Final Assessment";

    // Collect unique sessions/semesters/faculties for header
    String headerSession = "", headerSem = "", headerFaculty = "";
    if (!secPapers.isEmpty()) {
        Map<String,Object> first = secPapers.get(0);
        headerSession = (String) first.get("session");
        headerSem     = String.valueOf(first.get("semester"));
        headerFaculty = (String) first.get("faculty");
    }
%>
  <div class="fap-doc">

    <%-- Form header --%>
    <div class="fap-header">
      <div class="fap-formno"><%= secFormNo %></div>
      <div class="fap-title-en"><%= secTitleEn %></div>
      <div class="fap-title-bm"><%= secTitleBm %></div>
      <div class="fap-umt">Universiti Malaysia Terengganu &nbsp;&middot;&nbsp; 21030 Kuala Nerus, Terengganu, Malaysia &nbsp;&middot;&nbsp; www.umt.edu.my</div>
    </div>

    <%-- Info row --%>
    <div class="fap-info">
      <div class="fap-info-cell">
        <div class="fap-info-label">Fakulti <span>Faculty</span></div>
        <div class="fap-info-value"><%= headerFaculty.isEmpty() ? "N/A" : headerFaculty %></div>
      </div>
      <div class="fap-info-cell">
        <div class="fap-info-label">Semester <span>Semester</span></div>
        <div class="fap-info-value"><%= headerSem.isEmpty() ? "N/A" : headerSem %></div>
      </div>
      <div class="fap-info-cell">
        <div class="fap-info-label">Sesi <span>Session</span></div>
        <div class="fap-info-value"><%= headerSession.isEmpty() ? "N/A" : headerSession %></div>
      </div>
      <div class="fap-info-cell">
        <div class="fap-info-label">Tarikh Dijana <span>Date Generated</span></div>
        <div class="fap-info-value"><%= generatedAt != null ? dtDate.format(generatedAt) : "N/A" %></div>
      </div>
    </div>

    <%-- Section label --%>
    <div class="fap-section"><%= secTypeLabel %></div>

    <%-- Main table --%>
    <div class="fap-table-wrap">
    <% if (secPapers.isEmpty()) { %>
      <div class="empty">Tiada rekod. / No records found.</div>
    <% } else { %>
    <table class="fap">
      <thead>
        <tr>
          <th class="th-top" rowspan="3">Bil.<br><span>No.</span></th>
          <th class="th-top" rowspan="3">Kod Kursus<br><span>Course Code</span></th>
          <th class="th-top" rowspan="3">Nama Kursus<br><span>Course Name</span></th>
          <th class="th-top" rowspan="3">Nama Pensyarah<br><span>Lecturer</span></th>
          <th class="th-top" rowspan="3">Penyemak (Vetter)<br><span>Vetting Panel</span></th>
          <th class="th-top" rowspan="3">Status</th>
          <th class="th-top" rowspan="3">Tarikh Hantar<br><span>Submitted</span></th>
          <th class="th-top" rowspan="3">Komen Panel Penyemak<br><span>Vetting Panel Comment</span></th>
          <% if (sec == 0) { %>
          <th class="th-top" colspan="8">Perlu Penambahbaikan / Tidak Perlu Penambahbaikan<br>
            <span>Need Improvement (PI) / No Improvement Needed (TPI)</span></th>
          <% } else { %>
          <th class="th-top" colspan="6">Perlu Penambahbaikan / Tidak Perlu Penambahbaikan<br>
            <span>Need Improvement (PI) / No Improvement Needed (TPI)</span></th>
          <% } %>
          <th class="th-top" rowspan="3">Kenyataan Penambahbaikan<br><span>Improvement Statement</span></th>
        </tr>
        <tr>
          <% if (sec == 0) { %>
          <th class="th-group" colspan="2">Aras Kesukaran<br>Difficulty Level</th>
          <th class="th-group" colspan="2">Kandungan Silibus<br>Syllabus Content</th>
          <th class="th-group" colspan="2">Agihan Markah<br>Mark Distribution</th>
          <th class="th-group" colspan="2">Skema Jawapan<br>Answer Scheme</th>
          <% } else { %>
          <th class="th-group" colspan="2">Kejelasan Arahan<br>Clarity of Instructions</th>
          <th class="th-group" colspan="2">Aras Kesukaran<br>Difficulty Level</th>
          <th class="th-group" colspan="2">Agihan Markah<br>Mark Distribution</th>
          <th class="th-group" colspan="2">Skema/Rubrik<br>Scheme/Rubric</th>
          <% } %>
        </tr>
        <tr>
          <% int colCount = sec == 0 ? 8 : 6; %>
          <% for (int ci = 0; ci < colCount; ci++) { %>
          <th class="th-sub"><%= (ci % 2 == 0) ? "PI/TPI" : "Catatan<br>Notes" %></th>
          <% } %>
        </tr>
      </thead>
      <tbody>
<%
        int rowNum = 0;
        for (Map<String,Object> p : secPapers) {
            rowNum++;
            String code     = (String) p.get("courseCode");
            String title    = (String) p.get("courseTitle");
            String lecturer = (String) p.get("lecturerName");
            String status   = (String) p.get("status");
            java.sql.Timestamp subDate = (java.sql.Timestamp) p.get("submittedDate");

            @SuppressWarnings("unchecked")
            List<Map<String,Object>> vetters = (List<Map<String,Object>>) p.get("vetters");
            @SuppressWarnings("unchecked")
            Map<String,Object[]> criteria = (Map<String,Object[]>) p.get("criteria");
            String panelComment = (String) p.get("panelComment");

            // Build vetter list string
            StringBuilder vetterStr = new StringBuilder();
            if (vetters != null) {
                for (Map<String,Object> v : vetters) {
                    if (vetterStr.length() > 0) vetterStr.append("\n");
                    vetterStr.append((String) v.get("name"));
                    if ((boolean) v.get("isLeader")) vetterStr.append(" (L)");
                }
            }

            // Status badge
            String bc = "b-draft", sl = "Draft";
            if (status != null) switch (status) {
                case "SUBMITTED":           bc="b-sub";    sl="Submitted";    break;
                case "UNDER_REVIEW":        bc="b-review"; sl="Under Review"; break;
                case "NEEDS_IMPROVEMENT":   bc="b-ni";     sl="Needs Impr.";  break;
                case "APPROVED":            bc="b-appr";   sl="Approved";     break;
                case "PENDING_LEADER_SIGN": bc="b-review"; sl="Pend. Sign";   break;
                case "LEADER_APPROVED":     bc="b-appr";   sl="Ldr Approved"; break;
                case "SENT_TO_FAKULTI":     bc="b-fin";    sl="Sent Fakulti"; break;
                case "FINALIZED":           bc="b-fin";    sl="Finalized";    break;
                case "REJECTED":            bc="b-rej";    sl="Rejected";     break;
            }

            // Criterion helper
            // returns HTML for PI/TPI or N/A
            // keys to use per section type
            String[] clKeys;
            if (sec == 0) {
                // Final exam: taxonomy, content, marks, answer
                clKeys = new String[]{"q_taxonomy","q_taxonomy","q_content","q_content","q_marks","q_marks","q_answer","q_answer"};
            } else {
                // Final assessment: clarity, taxonomy, marks, scheme/rubric
                clKeys = new String[]{"q_clarity","q_clarity","q_taxonomy","q_taxonomy","q_marks","q_marks","scheme_rubric","scheme_rubric"};
            }
%>
        <tr>
          <td class="td-no"><%= rowNum %></td>
          <td class="td-code"><strong><%= code %></strong></td>
          <td class="td-name"><%= title %></td>
          <td class="td-lecturer"><%= lecturer %></td>
          <td class="td-vetter" style="white-space:pre-line"><%= vetterStr.length()>0?vetterStr.toString():"<span style='color:#9ca3af;font-style:italic'>Unassigned</span>" %></td>
          <td style="padding:6px 8px;text-align:center;white-space:nowrap">
            <span class="badge <%= bc %>"><%= sl %></span>
          </td>
          <td style="padding:6px 8px;font-size:10px;white-space:nowrap;font-family:monospace">
            <%= subDate != null ? new SimpleDateFormat("dd/MM/yyyy").format(subDate) : "N/A" %>
          </td>
          <td class="td-comment">
            <% if (panelComment != null && !panelComment.isEmpty()) { %>
            <span style="white-space:pre-line;font-size:10px"><%= panelComment.length() > 300 ? panelComment.substring(0, 300) + "..." : panelComment %></span>
            <% } else if (criteria == null || criteria.isEmpty()) { %>
            <span style="color:#9ca3af;font-style:italic;font-size:10px">Tiada ulasan / No comments</span>
            <% } else { %>
            <span style="color:#9ca3af;font-style:italic;font-size:10px">Tiada ulasan / No comments</span>
            <% } %>
          </td>
<%
            // Render criterion columns (alternating PI/TPI badge and notes)
            String[] criteriaKeys;
            String[] criteriaNotes;
            if (sec == 0) {
                criteriaKeys  = new String[]{"q_taxonomy","q_content","q_marks","q_answer"};
            } else {
                criteriaKeys  = new String[]{"q_clarity","q_taxonomy","q_marks","scheme_rubric"};
            }
            for (String key : criteriaKeys) {
                Object[] res = criteria != null ? criteria.get(key) : null;
                if (res == null) {
%>
          <td class="td-cl"><span class="na">N/A</span></td>
          <td class="td-cl"></td>
<%
                } else {
                    boolean isOk = (boolean) res[0];
                    String  note = (String) res[1];
%>
          <td class="td-cl">
            <% if (isOk) { %><span class="tpi">TPI</span><% } else { %><span class="pi">PI</span><% } %>
          </td>
          <td class="td-cl">
            <% if (note != null && !note.isEmpty()) { %>
            <span class="cl-note"><%= note.length() > 120 ? note.substring(0,120)+"..." : note %></span>
            <% } %>
          </td>
<%
                }
            }
%>
          <td class="td-impr">
            <% if ("NEEDS_IMPROVEMENT".equals(status)) { %>
            <span style="color:#d97706;font-size:10px;font-weight:600">Menunggu penambahbaikan<br><span style="font-weight:400">Awaiting improvement</span></span>
            <% } else if ("APPROVED".equals(status)||"FINALIZED".equals(status)||"LEADER_APPROVED".equals(status)||"SENT_TO_FAKULTI".equals(status)) { %>
            <span style="color:#16a34a;font-size:10px;font-weight:600">Telah diluluskan<br><span style="font-weight:400">Approved</span></span>
            <% } else if ("REJECTED".equals(status)) { %>
            <span style="color:#dc2626;font-size:10px;font-weight:600">Ditolak<br><span style="font-weight:400">Rejected</span></span>
            <% } else { %>
            <span style="color:#9ca3af;font-size:10px;font-style:italic">Dalam semakan<br>Under review</span>
            <% } %>
          </td>
        </tr>
<%
        } // end for papers
%>
      </tbody>
    </table>
    <% } %>
    </div>

    <%-- Signature section --%>
    <div class="fap-sig">
      <div class="sig-cell">
        <div class="sig-label">Pengesahan Ketua Program</div>
        <div class="sig-sub">Head of Programme Approval</div>
        <div class="sig-line"></div>
        <div class="sig-name">Tandatangan / Signature &amp; Cop / Stamp</div>
        <div class="sig-date">Tarikh / Date: ___________________</div>
      </div>
      <div class="sig-cell">
        <div class="sig-label">Tarikh Diterima</div>
        <div class="sig-sub">Date Received by Vetting Panel</div>
        <div class="sig-line"></div>
        <div class="sig-date">Tarikh / Date: ___________________</div>
      </div>
      <div class="sig-cell">
        <div class="sig-label">Urusetia Peperiksaan</div>
        <div class="sig-sub">Examination Secretariat</div>
        <div class="sig-line"></div>
        <div class="sig-name">Tandatangan Penerima &amp; Cop</div>
        <div class="sig-date">Tarikh / Date: ___________________</div>
      </div>
    </div>

  </div><%-- /fap-doc --%>
<% } // end sec loop %>

</div><%-- /page-wrap --%>

<script>
window.addEventListener('beforeprint', function() {
  document.querySelectorAll('.fap-doc').forEach(function(d){ d.style.pageBreakAfter='always'; });
});
</script>
</body>
</html>
