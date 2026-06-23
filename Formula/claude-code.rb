class ClaudeCode < Formula
  desc "Anthropic's official CLI for Claude"
  homepage "https://github.com/anthropics/claude-code"
  url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-arm64.tar.gz"
  version "2.1.186"
  sha256 "8f87d5ce142b729a62e23ee18ad5645b3836c5e72f2fb249acf228f1e0611342"

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
      sha256 "8f87d5ce142b729a62e23ee18ad5645b3836c5e72f2fb249acf228f1e0611342"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-x64.tar.gz"
      sha256 "073a36742e716169fb185eb65b8719e3714b6788aff757476d9b73866adf4a72"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-arm64.tar.gz"
      sha256 "74c099dc935ff69ea0e31be067766945de8abc76444dd170772a7f3ba52329c9"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-x64.tar.gz"
      sha256 "2df436ea6486ec8dee5316ec8fad6f922d3aee24bfcb15c8fa663864b6338698"
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
