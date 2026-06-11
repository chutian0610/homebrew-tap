class ClaudeCode < Formula
  desc "Anthropic's official CLI for Claude"
  homepage "https://github.com/anthropics/claude-code"
  url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-arm64.tar.gz"
  version "2.1.173"
  sha256 "4db2313c2e92d21eb7767c1b12431785877339e6389366736b07bcc5a031dcfe"

  # claude-code is distributed under Anthropic's proprietary Commercial Terms
  # of Service, which incorporate the Acceptable Use Policy. This dual
  # license set has no SPDX representation, so we use `:cannot_represent`
  # and document the terms in this comment.
  #   - Anthropic Commercial Terms of Service
  #   - Anthropic Acceptable Use Policy
  license :cannot_represent

  # livecheck 块保留(满足 REQUIREMENTS.md FORM-08):
  # 主要的 version 同步走 GitHub Actions webhook,但保留 livecheck 作为兜底,
  # 以便用户在本地 `brew livecheck` 也能感知 upstream 新版本。
  livecheck do
    url :github_releases
    strategy :github_releases
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  on_macos do
    on_arm do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-arm64.tar.gz"
      sha256 "4db2313c2e92d21eb7767c1b12431785877339e6389366736b07bcc5a031dcfe"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-x64.tar.gz"
      sha256 "a3da948a15ae899df6540abc33030f514595f1ce082e5544f640ee1036550caf"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-arm64.tar.gz"
      sha256 "2f0038e9f7b3ee049e7db202b4f10af7d2e62af542b7fd7d1f542ea04166a4fe"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-x64.tar.gz"
      sha256 "b3d1afba5c02fa0fed43150e9470e556cf0cfc3a5c27d836a199d54051c96390"
    end
  end

  def install
    bin.install "claude"
  end

  def caveats
    <<~EOS
      This tap shadows the official homebrew-cask `claude-code` cask (which
      downloads from `downloads.claude.ai` and is unreachable from some
      networks). If you previously installed the cask, uninstall it first:

        brew uninstall --cask claude-code
    EOS
  end

  test do
    output = shell_output("#{bin}/claude --version")
    assert_match(/^#{Regexp.escape(version.to_s)}\b/, output)
  end
end
