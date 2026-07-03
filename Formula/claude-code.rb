class ClaudeCode < Formula
  desc "Anthropic's official CLI for Claude"
  homepage "https://github.com/anthropics/claude-code"
  url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-arm64.tar.gz"
  version "2.1.199"
  sha256 "30b628e9623d824e37fc3368ed02c93637a524d97031eae0373857013290e8ac"

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
      sha256 "30b628e9623d824e37fc3368ed02c93637a524d97031eae0373857013290e8ac"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-x64.tar.gz"
      sha256 "28633041a069cc5f3f7513c85d4c979aff03e8cc9098e4558a83d921531b4890"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-arm64.tar.gz"
      sha256 "fb4a6ee96fb79b9c2447df52e47142691a696d9748d4a423d3b594fc0dff751a"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-x64.tar.gz"
      sha256 "80a65363a6735143f9bbd7b7c44af604ccd356c78bf4ded12491e66f2bfe7402"
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
