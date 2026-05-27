#!/bin/bash
set -e

# Write flag — always exactly this block
mkdir -p /root
echo "${CTF_FLAG}" > /root/flag.txt
chmod 600 /root/flag.txt
chown root:root /root/flag.txt

# === Lab setup ===
apt-get update
apt-get install -y --no-install-recommends python3
rm -rf /var/lib/apt/lists/*

mkdir -p /opt/xss-lab/static
cat > /opt/xss-lab/app.py <<'PY'
#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs
import html

COMMENTS = [
    {"user": "alice", "text": "Welcome to the team board."},
    {"user": "bob", "text": "Remember to review the draft."},
]

INDEX = r'''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Team Notes</title>
  <style>
    body { font-family: Arial, sans-serif; background:#0f1117; color:#e2e8f0; margin:0; }
    .nav { background:#1e2130; border-bottom:1px solid #2d3748; padding:16px 24px; display:flex; justify-content:space-between; }
    .brand { color:#6366f1; font-weight:700; }
    .wrap { max-width:960px; margin:32px auto; padding:0 20px; }
    .card { background:#1e2130; border:1px solid #2d3748; border-radius:16px; padding:20px; margin-bottom:20px; box-shadow:0 10px 30px rgba(0,0,0,.25); }
    input, textarea, button { width:100%; box-sizing:border-box; margin-top:10px; padding:12px 14px; border-radius:10px; border:1px solid #2d3748; background:#0f1117; color:#e2e8f0; }
    button { background:#6366f1; border:none; font-weight:700; cursor:pointer; }
    .comment { padding:12px 0; border-top:1px solid #2d3748; }
    .muted { color:#94a3b8; }
    #flagBox { display:none; margin-top:16px; padding:14px; background:#102316; border:1px solid #22c55e; color:#22c55e; border-radius:10px; }
    code { color:#22c55e; }
  </style>
</head>
<body>
  <div class="nav"><div class="brand">Secubox</div><div>Reflected XSS Comment</div></div>
  <div class="wrap">
    <div class="card">
      <h2>Objective</h2>
      <p>Submit a comment that is rendered back into the page unsafely. Trigger the hidden action to reveal the flag.</p>
      <p class="muted">Hint: the page uses your input directly in the HTML response.</p>
    </div>
    <div class="card">
      <h2>Interactive demo</h2>
      <form method="GET" action="/">
        <label class="muted">Comment</label>
        <textarea name="comment" rows="4" placeholder="Write a comment..."></textarea>
        <button type="submit">Post comment</button>
      </form>
      <div id="comments">__COMMENTS__</div>
    </div>
    <div class="card">
      <h2>Flag reveal</h2>
      <p class="muted">The hidden action unlocks the secret below.</p>
      <div id="flagBox">Flag: <span id="flagValue">__CTF_FLAG__</span></div>
    </div>
  </div>
  <script>
    function revealFlag(){ document.getElementById('flagBox').style.display='block'; }
  </script>
</body>
</html>'''

class H(BaseHTTPRequestHandler):
    def do_GET(self):
        qs = parse_qs(urlparse(self.path).query)
        c = qs.get('comment', [''])[0]
        rendered = ''.join([f'<div class="comment"><strong>{html.escape(x["user"])}:</strong> {html.escape(x["text"])} </div>' for x in COMMENTS])
        if c:
            rendered += f'<div class="comment"><strong>you:</strong> {c}</div>'
        page = INDEX.replace('__COMMENTS__', rendered)
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(page.encode())

HTTPServer(('0.0.0.0', 8000), H).serve_forever()
PY
chmod +x /opt/xss-lab/app.py
cat > /etc/motd <<'MOTD'
Intermediate lab: the comment field reflects input into HTML. Find a payload that executes JavaScript and calls revealFlag().
MOTD

export KASM_VNC_CMD="bash"
python3 /opt/xss-lab/app.py >/tmp/xss-lab.log 2>&1 &

# Kasm startup — must be last line
exec /dockerstartup/vnc_startup.sh