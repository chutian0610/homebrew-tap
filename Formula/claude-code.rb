class ClaudeCode < Formula
  desc "Anthropic's official CLI for Claude"
  homepage "https://github.com/anthropics/claude-code"
  url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-arm64.tar.gz"
  version "2.1.259"
  sha256 "2e9440dd56c919f962e8896c2b8f899b25cc020ebcad7aad702c85e7102d6422"

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
      sha256 "2e9440dd56c919f962e8896c2b8f899b25cc020ebcad7aad702c85e7102d6422"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-x64.tar.gz"
      sha256 "5513f60a87a24ede345d6a18497d4387e1959d1f0f66d795d6e0f3c9f37ff9fb"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-arm64.tar.gz"
      sha256 "de20156d423cf3d5038e5df732a28e642921a51ec110fd3a8b6d0d25415e7358"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-x64.tar.gz"
      sha256 "f77fff577240f535c9c1b44dfef705280cb4809d6f0d50b6997f4965331ade34"
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
