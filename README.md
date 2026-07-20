# chutian0610/homebrew-tap

A personal Homebrew tap that distributes Anthropic's official `claude-code` CLI
from GitHub Releases — works where `downloads.claude.ai` doesn't.

## Installation

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

## Relationship with the official homebrew-cask

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

## Known issues

### `claude doctor` reports two benign warnings

`claude doctor`'s installation detection only recognizes a fixed set of
install methods: the official native installer (`~/.local/share/claude/versions/`),
npm global/local installs, and a handful of package managers — where Homebrew
is only detected via `/Caskroom/` paths (i.e. the official **cask**). A
third-party tap **formula** like this one matches none of them, so doctor
classifies it as an unregistered "native" install and reports:

1. `Running native installation but config install method is 'not set'` —
   the formula install is not recorded in `~/.claude.json`'s `installMethod`.
2. `/Users/<you>/.local/bin/claude was not created by the native installer
   (it is not a symlink into the versions/ directory), so auto-update leaves
   it untouched` — only appears if you created that symlink yourself.

Both warnings are **harmless and can be ignored**: updates are delivered via
`brew upgrade`, and Claude Code's built-in auto-updater explicitly leaves
non-native binaries untouched (which is exactly the behavior you want for a
brew-managed install). Do not work around the second warning by writing
`"installMethod": "native"` into `~/.claude.json` — that can activate the
native auto-updater, which downloads versions into `~/.local/share/claude/`
that never end up on your `PATH`.

### The formula intentionally does not create `~/.local/bin/claude`

Some tools look for `claude` at `~/.local/bin/claude` (the native installer's
default location). This formula does **not** create that symlink for you,
because Homebrew runs `post_install` with `HOME` redirected to a temporary
directory inside a sandbox (`deny_read_home`) — writes to the real home
directory are silently discarded or denied, and the resulting symlink would
also point at the versioned Cellar path that breaks on every upgrade.

If you want the symlink, create it **once**, pointing at Homebrew's stable
`opt` path (which brew re-points to the current Cellar version on every
upgrade, so the link never goes stale):

```sh
mkdir -p "$HOME/.local/bin" && ln -sf "$(brew --prefix)/opt/claude-code/bin/claude" "$HOME/.local/bin/claude"
```

## Auto-updates

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
