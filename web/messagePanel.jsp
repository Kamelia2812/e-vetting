<%--
  messagePanel.jsp — Reusable per-assessment discussion panel.
  Include via: <jsp:include page="messagePanel.jsp"/>
  Requires request attribute: msgPaperId (int)
  Requires session attrs:     userId (int), fullName (String)
--%>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%
    Object _pid = request.getAttribute("msgPaperId");
    int    _msgPaperId = (_pid instanceof Integer) ? (Integer)_pid : 0;
    int    _msgUserId  = session.getAttribute("userId") != null ? (int) session.getAttribute("userId") : 0;
    String _msgCtx     = request.getContextPath();
%>
<style>
/* ── Message Panel ────────────────────────────────────────────── */
.msg-panel{background:#fff;border:1px solid var(--border);border-radius:var(--r);box-shadow:var(--sh);overflow:hidden;margin-bottom:16px}
.msg-panel-head{padding:13px 18px;border-bottom:1px solid var(--border);background:linear-gradient(135deg,#312e81,#4c1d95);display:flex;align-items:center;justify-content:space-between}
.msg-panel-title{font-size:13px;font-weight:800;color:#fff;display:flex;align-items:center;gap:8px}
.msg-unread-badge{background:#dc2626;color:#fff;border-radius:999px;font-size:10px;font-weight:700;padding:1px 7px;min-width:18px;text-align:center;display:none}
.msg-thread{height:360px;overflow-y:auto;padding:14px 16px;display:flex;flex-direction:column;gap:12px;background:#f8f7fc;scroll-behavior:smooth}
.msg-thread::-webkit-scrollbar{width:4px}
.msg-thread::-webkit-scrollbar-thumb{background:var(--teal-b);border-radius:4px}

/* Message rows */
.msg-row{display:flex;align-items:flex-end;gap:8px;max-width:90%}
.msg-mine{align-self:flex-end;flex-direction:row-reverse;margin-left:auto}
.msg-theirs{align-self:flex-start}
.msg-avatar{width:32px;height:32px;border-radius:50%;background:linear-gradient(135deg,#4c1d95,#6d28d9);color:#fff;display:grid;place-items:center;font-size:11px;font-weight:800;flex-shrink:0}
.msg-avatar-mine{background:linear-gradient(135deg,#f59e0b,#fcd34d);color:#2a1454}
.msg-bubble-wrap{display:flex;flex-direction:column;gap:3px;max-width:100%}
.msg-mine .msg-bubble-wrap{align-items:flex-end}
.msg-meta-top{display:flex;align-items:center;gap:6px;margin-bottom:1px}
.msg-sender{font-size:11px;font-weight:700;color:var(--ink2)}
.msg-role-chip{font-size:10px;font-weight:700;background:var(--teal-soft);color:var(--teal);border:1px solid var(--teal-b);border-radius:4px;padding:0 5px}
.msg-bubble{background:#fff;border:1px solid var(--border);border-radius:14px;border-bottom-left-radius:4px;padding:9px 13px;font-size:13px;line-height:1.55;color:var(--ink);max-width:420px;word-break:break-word;box-shadow:0 1px 3px rgba(11,22,40,.05)}
.msg-mine .msg-bubble{background:linear-gradient(135deg,#4c1d95,#6d28d9);color:#fff;border:none;border-radius:14px;border-bottom-right-radius:4px}
.msg-time{font-size:10px;color:var(--muted);margin-top:1px}
.msg-mine .msg-time{text-align:right}

/* Empty state */
.msg-empty{text-align:center;padding:40px 20px;font-size:12px;color:var(--muted);font-style:italic}

/* Loading */
.msg-loading{text-align:center;padding:20px;font-size:12px;color:var(--muted)}

/* Input area */
.msg-input-wrap{padding:12px 16px;border-top:1px solid var(--border);background:#fff;display:flex;gap:8px;align-items:flex-end}
.msg-textarea{flex:1;border:1px solid var(--border);border-radius:10px;padding:9px 12px;font-family:'Sora',sans-serif;font-size:13px;color:var(--ink);background:#fafbfc;outline:none;resize:none;min-height:40px;max-height:120px;line-height:1.5;transition:.15s;overflow-y:auto}
.msg-textarea:focus{border-color:var(--teal);background:#fff;box-shadow:0 0 0 3px var(--teal-soft)}
.msg-textarea::placeholder{color:var(--muted)}
.msg-send-btn{width:38px;height:38px;border-radius:50%;background:var(--teal);border:none;cursor:pointer;display:grid;place-items:center;flex-shrink:0;transition:.15s}
.msg-send-btn:hover{background:#4c1d95}
.msg-send-btn:disabled{background:var(--border);cursor:not-allowed}
.msg-send-btn svg{width:16px;height:16px;fill:none;stroke:#fff;stroke-width:2;stroke-linecap:round;stroke-linejoin:round}
</style>

<div class="msg-panel" id="msgPanel_<%= _msgPaperId %>">
  <div class="msg-panel-head">
    <div class="msg-panel-title">
      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.8)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/>
      </svg>
      Discussion
      <span class="msg-unread-badge" id="msgUnread_<%= _msgPaperId %>"></span>
    </div>
  </div>
  <div class="msg-thread" id="msgThread_<%= _msgPaperId %>">
    <div class="msg-loading">Loading messages...</div>
  </div>
  <div class="msg-input-wrap">
    <textarea class="msg-textarea" id="msgInput_<%= _msgPaperId %>"
              placeholder="Write a message..."
              rows="1"
              onkeydown="msgHandleKey(event, <%= _msgPaperId %>)"
              oninput="msgAutoResize(this)"></textarea>
    <button class="msg-send-btn" id="msgSendBtn_<%= _msgPaperId %>"
            onclick="msgSend(<%= _msgPaperId %>)" title="Send (Ctrl+Enter)">
      <svg viewBox="0 0 24 24"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>
    </button>
  </div>
</div>

<script>
(function() {
  var CTX  = '<%= _msgCtx %>';
  var PID  = <%= _msgPaperId %>;

  function threadEl()   { return document.getElementById('msgThread_'  + PID); }
  function inputEl()    { return document.getElementById('msgInput_'   + PID); }
  function sendBtn()    { return document.getElementById('msgSendBtn_' + PID); }
  function unreadEl()   { return document.getElementById('msgUnread_'  + PID); }

  function scrollToBottom() {
    var el = threadEl();
    if (el) el.scrollTop = el.scrollHeight;
  }

  function loadThread() {
    var el = threadEl();
    if (!el) return;
    el.innerHTML = '<div class="msg-loading">Loading...</div>';
    var xhr = new XMLHttpRequest();
    xhr.open('GET', CTX + '/MessageServlet?action=thread&paperId=' + PID, true);
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        if (xhr.status === 200) {
          el.innerHTML = xhr.responseText;
          scrollToBottom();
          // Hide unread badge after load
          var u = unreadEl();
          if (u) u.style.display = 'none';
        } else {
          el.innerHTML = '<div class="msg-empty">Could not load messages.</div>';
        }
      }
    };
    xhr.send();
  }

  window.msgSend = function(pid) {
    if (pid !== PID) return;
    var inp  = inputEl();
    var btn  = sendBtn();
    if (!inp || !btn) return;
    var body = inp.value.trim();
    if (!body) return;

    btn.disabled = true;
    var xhr = new XMLHttpRequest();
    xhr.open('POST', CTX + '/MessageServlet', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function() {
      if (xhr.readyState === 4) {
        btn.disabled = false;
        if (xhr.status === 200) {
          try {
            var resp = JSON.parse(xhr.responseText);
            if (resp.ok) {
              inp.value = '';
              inp.style.height = '';
              loadThread();
            }
          } catch(e) {}
        }
      }
    };
    xhr.send('action=send&paperId=' + PID + '&body=' + encodeURIComponent(body));
  };

  window.msgHandleKey = function(e, pid) {
    if (pid !== PID) return;
    // Ctrl+Enter or Cmd+Enter to send
    if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
      e.preventDefault();
      msgSend(pid);
    }
  };

  window.msgAutoResize = function(el) {
    el.style.height = 'auto';
    el.style.height = Math.min(el.scrollHeight, 120) + 'px';
  };

  // Initial load
  if (PID > 0) loadThread();
})();
</script>
