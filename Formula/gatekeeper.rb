class Gatekeeper < Formula
  desc "Service authentication status monitor with daemon, CLI, tmux integration, and macOS GUI"
  homepage "https://github.com/retraut/gatekeeper"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.3.1/gatekeeper-darwin-arm64"
      sha256 "WILL_BE_REPLACED_BY_RELEASE_WORKFLOW"
    end
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.3.1/gatekeeper-darwin-amd64"
      sha256 "WILL_BE_REPLACED_BY_RELEASE_WORKFLOW"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.3.1/gatekeeper-linux-arm64"
      sha256 "WILL_BE_REPLACED_BY_RELEASE_WORKFLOW"
    end
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.3.1/gatekeeper-linux-amd64"
      sha256 "WILL_BE_REPLACED_BY_RELEASE_WORKFLOW"
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
