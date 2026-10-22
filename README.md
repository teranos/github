# QNTX GitHub Plugin

GitHub integration for repository event tracking and automation.

## Features

- **Event Polling**: Periodic polling of GitHub API for repository events
- **Attestation Creation**: Creates attestations for:
  - Pull requests merged
  - Releases published
  - Issues opened/closed
  - Pushes to main/master branches
- **Rate Limit Aware**: Respects GitHub API rate limits (5,000 requests/hour with token)

## Configuration

The plugin is its record on the node ([QNTX ADR-002](https://github.com/teranos/QNTX/blob/main/docs/adr/ADR-002-plugin-configuration.md)): `plugins_add` this repository's URL, then `PUT /api/plugins/github/config` with the plugin's keys:

| Key | |
|---|---|
| `token` | GitHub personal access token |
| `repos` | Repositories to watch, `owner/repo` |
| `poll_interval` | Seconds between polls; 300 when unset |

and QNTX's `build.*` keys, so the node builds it from this repository:

| Key | Value |
|---|---|
| `build.core` | `github.com/teranos/github@main` |
| `build.packages` | `go` |
| `build.command` | `CGO_ENABLED=0 go build -o bin/qntx-github-plugin ./cmd/qntx-github-plugin` |
| `build.output` | `bin/qntx-github-plugin` |

ADR-002 names a plugin after the last segment of its repository URL: this repository is `github`, and so is the plugin's `Metadata().Name`.

## Event Attestations

### Pull Request Merged
- **Subject**: PR URL
- **Predicate**: `pr-merged`
- **Context**: `github`
- **Attributes**: pr_number, pr_title, pr_url, author, base_ref, head_ref, merged_at

### Release Published
- **Subject**: Release URL
- **Predicate**: `released`
- **Context**: `github`
- **Attributes**: tag, name, url, author, body

### Issue Opened/Closed
- **Subject**: Issue URL
- **Predicate**: `issue-opened` or `issue-closed`
- **Context**: `github`
- **Attributes**: issue_number, title, url, author, state

### Push to Main/Master
- **Subject**: Branch URL
- **Predicate**: `pushed`
- **Context**: `github`
- **Attributes**: ref, branch, commit_count, commits, actor

## Usage

The plugin automatically creates attestations for repository events. Query them in the canvas:

```
// Find all merged PRs
subject: * predicate: pr-merged context: github

// Find all releases
subject: * predicate: released context: github
```

Compose with other plugins (e.g., post to Bluesky via qntx-atproto) using ax-py meld.

## Building & Installation

This is its own Go module, `github.com/teranos/github`, requiring `github.com/teranos/QNTX` (see `go.mod`). It is pure Go: QNTX's cgo storage is the node's, not the plugin's, so it builds with `CGO_ENABLED=0`.

```bash
# Build bin/qntx-github-plugin
make build

# Install to ~/.qntx/plugins/
make install
```

`flake.nix` pins the nixpkgs the node builds with (`nix shell --inputs-from <this repo> nixpkgs#go`, ADR-002) and gives `nix develop` a shell with go and make.
