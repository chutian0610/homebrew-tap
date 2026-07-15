class ClaudeCode < Formula
  desc "Anthropic's official CLI for Claude"
  homepage "https://github.com/anthropics/claude-code"
  url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-arm64.tar.gz"
  version "2.1.210"
  sha256 "0d30caeef4dd693b331da31e0e0250e4ca6c5ec811f58ce961c2441d27efb1a2"

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
      sha256 "0d30caeef4dd693b331da31e0e0250e4ca6c5ec811f58ce961c2441d27efb1a2"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-x64.tar.gz"
      sha256 "cb720c25d0eb355c333f9d69e37180a18cee1aef5e47a119d5f95853a1104bb0"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-arm64.tar.gz"
      sha256 "83c01a39c3f785c6ae43c8923d5596e3246e7b87782b4cacc34259fbee5821d8"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-x64.tar.gz"
      sha256 "3db32c13a1e16b2d867d096a9808f42d8678c5597d10799a1904fd897e043beb"
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
