class Qtwebkit < Formula
  desc "Qt Port of WebKit"
  homepage "https://code.qt.io/cgit/qt/qtwebkit.git"
  url "https://download.qt.io/snapshots/ci/qtwebkit/5.212/latest/src/submodules/qtwebkit-opensource-src-5.212.tar.xz"
  sha256 "10cbdaba60aac79d27016aa05bae9ab3ec7b0aed4df163debfbf8fddd66adc14"
  license all_of: ["GFDL-1.3-only", "GPL-2.0-only", "GPL-3.0-only", "LGPL-2.1-only", "LGPL-3.0-only"]

  depends_on "cmake" => :build
  depends_on "python@3.10" => :build

  depends_on "jpeg-turbo"
  depends_on "qt@5"
  depends_on "webp"

  uses_from_macos "gperf"
  uses_from_macos "icu4c"
  uses_from_macos "libxml2"
  uses_from_macos "libxslt"
  uses_from_macos "perl"
  uses_from_macos "ruby"
  uses_from_macos "sqlite"
  uses_from_macos "zlib"

  # Fix build for arm64
  patch do
    url "https://raw.githubusercontent.com/DingoBits/homebrew/master/Patches/qtwebkit_arm64.patch"
    sha256 "f74f0a889e9e7ba5c8cc07ddff4ca7c6d4ec23d93b785042c2b424d9d0abb350"
  end

  def install
    args = std_cmake_args + %W[
      -DPORT=Qt
      -DCMAKE_INSTALL_NAME_DIR=#{opt_lib}
    ]
    system "cmake", ",", *args
    system "make"
    system "make", "install"
    frameworks.install_symlink Dir["#{lib}/*.framework"]
  end
end
