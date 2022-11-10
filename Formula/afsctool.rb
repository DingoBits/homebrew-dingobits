class Afsctool < Formula
  desc "Utility for manipulating APFS and ZFS compressed files, with LZFSE"
  homepage "https://github.com/RJVB/afsctool"
  url "https://github.com/RJVB/afsctool/archive/refs/tags/v1.7.3.tar.gz"
  sha256 "5776ff5aaf05c513bead107536d9e98e6037019a0de8a1435cc9da89ea8d49b8"
  license all_of: ["GPL-3.0-only", "BSL-1.0"]
  head "https://github.com/RJVB/afsctool.git"

  depends_on "cmake" => :build
  depends_on "google-sparsehash" => :build
  depends_on "pkg-config" => :build
  depends_on :macos

  # Add LZFSE 1.0+2-e634ca5
  patch do
    url "https://raw.githubusercontent.com/DingoBits/homebrew/master/Patches/afsctool_lzfse_e634ca5.patch"
    sha256 "92de133352814f3a5fb486e11f8816091e4a273dd1a6f3d49606d44e0951e49b"
  end

  def install
    system "cmake", ".", *std_cmake_args
    system "cmake", "--build", "."
    bin.install "afsctool"
    bin.install "zfsctool"
  end

  test do
    path = testpath/"foo"
    path.write "some text here."
    system "#{bin}/afsctool", "-c", path
    system "#{bin}/afsctool", "-v", path

    system "#{bin}/zfsctool", "-c", path
    system "#{bin}/zfsctool", "-v", path
  end
end
