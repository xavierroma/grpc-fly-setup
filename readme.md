# gRPC Connect Server Example with Fly.io

TLDR;
```toml
[[services.ports]]
port = 443
handlers = ["tls", "http"]
tls_options = { "alpn" = ["h2"] }
[services.ports.http_options]
h2_backend = true
```

- External traffic uses HTTP/2 with TLS (h2)
- Internal cluster communication uses HTTP/2 cleartext (h2c)
- Fly.io handles TLS termination

| Protocol | Web Browsers | Connect | gRPC-web | gRPC |
|----------|-------------|----------|-----------|------|
| HTTP/2 + TLS (h2) | ✓ | ✓ | ✓ | ✓ |
| HTTP/2 cleartext (h2c) | | ✓ | ✓ | ✓ |

## Key Configuration

- `handlers = ["tls", "http"]` - Orders Fly.io to first handle TLS termination, then pass the decrypted traffic to the HTTP handler
- `tls_options = { "alpn" = ["h2"] }` Advertises HTTP/2 support to clients through ALPN
- `h2_backend = true` - Tells Fly.io to forward requests to your application using h2c


Try it - replace `your-app.fly.dev` with your host
```bash
grpcurl -proto ./proto/eliza.proto \
  -import-path ./proto \
  -d '{"sentence": "hello"}' \
  your-app.fly.dev:443 \
  connectrpc.eliza.v1.ElizaService/Say
```