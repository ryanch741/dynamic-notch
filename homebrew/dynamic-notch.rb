cask "dynamic-notch" do
  version "1.0.0"
  homepage "https://github.com/ryanch741/dynamic-notch"
  url "https://github.com/ryanch741/dynamic-notch/releases/download/v#{version}/灵动刘海-#{version}.dmg"
  sha256 "ff49f816c88a74ab5ca688630289534a7f8dc0f21187e00c055949582827aae0"
  name "Dynamic Notch"
  desc "A macOS utility for Dynamic Island-style interaction on MacBook Pro with notch"

  depends_on macos: ">= :sonoma"

  app "灵动刘海.app"

  zap trash: [
    "~/Library/Application Support/com.hianzuo.NotchIsland",
    "~/Library/Preferences/com.hianzuo.NotchIsland.plist",
    "~/Library/Saved Application State/com.hianzuo.NotchIsland.savedState",
  ]


end