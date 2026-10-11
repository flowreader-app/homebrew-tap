# Homebrew cask template for the FlowReader desktop app.
#
# This file is a TEMPLATE, not the cask users install. `make deploy-homebrew`
# renders it with `scripts/render-package-manifest.mjs` from the release's
# verified `artifact-manifest.json` and commits the result to the tap
# flowreader-app/homebrew-tap as `Casks/flowreader.rb`
# (`brew install --cask flowreader-app/tap/flowreader`). `1.0.0` and `c164ed9e7f0000a5cd144c278221e4e6133752506a9481355b7058a7bed3816f` are substituted
# from that manifest, which is the same record the delivery gate checks the DMG
# bytes against — so the checksum a user's `brew install` verifies and the
# checksum the release published cannot drift apart.
#
# The placeholders are plain Ruby strings, so `ruby -c` parses this file as-is.
cask "flowreader" do
  version "1.0.0"
  sha256 "c164ed9e7f0000a5cd144c278221e4e6133752506a9481355b7058a7bed3816f"

  # One universal DMG, arm64 and x86_64 in the same bundle, so there is no
  # `arch` stanza and no per-architecture checksum. Downloaded from the public
  # release repository: the source repository is private.
  url "https://github.com/flowreader-app/flowreader/releases/download/v#{version}/FlowReader-macos-#{version}-universal.dmg",
      verified: "github.com/flowreader-app/flowreader/"
  name "FlowReader"
  desc "Distraction-free reading app with pacing aids"
  homepage "https://flowreader.io/"

  # `brew bump-cask-pr` and third-party tap checkers both need this to discover
  # a new version. `:github_latest` reads the repository's latest *stable*
  # release, so a prerelease tag never bumps the cask.
  livecheck do
    url "https://github.com/flowreader-app/flowreader"
    strategy :github_latest
  end

  # `src-tauri/tauri.conf.json` sets `minimumSystemVersion: "10.15"`.
  depends_on macos: ">= :catalina"

  app "FlowReader.app"

  # `com.flowreader.desktop` is the bundle identifier from
  # `src-tauri/tauri.conf.json`; the Tauri app data directory, the WebKit
  # storage and the window-state store all hang off it.
  #
  # Deliberately NOT here: the login keychain items FlowReader writes under the
  # service name `com.flowreader.desktop` (see `src-tauri/src/commands.rs`).
  # `zap` cannot remove keychain entries, and a cask must not claim to. Removing
  # those is a manual Keychain Access step, documented in
  # `docs/release/store-distribution.md`.
  zap trash: [
    "~/Library/Application Support/com.flowreader.desktop",
    "~/Library/Caches/com.flowreader.desktop",
    "~/Library/HTTPStorages/com.flowreader.desktop",
    "~/Library/Preferences/com.flowreader.desktop.plist",
    "~/Library/Saved Application State/com.flowreader.desktop.savedState",
    "~/Library/WebKit/com.flowreader.desktop",
  ]
end
