class Gatekeeper < Formula
  desc "Service authentication status monitor with daemon, CLI, tmux integration, and macOS GUI"
  homepage "https://github.com/retraut/gatekeeper"
  license "MIT"
  version "v0.6.0"

  on_macos do
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.6.0/gatekeeper-darwin-arm64"
      sha256 "90c13a9edc065adbfe10b735a34ff40bc88cabb59fd68c4e96461a38ce567422"
    end
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.6.0/gatekeeper-darwin-amd64"
      sha256 ""
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.6.0/gatekeeper-linux-arm64"
      sha256 "245c578889486da4a06b4d9f063999f4cd7defd1fd68922b362a36e486b84cba"
    end
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.6.0/gatekeeper-linux-amd64"
      sha256 "89d16d177b58e12500483ddefb1726217a0c388aaf255831c3db4654f7e0164b"
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
