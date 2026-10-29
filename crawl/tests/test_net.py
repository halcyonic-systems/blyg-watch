"""net.Fetcher against a local static server: the User-Agent goes out, and a
second read of an unchanged file is a conditional request answered 304."""
import functools
import http.server
import tempfile
import threading
import unittest
from pathlib import Path

from blygwatch.net import USER_AGENT, Fetcher

SAMPLE = Path(__file__).parent / "fixtures" / "conformance-samples" / "fake-remote"


class Handler(http.server.SimpleHTTPRequestHandler):
    seen = []

    def log_message(self, *args):
        pass

    def send_response(self, code, message=None):
        Handler.seen.append((self.headers.get("User-Agent"), code))
        super().send_response(code, message)


class TestFetcher(unittest.TestCase):
    def test_conditional_get_and_user_agent(self):
        server = http.server.ThreadingHTTPServer(
            ("127.0.0.1", 0), functools.partial(Handler, directory=str(SAMPLE)))
        threading.Thread(target=server.serve_forever, daemon=True).start()
        url = f"http://127.0.0.1:{server.server_address[1]}/blyg.json"
        try:
            with tempfile.TemporaryDirectory() as cache:
                fetch = Fetcher(cache, interval=0)
                first, second = fetch.get(url), fetch.get(url)
        finally:
            server.shutdown()
        self.assertEqual(first.body, second.body)
        self.assertEqual(Handler.seen, [(USER_AGENT, 200), (USER_AGENT, 304)])
        self.assertEqual(fetch.requests, 2)


if __name__ == "__main__":
    unittest.main()
