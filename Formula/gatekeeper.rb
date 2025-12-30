class Gatekeeper < Formula
  desc "Service authentication status monitor with daemon, CLI, tmux integration, and macOS GUI"
  homepage "https://github.com/retraut/gatekeeper"
  license "MIT"
  version "v0.4.1"

  on_macos do
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.4.1/gatekeeper-darwin-arm64"
      sha256 "52390beb55ec5d5394598af1f02c650dbc3ac8db8c5671aa065ba4dcebb6446b"
    end
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.4.1/gatekeeper-darwin-amd64"
      sha256 "f08b2589019c523d1c6dc0fed948ac4ce64755af666e952da1e6be9588fb755e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.4.1/gatekeeper-linux-arm64"
      sha256 "8bcf66fed6f46a099e87b01b902eb9fa244128a41dd5417a574e4097924d9490"
    end
    on_intel do
      url "https://github.com/retraut/gatekeeper/releases/download/v0.4.1/gatekeeper-linux-amd64"
      sha256 "202f83ed84806fbb12769727631c09d58f5aacb8e35fc707f8d22766ccb47394"
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
