# Homebrew cask template for the FlowReader desktop app.
#
# This file is a TEMPLATE, not the cask users install. `make deploy-homebrew`
# renders it with `scripts/render-package-manifest.mjs` from the release's
# verified `artifact-manifest.json` and commits the result to the tap
# flowreader-app/homebrew-tap as `Casks/flowreader.rb`
# (`brew install --cask flowreader-app/tap/flowreader`). `1.1.6` and `d59687363ae206f6a60794da49005d19349d7a60c41bc854fef3e6af09bd7e49` are substituted
# from that manifest, which is the same record the delivery gate checks the DMG
# bytes against — so the checksum a user's `brew install` verifies and the
# checksum the release published cannot drift apart.
#
# The placeholders are plain Ruby strings, so `ruby -c` parses this file as-is.
cask "flowreader" do
  version "1.1.6"
  sha256 "d59687363ae206f6a60794da49005d19349d7a60c41bc854fef3e6af09bd7e49"

  # One universal DMG, arm64 and x86_64 in the same bundle, so there is no
  # `arch` stanza and no per-architecture checksum. Fetched through the
  # download counter (infra/download-worker, `/r/<tag>/<asset>`), which counts
  # the install with its version and answers 302 to
  # https://github.com/flowreader-app/flowreader/releases/download/v<version>/FlowReader-macos-<version>-universal.dmg
  # in the public release repository: the source repository is private. The
  # sha256 above is still checked against the file GitHub serves.
  #
  # No `verified:`: Homebrew 7 deprecates it and verifies the URL by default;
  # get.flowreader.io is under the homepage's domain.
  url "https://get.flowreader.io/r/v#{version}/macos-dmg?src=homebrew"
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

  # The app updates itself in place: the desktop updater replaces
  # /Applications/FlowReader.app with the signed bundle from latest.json
  # (docs/release/desktop-updater.md). `auto_updates true` is Homebrew's
  # convention for such apps: `brew upgrade` leaves the cask alone unless run
  # with `--greedy`, so brew and the app never race to replace the same bundle,
  # and `brew outdated` does not nag about a version the app already took.
  auto_updates true
  # No version floor. The app's is 10.15 (`minimumSystemVersion` in
  # `src-tauri/tauri.conf.json`), below every macOS Homebrew still runs on, and
  # Homebrew 7 refuses `:catalina` outright ("Calling `depends_on macos:
  # :catalina` is disabled"), which broke `brew install` for 1.0.0. `brew style`
  # still wants the cask marked macOS-only.
  depends_on :macos

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
