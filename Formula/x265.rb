class X265 < Formula
  desc "H.265/HEVC encoder, with ARM NEON SIMD"
  homepage "https://bitbucket.org/multicoreware/x265_git"
  license "GPL-2.0-only"
  head "https://bitbucket.org/multicoreware/x265_git.git", branch: "master"

  # Apply HandBrake's patches
  stable do
    # x265 is long overdue for a new point release
    # 40e37bce9 is HandBrake's snapshot-20221114
    url "https://bitbucket.org/multicoreware/x265_git/get/40e37bce9a35.tar.gz"
    version "3.5+69-40e37bce9"
    sha256 "3572b108c2989e2f1d6a823f35c3244d718fbb1f99372ac31a392b1ea01cb96b"
    patch do
      url "https://raw.githubusercontent.com/DingoBits/homebrew-dingobits/master/Patches/x265-40e37bce9.patch"
      sha256 "83ef6395bade1b857e0e2e2b399f5834435194216f6a2e5bbc24c00bc0943a8f"
    end
  end

  bottle do
    root_url "https://github.com/DingoBits/homebrew-dingobits/releases/download/bottles"
    sha256 cellar: :any, arm64_monterey: "6b3f02dc41509a6a0ee6b6eeb8aeb70cacb28dc68832de6eca89b2f3751e65d3"
  end

  depends_on "cmake" => :build

  on_intel do
    depends_on "nasm" => :build
  end

  def install
    # Update version number
    inreplace "x265Version.txt" do |s|
      s.gsub! "repositorychangeset: f0c1022b6", "repositorychangeset: 20255e6f0"
      s.gsub! "releasetagdistance: 1", "releasetagdistance: 39"
    end

    # Build based on the script at ./build/linux/multilib.sh
    args = std_cmake_args + %W[
      -DLINKED_10BIT=ON
      -DLINKED_12BIT=ON
      -DEXTRA_LINK_FLAGS=-L.
      -DEXTRA_LIB=x265_main10.a;x265_main12.a
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]
    high_bit_depth_args = std_cmake_args + %w[
      -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF
      -DENABLE_SHARED=OFF -DENABLE_CLI=OFF
    ]
    (buildpath/"8bit").mkpath

    mkdir "10bit" do
      system "cmake", buildpath/"source", "-DENABLE_HDR10_PLUS=ON", *high_bit_depth_args
      system "make"
      mv "libx265.a", buildpath/"8bit/libx265_main10.a"
    end

    mkdir "12bit" do
      system "cmake", buildpath/"source", "-DMAIN12=ON", *high_bit_depth_args
      system "make"
      mv "libx265.a", buildpath/"8bit/libx265_main12.a"
    end

    cd "8bit" do
      system "cmake", buildpath/"source", *args
      system "make"
      mv "libx265.a", "libx265_main.a"

      if OS.mac?
        system "libtool", "-static", "-o", "libx265.a", "libx265_main.a",
                          "libx265_main10.a", "libx265_main12.a"
      else
        system "ar", "cr", "libx265.a", "libx265_main.a", "libx265_main10.a",
                           "libx265_main12.a"
        system "ranlib", "libx265.a"
      end

      system "make", "install"
    end
  end

  test do
    yuv_path = testpath/"raw.yuv"
    x265_path = testpath/"x265.265"
    yuv_path.binwrite "\xCO\xFF\xEE" * 3200
    system bin/"x265", "--input-res", "80x80", "--fps", "1", yuv_path, x265_path
    header = "AAAAAUABDAH//w=="
    assert_equal header.unpack("m"), [x265_path.read(10)]
  end
end
