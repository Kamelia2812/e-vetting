<%--
  notificationBell.jsp — drop-in notification bell for any topnav.
  Requires session attrs: userId (int)
  Usage: place this include inside .nav-right, before the logout link.
--%>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%
    String _nbCtx = request.getContextPath();
%>
<style>
/* ── Notification bell ── */
.nb-wrap{position:relative;flex-shrink:0}
.nb-btn{width:32px;height:32px;border-radius:50%;border:1px solid rgba(255,255,255,.2);background:none;color:rgba(255,255,255,.7);display:grid;place-items:center;cursor:pointer;transition:.15s;position:relative}
.nb-btn:hover{background:rgba(255,255,255,.1);color:#fff}
.nb-btn svg{width:16px;height:16px;fill:none;stroke:currentColor;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
.nb-badge{position:absolute;top:-4px;right:-4px;min-width:16px;height:16px;border-radius:8px;background:#dc2626;color:#fff;font-size:9px;font-weight:700;display:none;align-items:center;justify-content:center;padding:0 4px;line-height:1;border:2px solid #4c1d95}
.nb-badge.show{display:flex}
.nb-dropdown{display:none;position:absolute;right:0;top:40px;width:320px;background:#fff;border:1px solid #e4e9f0;border-radius:10px;box-shadow:0 8px 30px rgba(0,0,0,.18);z-index:999;overflow:hidden}
.nb-dropdown.open{display:block}
.nb-dhead{display:flex;align-items:center;justify-content:space-between;padding:11px 14px;border-bottom:1px solid #e4e9f0;background:#f9fafb}
.nb-dhead-title{font-size:12px;font-weight:700;color:#1e1133}
.nb-mark-all{font-size:11px;color:#6d28d9;background:none;border:none;cursor:pointer;font-family:inherit;font-weight:600;padding:0}
.nb-mark-all:hover{color:#4c1d95}
.nb-list{max-height:340px;overflow-y:auto}
.nb-list::-webkit-scrollbar{width:4px}
.nb-list::-webkit-scrollbar-thumb{background:#ddd6fe;border-radius:4px}
.notif-item{display:flex;align-items:flex-start;gap:9px;padding:10px 14px;cursor:pointer;border-bottom:1px solid #f1f5f9;transition:.12s}
.notif-item:hover{background:#f5f3ff}
.notif-item:last-child{border-bottom:none}
.notif-item.notif-read{opacity:.6}
.notif-icon{flex-shrink:0;margin-top:3px}
.notif-content{flex:1;min-width:0}
.notif-text{font-size:12px;color:#1e1133;line-height:1.45;word-break:break-word}
.notif-time{font-size:10px;color:#7a8aab;margin-top:3px}
.notif-empty{padding:24px 16px;text-align:center;font-size:12px;color:#7a8aab;font-style:italic}
</style>

<div class="nb-wrap" id="nbWrap">
  <button class="nb-btn" onclick="nbToggle()" title="Notifications" aria-label="Notifications">
    <svg viewBox="0 0 24 24"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
    <div class="nb-badge" id="nbBadge"></div>
  </button>
  <div class="nb-dropdown" id="nbDropdown">
    <div class="nb-dhead">
      <span class="nb-dhead-title">Notifications</span>
      <button class="nb-mark-all" onclick="nbMarkAll()">Mark all read</button>
    </div>
    <div class="nb-list" id="nbList">
      <div class="notif-empty">Loading...</div>
    </div>
  </div>
</div>

<script>
(function(){
  var CTX = '<%= _nbCtx %>';
  var nbOpen = false;

  function nbLoadCount() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', CTX + '/NotificationServlet?action=count', true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4 && xhr.status === 200) {
        var n = parseInt(xhr.responseText, 10) || 0;
        var badge = document.getElementById('nbBadge');
        if (badge) {
          badge.textContent = n > 9 ? '9+' : String(n);
          if (n > 0) badge.classList.add('show'); else badge.classList.remove('show');
        }
      }
    };
    xhr.send();
  }

  function nbLoadList() {
    var list = document.getElementById('nbList');
    if (!list) return;
    list.innerHTML = '<div class="notif-empty">Loading...</div>';
    var xhr = new XMLHttpRequest();
    xhr.open('GET', CTX + '/NotificationServlet?action=list', true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4 && xhr.status === 200) {
        list.innerHTML = xhr.responseText || '<div class="notif-empty">No notifications.</div>';
      }
    };
    xhr.send();
  }

  window.nbToggle = function() {
    var dd = document.getElementById('nbDropdown');
    if (!dd) return;
    nbOpen = !nbOpen;
    if (nbOpen) {
      dd.classList.add('open');
      nbLoadList();
    } else {
      dd.classList.remove('open');
    }
  };

  window.markRead = function(nid, paperId) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', CTX + '/NotificationServlet', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.send('action=markRead&id=' + nid);
    nbLoadCount();
    nbLoadList();
    if (paperId > 0) {
      window.location.href = CTX + '/LecturerReviewServlet?paperId=' + paperId;
    }
  };

  window.nbMarkAll = function() {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', CTX + '/NotificationServlet', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) { nbLoadCount(); nbLoadList(); }
    };
    xhr.send('action=markAllRead');
  };

  // Close dropdown when clicking outside
  document.addEventListener('click', function(e) {
    var wrap = document.getElementById('nbWrap');
    if (wrap && !wrap.contains(e.target) && nbOpen) {
      document.getElementById('nbDropdown').classList.remove('open');
      nbOpen = false;
    }
  });

  // Load count on page load and poll every 60s
  nbLoadCount();
  setInterval(nbLoadCount, 60000);
})();
</script>
