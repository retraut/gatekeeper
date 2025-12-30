class Gatekeeper < Formula
  desc "Service authentication status monitor with daemon, CLI, tmux integration, and macOS GUI"
  homepage "https://github.com/retraut/gatekeeper"
  license "MIT"
  version "v0.5.2"

  on_macos do
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.5.2/gatekeeper-darwin-arm64"
      sha256 "8d51d3f67f95a88f857aa81ccdd637efc50d22d46ad61c04223eeb08955f728c"
    end
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.5.2/gatekeeper-darwin-amd64"
      sha256 "165189cc85ac2cef1d209dcec35e17381057bf972aa5ba4b886ef1c8e3dd0366"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.5.2/gatekeeper-linux-arm64"
      sha256 ""
    end
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.5.2/gatekeeper-linux-amd64"
      sha256 "dfc3f1f93d3e9cbe01199bb21a4ed92b9c339da278c89b0a77da4b40c1cbbb0b"
    end
  end

  def install
    arch = if Hardware::CPU.arm?
             "arm64"
           else
             "amd64"
           end
    
    os_name = if OS.mac?
                "darwin"
              elsif OS.linux?
                "linux"
              else
                "unknown"
              end
    
    binary_name = "gatekeeper-#{os_name}-#{arch}"
    bin.install binary_name => "gatekeeper"
  end

  test do
    system "#{<built-in function bin>}/gatekeeper", "--help"
  end
end
