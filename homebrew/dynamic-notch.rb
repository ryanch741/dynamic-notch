cask "dynamic-notch" do
  version "1.0.5"
  sha256 "f545a3e233785a9ee1790eed95bd207d1e56acbd99ae528d32b1c5dd47433c02"

  url "https://github.com/ryanch741/dynamic-notch/releases/download/v#{version}/dynamic-notch-#{version}.dmg"
  name "Dynamic Notch"
  name "灵动刘海"
  desc "A macOS utility for Dynamic Island-style interaction on MacBook Pro with notch"

  depends_on macos: ">= :sonoma"

  app "灵动刘海.app"

  homepage "https://github.com/ryanch741/dynamic-notch"

  zap trash: [
    "~/Library/Application Support/com.hianzuo.NotchIsland",
    "~/Library/Preferences/com.hianzuo.NotchIsland.plist",
    "~/Library/Saved Application State/com.hianzuo.NotchIsland.savedState",
  ]


end