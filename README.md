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
