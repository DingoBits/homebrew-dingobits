cask "qgis-arm64" do
  version "3.28.1_1"
  sha256 "8f485ccc780e45e92353e01e42db634ed8d242ea976021812d25d70e0191839c"

  url "https://github.com/DingoBits/qgis-arm64-apple/releases/download/#{version}/QGIS_#{version}_arm64_apple_darwin21.7z"
  name "QGIS"
  desc " QGIS on Apple Silicon"
  homepage "https://github.com/DingoBits/qgis-arm64-apple"

  conflicts_with cask: "qgis"
  depends_on macos: ">= :monterey"
  depends_on arch: :arm64

  app "QGIS.app"

  zap trash: [
    "~/Library/Application Support/QGIS",
    "~/Library/Caches/QGIS",
    "~/Library/Saved Application State/org.qgis.qgis*.savedState",
]
end
