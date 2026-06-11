#!/usr/bin/env ruby
# frozen_string_literal: true
#
# scripts/bump_formula.rb
#
# 上游 anthropics/claude-code 发布了新版本时，把 Formula/claude-code.rb
# 中的 version 与各平台 sha256 同步更新。
#
# 用法：
#   bump_formula.rb <formula_path> <new_version> <shasums_path>
#
# 参数：
#   formula_path  -- Formula 文件路径
#   new_version   -- 新的版本号（不带 v 前缀），例如 2.1.200
#   shasums_path  -- SHASUMS256.txt 路径（每行 "<sha>  <filename>"）

formula_path = ARGV[0] or abort '缺少 formula_path'
new_version  = ARGV[1] or abort '缺少 new_version'
shasums_path = ARGV[2] or abort '缺少 shasums_path'

abort "非法 version: #{new_version}" unless new_version.match?(/\A\d[\d.]*\z/)

# 解析 SHASUMS256.txt -> {filename => sha}
shas = File.foreach(shasums_path).with_object({}) do |line, h|
  sha, name = line.strip.split(/\s+/, 2)
  h[name] = sha if name && !name.empty?
end

formula = File.read(formula_path)

# 1) 更新顶部 version 行
version_pattern = /^(\s*version\s+")\K[^"]+/
unless formula.sub!(version_pattern) { new_version }
  abort '未找到 version 行，更新失败'
end

# 2) 更新顶部 url/version/sha256（3 行结构：url → version → sha256）
#    顶部 url 历史上固定指向 darwin-arm64，保持与原 formula 一致
top_level_pattern = /^(\s*url\s+"[^"]*claude-darwin-arm64\.tar\.gz"\s*\n\s*version\s+"[^"]+"\s*\n\s*sha256\s+")[a-f0-9]+(")/
top_level_sha = shas['claude-darwin-arm64.tar.gz'] or abort 'SHASUMS256.txt 中缺少 darwin-arm64'
unless formula.sub!(top_level_pattern, "\\1#{top_level_sha}\\2")
  abort 'Formula 中找不到顶部 url/version/sha256 锚点'
end

# 3) 更新 4 个平台的 sha256
#    URL 行形如：
#      url ".../claude-<platform>.tar.gz"
#      sha256 "<old_sha>"
#    我们锚定 URL，把紧随其后的 sha256 整段替换掉。
PLATFORMS = %w[darwin-arm64 darwin-x64 linux-arm64 linux-x64].freeze
PLATFORMS.each do |platform|
  filename = "claude-#{platform}.tar.gz"
  new_sha = shas[filename] or abort "SHASUMS256.txt 中缺少 #{filename}，上游可能新增/删除了平台"

  # 多行匹配：URL 行 + 紧随其后的 sha256 行
  pattern = /^(.*?claude-#{Regexp.escape(platform)}\.tar\.gz"\s*\n\s*sha256\s+")[a-f0-9]+(")/
  unless formula.sub!(pattern, "\\1#{new_sha}\\2")
    abort "Formula 中找不到 #{platform} 的 sha256 锚点"
  end
end

File.write(formula_path, formula)
puts "OK: formula 已更新到 #{new_version}"
