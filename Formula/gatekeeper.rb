class Gatekeeper < Formula
  desc "Service authentication status monitor with daemon, CLI, tmux integration, and macOS GUI"
  homepage "https://github.com/retraut/gatekeeper"
  url "https://github.com/retraut/gatekeeper/releases/download/v0.3.0/gatekeeper-darwin-arm64"
  sha256 "a14cee5c85fba47eba86ddc703ed6007e1fc3f3c7b8b79652901cae60bc9abcb"
  version "0.3.0"

  depends_on :macos

  def install
    bin.install "gatekeeper-darwin-arm64" => "gatekeeper"
  end

  test do
    system "#{bin}/gatekeeper", "--help"
  end
end
