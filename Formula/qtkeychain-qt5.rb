class QtkeychainQt5 < Formula
  desc "Platform-independent Qt API for storing passwords securely"
  homepage "https://github.com/frankosterfeld/qtkeychain"
  url "https://github.com/frankosterfeld/qtkeychain/archive/v0.13.2.tar.gz"
  sha256 "20beeb32de7c4eb0af9039b21e18370faf847ac8697ab3045906076afbc4caa5"
  license "BSD-2-Clause"

  bottle do
    root_url "https://github.com/DingoBits/homebrew-dingobits/releases/download/bottles"
    rebuild 1
    sha256 cellar: :any, arm64_monterey: "5f75f24fb40717b99a723a4a0c6ac2646f290da1483f325cad3307d7872946c3"
  end

  depends_on "cmake" => :build
  depends_on "qt@5"

  on_linux do
    depends_on "libsecret"
  end

  fails_with gcc: "5"

  def install
    system "cmake", ".", "-DBUILD_TRANSLATIONS=OFF", "-DBUILD_WITH_QT6=OFF", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <qt5keychain/keychain.h>
      int main() {
        QKeychain::ReadPasswordJob job(QLatin1String(""));
        return 0;
      }
    EOS
    flags = ["-I#{Formula["qt"].opt_include}"]
    flags += if OS.mac?
      [
        "-F#{Formula["qt"].opt_lib}",
        "-framework", "QtCore"
      ]
    else
      [
        "-fPIC",
        "-L#{Formula["qt"].opt_lib}", "-lQt5Core",
        "-Wl,-rpath,#{Formula["qt"].opt_lib}",
        "-Wl,-rpath,#{lib}"
      ]
    end
    system ENV.cxx, "test.cpp", "-o", "test", "-std=c++17", "-I#{include}",
                    "-L#{lib}", "-lqt5keychain", *flags
    system "./test"
  end
end
