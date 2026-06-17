class ClaudeCode < Formula
  desc "Anthropic's official CLI for Claude"
  homepage "https://github.com/anthropics/claude-code"
  url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-arm64.tar.gz"
  version "2.1.179"
  sha256 "0137d8dbc95d3a993dc74580ad4c3bd3a187c526882af05d0b5d6b0462fdafe3"

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
      sha256 "0137d8dbc95d3a993dc74580ad4c3bd3a187c526882af05d0b5d6b0462fdafe3"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-darwin-x64.tar.gz"
      sha256 "80cee5f1bb773aa8171174816ed2cd9f430dd16a5568db8e0254d66368245bb9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-arm64.tar.gz"
      sha256 "2439f35a1520c4ff9fb8748893db53cbeb25e98cee3882cea7d8774ca3e978bb"
    end
    on_intel do
      url "https://github.com/anthropics/claude-code/releases/download/v#{version}/claude-linux-x64.tar.gz"
      sha256 "ab2332560769f1717ec215f4737d19445f251fb7ccee2de0207a129eccf52e21"
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
