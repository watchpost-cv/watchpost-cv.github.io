# Watchpost website

Public website and documentation source for Watchpost, built with Nift.

Read `HANDOVER.md` before editing. Build from this directory with:

```sh
nift build
nift status
```

The generated deployment repository is nested at `public/` and is committed
separately before the source repository records its updated Git pointer.

## Documentation page ownership

Keep one clear responsibility per page. The canonical model of what is
monitored lives on `docs/posts`; `docs/agent-architecture` covers the separate
agent's installation, pairing, delivery, queueing, and local management;
`docs/security` covers authentication, sessions, bootstrap tokens, proxy
trust, and audit ordering; `docs/verification` records exercised gates and
their boundaries; `docs/collection` covers how observations enter Watchpost.
New or revised pages must be added to `.nift/tracked.json` and the navigation
in `templates/docs-nav.html`, and neighbouring pages should link rather than
duplicate.
