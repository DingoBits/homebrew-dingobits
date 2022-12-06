cask "qgis" do
  version "3.28.1"
  sha256 "be5fe69cc5f49fc29ff5e532a3fcddecfc9f933e23fc6ccc0b99fa61b5a4d0c0"

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
