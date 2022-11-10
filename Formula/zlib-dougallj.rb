class ZlibDougallj < Formula
  desc "Experimental fork of zlib with performance improvements for Apple Silicon"
  homepage "https://github.com/dougallj/zlib-dougallj"
  license "Zlib"
  head "https://github.com/dougallj/zlib-dougallj.git", branch: "main"

  keg_only :provided_by_macos

  depends_on "cmake" => :build

  depends_on arch: :arm64
  depends_on :macos

  # https://zlib.net/zlib_how.html
  resource "test_artifact" do
    url "https://zlib.net/zpipe.c"
    version "20051211"
    sha256 "68140a82582ede938159630bca0fb13a93b4bf1cb2e85b08943c26242cf8f3a6"
  end

  def install
    system "cmake", *std_cmake_args
    system "make", "install"
    system "make", "clean"
    system "cmake", *std_cmake_args, "-DBUILD_SHARED_LIBS=1"
    system "make", "install"
  end

  test do
    testpath.install resource("test_artifact")
    system ENV.cc, "zpipe.c", "-I#{include}", "-L#{lib}", "-lz", "-o", "zpipe"

    touch "foo.txt"
    output = "./zpipe < foo.txt > foo.txt.z"
    system output
    assert_predicate testpath/"foo.txt.z", :exist?
  end
end
