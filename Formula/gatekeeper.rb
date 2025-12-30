class Gatekeeper < Formula
  desc "Service authentication status monitor with daemon, CLI, and macOS GUI"
  homepage "https://github.com/retraut/gatekeeper"
  license "MIT"

  version "0.1.0"

  on_macos do
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v#{version}/gatekeeper-darwin-amd64"
      sha256 "0" * 64 # Placeholder, updated by CI/CD
    end
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v#{version}/gatekeeper-darwin-arm64"
      sha256 "0" * 64 # Placeholder, updated by CI/CD
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v#{version}/gatekeeper-linux-amd64"
      sha256 "0" * 64 # Placeholder, updated by CI/CD
    end
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v#{version}/gatekeeper-linux-arm64"
      sha256 "0" * 64 # Placeholder, updated by CI/CD
    end
  end

  def install
    # Determine binary name based on OS and architecture
    if OS.mac?
      arch_suffix = Hardware::CPU.arm? ? "arm64" : "amd64"
      bin.install "gatekeeper-darwin-#{arch_suffix}" => "gatekeeper"
    elsif OS.linux?
      arch_suffix = Hardware::CPU.arm? ? "arm64" : "amd64"
      bin.install "gatekeeper-linux-#{arch_suffix}" => "gatekeeper"
    end

    # Create config and cache directories
    (Dir.home / ".config" / "gatekeeper").mkpath
    (Dir.home / ".cache" / "gatekeeper").mkpath
  end

  def post_install
    puts "Gatekeeper installed successfully!"
    puts "\nInitialize config with:"
    puts "  gatekeeper init"
    puts "\nStart daemon with:"
    puts "  gatekeeper daemon"
    puts "\nFor tmux integration, add to ~/.tmux.conf:"
    puts '  set -g status-right "#(#{opt_bin}/gatekeeper-tmux) | #(date \'+%%H:%%M\')"'
  end

  service do
    run [opt_bin / "gatekeeper", "daemon"]
    keep_alive true
    log_path var / "log" / "gatekeeper.log"
    error_log_path var / "log" / "gatekeeper.error.log"
  end

  test do
    system bin / "gatekeeper", "init"
    assert_predicate (Dir.home / ".config" / "gatekeeper" / "config.yaml"), :exist?
  end
end
