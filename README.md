# chutian0610/homebrew-tap

A personal Homebrew tap that distributes Anthropic's official `claude-code` CLI
from GitHub Releases — works where `downloads.claude.ai` doesn't.

## English

### Installation

```sh
brew install chutian0610/tap/claude-code
```

No `brew tap` step is required; the qualified formula name resolves the tap
automatically. After installation, verify with:

```sh
claude --version
```

Supported platforms:

- macOS Apple Silicon (`arm64`)
- macOS Intel (`x64`)
- Linux `arm64`
- Linux `x64`

Windows is not supported by this tap. Windows users should use the official
installer from Anthropic.

### Relationship with the official homebrew-cask

`homebrew-cask` already ships a `claude-code` cask. That cask downloads the
binary from `https://downloads.claude.ai/...`. This tap is **not** a replacement for the
casks team — it is a personal mirror that pulls the same binary from
`github.com/anthropics/claude-code` releases instead.

If you previously installed the official cask, uninstall it before installing
from this tap to avoid the `claude` binary colliding on `PATH`:

```sh
brew uninstall --cask claude-code
brew install chutian0610/tap/claude-code
```

You can confirm which `claude` is on your `PATH` with `which claude`. The
formula installs to Homebrew's `bin` directory (`/opt/homebrew/bin/claude` on
Apple Silicon, `/usr/local/bin/claude` on Intel macOS, `/home/linuxbrew/.linuxbrew/bin/claude`
on Linux).

### Auto-updates

A daily GitHub Actions workflow (`.github/workflows/bump-claude-code.yml`)
watches [anthropics/claude-code releases](https://github.com/anthropics/claude-code/releases).

When a new version is published upstream, the workflow:

1. Fetches the latest release tag via the GitHub API.
2. Downloads the upstream `SHASUMS256.txt` (signed by Anthropic) instead of
   hashing tarballs itself.
3. Runs `scripts/bump_formula.rb` to update `version` and the four
   platform-specific `sha256` values in `Formula/claude-code.rb`.
4. Re-verifies every sha256 in the formula against `SHASUMS256.txt` and runs
   `ruby -c` for a syntax check.
5. Opens a pull request against `main` for human review.

The workflow can also be triggered manually from the Actions tab
(`workflow_dispatch`) to force a re-check. Direct pushes to `main` never
happen — every bump is reviewed via PR before the formula is updated for
end users.

If Anthropic ever changes the asset naming (e.g. renames
`claude-darwin-arm64.tar.gz`) or adds a new platform, the bump script will
fail loudly with a clear error message, and the PR will not be opened. In
that case, update `PLATFORMS` in `scripts/bump_formula.rb` to match the new
shape and rerun the workflow.
