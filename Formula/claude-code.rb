class ClaudeCode < Formula
  desc "Anthropic's official CLI for Claude"
  homepage "https://github.com/anthropics/claude-code"
  url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-arm64.tar.gz"
  version "2.1.207"
  sha256 "42603b9b96c30a61da4a51c4c6e018db551c8605cd4e8b92777aa68ddaf88deb"

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
      sha256 "42603b9b96c30a61da4a51c4c6e018db551c8605cd4e8b92777aa68ddaf88deb"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-x64.tar.gz"
      sha256 "6afab88ee771f2ad2e67fd78f8b4ae0c1df9f100fddd86f49c064499c733ef99"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-arm64.tar.gz"
      sha256 "d656953866e463f9488105e59dff950040948672ff1a68f660b7cb4e96179e5c"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-x64.tar.gz"
      sha256 "8315b69621c8fa391404bc62682e954c64245fa5f2fe3d528b5489cbb973c871"
    end
  end

  def install
    bin.install "claude"
  end

  # 安装完成后在用户 $HOME/.local/bin 下建立软链接，
  # 便于将该目录放在 PATH 前列时直接调用 claude。
  def post_install
    local_bin = File.join(Dir.home, ".local/bin")
    # 若目标目录不存在则自动创建
    FileUtils.mkdir_p(local_bin)
    # 强制覆盖已有链接，指向当前 Cellar 中的二进制
    ln_sf bin/"claude", "#{local_bin}/claude"
  end

  def caveats
    local_bin = File.join(Dir.home, ".local/bin")
    in_path = ENV["PATH"]
      .split(File::PATH_SEPARATOR)
      .map { |p| File.expand_path(p) }
      .include?(local_bin)
    # 根据 PATH 检测结果给出对应提示
    # else 分支用 heredoc 包裹，避免双引号/$HOME/$PATH 被 Ruby 误解析
    path_hint = if in_path
      "`#{local_bin}` 已在当前 PATH 中，软链接可直接生效。"
    else
      <<~MSG
        `#{local_bin}` 不在当前 PATH 中，请将其加入 shell 配置，例如：

          export PATH="$HOME/.local/bin:$PATH"
      MSG
    end

    <<~EOS
      This tap shadows the official homebrew-cask `claude-code` cask (which
      downloads from `downloads.claude.ai` and is unreachable from some
      networks). If you previously installed the cask, uninstall it first:

        brew uninstall --cask claude-code

      已在 `#{local_bin}/claude` 创建指向本 formula 二进制的软链接。

      #{path_hint}
    EOS
  end

  test do
    output = shell_output("#{bin}/claude --version")
    assert_match(/^#{Regexp.escape(version.to_s)}\b/, output)
  end
end
