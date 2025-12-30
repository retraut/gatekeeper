class Gatekeeper < Formula
  desc "Service authentication status monitor with daemon, CLI, tmux integration, and macOS GUI"
  homepage "https://github.com/retraut/gatekeeper"
  license "MIT"
  version "v0.5.0"

  on_macos do
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.5.0/gatekeeper-darwin-arm64"
      sha256 "5b9a76977fcb6cb8589219a9214cc5b6d5b9691d301e8cbf3515950fbdcf8f0b"
    end
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.5.0/gatekeeper-darwin-amd64"
      sha256 "8da35a8a39989cc0ab8d96e87f1350fb035ff202e0aa88d6bbc3e6a9b48ebbf3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.5.0/gatekeeper-linux-arm64"
      sha256 "365f080d3b0758c1f38a4b928bbbe25403f039ab4dce92a61bd37c8b1c5d22fb"
    end
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.5.0/gatekeeper-linux-amd64"
      sha256 "41bb22b169cb9656e1e106830d066df53693d7971c24f86caaefeb54b6cfd02c"
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
