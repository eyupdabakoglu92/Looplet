# qa-fn-proxy.py — QA copy of evidence/fn-proxy.py (mode file: qa/functional-r1/proxy-mode) in front of the Functions emulator.
# The app's debug emulator wiring calls functions on :5001 (infra/firebase.json); the evidence
# config (firebase.evidence.json) runs the Functions emulator on :5002 and this proxy on :5001.
# Mode = the first word of evidence/runtime/proxy-mode (re-read per request):
#   pass  forward the request, return the response
#   drop  forward the request (the server runs and writes), then close the client connection
#         without a response — a mid-request drop after the server write
#   hold  forward the request, keep the client connection open without a response
#   down  refuse: close at once without forwarding (the backend is unreachable)
#   slow  wait 4 s, then pass (a request still in flight when the screen goes away)
import http.server, socketserver, urllib.request, urllib.error, os, time, sys, datetime
MODE = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'proxy-mode')
def mode():
    try: return open(MODE).read().split()[0]
    except Exception: return 'pass'
class H(http.server.BaseHTTPRequestHandler):
    def log_message(self, *a): pass
    def do_POST(self):
        m = mode()
        body = self.rfile.read(int(self.headers.get('Content-Length', 0)))
        stamp = datetime.datetime.utcnow().isoformat(timespec='milliseconds') + 'Z'
        if m == 'down':
            print(f'{stamp} {m} {self.path} -> closed without forwarding', flush=True)
            self.close_connection = True; return
        if m == 'slow':
            time.sleep(4)
        req = urllib.request.Request('http://127.0.0.1:5002' + self.path, data=body, method='POST',
            headers={k: v for k, v in self.headers.items() if k.lower() not in ('host', 'content-length')})
        try:
            with urllib.request.urlopen(req) as r:
                status, headers, data = r.status, r.getheaders(), r.read()
        except urllib.error.HTTPError as e:  # QA fix: pass 4xx/5xx through (the delivery proxy dropped them)
            status, headers, data = e.code, e.headers.items(), e.read()
        print(f'{stamp} {m} {self.path} upstream {status} {data[:120]!r}', flush=True)
        if m == 'drop':
            self.close_connection = True; return
        if m == 'hold':
            while mode() == 'hold': time.sleep(0.5)
            self.close_connection = True; return
        self.send_response(status)
        for k, v in headers:
            if k.lower() not in ('transfer-encoding', 'connection', 'content-length'): self.send_header(k, v)
        self.send_header('Content-Length', str(len(data))); self.end_headers(); self.wfile.write(data)
class S(socketserver.ThreadingMixIn, http.server.HTTPServer): daemon_threads = True
print('fn-proxy on :5001 -> :5002', flush=True)
S(('127.0.0.1', 5001), H).serve_forever()
