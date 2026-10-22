class ClaudeCode < Formula
  desc "Anthropic's official CLI for Claude"
  homepage "https://github.com/anthropics/claude-code"
  url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-arm64.tar.gz"
  version "2.1.308"
  sha256 "e05000c2f5194208379b025df141e4f286ada8b3151fd7c1876d2a339ecf8fa3"

  # claude-code is distributed under Anthropic's proprietary Commercial Terms
  # of Service, which incorporate the Acceptable Use Policy. This dual
  # license set has no SPDX representation, so we use `:cannot_represent`
  # and document the terms in this comment.
  #   - Anthropic Commercial Terms of Service
  #   - Anthropic Acceptable Use Policy
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-arm64.tar.gz"
      sha256 "e05000c2f5194208379b025df141e4f286ada8b3151fd7c1876d2a339ecf8fa3"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-x64.tar.gz"
      sha256 "3fda4561145b340ee679b0bb06dfc3cc67e1aebda802829c112c91cc2fc078ad"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-arm64.tar.gz"
      sha256 "196b868da6b7c1105c55aa44f3d99c1f7d1325559940924dca92da9e4c6f12a0"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-x64.tar.gz"
      sha256 "6a699c7205d3c5f99e03a21d6b0511366f41c9a7284547b6e0785504ebdb261a"
    end
  end

  def install
    bin.install "claude"
  end

  # 注意：不要在 post_install 中向用户主目录（如 ~/.local/bin）写文件。
  # Homebrew 运行 post_install 时会将 HOME 替换为临时目录并启用 sandbox
  # （deny_read_home），写入要么落到临时目录被丢弃、要么被 sandbox 拒绝，
  # 且不会报错——这就是之前 ~/.local/bin/claude 升级后断链却无人修复的原因。
  def caveats
    local_bin = File.join(Dir.home, ".local/bin")

    <<~EOS
      This tap shadows the official homebrew-cask `claude-code` cask (which
      downloads from `downloads.claude.ai` and is unreachable from some
      networks). If you previously installed the cask, uninstall it first:

        brew uninstall --cask claude-code

      claude 已通过 `#{HOMEBREW_PREFIX}/bin/claude` 提供（brew 自动维护，升级不受影响）。

      如需让 claude 出现在 `#{local_bin}`（部分工具默认在该路径查找），
      可一次性执行以下命令，创建指向 opt 稳定路径的软链接：

        mkdir -p "#{local_bin}" && ln -sf "#{opt_bin}/claude" "#{local_bin}/claude"

      该链接指向 `#{opt_bin}`（brew 每次升级会自动将其重定向到新版 Cellar），
      因此升级后不会失效，无需重复执行。
    EOS
  end

  test do
    output = shell_output("#{bin}/claude --version")
    assert_match(/^#{Regexp.escape(version.to_s)}\b/, output)
  end
end
