class X265 < Formula
  desc "H.265/HEVC encoder, with ARM NEON SIMD"
  homepage "https://bitbucket.org/multicoreware/x265_git"
  license "GPL-2.0-only"
  head "https://bitbucket.org/multicoreware/x265_git.git", branch: "master"

  # Apply HandBrake's patches
  stable do
    # x265 is long overdue for a new point release
    # 20255e6f0ead is HandBrake's snapshot-20220709
    url "https://bitbucket.org/multicoreware/x265_git/get/20255e6f0ead.tar.gz"
    version "3.5+39-20255e6f0"
    sha256 "f93e8b9e97054ea420aabfba72b5c6fcadb0710ba51855388a3c113fab4445d8"
    patch do
      url "https://raw.githubusercontent.com/DingoBits/homebrew-dingobits/master/Patches/x265_20255e6f0.patch"
      sha256 "60776617d1224a28120900b72ef16961dc9663b27bb1bb2092761fbb01bf21f3"
    end
  end

  bottle do
    root_url "https://github.com/DingoBits/homebrew-dingobits/releases/download/bottles"
    rebuild 1
    sha256 cellar: :any, arm64_monterey: "080273c0d866d227c968da1cff2d346b5676a0085c7f7d2e47d240c54ebc65a3"
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
