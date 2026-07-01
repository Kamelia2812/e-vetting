<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="Model.Assessment, Model.Question, Model.QuestionComment, Model.User, Model.Course" %>
<%@ page import="Controller.LecturerRow, Model.VetterCourseInfo" %>
<%@ page import="java.util.List, java.util.Map, java.util.ArrayList" %>
<%--
    vetterDashboard.jsp
    Multi-vetter review dashboard.

    Pages rendered via ?page= parameter (set by VetterDashboardServlet):
      dashboard  – summary stat cards
      queue      – papers awaiting review
      review     – per-question review for one paper
      reviewed   – papers already actioned

    Session attributes expected:
      userId       (int)     – current vetter's user_id
      fullName     (String)  – display name
      role         (String)  – "Vetter" or "Lecturer" (isVetter = true)
      isVetter     (Boolean) – true when a lecturer is also a vetter

    Request attributes set by servlet for page=review:
      paper            (Assessment)
      questions        (List<Question>)
      commentMap       (Map<Integer,List<QuestionComment>>)  – keyed by questionId
      assignedVetters  (List<User>)
      approvedCount    (int)
      needsWorkCount   (int)
      pendingCount     (int)
--%>
<%
    /* ── Session guard ───────────────────────────────────────────────────── */
    HttpSession sess = request.getSession(false);
    if (sess == null || sess.getAttribute("userId") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String currentRole = (String) sess.getAttribute("role");
    String fullName = (String) sess.getAttribute("fullName");
    int currentUserId = (Integer) sess.getAttribute("userId");
    String currentPage = (String) request.getAttribute("page");
    if (currentPage == null) {
        currentPage = "dashboard";
    }

    /* ── Review-page attributes (null on other pages) ────────────────────── */
    Assessment paper = (Assessment) request.getAttribute("paper");
    List questions = (List) request.getAttribute("questions");
    Map commentMap = (Map) request.getAttribute("commentMap");
    List assignedVetters = (List) request.getAttribute("assignedVetters");

    Integer approvedCount = (Integer) request.getAttribute("approvedCount");
    Integer needsWorkCount = (Integer) request.getAttribute("needsWorkCount");
    Integer pendingCount = (Integer) request.getAttribute("pendingCount");
    if (approvedCount == null) {
        approvedCount = 0;
    }
    if (needsWorkCount == null) {
        needsWorkCount = 0;
    }
    if (pendingCount == null) {
        pendingCount = 0;
    }

    /* ── Queue / reviewed page attributes ───────────────────────────────── */
    List pendingPapers = (List) request.getAttribute("pendingPapers");
    List leaderPending = (List) request.getAttribute("leaderPending");
    List leaderApproved = (List) request.getAttribute("leaderApproved");
    List reviewedPapers = (List) request.getAttribute("reviewedPapers");
    Map lecturerNameMap = (Map) request.getAttribute("lecturerNameMap");
    if (pendingPapers == null) {
        pendingPapers = new java.util.ArrayList();
    }
    if (leaderPending == null) {
        leaderPending = new java.util.ArrayList();
    }
    if (leaderApproved == null) {
        leaderApproved = new java.util.ArrayList();
    }
    if (lecturerNameMap == null) {
        lecturerNameMap = new java.util.HashMap();
    }

    /* ── Dashboard counts ────────────────────────────────────────────────── */
    Integer dashPending = (Integer) request.getAttribute("pendingCount");
    Integer dashReviewed = (Integer) request.getAttribute("reviewedCount");
    Integer dashCourses = (Integer) request.getAttribute("courseCount");
    Integer dashApproved = (Integer) request.getAttribute("approvedCount");
    if (dashPending == null) {
        dashPending = 0;
    }
    if (dashReviewed == null) {
        dashReviewed = 0;
    }
    if (dashCourses == null) {
        dashCourses = 0;
    }
    if (dashApproved == null) {
        dashApproved = 0;
    }

    /* ── Dashboard lecturer rows ─────────────────────────────────────────── */
    List<LecturerRow> lecturerRows = (List<LecturerRow>) request.getAttribute("lecturerRows");
    if (lecturerRows == null) {
        lecturerRows = new ArrayList<>();
    }
    List recentPending = (List) request.getAttribute("recentPending");
    if (recentPending == null) {
        recentPending = new ArrayList();
    }
    
    List<VetterCourseInfo> assignedCoursesList = (List<VetterCourseInfo>) request.getAttribute("assignedCoursesList");
    if (assignedCoursesList == null) {
        assignedCoursesList = new ArrayList<>();
    }

    /* ── Total questions / vetters for review page ───────────────────────── */
    int totalQuestions = (questions != null) ? questions.size() : 0;
    int totalVetters = (assignedVetters != null) ? assignedVetters.size() : 0;

    /* Avatar colour classes — cycles mod 4 ────────────────────────────────── */
    String[] AVATAR_COLORS = {"#2563eb", "#7c3aed", "#0891b2", "#db2777"};
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Vetter Dashboard — E-Vetting System</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet"/>
        <style>
            /* ═══════════════════════════════════════════════════════════════════
               CSS CUSTOM PROPERTIES
            ═══════════════════════════════════════════════════════════════════ */
            :root {
                --primary:        #2563eb;
                --primary-dark:   #1d4ed8;
                --primary-light:  #dbeafe;
                --success:        #16a34a;
                --success-light:  #dcfce7;
                --warning:        #d97706;
                --warning-light:  #fef3c7;
                --danger:         #dc2626;
                --danger-light:   #fee2e2;
                --purple:         #7c3aed;
                --purple-light:   #ede9fe;
                --slate-50:       #f8fafc;
                --slate-100:      #f1f5f9;
                --slate-200:      #e2e8f0;
                --slate-300:      #cbd5e1;
                --slate-400:      #94a3b8;
                --slate-500:      #64748b;
                --slate-600:      #475569;
                --slate-700:      #334155;
                --slate-800:      #1e293b;
                --slate-900:      #0f172a;
                --navy:           #2a1454;
                --teal:           #5b21b6;
                --radius-sm:      6px;
                --radius-md:      10px;
                --radius-lg:      14px;
                --shadow-sm:      0 1px 3px rgba(0,0,0,.08);
                --shadow-md:      0 4px 12px rgba(0,0,0,.10);
                --shadow-lg:      0 8px 24px rgba(0,0,0,.12);
                --transition:     .18s ease;
            }

            /* ═══════════════════════════════════════════════════════════════════
               RESET & BASE
            ═══════════════════════════════════════════════════════════════════ */
            *, *::before, *::after {
                box-sizing: border-box;
                margin: 0;
                padding: 0;
            }
            body {
                font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                background: var(--slate-100);
                color: var(--slate-800);
                font-size: 14px;
                line-height: 1.5;
                min-height: 100vh;
            }
            a {
                color: inherit;
                text-decoration: none;
            }
            button {
                font-family: inherit;
                cursor: pointer;
            }

            /* ═══════════════════════════════════════════════════════════════════
               TOPNAV
            ═══════════════════════════════════════════════════════════════════ */
            .topnav{
                background:linear-gradient(135deg,#312e81 0%,#4c1d95 55%,#6d28d9 100%);
                position:sticky;
                top:0;
                z-index:100;
                border-bottom:2px solid #f59e0b
            }
            .nav-inner{
                max-width:1300px;
                margin:0 auto;
                padding:0 24px;
                height:58px;
                display:flex;
                align-items:center
            }
            .brand{
                display:flex;
                align-items:center;
                gap:9px;
                padding-right:22px;
                border-right:1px solid rgba(255,255,255,.1);
                flex-shrink:0;
                text-decoration:none
            }
            .brand-logo{
                width:36px;
                height:36px;
                object-fit:contain;
                border-radius:6px
            }
            .brand-name{
                font-size:13px;
                font-weight:800;
                color:#fff
            }
            .brand-sub{
                font-size:10px;
                color:rgba(255,255,255,.4)
            }
            .nav-tabs{
                display:flex;
                align-items:center;
                gap:2px;
                padding-left:16px;
                flex:1;
                overflow:visible
            }
            .nav-tabs::-webkit-scrollbar{
                display:none
            }
            .tab{
                display:flex;
                align-items:center;
                gap:6px;
                padding:7px 12px;
                border-radius:8px;
                border:1px solid transparent;
                background:none;
                color:rgba(255,255,255,.5);
                font-family:inherit;
                font-size:13px;
                font-weight:600;
                cursor:pointer;
                white-space:nowrap;
                transition:.15s;
                text-decoration:none
            }
            .tab:hover{
                background:rgba(255,255,255,.07);
                color:#fff
            }
            .tab.active{
                background:rgba(245,158,11,.2);
                border-color:rgba(245,158,11,.45);
                color:#fbbf24
            }
            .nav-right{
                margin-left:auto;
                display:flex;
                align-items:center;
                gap:10px;
                padding-left:16px;
                border-left:1px solid rgba(255,255,255,.1);
                flex-shrink:0
            }
            .nav-user-link{
                display:flex;
                align-items:center;
                gap:9px;
                text-decoration:none;
                border-radius:8px;
                padding:4px 8px;
                transition:.15s
            }
            .nav-user-link:hover{
                background:rgba(255,255,255,.06)
            }
            .user-name{
                font-size:12px;
                font-weight:700;
                color:#fff
            }
            .user-role{
                font-size:10px;
                color:rgba(255,255,255,.4)
            }
            .avatar{
                width:34px;
                height:34px;
                border-radius:50%;
                background:linear-gradient(135deg,#f59e0b,#fcd34d);
                color:#2a1454;
                display:grid;
                place-items:center;
                font-weight:800;
                font-size:13px;
                flex-shrink:0
            }
            .logout-link{
                width:32px;
                height:32px;
                border-radius:50%;
                border:1px solid rgba(255,255,255,.15);
                background:none;
                color:rgba(255,255,255,.5);
                display:grid;
                place-items:center;
                text-decoration:none;
                transition:.15s
            }
            .logout-link:hover{
                background:rgba(190,18,60,.25);
                color:#fda4af
            }

            /* ── Main content area ── */
            .vd-main {
                min-height: calc(100vh - 58px);
                background: var(--slate-100);
            }

            /* ═══════════════════════════════════════════════════════════════════
               SHARED COMPONENTS
            ═══════════════════════════════════════════════════════════════════ */

            /* Page header strip */
            .page-header {
                background: #fff;
                border-bottom: 1px solid var(--slate-200);
                padding: 1.25rem 1.75rem;
            }
            .page-header h1 {
                font-size: 1.2rem;
                font-weight: 700;
                color: var(--slate-900);
            }
            .page-header p  {
                font-size: .82rem;
                color: var(--slate-500);
                margin-top: .2rem;
            }

            /* Breadcrumb */
            .breadcrumb {
                display: flex;
                align-items: center;
                gap: .4rem;
                font-size: .78rem;
                color: var(--slate-400);
                margin-bottom: .4rem;
            }
            .breadcrumb a {
                color: var(--primary);
            }
            .breadcrumb svg {
                width: 12px;
                height: 12px;
            }

            /* Stat cards */
            .stat-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
                gap: 1rem;
                padding: 1.5rem 1.75rem;
            }
            .stat-card {
                background: #fff;
                border: 1px solid var(--slate-200);
                border-radius: var(--radius-md);
                padding: 1.1rem 1.2rem;
                display: flex;
                flex-direction: column;
                gap: .3rem;
                box-shadow: var(--shadow-sm);
                transition: box-shadow var(--transition);
                position: relative;
                overflow: hidden;
            }
            .stat-card:hover {
                box-shadow: var(--shadow-md);
            }
            .stat-card .stat-label {
                font-size: .75rem;
                font-weight: 600;
                color: var(--slate-500);
                text-transform: uppercase;
                letter-spacing: .05em;
            }
            .stat-card .stat-value {
                font-size: 2rem;
                font-weight: 800;
                line-height: 1;
            }
            .stat-card .stat-sub   {
                font-size: .75rem;
                color: var(--slate-400);
            }
            .stat-card.blue   .stat-value {
                color: var(--primary);
            }
            .stat-card.green  .stat-value {
                color: var(--success);
            }
            .stat-card.yellow .stat-value {
                color: var(--warning);
            }
            .stat-card.red    .stat-value {
                color: var(--danger);
            }
            .stat-card.purple .stat-value {
                color: var(--purple);
            }
            .stat-card .stat-icon {
                position: absolute;
                right: 16px;
                top: 50%;
                transform: translateY(-50%);
                font-size: 36px;
                opacity: .12;
                pointer-events: none;
            }

            /* Buttons */
            .btn {
                display: inline-flex;
                align-items: center;
                gap: .4rem;
                padding: .45rem 1rem;
                border-radius: var(--radius-sm);
                font-size: .83rem;
                font-weight: 600;
                border: none;
                transition: background var(--transition), box-shadow var(--transition);
                white-space: nowrap;
            }
            .btn svg {
                width: 15px;
                height: 15px;
            }
            .btn-primary   {
                background: var(--primary);
                color: #fff;
            }
            .btn-primary:hover {
                background: var(--primary-dark);
                box-shadow: 0 2px 8px rgba(37,99,235,.35);
            }
            .btn-success   {
                background: var(--success);
                color: #fff;
            }
            .btn-success:hover {
                background: #15803d;
            }
            .btn-warning   {
                background: var(--warning);
                color: #fff;
            }
            .btn-warning:hover {
                background: #b45309;
            }
            .btn-danger    {
                background: var(--danger);
                color: #fff;
            }
            .btn-danger:hover {
                background: #b91c1c;
            }
            .btn-ghost {
                background: transparent;
                color: var(--slate-600);
                border: 1px solid var(--slate-200);
            }
            .btn-ghost:hover {
                background: var(--slate-100);
            }
            .btn-sm {
                padding: .3rem .7rem;
                font-size: .78rem;
            }

            /* Badge pills */
            .badge {
                display: inline-flex;
                align-items: center;
                padding: .18rem .6rem;
                border-radius: 999px;
                font-size: .73rem;
                font-weight: 600;
                white-space: nowrap;
            }
            .badge-blue    {
                background: var(--primary-light);
                color: var(--primary-dark);
            }
            .badge-green   {
                background: var(--success-light);
                color: #166534;
            }
            .badge-yellow  {
                background: var(--warning-light);
                color: #92400e;
            }
            .badge-red     {
                background: var(--danger-light);
                color: #991b1b;
            }
            .badge-purple  {
                background: var(--purple-light);
                color: #5b21b6;
            }
            .badge-slate   {
                background: var(--slate-100);
                color: var(--slate-600);
            }

            /* Content container */
            .content-wrap {
                padding: 1.25rem 1.75rem;
            }

            /* ── Dashboard 2-col layout ── */
            .dash-grid {
                display: grid;
                grid-template-columns: 1fr 340px;
                gap: 18px;
                padding: 1.25rem 1.75rem;
                align-items: start;
            }
            @media(max-width:900px){
                .dash-grid {
                    grid-template-columns: 1fr;
                }
            }

            /* ── Section card ── */
            .sec-card {
                background: #fff;
                border: 1px solid var(--slate-200);
                border-radius: var(--radius-md);
                box-shadow: var(--shadow-sm);
                overflow: hidden;
            }
            .sec-card-head {
                padding: 13px 16px;
                border-bottom: 1px solid var(--slate-100);
                display: flex;
                align-items: center;
                justify-content: space-between;
            }
            .sec-card-head h3 {
                font-size: 13px;
                font-weight: 800;
                color: var(--slate-800);
            }
            .sec-card-head span {
                font-size: 11px;
                color: var(--slate-400);
                font-weight: 600;
            }
            .sec-card-body {
                padding: 0;
            }

            /* ── Lecturer assignment table ── */
            .la-row {
                display: grid;
                grid-template-columns: 1fr auto;
                gap: 10px;
                padding: 13px 16px;
                border-bottom: 1px solid var(--slate-100);
                align-items: start;
                transition: background var(--transition);
            }
            .la-row:last-child {
                border-bottom: none;
            }
            .la-row:hover {
                background: var(--slate-50);
            }
            .la-course-code {
                font-family: monospace;
                font-size: 11px;
                font-weight: 800;
                color: var(--teal);
                background: rgba(91,33,182,.08);
                border: 1px solid rgba(91,33,182,.2);
                border-radius: 5px;
                padding: 2px 7px;
                display: inline-block;
                margin-bottom: 4px;
            }
            .la-course-name {
                font-size: 12px;
                font-weight: 700;
                color: var(--slate-700);
                line-height: 1.3;
            }
            .la-lecturer {
                font-size: 12px;
                color: var(--slate-500);
                margin-top: 3px;
                display: flex;
                align-items: center;
                gap: 5px;
            }
            .la-lecturer-avatar {
                width: 20px;
                height: 20px;
                border-radius: 50%;
                background: var(--primary-light);
                color: var(--primary);
                display: grid;
                place-items: center;
                font-size: 9px;
                font-weight: 800;
                flex-shrink: 0;
            }
            .la-contact {
                font-size: 10px;
                color: var(--slate-400);
                margin-top: 2px;
            }
            .la-status-pills {
                display: flex;
                flex-direction: column;
                gap: 3px;
                align-items: flex-end;
            }
            .la-pill {
                font-size: 10px;
                font-weight: 700;
                padding: 2px 8px;
                border-radius: 999px;
                white-space: nowrap;
            }
            .lap-pending  {
                background: var(--warning-light);
                color: #92400e;
            }
            .lap-approved {
                background: var(--success-light);
                color: #14532d;
            }
            .lap-action   {
                background: var(--danger-light);
                color: #991b1b;
            }
            .lap-draft    {
                background: var(--slate-100);
                color: var(--slate-500);
            }
            .la-empty {
                padding: 28px 16px;
                text-align: center;
                color: var(--slate-400);
                font-size: 13px;
            }

            /* ── Recent queue preview (dashboard sidebar) ── */
            .rq-item {
                padding: 11px 16px;
                border-bottom: 1px solid var(--slate-100);
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 10px;
            }
            .rq-item:last-child {
                border-bottom: none;
            }
            .rq-code {
                font-size: 12px;
                font-weight: 800;
                color: var(--slate-800);
            }
            .rq-sub  {
                font-size: 11px;
                color: var(--slate-400);
                margin-top: 1px;
            }
            .rq-action {
                flex-shrink: 0;
            }

            /* ── Queue page enhancements ── */
            .paper-card-meta {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
                margin-top: 7px;
            }
            .meta-chip {
                font-size: 11px;
                font-weight: 600;
                color: var(--slate-500);
                display: flex;
                align-items: center;
                gap: 3px;
            }
            .meta-chip svg {
                width: 12px;
                height: 12px;
            }
            .urgency-bar {
                height: 3px;
                border-radius: 0 0 var(--radius-md) var(--radius-md);
            }
            .urg-high   {
                background: var(--danger);
            }
            .urg-medium {
                background: var(--warning);
            }
            .urg-low    {
                background: var(--success);
            }
            .lecturer-chip {
                display: flex;
                align-items: center;
                gap: 5px;
                font-size: 11px;
                color: var(--slate-600);
                font-weight: 600;
            }
            .lc-dot {
                width: 18px;
                height: 18px;
                border-radius: 50%;
                background: var(--primary-light);
                color: var(--primary);
                display: grid;
                place-items: center;
                font-size: 8px;
                font-weight: 900;
                flex-shrink: 0;
            }

            /* ── Reviewed grouped sections ── */
            .verdict-group {
                margin-bottom: 18px;
            }
            .verdict-group-head {
                display: flex;
                align-items: center;
                gap: 8px;
                margin-bottom: 10px;
                font-size: 12px;
                font-weight: 800;
                text-transform: uppercase;
                letter-spacing: .06em;
                color: var(--slate-500);
            }
            .verdict-group-head::after {
                content: '';
                flex: 1;
                height: 1px;
                background: var(--slate-200);
            }

            /* Paper list card */
            .paper-card {
                background: #fff;
                border: 1px solid var(--slate-200);
                border-radius: var(--radius-md);
                padding: 1.1rem 1.25rem;
                display: flex;
                align-items: center;
                gap: 1rem;
                margin-bottom: .75rem;
                box-shadow: var(--shadow-sm);
                transition: box-shadow var(--transition), border-color var(--transition);
            }
            .paper-card:hover {
                box-shadow: var(--shadow-md);
                border-color: var(--slate-300);
            }
            .paper-card .paper-info {
                flex: 1;
                min-width: 0;
            }
            .paper-card .paper-title {
                font-weight: 700;
                font-size: .95rem;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }
            .paper-card .paper-meta  {
                font-size: .78rem;
                color: var(--slate-500);
                margin-top: .2rem;
            }
            .paper-card .paper-actions {
                flex-shrink: 0;
                display: flex;
                gap: .5rem;
                align-items: center;
            }

            /* Empty state */
            .empty-state {
                text-align: center;
                padding: 3rem 1.5rem;
                color: var(--slate-400);
            }
            .empty-state svg {
                width: 48px;
                height: 48px;
                margin-bottom: 1rem;
            }
            .empty-state h3 {
                font-size: 1rem;
                font-weight: 600;
                color: var(--slate-500);
            }
            .empty-state p  {
                font-size: .83rem;
                margin-top: .3rem;
            }

            /* ═══════════════════════════════════════════════════════════════════
               REVIEW PAGE — PAPER SUMMARY STRIP
            ═══════════════════════════════════════════════════════════════════ */
            .review-header {
                background: #fff;
                border-bottom: 1px solid var(--slate-200);
                padding: 1rem 1.75rem;
                position: sticky;
                top: 58px;
                z-index: 50;
                box-shadow: var(--shadow-sm);
            }
            .review-header-top {
                display: flex;
                align-items: flex-start;
                justify-content: space-between;
                gap: 1rem;
                flex-wrap: wrap;
                margin-bottom: .8rem;
            }
            .review-title {
                font-size: 1.1rem;
                font-weight: 800;
                color: var(--slate-900);
            }
            .review-sub   {
                font-size: .8rem;
                color: var(--slate-500);
                margin-top: .15rem;
            }

            /* Progress bar across all questions */
            .review-progress {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: .75rem;
            }
            .progress-item {
                display: flex;
                flex-direction: column;
                gap: .3rem;
            }
            .progress-label {
                display: flex;
                justify-content: space-between;
                font-size: .73rem;
                font-weight: 600;
                color: var(--slate-500);
                text-transform: uppercase;
                letter-spacing: .04em;
            }
            .progress-bar-track {
                height: 6px;
                background: var(--slate-100);
                border-radius: 999px;
                overflow: hidden;
            }
            .progress-bar-fill {
                height: 100%;
                border-radius: 999px;
                transition: width .4s ease;
            }
            .fill-green  {
                background: var(--success);
            }
            .fill-yellow {
                background: var(--warning);
            }
            .fill-slate  {
                background: var(--slate-300);
            }

            /* Vetter legend strip below progress */
            .vetter-legend {
                display: flex;
                gap: .75rem;
                flex-wrap: wrap;
                margin-top: .6rem;
                padding-top: .6rem;
                border-top: 1px solid var(--slate-100);
            }
            .vetter-legend-item {
                display: flex;
                align-items: center;
                gap: .4rem;
                font-size: .75rem;
                color: var(--slate-600);
            }
            .legend-dot {
                width: 10px;
                height: 10px;
                border-radius: 50%;
            }

            /* ═══════════════════════════════════════════════════════════════════
               REVIEW PAGE — QUESTION CARDS
            ═══════════════════════════════════════════════════════════════════ */
            .review-body {
                padding: 1.25rem 1.75rem;
            }

            /* Question card wrapper */
            .q-card {
                background: #fff;
                border: 1px solid var(--slate-200);
                border-radius: var(--radius-lg);
                margin-bottom: 1.25rem;
                box-shadow: var(--shadow-sm);
                overflow: hidden;
                transition: box-shadow var(--transition);
            }
            .q-card:hover {
                box-shadow: var(--shadow-md);
            }

            /* Question card header */
            .q-card-header {
                display: flex;
                align-items: center;
                gap: .65rem;
                padding: .9rem 1.25rem;
                background: var(--slate-50);
                border-bottom: 1px solid var(--slate-200);
                cursor: pointer;
                user-select: none;
                flex-wrap: wrap;
                transition: background var(--transition);
            }
            .q-card-header:hover {
                background: var(--slate-100);
            }

            .q-num {
                width: 32px;
                height: 32px;
                border-radius: 8px;
                background: var(--primary);
                color: #fff;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 800;
                font-size: .82rem;
                flex-shrink: 0;
            }

            .q-card-meta {
                display: flex;
                align-items: center;
                gap: .4rem;
                flex-wrap: wrap;
                flex: 1;
            }

            .q-status-badge {
                margin-left: auto;
            }

            /* Expand/collapse chevron */
            .q-chevron {
                width: 20px;
                height: 20px;
                flex-shrink: 0;
                color: var(--slate-400);
                transition: transform var(--transition);
            }
            .q-card.collapsed .q-chevron {
                transform: rotate(-90deg);
            }

            /* Progress pills showing how many vetters reviewed this question */
            .q-review-progress {
                display: flex;
                align-items: center;
                gap: .3rem;
                margin-left: .5rem;
            }
            .review-dot {
                width: 8px;
                height: 8px;
                border-radius: 50%;
                border: 1.5px solid var(--slate-300);
                background: #fff;
                transition: background .2s, border-color .2s;
            }
            .review-dot.done   {
                background: var(--success);
                border-color: var(--success);
            }
            .review-dot.flagged{
                background: var(--warning);
                border-color: var(--warning);
            }

            /* Question text body */
            .q-body {
                padding: 1rem 1.25rem;
                border-bottom: 1px solid var(--slate-200);
                font-size: .9rem;
                line-height: 1.7;
                color: var(--slate-700);
            }
            .q-body.collapsed {
                display: none;
            }

            /* MCQ choices */
            .q-choices {
                margin-top: .75rem;
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: .4rem;
            }
            .q-choice {
                display: flex;
                align-items: flex-start;
                gap: .5rem;
                font-size: .84rem;
                color: var(--slate-600);
            }
            .q-choice-label {
                width: 22px;
                height: 22px;
                border-radius: 50%;
                border: 1.5px solid var(--slate-300);
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: .72rem;
                font-weight: 700;
                flex-shrink: 0;
                color: var(--slate-500);
            }
            .q-choice.correct .q-choice-label {
                border-color: var(--success);
                background: var(--success-light);
                color: var(--success);
            }

            /* ═══════════════════════════════════════════════════════════════════
               REVIEW PAGE — VETTER PANELS GRID
            ═══════════════════════════════════════════════════════════════════ */
            .vetter-panels-wrapper {
                border-top: 2px solid var(--slate-100);
            }
            .vetter-panels-label {
                padding: .5rem 1.25rem;
                font-size: .72rem;
                font-weight: 700;
                color: var(--slate-400);
                text-transform: uppercase;
                letter-spacing: .06em;
                background: var(--slate-50);
                border-bottom: 1px solid var(--slate-100);
            }

            .vetter-panels-grid {
                display: grid;
                /* Each vetter gets equal column; min 280px keeps it readable */
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            }
            .vetter-panels-grid.collapsed {
                display: none;
            }

            /* Individual vetter panel */
            .vetter-panel {
                padding: 1rem 1.25rem;
                border-right: 1px solid var(--slate-200);
                display: flex;
                flex-direction: column;
                gap: .75rem;
                position: relative;
                transition: background var(--transition);
            }
            .vetter-panel:last-child {
                border-right: none;
            }
            .vetter-panel.is-me {
                background: #fafbff;
            }

            /* Panel header: avatar + name + date */
            .vp-header {
                display: flex;
                align-items: flex-start;
                gap: .65rem;
            }
            .vp-avatar {
                width: 38px;
                height: 38px;
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 800;
                font-size: .82rem;
                color: #fff;
                flex-shrink: 0;
                letter-spacing: .02em;
            }
            .vp-name-block {
                flex: 1;
                min-width: 0;
            }
            .vp-name {
                font-weight: 700;
                font-size: .88rem;
                color: var(--slate-900);
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }
            .vp-date {
                font-size: .73rem;
                color: var(--slate-400);
                margin-top: .1rem;
            }
            .vp-badge-row {
                display: flex;
                gap: .35rem;
                margin-top: .25rem;
                flex-wrap: wrap;
            }
            .vp-role-badge {
                font-size: .68rem;
                padding: .1rem .45rem;
                border-radius: 4px;
                background: var(--purple-light);
                color: #5b21b6;
                font-weight: 600;
            }
            .vp-me-badge {
                font-size: .68rem;
                padding: .1rem .45rem;
                border-radius: 4px;
                background: var(--primary-light);
                color: var(--primary-dark);
                font-weight: 600;
            }

            /* Comment text */
            .vp-comment-text {
                font-size: .87rem;
                line-height: 1.6;
                color: var(--slate-700);
                background: var(--slate-50);
                border-radius: var(--radius-sm);
                padding: .65rem .8rem;
                border-left: 3px solid var(--slate-200);
            }

            /* Tag row */
            .vp-tags {
                display: flex;
                flex-wrap: wrap;
                gap: .4rem;
            }
            .vp-tag {
                display: inline-flex;
                align-items: center;
                gap: .3rem;
                border-radius: 4px;
                padding: .18rem .6rem;
                font-size: .73rem;
                font-weight: 600;
            }
            .vp-tag svg {
                width: 11px;
                height: 11px;
            }
            .tag-content  {
                background: #dbeafe;
                color: #1e40af;
            }
            .tag-taxonomy {
                background: #d1fae5;
                color: #065f46;
            }
            .tag-rewrite  {
                background: #fee2e2;
                color: #991b1b;
            }

            /* Empty / awaiting state */
            .vp-empty {
                flex: 1;
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                padding: 1rem .5rem;
                gap: .4rem;
                color: var(--slate-300);
                text-align: center;
            }
            .vp-empty svg {
                width: 32px;
                height: 32px;
            }
            .vp-empty-text {
                font-size: .8rem;
                color: var(--slate-400);
            }

            /* ── Inline comment form (current vetter only) ──────────────────── */
            .vp-form {
                border-top: 1px dashed var(--slate-200);
                padding-top: .75rem;
                display: flex;
                flex-direction: column;
                gap: .5rem;
            }
            .vp-form-title {
                font-size: .73rem;
                font-weight: 700;
                color: var(--slate-500);
                text-transform: uppercase;
                letter-spacing: .05em;
            }
            .vp-textarea {
                resize: vertical;
                min-height: 80px;
                border: 1.5px solid var(--slate-200);
                border-radius: var(--radius-sm);
                padding: .55rem .7rem;
                font-size: .86rem;
                font-family: inherit;
                line-height: 1.5;
                width: 100%;
                color: var(--slate-800);
                transition: border-color var(--transition), box-shadow var(--transition);
                background: #fff;
            }
            .vp-textarea:focus {
                outline: none;
                border-color: var(--primary);
                box-shadow: 0 0 0 3px rgba(37,99,235,.12);
            }
            .vp-selects {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: .5rem;
            }
            .vp-select {
                border: 1.5px solid var(--slate-200);
                border-radius: var(--radius-sm);
                padding: .35rem .5rem;
                font-size: .8rem;
                background: #fff;
                color: var(--slate-700);
                transition: border-color var(--transition);
            }
            .vp-select:focus {
                outline: none;
                border-color: var(--primary);
            }
            .vp-form-actions {
                display: flex;
                gap: .4rem;
                justify-content: flex-end;
            }
            .btn-save-comment {
                background: var(--primary);
                color: #fff;
                border: none;
                border-radius: var(--radius-sm);
                padding: .4rem .9rem;
                font-size: .82rem;
                font-weight: 700;
                cursor: pointer;
                display: flex;
                align-items: center;
                gap: .35rem;
                transition: background var(--transition), box-shadow var(--transition);
            }
            .btn-save-comment:hover {
                background: var(--primary-dark);
                box-shadow: 0 2px 8px rgba(37,99,235,.3);
            }
            .btn-save-comment:disabled {
                opacity: .6;
                cursor: not-allowed;
            }
            .btn-save-comment svg {
                width: 14px;
                height: 14px;
            }
            .btn-clear-comment {
                background: none;
                border: 1px solid var(--slate-200);
                border-radius: var(--radius-sm);
                padding: .4rem .7rem;
                font-size: .8rem;
                color: var(--slate-500);
                cursor: pointer;
                transition: background var(--transition);
            }
            .btn-clear-comment:hover {
                background: var(--danger-light);
                color: var(--danger);
                border-color: var(--danger);
            }

            /* ═══════════════════════════════════════════════════════════════════
               REVIEW PAGE — VERDICT PANEL (sticky at bottom)
            ═══════════════════════════════════════════════════════════════════ */
            .verdict-panel {
                background: #fff;
                border-top: 2px solid var(--slate-200);
                padding: 1.25rem 1.75rem;
                position: sticky;
                bottom: 0;
                z-index: 40;
                display: flex;
                align-items: center;
                gap: 1rem;
                flex-wrap: wrap;
                box-shadow: 0 -4px 16px rgba(0,0,0,.06);
            }
            .verdict-label {
                font-weight: 700;
                color: var(--slate-700);
                font-size: .9rem;
                flex: 1;
            }
            .verdict-label span {
                font-size: .78rem;
                color: var(--slate-400);
                font-weight: 400;
                display: block;
            }
            .verdict-actions {
                display: flex;
                gap: .6rem;
                flex-wrap: wrap;
            }

            /* ═══════════════════════════════════════════════════════════════════
               VERDICT MODAL
            ═══════════════════════════════════════════════════════════════════ */
            .modal-overlay {
                position: fixed;
                inset: 0;
                z-index: 200;
                background: rgba(15,23,42,.45);
                backdrop-filter: blur(3px);
                display: flex;
                align-items: center;
                justify-content: center;
                opacity: 0;
                pointer-events: none;
                transition: opacity .2s;
            }
            .modal-overlay.open {
                opacity: 1;
                pointer-events: all;
            }
            .modal-box {
                background: #fff;
                border-radius: var(--radius-lg);
                padding: 1.5rem;
                width: 460px;
                max-width: 95vw;
                box-shadow: var(--shadow-lg);
                transform: translateY(12px);
                transition: transform .2s;
            }
            .modal-overlay.open .modal-box {
                transform: translateY(0);
            }
            .modal-title {
                font-size: 1rem;
                font-weight: 800;
                color: var(--slate-900);
                margin-bottom: .35rem;
            }
            .modal-sub   {
                font-size: .82rem;
                color: var(--slate-500);
                margin-bottom: 1rem;
            }
            .modal-textarea {
                width: 100%;
                min-height: 100px;
                resize: vertical;
                border: 1.5px solid var(--slate-200);
                border-radius: var(--radius-sm);
                padding: .6rem .8rem;
                font-size: .88rem;
                font-family: inherit;
                line-height: 1.5;
                transition: border-color var(--transition), box-shadow var(--transition);
            }
            .modal-textarea:focus {
                outline: none;
                border-color: var(--primary);
                box-shadow: 0 0 0 3px rgba(37,99,235,.12);
            }
            .modal-actions {
                display: flex;
                gap: .5rem;
                justify-content: flex-end;
                margin-top: 1rem;
            }

            /* ═══════════════════════════════════════════════════════════════════
               TOAST NOTIFICATION
            ═══════════════════════════════════════════════════════════════════ */
            .toast-container {
                position: fixed;
                top: 1.2rem;
                right: 1.5rem;
                z-index: 9999;
                display: flex;
                flex-direction: column;
                gap: .5rem;
                pointer-events: none;
            }
            .toast {
                background: var(--slate-900);
                color: #fff;
                padding: .65rem 1.1rem;
                border-radius: var(--radius-md);
                font-size: .85rem;
                font-weight: 600;
                box-shadow: var(--shadow-md);
                display: flex;
                align-items: center;
                gap: .5rem;
                transform: translateX(120%);
                transition: transform .25s ease;
                pointer-events: all;
            }
            .toast.show {
                transform: translateX(0);
            }
            .toast.success {
                background: #166534;
            }
            .toast.error   {
                background: var(--danger);
            }
            .toast svg {
                width: 16px;
                height: 16px;
                flex-shrink: 0;
            }
        /* ── COURSE CARDS ── */
.courses-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:14px}
@media(max-width:960px){.courses-grid{grid-template-columns:repeat(2,1fr)}}
@media(max-width:580px){.courses-grid{grid-template-columns:1fr}}
.course-card{background:var(--surface);border:1px solid var(--border);border-radius:var(--r);padding:16px;box-shadow:var(--sh);transition:.15s}
.course-card:hover{transform:translateY(-2px);border-color:var(--primary)}
.cc-top{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:8px}
.cc-code{font-family:monospace;font-size:11px;font-weight:700;color:var(--primary);background:var(--primary-light);border:1px solid var(--primary-light);border-radius:5px;padding:2px 7px}
.cc-cr{font-size:11px;font-weight:700;color:var(--muted);border:1px solid var(--border);border-radius:5px;padding:2px 7px}
.cc-name{font-size:14px;font-weight:800;margin-bottom:10px;line-height:1.35}
.kv-grid{display:grid;grid-template-columns:1fr 1fr;gap:6px;margin-bottom:10px}
.kv-item{background:rgba(255,255,255,0.6);border:1px solid rgba(0,0,0,0.05);border-radius:8px;padding:7px 9px}
.kv-item b{display:block;font-size:10px;font-weight:700;color:var(--slate-500);text-transform:uppercase;letter-spacing:.4px;margin-bottom:2px}
.kv-item span{font-size:12px;font-weight:700;color:var(--slate-800)}
.kv-full{grid-column:1/-1}
</style>

    </head>
    <body>
        <%
            /* Set currentPage attribute so topnav.jsp can highlight the right tab */
            request.setAttribute("currentPage", currentPage);
        %>
        <jsp:include page="topnav.jsp"/>

        <%-- ══════════════════════════════════════════════════════════════
             MAIN CONTENT
        ══════════════════════════════════════════════════════════════ --%>
        <div class="vd-main">

            <%-- ╔══════════════════════════════════════════════════════════╗
                 ║  PAGE: ASSIGNED COURSES                                 ║
                 ╚══════════════════════════════════════════════════════════╝ --%>
            <% if ("courses".equals(currentPage)) { %>
            <div class="page-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                <div>
                    <h1>Assigned Courses</h1>
                    <p>Courses assigned to you and their lecturers.</p>
                </div>
                <div style="position: relative;">
                    <i class="bi bi-search" style="position: absolute; left: 12px; top: 10px; color: var(--slate-400);"></i>
                    <input type="text" id="searchCourses" placeholder="Search courses..." style="padding: 8px 12px 8px 32px; border: 1px solid var(--slate-300); border-radius: 6px; font-size: 13px; width: 260px;">
                </div>
            </div>
            <div class="content-wrap">
                <div class="sec-card">
                    <div class="sec-card-head">
                        <h3>Your Courses</h3>
                        <span><%= assignedCoursesList.size() %> total</span>
                    </div>
                    <div class="sec-card-body" style="padding: 16px;">
                        <% if (assignedCoursesList.isEmpty()) { %>
                            <div class="empty-state">
                                <i class="bi bi-journal-text" style="font-size: 32px; color: var(--slate-300);"></i>
                                <p style="margin-top: 10px; color: var(--slate-500);">No courses assigned yet.</p>
                            </div>
                        <% } else { %>
                            <div class="courses-grid">
                                <% 
                                    String[] cardStyles = {
                                        "background: #eff6ff; border-color: #bfdbfe;", // Blue
                                        "background: #f5f3ff; border-color: #ddd6fe;", // Purple
                                        "background: #f0fdf4; border-color: #bbf7d0;", // Green
                                        "background: #fffbeb; border-color: #fde68a;", // Amber
                                        "background: #fdf2f8; border-color: #fbcfe8;", // Pink
                                        "background: #f0fdfa; border-color: #99f6e4;"  // Teal
                                    };
                                    int cardIdx = 0;
                                    for (VetterCourseInfo ci : assignedCoursesList) { 
                                        String currentStyle = cardStyles[cardIdx % cardStyles.length];
                                        cardIdx++;
                                %>
                                <div class="course-card" style="<%= currentStyle %>">
                                    <div class="cc-top">
                                        <span class="cc-code"><%= ci.courseCode %></span>
                                        <span class="cc-cr"><%= ci.credit %> CR</span>
                                    </div>
                                    <div class="cc-name"><%= ci.courseName %></div>
                                    <div class="kv-grid">
                                        <div class="kv-item"><b>Credits</b><span><%= ci.credit %> CR</span></div>
                                        <div class="kv-item"><b>Exam</b><span><%= ci.examHour %> hrs</span></div>
                                        <div class="kv-item"><b>Core</b><span><%= ci.core != null ? ci.core : "—" %></span></div>
                                        <div class="kv-item"><b>Category</b><span><%= ci.coCategory != null ? ci.coCategory : "—" %></span></div>
                                        <div class="kv-item kv-full"><b>Department</b><span><%= ci.department != null ? ci.department : "—" %></span></div>
                                        <div class="kv-item"><b>Faculty</b><span><%= ci.faculty != null ? ci.faculty : "FSKM" %></span></div>
                                        <div class="kv-item"><b>Senate Ref</b><span><%= ci.senateRef != null ? ci.senateRef : "—" %></span></div>
                                    </div>
                                    <div style="font-size:11px;color:var(--muted);margin-bottom:12px;margin-top:16px;display:flex;justify-content:space-between;align-items:center;">
                                        <span>Lecturer: <b style="color:var(--slate-800)"><%= ci.lecturerName != null ? ci.lecturerName : "Not assigned" %></b></span>
                                        <span class="badge <%= ci.isLeader ? "badge-green" : "badge-slate" %>" style="font-size: 9px;"><%= ci.isLeader ? "Leader" : "Member" %></span>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>

            <%-- ╔══════════════════════════════════════════════════════════╗
                 ║  PAGE: VETTING TEAMS                                    ║
                 ╚══════════════════════════════════════════════════════════╝ --%>
            <% if ("teams".equals(currentPage)) { %>
            <div class="page-header">
                <h1>Vetting Teams</h1>
                <p>Your team members for each assigned course.</p>
            </div>
            <div class="content-wrap">
                <div class="sec-card">
                    <div class="sec-card-head">
                        <h3>My Vetting Teams</h3>
                        <span><%= assignedCoursesList.size() %> teams</span>
                    </div>
                    <div class="sec-card-body" style="padding: 16px;">
                        <% if (assignedCoursesList.isEmpty()) { %>
                            <div class="empty-state">
                                <i class="bi bi-people" style="font-size: 32px; color: var(--slate-300);"></i>
                                <p style="margin-top: 10px; color: var(--slate-500);">No vetting teams assigned yet.</p>
                            </div>
                        <% } else { %>
                            <div style="display: grid; gap: 16px; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));">
                                <% for (VetterCourseInfo ci : assignedCoursesList) { %>
                                <div class="paper-card" style="margin: 0; align-items: flex-start; flex-direction: column;">
                                    <div style="display: flex; justify-content: space-between; width: 100%; align-items: center;">
                                        <div class="paper-title" style="color: var(--navy);"><%= ci.courseCode %></div>
                                        <span class="badge <%= ci.isLeader ? "badge-green" : "badge-slate" %>" style="font-size: 10px;"><%= ci.isLeader ? "Leader" : "Member" %></span>
                                    </div>
                                    <div style="font-weight: 600; font-size: 12px; color: var(--slate-600); margin-top: 2px;"><%= ci.courseName %></div>
                                    
                                    <div style="margin-top: 16px; width: 100%; background: var(--slate-50); border-radius: var(--radius-sm); padding: 12px; border: 1px solid var(--slate-100);">
                                        <div style="font-size: 10px; font-weight: 700; color: var(--slate-400); text-transform: uppercase; margin-bottom: 10px; display: flex; justify-content: space-between;">
                                            <span>Team Members</span>
                                            <span style="color: var(--primary);"><%= ci.coVetters.size() + 1 %> total</span>
                                        </div>
                                        
                                        <div style="display: flex; flex-direction: column; gap: 8px;">
                                            <%-- Add current user (You) to the top of the list --%>
                                            <div style="display: flex; align-items: center; gap: 10px;">
                                                <div class="avatar" style="width: 26px; height: 26px; font-size: 10px; background: var(--primary-light); color: var(--primary);"><%= fullName != null && !fullName.isEmpty() ? fullName.substring(0,1).toUpperCase() : "U" %></div>
                                                <div style="font-size: 12px; color: var(--slate-800); font-weight: 600;">You <%= ci.isLeader ? "<span style='color:var(--success);font-weight:700;font-size:11px;margin-left:4px;'>(Leader)</span>" : "" %></div>
                                            </div>
                                            
                                            <% for (String cvName : ci.coVetters) { 
                                                boolean isLdr = cvName.endsWith("(Leader)");
                                                String cleanName = cvName.replace(" (Leader)", "");
                                                String init = cleanName.length() > 0 ? cleanName.substring(0,1).toUpperCase() : "V";
                                            %>
                                                <div style="display: flex; align-items: center; gap: 10px;">
                                                    <div class="avatar" style="width: 26px; height: 26px; font-size: 10px; background: #e2e8f0; color: #475569;"><%= init %></div>
                                                    <div style="font-size: 12px; color: var(--slate-700);">
                                                        <%= cleanName %>
                                                        <%= isLdr ? "<span style='color:var(--success);font-weight:700;font-size:11px;margin-left:4px;'>(Leader)</span>" : "" %>
                                                    </div>
                                                </div>
                                            <% } %>
                                        </div>
                                    </div>
                                </div>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <% } %>

            <%-- ╔══════════════════════════════════════════════════════════╗
                 ║  PAGE: DASHBOARD                                        ║
                 ╚══════════════════════════════════════════════════════════╝ --%>
            <% if ("dashboard".equals(currentPage)) {%>
            <div class="page-header">
                <h1>Vetter Dashboard</h1>
                <p>Welcome back, <%= fullName%>. Here's your review overview for today.</p>
            </div>
            
            <%-- ── Overall Progress Bar ─────────────────────────────────────── --%>
            <%
                int totalVetting = dashPending + dashReviewed;
                int percentComplete = totalVetting > 0 ? (dashReviewed * 100 / totalVetting) : 0;
            %>
            <div style="margin-bottom: 24px; background: #fff; padding: 20px; border-radius: var(--radius-lg); border: 1px solid var(--border); box-shadow: var(--shadow-sm);">
                <div style="display: flex; justify-content: space-between; margin-bottom: 8px; font-weight: 700; color: var(--slate-700);">
                    <span>Overall Vetting Progress</span>
                    <span style="color: var(--primary);"><%= percentComplete %>% Complete</span>
                </div>
                <div style="height: 10px; background: var(--slate-100); border-radius: 99px; overflow: hidden;">
                    <div style="height: 100%; width: <%= percentComplete %>%; background: linear-gradient(90deg, var(--primary), var(--purple)); border-radius: 99px; transition: width 1s ease-in-out;"></div>
                </div>
                <div style="margin-top: 8px; font-size: 12px; color: var(--slate-500); font-weight: 600;">
                    You have reviewed <%= dashReviewed %> out of <%= totalVetting %> papers assigned to you.
                </div>
            </div>


            <%-- ── Stat cards ─────────────────────────────────────────────── --%>
            
    <div style="padding: 1.5rem 1.75rem 0;">
        <jsp:include page="calendarWidget.jsp"/>
    </div>
<div class="stat-grid">
                <div class="stat-card yellow" onclick="window.location = 'VetterDashboardServlet?page=queue'" style="cursor:pointer">
                    <div class="stat-icon"><i class="bi bi-hourglass-split"></i></div>
                    <div class="stat-label">Pending Review</div>
                    <div class="stat-value"><%= dashPending%></div>
                    <div class="stat-sub">papers awaiting action</div>
                </div>
                <div class="stat-card green" onclick="window.location = 'VetterDashboardServlet?page=reviewed'" style="cursor:pointer">
                    <div class="stat-icon"><i class="bi bi-check2-all"></i></div>
                    <div class="stat-label">Reviewed</div>
                    <div class="stat-value"><%= dashReviewed%></div>
                    <div class="stat-sub">papers actioned total</div>
                </div>
                <div class="stat-card blue">
                    <div class="stat-icon"><i class="bi bi-journal-bookmark"></i></div>
                    <div class="stat-label">Assigned Courses</div>
                    <div class="stat-value"><%= dashCourses%></div>
                    <div class="stat-sub">courses under your vetting</div>
                </div>
                <div class="stat-card purple">
                    <div class="stat-icon"><i class="bi bi-patch-check"></i></div>
                    <div class="stat-label">Approved</div>
                    <div class="stat-value"><%= dashApproved%></div>
                    <div class="stat-sub">papers approved</div>
                </div>
            </div>

            <%-- ── Main dash grid: lecturer table + pending sidebar ────────── --%>
            <div class="dash-grid">

                <%-- LEFT: Assessments Progress Table ── --%>
                <div class="sec-card">
                    <div class="sec-card-head">
                        <h3>Assessments Progress</h3>
                        <span><%= lecturerRows.size()%> course<%= lecturerRows.size() != 1 ? "s" : ""%></span>
                    </div>
                    <div class="sec-card-body">
                        <% if (lecturerRows.isEmpty()) { %>
                        <div class="la-empty">No courses are assigned to you yet.</div>
                        <% } else {
                            for (LecturerRow lr : lecturerRows) {
                        %>
                        <div class="la-row" style="align-items: center;">
                            <div style="flex: 1;">
                                <span class="la-course-code"><%= lr.courseCode%></span>
                                <% if (lr.isLeader) { %>
                                <span class="la-pill lap-approved" style="font-size:10px; margin-left: 6px; background-color: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; padding: 2px 6px; border-radius: 4px; font-weight: bold;">Vetting Leader</span>
                                <% }%>
                                <div class="la-course-name" style="margin-bottom: 8px;"><%= lr.courseName != null ? lr.courseName : lr.courseCode%></div>

                                <!-- Progress Bar block -->
                                <%
                                    int total = lr.totalPapers;
                                    int approved = lr.approvedPapers;
                                    int percent = total > 0 ? (approved * 100 / total) : 0;
                                %>
                                <div class="la-progress-block" style="max-width: 450px;">
                                    <div style="display: flex; justify-content: space-between; font-size: 11px; color: var(--slate-500); margin-bottom: 3px; font-weight: 600;">
                                        <span>Vetting Progress: <%= approved%> of <%= total%> papers approved</span>
                                        <span><%= percent%>%</span>
                                    </div>
                                    <div style="height: 6px; background-color: var(--slate-200); border-radius: 999px; overflow: hidden;">
                                        <div style="height: 100%; background: linear-gradient(90deg, #10b981, #059669); width: <%= percent%>%; border-radius: 999px;"></div>
                                    </div>
                                </div>
                            </div>
                            <div class="la-status-pills">
                                <% if (lr.pendingPapers > 0) {%>
                                <span class="la-pill lap-pending"><%= lr.pendingPapers%> pending</span>
                                <% } %>
                                <% if (lr.approvedPapers > 0) {%>
                                <span class="la-pill lap-approved"><%= lr.approvedPapers%> approved</span>
                                <% } %>
                                <% if (lr.actionPapers > 0) {%>
                                <span class="la-pill lap-action"><%= lr.actionPapers%> needs action</span>
                                <% } %>
                                <% if (lr.draftPapers > 0) {%>
                                <span class="la-pill lap-draft"><%= lr.draftPapers%> draft</span>
                                <% } %>
                                <% if (lr.totalPapers == 0) { %>
                                <span class="la-pill lap-draft">no papers yet</span>
                                <% } %>
                            </div>
                        </div>
                        <% }
                } %>
                    </div>
                </div>

                <%-- RIGHT: Upcoming queue preview ── --%>
                <div>
                    <div class="sec-card">
                        <div class="sec-card-head">
                            <h3>Pending Papers</h3>
                            <% if (dashPending > 0) { %>
                            <a href="VetterDashboardServlet?page=queue" style="font-size:11px;font-weight:700;color:var(--primary);">View all</a>
                            <% } %>
                        </div>
                        <div class="sec-card-body">
                            <% if (recentPending == null || recentPending.isEmpty()) { %>
                            <div class="la-empty">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="width:32px;height:32px;margin:0 auto 8px;display:block;">
                                <path d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                                </svg>
                                All clear — no pending papers.
                            </div>
                            <% } else {
                                for (int i = 0; i < recentPending.size(); i++) {
                                    Assessment rpa = (Assessment) recentPending.get(i);
                            %>
                            <div class="rq-item">
                                <div>
                                    <div class="rq-code"><%= rpa.getCourseCode()%></div>
                                    <div class="rq-sub"><%= rpa.getPaperTypeLabel()%></div>
                                </div>
                                <div class="rq-action">
                                    <a href="VetterDashboardServlet?page=review&paperId=<%= rpa.getPaperId()%>"
                                       class="btn btn-primary btn-sm">Review</a>
                                </div>
                            </div>
                            <% } %>
                            <% if (dashPending > 3) {%>
                            <div style="padding:10px 16px;border-top:1px solid var(--slate-100);text-align:center;">
                                <a href="VetterDashboardServlet?page=queue" style="font-size:12px;font-weight:700;color:var(--primary);">
                                    + <%= dashPending - 3%> more papers in queue
                                </a>
                            </div>
                            <% } %>
                            <% } %>
                        </div>
                    </div>

                    <%-- Quick stats mini card --%>
                    <% if (!lecturerRows.isEmpty()) { %>
                    <div class="sec-card" style="margin-top:14px;">
                        <div class="sec-card-head"><h3>Quick Stats</h3></div>
                        <div style="padding:14px 16px;display:grid;grid-template-columns:1fr 1fr;gap:10px;">
                            <%
                                int totalLecturerPapers = 0, totalPending2 = 0, totalApproved2 = 0;
                                for (LecturerRow lr2 : lecturerRows) {
                                    totalLecturerPapers += lr2.totalPapers;
                                    totalPending2 += lr2.pendingPapers;
                                    totalApproved2 += lr2.approvedPapers;
                                }
                                int pct2 = totalLecturerPapers > 0 ? (totalApproved2 * 100 / totalLecturerPapers) : 0;
                            %>
                            <div style="text-align:center;padding:10px;background:var(--slate-50);border-radius:8px;border:1px solid var(--slate-200)">
                                <div style="font-size:22px;font-weight:800;color:var(--primary)"><%= totalLecturerPapers%></div>
                                <div style="font-size:10px;font-weight:700;color:var(--slate-400);text-transform:uppercase;letter-spacing:.5px;margin-top:2px">Total Papers</div>
                            </div>
                            <div style="text-align:center;padding:10px;background:var(--slate-50);border-radius:8px;border:1px solid var(--slate-200)">
                                <div style="font-size:22px;font-weight:800;color:var(--success)"><%= pct2%>%</div>
                                <div style="font-size:10px;font-weight:700;color:var(--slate-400);text-transform:uppercase;letter-spacing:.5px;margin-top:2px">Approval Rate</div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>

            </div><%-- end dash-grid --%>

            <%-- ╔══════════════════════════════════════════════════════════╗
                 ║  PAGE: QUEUE                                            ║
                 ╚══════════════════════════════════════════════════════════╝ --%>
            <% } else if ("queue".equals(currentPage)) { %>
            <div class="page-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                <div>
                    <h1>Vetting Queue</h1>
                    <p>Exam papers submitted and awaiting your review — sorted by submission date.</p>
                </div>
                <div style="position: relative;">
                    <i class="bi bi-search" style="position: absolute; left: 12px; top: 10px; color: var(--slate-400);"></i>
                    <input type="text" id="searchQueue" placeholder="Search by course code, name..." style="padding: 8px 12px 8px 32px; border: 1px solid var(--slate-300); border-radius: 6px; font-size: 13px; width: 260px;">
                </div>
            </div>
            <div class="content-wrap">
                <% if (pendingPapers == null || pendingPapers.isEmpty()) { %>
                <div class="empty-state">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                    <path d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"/>
                    </svg>
                    <h3>All clear!</h3>
                    <p>No papers are currently waiting for your review.</p>
                </div>
                <% } else {
                    for (int i = 0; i < pendingPapers.size(); i++) {
                        Assessment a = (Assessment) pendingPapers.get(i);

                        /* Lecturer name from map */
                        String lecName = lecturerNameMap.containsKey(a.getLecturerId())
                                ? (String) lecturerNameMap.get(a.getLecturerId()) : "—";
                        String lecInit2 = "L";
                        if (lecName != null && !lecName.trim().isEmpty() && !"—".equals(lecName)) {
                            String[] lp2 = lecName.trim().split("\\s+");
                            int ls2 = (lp2.length > 1 && lp2[0].endsWith(".")) ? 1 : 0;
                            StringBuilder lsb2 = new StringBuilder();
                            for (int p2 = ls2; p2 < lp2.length && lsb2.length() < 2; p2++) {
                                lsb2.append(Character.toUpperCase(lp2[p2].charAt(0)));
                            }
                            if (lsb2.length() > 0) {
                                lecInit2 = lsb2.toString();
                            }
                        }

                        /* Days waiting */
                        long daysWaiting = 0;
                        String daysLabel = "";
                        if (a.getSubmittedDate() != null) {
                            daysWaiting = (new java.util.Date().getTime() - a.getSubmittedDate().getTime())
                                    / (1000L * 60 * 60 * 24);
                            daysLabel = daysWaiting == 0 ? "Today" : daysWaiting + " day" + (daysWaiting != 1 ? "s" : "") + " ago";
                        }
                        /* Urgency level */
                        String urgCls = daysWaiting >= 7 ? "urg-high"
                                : daysWaiting >= 3 ? "urg-medium" : "urg-low";
                %>
                <div class="paper-card" style="padding-bottom:0;overflow:hidden;flex-direction:column;align-items:stretch;gap:0">
                    <div style="display:flex;align-items:center;gap:1rem;padding:1.1rem 1.25rem;">
                        <div class="paper-info">
                            <div class="paper-title">
                                <span style="font-family:monospace;font-size:12px;background:var(--primary-light);color:var(--primary);padding:2px 6px;border-radius:4px;margin-right:6px;font-weight:800"><%= a.getCourseCode()%></span>
                                <%= a.getCourseTitle()%>
                            </div>
                            <div class="paper-card-meta">
                                <span class="meta-chip">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                                    <%= a.getPaperTypeLabel()%>
                                </span>
                                <% if (daysLabel.length() > 0) {%>
                                <span class="meta-chip" style="<%= daysWaiting >= 7 ? "color:var(--danger);font-weight:700" : daysWaiting >= 3 ? "color:var(--warning)" : ""%>">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                                    Submitted <%= daysLabel%>
                                </span>
                                <% }%>
                                <span class="lecturer-chip">
                                    <div class="lc-dot"><%= lecInit2%></div>
                                    <%= lecName%>
                                </span>
                                <% if (a.getAcademicSession() != null) {%>
                                <span class="meta-chip">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                                    <%= a.getAcademicSession()%> Sem <%= a.getSemester()%>
                                </span>
                                <% }%>
                            </div>
                        </div>
                        <div class="paper-actions">
                            <% if (daysWaiting >= 3) { %>
                                <span class="badge badge-red" style="font-weight: 800; animation: pulse 2s infinite; background: var(--danger); color: white;">
                                    <i class="bi bi-exclamation-triangle-fill" style="margin-right: 4px;"></i> URGENT
                                </span>
                                <style>
                                    @keyframes pulse {
                                        0% { box-shadow: 0 0 0 0 rgba(220, 38, 38, 0.7); }
                                        70% { box-shadow: 0 0 0 6px rgba(220, 38, 38, 0); }
                                        100% { box-shadow: 0 0 0 0 rgba(220, 38, 38, 0); }
                                    }
                                </style>
                            <% } %>
                            <span class="badge badge-yellow"><%= a.getStatusLabel()%></span>
                            <a href="<%= request.getContextPath()%>/SubmissionPackageServlet?paperId=<%= a.getPaperId()%>"
                               class="btn btn-sm" style="background:#6d28d9;color:#fff;font-weight:700;">Package</a>
                            <a href="VetterDashboardServlet?page=review&paperId=<%= a.getPaperId()%>"
                               class="btn btn-primary btn-sm">Review</a>
                        </div>
                    </div>
                    <div class="urgency-bar <%= urgCls%>"></div>
                </div>
                <% }
        } %>
            </div>

            <%-- ── Leader Vetter: Papers to review and submit to KP ── --%>
            <%
                java.util.List allLeaderQueue = new java.util.ArrayList();
                if (leaderPending != null) {
                    allLeaderQueue.addAll(leaderPending);
                }
                if (leaderApproved != null)
                    allLeaderQueue.addAll(leaderApproved);
            %>
            <% if (!allLeaderQueue.isEmpty()) { %>
            <div class="page-header" style="margin-top:28px">
                <h1>Pending Submission to KP</h1>
                <p>These papers have been submitted by the lecturer for your final review. Review each paper and submit to KP to finalize.</p>
            </div>
            <div class="content-wrap">
                <% for (int i = 0; i < allLeaderQueue.size(); i++) {
            Assessment lp = (Assessment) allLeaderQueue.get(i);
            boolean lpApproved = "LEADER_APPROVED".equals(lp.getStatus());%>
                <div class="paper-card" style="border-left:4px solid <%= lpApproved ? "#15803d" : "#d97706"%>">
                    <div class="paper-info">
                        <div class="paper-title">
                            <span style="font-family:monospace;font-size:12px;background:<%= lpApproved ? "#dcfce7" : "#fffbeb"%>;color:<%= lpApproved ? "#15803d" : "#d97706"%>;padding:2px 6px;border-radius:4px;margin-right:6px;font-weight:800"><%= lp.getCourseCode()%></span>
                            <%= lp.getCourseTitle()%>
                        </div>
                        <div class="paper-card-meta">
                            <span class="meta-chip"><%= lp.getPaperTypeLabel()%></span>
                            <% if (lp.getAcademicSession() != null) {%>
                            <span class="meta-chip"><%= lp.getAcademicSession()%> Sem <%= lp.getSemester()%></span>
                            <% } %>
                            <% if (lp.getUpdatedAt() != null) {%>
                            <span class="meta-chip" style="color:<%= lpApproved ? "#15803d" : "#d97706"%>">Submitted: <%= new java.text.SimpleDateFormat("d MMM yyyy HH:mm").format(lp.getUpdatedAt())%></span>
                            <% }%>
                        </div>
                    </div>
                    <div class="paper-actions">
                        <span class="meta-chip" style="background:<%= lpApproved ? "#dcfce7" : "#fffbeb"%>;color:<%= lpApproved ? "#15803d" : "#d97706"%>;font-weight:700;border:1px solid <%= lpApproved ? "#86efac" : "#fcd34d"%>;border-radius:999px;padding:3px 10px;"><%= lp.getStatusLabel()%></span>
                        <a href="VetterDashboardServlet?page=review&paperId=<%= lp.getPaperId()%>" class="btn btn-ghost btn-sm">View Paper</a>
                        <form method="post" action="<%= request.getContextPath()%>/VetterDashboardServlet" style="display:inline"
                              onsubmit="return confirm('Submit this assessment to KP as finalized?')">
                            <input type="hidden" name="action"  value="signAndSend"/>
                            <input type="hidden" name="paperId" value="<%= lp.getPaperId()%>"/>
                            <button type="submit" class="btn btn-sm" style="background:#312e81;color:#fff;font-weight:700;border:none;cursor:pointer">Submit to KP</button>
                        </form>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>

            <%-- ╔══════════════════════════════════════════════════════════╗
                 ║  PAGE: REVIEWED                                         ║
                 ╚══════════════════════════════════════════════════════════╝ --%>
            <% } else if ("reviewed".equals(currentPage)) {
                /* Count outcomes for the header summary */
                int rApproved = 0, rImprove = 0, rRejected = 0;
                if (reviewedPapers != null) {
                    for (int i = 0; i < reviewedPapers.size(); i++) {
                        Assessment ra = (Assessment) reviewedPapers.get(i);
                        if ("APPROVED".equals(ra.getStatus())) {
                            rApproved++;
                        } else if ("NEEDS_IMPROVEMENT".equals(ra.getStatus())) {
                            rImprove++;
                        } else if ("REJECTED".equals(ra.getStatus())) {
                            rRejected++;
                        }
                    }
                }
            %>
            <div class="page-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                <div>
                    <h1>Reviewed Papers</h1>
                    <p>
                        <%= rApproved > 0 ? rApproved + " approved" : ""%>
                        <%= rApproved > 0 && (rImprove > 0 || rRejected > 0) ? " &bull; " : ""%>
                        <%= rImprove > 0 ? rImprove + " needs improvement" : ""%>
                        <%= rImprove > 0 && rRejected > 0 ? " &bull; " : ""%>
                        <%= rRejected > 0 ? rRejected + " rejected" : ""%>
                        <% if (rApproved == 0 && rImprove == 0 && rRejected == 0) { %>Papers you have actioned.<% } %>
                    </p>
                </div>
                <div style="position: relative;">
                    <i class="bi bi-search" style="position: absolute; left: 12px; top: 10px; color: var(--slate-400);"></i>
                    <input type="text" id="searchReviewed" placeholder="Search timeline..." style="padding: 8px 12px 8px 32px; border: 1px solid var(--slate-300); border-radius: 6px; font-size: 13px; width: 260px;">
                </div>
            </div>
            <style>
                .timeline-container {
                    position: relative;
                    max-width: 850px;
                    margin: 0 auto;
                    padding-left: 30px;
                }
                .timeline-container::before {
                    content: '';
                    position: absolute;
                    top: 0; left: 14px;
                    height: 100%;
                    width: 2px;
                    background: var(--slate-200);
                }
                .timeline-item {
                    position: relative;
                    margin-bottom: 24px;
                }
                .timeline-item::before {
                    content: '';
                    position: absolute;
                    top: 16px; left: -21px;
                    width: 12px; height: 12px;
                    border-radius: 50%;
                    background: #fff;
                    border: 3px solid var(--slate-400);
                    z-index: 2;
                }
                .timeline-item.status-APPROVED::before { border-color: var(--success); }
                .timeline-item.status-NEEDS_IMPROVEMENT::before { border-color: var(--warning); }
                .timeline-item.status-REJECTED::before { border-color: var(--danger); }
                .timeline-date {
                    font-size: 11px;
                    font-weight: 700;
                    color: var(--slate-400);
                    margin-bottom: 6px;
                    text-transform: uppercase;
                    letter-spacing: 0.5px;
                }
            </style>
            <div class="content-wrap">
                <% if (reviewedPapers == null || reviewedPapers.isEmpty()) { %>
                <div class="empty-state">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                    <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                    </svg>
                    <h3>No reviews yet</h3>
                    <p>Papers you approve or reject will appear here in your timeline.</p>
                </div>
                <% } else { %>
                <div class="timeline-container">
                    <% for (int i = 0; i < reviewedPapers.size(); i++) {
                            Assessment a = (Assessment) reviewedPapers.get(i);
                            String lecName2 = lecturerNameMap.containsKey(a.getLecturerId())
                                    ? (String) lecturerNameMap.get(a.getLecturerId()) : "—";
                            String badgeClass = "APPROVED".equals(a.getStatus()) ? "badge-green" : 
                                               ("NEEDS_IMPROVEMENT".equals(a.getStatus()) ? "badge-yellow" : "badge-red");
                            String formattedDate = a.getUpdatedAt() != null ? new java.text.SimpleDateFormat("dd MMM yyyy, HH:mm").format(a.getUpdatedAt()) : "Recently";
                    %>
                    <div class="timeline-item status-<%= a.getStatus() %>">
                        <div class="timeline-date"><i class="bi bi-clock-history" style="margin-right:4px;"></i> <%= formattedDate %></div>
                        <div class="paper-card" style="margin-bottom: 0;">
                            <div class="paper-info">
                                <div class="paper-title">
                                    <span style="font-family:monospace;font-size:12px;background:var(--primary-light);color:var(--primary);padding:2px 6px;border-radius:4px;margin-right:6px;font-weight:800"><%= a.getCourseCode()%></span>
                                    <%= a.getCourseTitle()%>
                                </div>
                                <div class="paper-card-meta">
                                    <span class="meta-chip"><%= a.getPaperTypeLabel()%></span>
                                    <% if (!"—".equals(lecName2)) {%>
                                    <span class="meta-chip timeline-lec" style="color:var(--slate-600);">by <%= lecName2%></span>
                                    <% } %>
                                    <% if (a.getAcademicSession() != null) {%>
                                    <span class="meta-chip"><%= a.getAcademicSession()%> Sem <%= a.getSemester()%></span>
                                    <% } %>
                                    <% if (a.getRemarks() != null && !a.getRemarks().trim().isEmpty()) {%>
                                    <span class="meta-chip" style="color:var(--slate-500);font-style:italic;max-width:300px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">"<%= a.getRemarks().length() > 60 ? a.getRemarks().substring(0, 60) + "…" : a.getRemarks()%>"</span>
                                    <% }%>
                                </div>
                            </div>
                            <div class="paper-actions">
                                <span class="badge <%= badgeClass %>"><%= a.getStatusLabel()%></span>
                                <a href="<%= request.getContextPath()%>/SubmissionPackageServlet?paperId=<%= a.getPaperId()%>"
                                   class="btn btn-sm" style="background:#6d28d9;color:#fff;font-weight:700;">Package</a>
                                <a href="VetterDashboardServlet?page=review&paperId=<%= a.getPaperId()%>"
                                   class="btn btn-ghost btn-sm">View</a>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>

            <%-- ╔══════════════════════════════════════════════════════════╗
                 ║  PAGE: REVIEW (main feature)                            ║
                 ╚══════════════════════════════════════════════════════════╝ --%>
            <% } else if ("review".equals(currentPage) && paper != null) {

                /* Compute total marks for percentage bars */
                int totalMarks = 0;
                if (questions != null) {
                    for (int qi = 0; qi < questions.size(); qi++) {
                        Question qtmp = (Question) questions.get(qi);
                        totalMarks += qtmp.getMarks();
                    }
                }
            %>

            <%-- ── Sticky review header ─────────────────────────────────────── --%>
            <div class="review-header">
                <div class="review-header-top">
                    <div>
                        <div class="breadcrumb">
                            <a href="VetterDashboardServlet?page=queue">Vetting Queue</a>
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="9 18 15 12 9 6"/></svg>
                            <span>Review</span>
                        </div>
                        <div class="review-title"><%= paper.getCourseCode()%> — <%= paper.getCourseTitle()%></div>
                        <div class="review-sub">
                            <%= paper.getPaperTypeLabel()%>
                            &bull; <%= totalQuestions%> questions displayed
                            &bull; <%= totalMarks%> total marks
                        </div>
                    </div>
                    <div style="display:flex;gap:.5rem;align-items:center;flex-wrap:wrap;">
                        <% if (totalVetters > 0) { %>
                        <div style="display:flex;gap:.3rem;align-items:center;">
                            <% for (int vi = 0; vi < assignedVetters.size(); vi++) {
                                    User av = (User) assignedVetters.get(vi);
                                    String avInitials = "VT";
                                    if (av.getFullName() != null) {
                                        String[] avp = av.getFullName().trim().split("\\s+");
                                        int avs = (avp.length > 1 && avp[0].endsWith(".")) ? 1 : 0;
                                        StringBuilder avsb = new StringBuilder();
                                        for (int p = avs; p < avp.length && avsb.length() < 2; p++) {
                                            avsb.append(Character.toUpperCase(avp[p].charAt(0)));
                                        }
                                        if (avsb.length() > 0) {
                                            avInitials = avsb.toString();
                                        }
                                    }
                                    String avColor = AVATAR_COLORS[vi % AVATAR_COLORS.length];
                            %>
                            <div title="<%= av.getFullName()%>"
                                 style="width:30px;height:30px;border-radius:8px;
                                 background:<%= avColor%>;color:#fff;
                                 display:flex;align-items:center;justify-content:center;
                                 font-size:.72rem;font-weight:800;border:2px solid #fff;
                                 margin-left:<%= vi > 0 ? "-6px" : "0"%>;
                                 box-shadow:0 0 0 1.5px var(--slate-200);">
                                <%= avInitials%>
                            </div>
                            <% }%>
                        </div>
                        <span style="font-size:.78rem;color:var(--slate-500);"><%= totalVetters%> vetter<%= totalVetters > 1 ? "s" : ""%> assigned</span>
                        <% }%>
                    </div>
                </div>

                <%-- ── Progress bars ────────────────────────────────────────── --%>
                <div class="review-progress">
                    <div class="progress-item">
                        <div class="progress-label">
                            <span style="color:var(--success);">&#10003; Reviewed OK</span>
                            <span><%= approvedCount%> / <%= totalQuestions%></span>
                        </div>
                        <div class="progress-bar-track">
                            <div class="progress-bar-fill fill-green"
                                 style="width:<%= totalQuestions > 0 ? (approvedCount * 100 / totalQuestions) : 0%>%"></div>
                        </div>
                    </div>
                    <div class="progress-item">
                        <div class="progress-label">
                            <span style="color:var(--warning);">&#9888; Needs Work</span>
                            <span><%= needsWorkCount%> / <%= totalQuestions%></span>
                        </div>
                        <div class="progress-bar-track">
                            <div class="progress-bar-fill fill-yellow"
                                 style="width:<%= totalQuestions > 0 ? (needsWorkCount * 100 / totalQuestions) : 0%>%"></div>
                        </div>
                    </div>
                    <div class="progress-item">
                        <div class="progress-label">
                            <span style="color:var(--slate-400);">&#9679; Pending</span>
                            <span><%= pendingCount%> / <%= totalQuestions%></span>
                        </div>
                        <div class="progress-bar-track">
                            <div class="progress-bar-fill fill-slate"
                                 style="width:<%= totalQuestions > 0 ? (pendingCount * 100 / totalQuestions) : 0%>%"></div>
                        </div>
                    </div>
                </div>

                <%-- ── Vetter colour legend ─────────────────────────────────── --%>
                <% if (totalVetters > 0) { %>
                <div class="vetter-legend">
                    <% for (int vi = 0; vi < assignedVetters.size(); vi++) {
                            User av = (User) assignedVetters.get(vi);
                            String avColor = AVATAR_COLORS[vi % AVATAR_COLORS.length];
                    %>
                    <div class="vetter-legend-item">
                        <div class="legend-dot" style="background:<%= avColor%>;"></div>
                        <span>Vetter <%= (vi + 1)%> — <%= av.getFullName()%>
                            <%= av.getUserId() == currentUserId ? " (you)" : ""%>
                        </span>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>

            <%-- ── Question cards ───────────────────────────────────────────── --%>
            <div class="review-body">

                <% if (questions == null || questions.isEmpty()) { %>
                <div class="empty-state">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                    <path d="M8.228 9c.549-1.165 2.03-2 3.772-2 2.21 0 4 1.343 4 3 0 1.4-1.278 2.575-3.006 2.907-.542.104-.994.54-.994 1.093m0 3h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    <h3>No questions found</h3>
                    <p>This paper has no questions yet.</p>
                </div>
                <% } else {
                    for (int qi = 0; qi < questions.size(); qi++) {
                        Question q = (Question) questions.get(qi);
                        int qid = q.getQuestionId();

                        /* Comments for this question from all vetters */
                        List qComments = (commentMap != null) ? (List) commentMap.get(qid) : null;
                        if (qComments == null) {
                            qComments = new ArrayList();
                        }

                        /* Build per-vetter lookup map for O(1) panel access */
                        java.util.Map byVetter = new java.util.HashMap();
                        for (int ci = 0; ci < qComments.size(); ci++) {
                            QuestionComment qc = (QuestionComment) qComments.get(ci);
                            byVetter.put(qc.getVetterId(), qc);
                        }

                        /* Derive question-level status from comments */
                        boolean anyFlagged = false;
                        int commentedVetters = byVetter.size();
                        for (int ci = 0; ci < qComments.size(); ci++) {
                            QuestionComment qc = (QuestionComment) qComments.get(ci);
                            if (qc.isContentFlagged()) {
                                anyFlagged = true;
                            }
                        }
                        boolean allReviewed = (totalVetters > 0) && (commentedVetters >= totalVetters);

                        String qStatusLabel, qStatusClass;
                        if (anyFlagged) {
                            qStatusLabel = "Needs Revision";
                            qStatusClass = "badge-yellow";
                        } else if (allReviewed) {
                            qStatusLabel = "Reviewed";
                            qStatusClass = "badge-green";
                        } else {
                            qStatusLabel = "Pending Review";
                            qStatusClass = "badge-slate";
                        }
                %>

                <div class="q-card" id="qcard-<%= qid%>">

                    <%-- ── Card header (clickable to collapse) ─────────────────── --%>
                    <div class="q-card-header" onclick="toggleCard(<%= qid%>)">
                        <div class="q-num">Q<%= q.getQuestionNo()%></div>

                        <div class="q-card-meta">
                            <span class="badge badge-blue"><%= q.getQuestionType()%></span>
                            <span class="badge badge-green"><%= q.getMarks()%> marks</span>
                            <% if (q.getChapter() != null && !q.getChapter().trim().isEmpty()) {%>
                            <span class="badge badge-yellow">Ch <%= q.getChapter()%></span>
                            <% } %>
                            <% if (q.getTaxonomyLevel() != null && !q.getTaxonomyLevel().trim().isEmpty()) {%>
                            <span class="badge badge-purple"><%= q.getTaxonomyLevel()%></span>
                            <% }%>

                            <%-- Icon progress: check/cross icons per assigned vetter ─────── --%>
                            <div class="q-review-progress" style="display:flex; gap: 4px; align-items: center;" title="<%= commentedVetters%> of <%= totalVetters%> vetters reviewed">
                                <% for (int vi = 0; vi < totalVetters; vi++) {
                                        User av = (User) assignedVetters.get(vi);
                                        QuestionComment vc = (QuestionComment) byVetter.get(av.getUserId());
                        if (vc == null) {%>
                                <i class="bi bi-x-circle-fill text-dark" style="font-size: 13px; opacity: 0.3;" 
                                   title="<%= av.getFullName()%>: Pending"></i>
                                <% } else if (vc.isContentFlagged()) {%>
                                <i class="bi bi-x-circle-fill text-danger" style="font-size: 13px;" 
                                   title="<%= av.getFullName()%>: Flagged (Needs revision)"></i>
                                <% } else {%>
                                <i class="bi bi-check-circle-fill text-success" style="font-size: 13px;" 
                                   title="<%= av.getFullName()%>: Reviewed OK"></i>
                                <% }
                           }%>
                            </div>
                        </div>

                        <span class="badge q-status-badge <%= qStatusClass%>"><%= qStatusLabel%></span>
                        <svg class="q-chevron" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                        <polyline points="6 9 12 15 18 9"/>
                        </svg>
                    </div>

                    <%-- ── Question body ────────────────────────────────────────── --%>
                    <div class="q-body" id="qbody-<%= qid%>">
                        <div style="font-size:.83rem;font-weight:600;color:var(--slate-400);margin-bottom:.4rem;text-transform:uppercase;letter-spacing:.05em;">Question</div>
                        <%= q.getQuestionText()%>

                        <%-- MCQ choices if objective ──────────────────────────── --%>
                        <% if ("OBJECTIVE".equalsIgnoreCase(q.getQuestionType())) { %>
                        <div class="q-choices">
                            <% String[] labels = {"A", "B", "C", "D"};
                                String[] choices = {q.getChoiceA(), q.getChoiceB(), q.getChoiceC(), q.getChoiceD()};
                                for (int ci = 0; ci < choices.length; ci++) {
                                    if (choices[ci] == null || choices[ci].trim().isEmpty()) {
                                        continue;
                                    }
                                    boolean isCorrect = String.valueOf((char) ('A' + ci)).equals(q.getCorrectAnswer());
                            %>
                            <div class="q-choice <%= isCorrect ? "correct" : ""%>">
                                <div class="q-choice-label"><%= labels[ci]%></div>
                                <span><%= choices[ci]%></span>
                            </div>
                            <% } %>
                        </div>
                        <% } %>

                        <%-- Malay translation if present ─────────────────────── --%>
                        <% if (q.getQuestionTextMs() != null && !q.getQuestionTextMs().trim().isEmpty()) {%>
                        <div style="margin-top:.75rem;padding:.65rem .8rem;background:var(--slate-50);
                             border-radius:var(--radius-sm);border-left:3px solid var(--slate-300);
                             font-size:.84rem;color:var(--slate-500);">
                            <span style="font-size:.72rem;font-weight:700;color:var(--slate-400);
                                  text-transform:uppercase;letter-spacing:.05em;">BM:</span><br>
                            <%= q.getQuestionTextMs()%>
                        </div>
                        <% }%>
                    </div>

                    <%-- ── Vetter review panels ────────────────────────────────── --%>
                    <div class="vetter-panels-wrapper">
                        <div class="vetter-panels-label" id="plabel-<%= qid%>">
                            Vetter Reviews &mdash; <%= commentedVetters%> of <%= totalVetters%> completed
                        </div>
                        <div class="vetter-panels-grid" id="vpgrid-<%= qid%>">

                            <% if (totalVetters == 0) { %>
                            <div class="vetter-panel" style="align-items:center;justify-content:center;padding:1.5rem;">
                                <div style="color:var(--slate-400);font-size:.85rem;">No vetters assigned to this course yet.</div>
                            </div>
                            <% } else {
                                for (int vi = 0; vi < assignedVetters.size(); vi++) {
                                    User vetter = (User) assignedVetters.get(vi);
                                    int vid = vetter.getUserId();
                                    QuestionComment com = (QuestionComment) byVetter.get(vid);
                                    boolean isMe = (vid == currentUserId);
                                    String avColor = AVATAR_COLORS[vi % AVATAR_COLORS.length];

                                    /* Vetter initials */
                                    String vInitials = "VT";
                                    if (vetter.getFullName() != null) {
                                        String[] vp = vetter.getFullName().trim().split("\\s+");
                                        int vs = (vp.length > 1 && vp[0].endsWith(".")) ? 1 : 0;
                                        StringBuilder vsb = new StringBuilder();
                                        for (int p = vs; p < vp.length && vsb.length() < 2; p++) {
                                            vsb.append(Character.toUpperCase(vp[p].charAt(0)));
                                        }
                                        if (vsb.length() > 0) {
                                            vInitials = vsb.toString();
                                        }
                                    }
                            %>

                            <div class="vetter-panel <%= isMe ? "is-me" : ""%>"
                                 id="vpanel-<%= qid%>-<%= vid%>">

                                <%-- ── Panel header ─────────────────────────────── --%>
                                <div class="vp-header">
                                    <div class="vp-avatar" style="background:<%= avColor%>;"><%= vInitials%></div>
                                    <div class="vp-name-block">
                                        <div class="vp-name"><%= vetter.getFullName()%></div>
                                        <div class="vp-date" id="vpdate-<%= qid%>-<%= vid%>">
                                            <%= com != null ? com.getFormattedDate() : "No review yet"%>
                                        </div>
                                        <div class="vp-badge-row">
                                            <span class="vp-role-badge">Vetter <%= (vi + 1)%></span>
                                            <% if (isMe) { %><span class="vp-me-badge">You</span><% } %>
                                        </div>
                                    </div>
                                </div>

                                <%-- ── Existing comment display ─────────────────── --%>
                                <% if (com != null) {%>
                                <div class="vp-comment-text" id="vpcmt-<%= qid%>-<%= vid%>">
                                    <%= com.getCommentText()%>
                                </div>
                                <% if (com.hasTags()) {%>
                                <div class="vp-tags" id="vptags-<%= qid%>-<%= vid%>">
                                    <% if (com.getContentTag() != null && !com.getContentTag().trim().isEmpty()) {
                                            String tagCls = com.getContentTag().toLowerCase().contains("rewrite")
                                                    ? "tag-rewrite"
                                                    : com.getContentTag().toLowerCase().contains("needs")
                                                    ? "tag-content" : "tag-taxonomy";
                                    %>
                                    <span class="vp-tag <%= tagCls%>">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M20.59 13.41l-7.17 7.17a2 2 0 01-2.83 0L2 12V2h10l8.59 8.59a2 2 0 010 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>
                                        <%= com.getContentTag()%>
                                    </span>
                                    <% } %>
                                    <% if (com.getTaxonomyTag() != null && !com.getTaxonomyTag().trim().isEmpty()) {%>
                                    <span class="vp-tag tag-taxonomy">
                                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/></svg>
                                        <%= com.getTaxonomyTag()%>
                                    </span>
                                    <% } %>
                                </div>
                                <% } %>
                                <% } else {%>
                                <div class="vp-empty" id="vpcmt-<%= qid%>-<%= vid%>">
                                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                    <circle cx="12" cy="12" r="9"/>
                                    <path d="M12 8v4l2 2"/>
                                    </svg>
                                    <span class="vp-empty-text">Awaiting review</span>
                                </div>
                                <% } %>

                                <%-- ── Editable form — current vetter only ─────── --%>
                                <% if (isMe) {%>
                                <div class="vp-form" id="vpform-<%= qid%>-<%= vid%>">
                                    <div class="vp-form-title">Your Review</div>
                                    <textarea class="vp-textarea"
                                              id="vptxt-<%= qid%>-<%= vid%>"
                                              placeholder="Write your detailed review comment here…"><%= com != null ? com.getCommentText() : ""%></textarea>
                                    <div class="vp-selects">
                                        <select class="vp-select" id="vpctag-<%= qid%>-<%= vid%>">
                                            <option value="">— Content tag —</option>
                                            <option value="Content: Acceptable"
                                                    <%= (com != null && "Content: Acceptable".equals(com.getContentTag())) ? "selected" : ""%>>
                                                Content: Acceptable</option>
                                            <option value="Content: Needs refinement"
                                                    <%= (com != null && "Content: Needs refinement".equals(com.getContentTag())) ? "selected" : ""%>>
                                                Content: Needs refinement</option>
                                            <option value="Content: Needs rewrite"
                                                    <%= (com != null && "Content: Needs rewrite".equals(com.getContentTag())) ? "selected" : ""%>>
                                                Content: Needs rewrite</option>
                                        </select>
                                        <select class="vp-select" id="vpttag-<%= qid%>-<%= vid%>">
                                            <option value="">— Taxonomy tag —</option>
                                            <option value="Taxonomy: Correct"
                                                    <%= (com != null && "Taxonomy: Correct".equals(com.getTaxonomyTag())) ? "selected" : ""%>>
                                                Taxonomy: Correct</option>
                                            <option value="Taxonomy: Suggest C1 Remember"
                                                    <%= (com != null && "Taxonomy: Suggest C1 Remember".equals(com.getTaxonomyTag())) ? "selected" : ""%>>
                                                Taxonomy: Suggest C1 Remember</option>
                                            <option value="Taxonomy: Suggest C2 Understand"
                                                    <%= (com != null && "Taxonomy: Suggest C2 Understand".equals(com.getTaxonomyTag())) ? "selected" : ""%>>
                                                Taxonomy: Suggest C2 Understand</option>
                                            <option value="Taxonomy: Suggest C3 Apply"
                                                    <%= (com != null && "Taxonomy: Suggest C3 Apply".equals(com.getTaxonomyTag())) ? "selected" : ""%>>
                                                Taxonomy: Suggest C3 Apply</option>
                                            <option value="Taxonomy: Suggest C4 Analyze"
                                                    <%= (com != null && "Taxonomy: Suggest C4 Analyze".equals(com.getTaxonomyTag())) ? "selected" : ""%>>
                                                Taxonomy: Suggest C4 Analyze</option>
                                            <option value="Taxonomy: Suggest C5 Evaluate"
                                                    <%= (com != null && "Taxonomy: Suggest C5 Evaluate".equals(com.getTaxonomyTag())) ? "selected" : ""%>>
                                                Taxonomy: Suggest C5 Evaluate</option>
                                            <option value="Taxonomy: Suggest C6 Create"
                                                    <%= (com != null && "Taxonomy: Suggest C6 Create".equals(com.getTaxonomyTag())) ? "selected" : ""%>>
                                                Taxonomy: Suggest C6 Create</option>
                                        </select>
                                    </div>
                                    <div class="vp-form-actions">
                                        <% if (com != null) {%>
                                        <button class="btn-clear-comment"
                                                onclick="clearComment(<%= qid%>, <%= vid%>)">
                                            Clear
                                        </button>
                                        <% }%>
                                        <button class="btn-save-comment"
                                                id="vpbtn-<%= qid%>-<%= vid%>"
                                                onclick="saveComment(<%= qid%>, <%= vid%>)">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                                            <polyline points="20 6 9 17 4 12"/>
                                            </svg>
                                            <%= com != null ? "Update" : "Save Comment"%>
                                        </button>
                                    </div>
                                </div>
                                <% } %>

                            </div><%-- end vetter-panel --%>

                            <% }
                /* end vetter loop */ } %>
                        </div><%-- end vetter-panels-grid --%>
                    </div><%-- end vetter-panels-wrapper --%>

                </div><%-- end q-card --%>
                <% }
        /* end question loop */ }%>
            </div><%-- end review-body --%>

            <%-- ── Sticky verdict panel ─────────────────────────────────────── --%>
            <div class="verdict-panel">
                <div class="verdict-label">
                    Paper Verdict
                    <span>Submit your final decision for this paper</span>
                </div>
                <div class="verdict-actions">
                    <button class="btn btn-success" onclick="openVerdict('approve')">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" width="15" height="15"><polyline points="20 6 9 17 4 12"/></svg>
                        Approve Paper
                    </button>
                    <button class="btn btn-warning" onclick="openVerdict('requestImprovement')">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" width="15" height="15"><path d="M12 9v4m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/></svg>
                        Request Improvement
                    </button>
                    <button class="btn btn-danger" onclick="openVerdict('reject')">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" width="15" height="15"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                        Reject
                    </button>
                </div>
            </div>

            <%-- ── Verdict modal ───────────────────────────────────────────── --%>
            <div class="modal-overlay" id="verdictModal">
                <div class="modal-box">
                    <div class="modal-title" id="modalTitle">Approve Paper</div>
                    <div class="modal-sub" id="modalSub">Add optional remarks for the lecturer.</div>
                    <textarea class="modal-textarea" id="modalRemarks"
                              placeholder="Remarks (optional for approval, recommended for others)…"></textarea>
                    <div class="modal-actions">
                        <button class="btn btn-ghost" onclick="closeVerdict()">Cancel</button>
                        <button class="btn" id="modalConfirmBtn" onclick="submitVerdict()">Confirm</button>
                    </div>
                </div>
            </div>

            <%-- Hidden form for verdict POST ───────────────────────────────── --%>
            <form id="verdictForm" method="POST" action="VetterDashboardServlet" style="display:none;">
                <input type="hidden" name="action"  id="verdictAction" value=""/>
                <input type="hidden" name="paperId" value="<%= paper.getPaperId()%>"/>
                <input type="hidden" name="remarks" id="verdictRemarks" value=""/>
            </form>

            <% }
    /* end review page */%>
        </div><%-- /.vd-main --%>
        
        <script>
            function setupLiveSearch(inputId, itemSelector, textSelectors) {
                const input = document.getElementById(inputId);
                if (!input) return;
                input.addEventListener('input', function(e) {
                    const query = e.target.value.toLowerCase();
                    const items = document.querySelectorAll(itemSelector);
                    items.forEach(item => {
                        let match = false;
                        textSelectors.forEach(sel => {
                            const el = item.querySelector(sel);
                            if (el && el.innerText.toLowerCase().includes(query)) {
                                match = true;
                            }
                        });
                        item.style.display = match ? '' : 'none';
                    });
                });
            }
            document.addEventListener('DOMContentLoaded', function() {
                setupLiveSearch('searchCourses', '.course-card', ['.cc-code', '.cc-name', '.kv-grid']);
                setupLiveSearch('searchQueue', '.paper-card', ['.paper-title', '.lecturer-chip', '.meta-chip']);
                setupLiveSearch('searchReviewed', '.timeline-item', ['.paper-title', '.timeline-lec', '.timeline-date']);
            });
        </script>
      <jsp:include page="footer.jsp"/>
</body>
</html>

        <%-- ══════════════════════════════════════════════════════════════
             TOAST CONTAINER
        ══════════════════════════════════════════════════════════════ --%>
        <div class="toast-container" id="toastContainer"></div>

        <%-- ══════════════════════════════════════════════════════════════
             JAVASCRIPT
             NOTE: All string interpolation uses concatenation (+), NOT
             template literals with ${} — JSP EL would intercept them.
        ══════════════════════════════════════════════════════════════ --%>
        <script>
            /* ── Card collapse / expand ────────────────────────────────────── */
            /**
             * Toggles the question card body and vetter panels grid visibility.
             * Rotates the chevron icon via the CSS class on the card.
             */
            function toggleCard(qid) {
                var card = document.getElementById('qcard-' + qid);
                var body = document.getElementById('qbody-' + qid);
                var grid = document.getElementById('vpgrid-' + qid);

                if (!card)
                    return;
                var collapsed = card.classList.toggle('collapsed');
                body.classList.toggle('collapsed', collapsed);
                grid.classList.toggle('collapsed', collapsed);
            }

            /* ── AJAX: Save / update a question comment ────────────────────── */
            /**
             * Saves the current vetter's comment for a question via AJAX.
             * On success: updates the displayed comment text + tags in-place
             * and changes the button label to "Update".
             *
             * @param {number} qid      - question ID
             * @param {number} vetterId - vetter user ID
             */
            function saveComment(qid, vetterId) {
                var txtEl = document.getElementById('vptxt-' + qid + '-' + vetterId);
                var ctagEl = document.getElementById('vpctag-' + qid + '-' + vetterId);
                var ttagEl = document.getElementById('vpttag-' + qid + '-' + vetterId);
                var btnEl = document.getElementById('vpbtn-' + qid + '-' + vetterId);

                if (!txtEl)
                    return;

                var txt = txtEl.value.trim();
                var ctag = ctagEl ? ctagEl.value : '';
                var ttag = ttagEl ? ttagEl.value : '';

                if (!txt) {
                    showToast('Please write a comment before saving.', 'error');
                    txtEl.focus();
                    return;
                }

                /* Disable button while saving to prevent double-submit */
                if (btnEl) {
                    btnEl.disabled = true;
                    btnEl.textContent = 'Saving…';
                }

                var params = new URLSearchParams();
                params.append('action', 'saveComment');
                params.append('questionId', qid);
                params.append('commentText', txt);
                params.append('contentTag', ctag);
                params.append('taxonomyTag', ttag);

                fetch('VetterDashboardServlet', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: params.toString()
                })
                        .then(function (res) {
                            return res.json();
                        })
                        .then(function (data) {
                            if (data.success) {
                                /* Update displayed comment text */
                                updateCommentDisplay(qid, vetterId, txt, ctag, ttag,
                                        data.date || '', data.vetterName || '');
                                showToast('Comment saved.', 'success');
                            } else {
                                showToast('Failed to save: ' + (data.message || 'Unknown error'), 'error');
                            }
                        })
                        .catch(function (err) {
                            console.error('saveComment error:', err);
                            showToast('Network error — please try again.', 'error');
                        })
                        .finally(function () {
                            if (btnEl) {
                                btnEl.disabled = false;
                                btnEl.textContent = 'Update';
                            }
                        });
            }

            /* ── AJAX: Clear (delete) a comment ────────────────────────────── */
            /**
             * Deletes the current vetter's comment for a question.
             *
             * @param {number} qid      - question ID
             * @param {number} vetterId - vetter user ID
             */
            function clearComment(qid, vetterId) {
                if (!confirm('Remove your comment for this question?'))
                    return;

                var params = new URLSearchParams();
                params.append('action', 'deleteComment');
                params.append('questionId', qid);

                fetch('VetterDashboardServlet', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: params.toString()
                })
                        .then(function (res) {
                            return res.json();
                        })
                        .then(function (data) {
                            if (data.success) {
                                /* Reset comment display to awaiting state */
                                var cmtEl = document.getElementById('vpcmt-' + qid + '-' + vetterId);
                                if (cmtEl) {
                                    cmtEl.innerHTML =
                                            '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="width:32px;height:32px;">' +
                                            '<circle cx="12" cy="12" r="9"/>' +
                                            '<path d="M12 8v4l2 2"/>' +
                                            '</svg>' +
                                            '<span class="vp-empty-text">Awaiting review</span>';
                                    cmtEl.className = 'vp-empty';
                                }
                                /* Clear tags */
                                var tagsEl = document.getElementById('vptags-' + qid + '-' + vetterId);
                                if (tagsEl)
                                    tagsEl.innerHTML = '';
                                /* Reset textarea */
                                var txtEl = document.getElementById('vptxt-' + qid + '-' + vetterId);
                                if (txtEl)
                                    txtEl.value = '';
                                /* Update date */
                                var dateEl = document.getElementById('vpdate-' + qid + '-' + vetterId);
                                if (dateEl)
                                    dateEl.textContent = 'No review yet';
                                showToast('Comment removed.', 'success');
                            } else {
                                showToast('Could not remove comment.', 'error');
                            }
                        })
                        .catch(function () {
                            showToast('Network error.', 'error');
                        });
            }

            /**
             * Updates the comment display section in-place after a successful save,
             * without requiring a full page reload.
             */
            function updateCommentDisplay(qid, vetterId, text, ctag, ttag, date, vetterName) {
                /* Update comment text element */
                var cmtEl = document.getElementById('vpcmt-' + qid + '-' + vetterId);
                if (cmtEl) {
                    cmtEl.className = 'vp-comment-text';
                    cmtEl.textContent = text;
                }

                /* Update date */
                var dateEl = document.getElementById('vpdate-' + qid + '-' + vetterId);
                if (dateEl && date)
                    dateEl.textContent = date;

                /* Update tags */
                var tagsEl = document.getElementById('vptags-' + qid + '-' + vetterId);
                if (tagsEl) {
                    tagsEl.innerHTML = '';
                    if (ctag) {
                        var tagCls = ctag.toLowerCase().indexOf('rewrite') >= 0 ? 'tag-rewrite'
                                : ctag.toLowerCase().indexOf('needs') >= 0 ? 'tag-content'
                                : 'tag-taxonomy';
                        tagsEl.innerHTML += '<span class="vp-tag ' + tagCls + '">' + escapeHtml(ctag) + '</span>';
                    }
                    if (ttag) {
                        tagsEl.innerHTML += '<span class="vp-tag tag-taxonomy">' + escapeHtml(ttag) + '</span>';
                    }
                }

                /* Update dot progress indicator in the card header */
                updateProgressDot(qid, vetterId,
                        ctag && ctag.toLowerCase().indexOf('needs') >= 0 ? 'flagged' : 'done');

                /* Update the review count label */
                updateReviewedCount(qid);
            }

            /**
             * Updates a single dot in the question header progress row.
             *
             * @param {number} qid      - question ID
             * @param {number} vetterId - identifies which dot to update
             * @param {string} state    - 'done' | 'flagged' | '' (pending)
             */
            function updateProgressDot(qid, vetterId, state) {
                /* Dots are identified by their position in the q-review-progress div.
                 We use data attributes if possible; fall back to scanning by title. */
                var progress = document.querySelector('#qcard-' + qid + ' .q-review-progress');
                if (!progress)
                    return;
                var dots = progress.querySelectorAll('.review-dot');
                dots.forEach(function (dot) {
                    if (dot.title && dot.title.indexOf('vetterId=' + vetterId) >= 0) {
                        dot.className = 'review-dot ' + state;
                    }
                });
            }

            /**
             * Updates the "X of N vetters reviewed" label above the vetter panels grid.
             */
            function updateReviewedCount(qid) {
                var grid = document.getElementById('vpgrid-' + qid);
                var label = document.getElementById('plabel-' + qid);
                if (!grid || !label)
                    return;

                var total = grid.querySelectorAll('.vetter-panel').length;
                /* Count panels that have a comment (have a .vp-comment-text child) */
                var done = grid.querySelectorAll('.vp-comment-text').length;
                label.textContent = 'Vetter Reviews \u2014 ' + done + ' of ' + total + ' completed';
            }

            /* ── Verdict modal ─────────────────────────────────────────────── */

            var _currentVerdict = '';

            var VERDICT_CONFIG = {
                approve: {title: 'Approve Paper', sub: 'Add optional remarks for the lecturer.', btnCls: 'btn-success', btnLabel: 'Approve'},
                requestImprovement: {title: 'Request Improvement', sub: 'Specify what needs to be improved.  These remarks will be sent to the lecturer.', btnCls: 'btn-warning', btnLabel: 'Send for Improvement'},
                reject: {title: 'Reject Paper', sub: 'State the reason for rejection. This will be visible to the lecturer.', btnCls: 'btn-danger', btnLabel: 'Reject Paper'}
            };

            /**
             * Opens the verdict confirmation modal with the appropriate title and button.
             *
             * @param {string} action - 'approve' | 'requestImprovement' | 'reject'
             */
            function openVerdict(action) {
                _currentVerdict = action;
                var cfg = VERDICT_CONFIG[action] || VERDICT_CONFIG.approve;

                document.getElementById('modalTitle').textContent = cfg.title;
                document.getElementById('modalSub').textContent = cfg.sub;
                document.getElementById('modalRemarks').value = '';

                var btn = document.getElementById('modalConfirmBtn');
                btn.className = 'btn ' + cfg.btnCls;
                btn.textContent = cfg.btnLabel;

                document.getElementById('verdictModal').classList.add('open');
                setTimeout(function () {
                    document.getElementById('modalRemarks').focus();
                }, 200);
            }

            /** Closes the verdict modal without submitting. */
            function closeVerdict() {
                document.getElementById('verdictModal').classList.remove('open');
                _currentVerdict = '';
            }

            /**
             * Submits the verdict form with the chosen action and remarks.
             * Requires remarks for reject and requestImprovement.
             */
            function submitVerdict() {
                var remarks = document.getElementById('modalRemarks').value.trim();

                if (_currentVerdict !== 'approve' && !remarks) {
                    showToast('Please add remarks before submitting.', 'error');
                    document.getElementById('modalRemarks').focus();
                    return;
                }

                document.getElementById('verdictAction').value = _currentVerdict;
                document.getElementById('verdictRemarks').value = remarks;
                document.getElementById('verdictForm').submit();
            }

            /* Close modal on overlay click */
            var vModal = document.getElementById('verdictModal');
            if (vModal) {
                vModal.addEventListener('click', function (e) {
                    if (e.target === this)
                        closeVerdict();
                });
            }

            /* Close modal on Escape key */
            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape')
                    closeVerdict();
            });

            /* ── Toast notification system ─────────────────────────────────── */
            /**
             * Shows a brief toast notification.
             *
             * @param {string} message - text to display
             * @param {string} type    - 'success' | 'error' | '' (neutral)
             */
            function showToast(message, type) {
                var container = document.getElementById('toastContainer');
                var t = document.createElement('div');
                t.className = 'toast ' + (type || '');
                t.textContent = message;
                container.appendChild(t);

                /* Trigger CSS transition */
                requestAnimationFrame(function () {
                    requestAnimationFrame(function () {
                        t.classList.add('show');
                    });
                });

                setTimeout(function () {
                    t.classList.remove('show');
                    setTimeout(function () {
                        if (t.parentNode)
                            t.parentNode.removeChild(t);
                    }, 300);
                }, 2800);
            }

            /* ── Utility: minimal HTML escape for dynamic DOM writes ───────── */
            function escapeHtml(str) {
                if (!str)
                    return '';
                return str.replace(/&/g, '&amp;')
                        .replace(/</g, '&lt;')
                        .replace(/>/g, '&gt;')
                        .replace(/"/g, '&quot;');
            }
            function setupLiveSearch(inputId, itemSelector, textSelectors) {
                const input = document.getElementById(inputId);
                if (!input) return;
                input.addEventListener('input', function(e) {
                    const query = e.target.value.toLowerCase();
                    const items = document.querySelectorAll(itemSelector);
                    items.forEach(item => {
                        let match = false;
                        textSelectors.forEach(sel => {
                            const el = item.querySelector(sel);
                            if (el && el.innerText.toLowerCase().includes(query)) {
                                match = true;
                            }
                        });
                        item.style.display = match ? '' : 'none';
                    });
                });
            }
            document.addEventListener('DOMContentLoaded', function() {
                setupLiveSearch('searchCourses', '.course-card', ['.cc-code', '.cc-name', '.kv-grid']);
                setupLiveSearch('searchQueue', '.paper-card', ['.paper-title', '.lecturer-chip', '.meta-chip']);
                setupLiveSearch('searchReviewed', '.timeline-item', ['.paper-title', '.timeline-lec', '.timeline-date']);
            });
        </script>
      <jsp:include page="footer.jsp"/>
</body>
</html>

