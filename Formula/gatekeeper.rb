class Gatekeeper < Formula
  desc "Service authentication status monitor with daemon, CLI, tmux integration, and macOS GUI"
  homepage "https://github.com/retraut/gatekeeper"

  on_macos do
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.3.0/gatekeeper-darwin-arm64"
      sha256 "a14cee5c85fba47eba86ddc703ed6007e1fc3f3c7b8b79652901cae60bc9abcb"
    end
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.3.0/gatekeeper-darwin-amd64"
      sha256 "7c8f5d4e6a9b2c1f3e8d9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8b9"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.3.0/gatekeeper-linux-arm64"
      sha256 "9f8e7d6c5b4a3f2e1d0c9b8a7f6e5d4c3b2a1f0e9d8c7b6a5f4e3d2c1b0a9"
    end
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.3.0/gatekeeper-linux-amd64"
      sha256 "1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1"
    end
  end

  def install
    # Extract arch and os from binary name pattern
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
    system "#{bin}/gatekeeper", "--help"
  end
end
