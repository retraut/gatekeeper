class Gatekeeper < Formula
  desc "Service authentication status monitor with daemon, CLI, tmux integration, and macOS GUI"
  homepage "https://github.com/retraut/gatekeeper"
  url "https://github.com/retraut/gatekeeper/releases/download/v0.2.0/gatekeeper-darwin-arm64"
  sha256 "REPLACE_ME_WITH_ACTUAL_SHA256"
  version "0.2.0"

  depends_on :macos

  def install
    bin.install "gatekeeper-darwin-arm64" => "gatekeeper"
  end

  test do
    system "#{bin}/gatekeeper", "--help"
  end
end
