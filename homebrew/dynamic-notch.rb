cask "dynamic-notch" do
  version "1.0.1"
  sha256 "795c33f8194052c874b7d3ca18a66bafaa551fa454a5e16ef584a53dfdcbec4e"

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