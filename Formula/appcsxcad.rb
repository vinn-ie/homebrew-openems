# typed: false
# frozen_string_literal: true

class Appcsxcad < Formula
  desc "Standalone GUI application for viewing CSXCAD 3D models"
  homepage "https://github.com/thliebig/AppCSXCAD"
  # Pinned to openEMS 0.0.36 submodule commit
  url "https://github.com/thliebig/AppCSXCAD.git",
      revision: "731d2dc6f0db23e2f643d18c04b05d02d97f5085"
  version "0.2.3"
  license "GPL-3.0-or-later"

  head "https://github.com/thliebig/AppCSXCAD.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "csxcad"
  depends_on "fparser"
  depends_on "qcsxcad"
  depends_on "qt"
  depends_on "vtk"

  def install
    # Remove deprecated CMake policy that's no longer supported
    inreplace "CMakeLists.txt", /cmake_policy\s*\(\s*SET\s+CMP0020\s+OLD\s*\)/i, ""

    args = std_cmake_args + %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5
      -DCSXCAD_ROOT_DIR=#{Formula["csxcad"].opt_prefix}
      -DQCSXCAD_ROOT_DIR=#{Formula["qcsxcad"].opt_prefix}
      -DFPARSER_ROOT_DIR=#{Formula["fparser"].opt_prefix}
      -DVTK_DIR=#{Formula["vtk"].opt_lib}/cmake/vtk
      -DQt6_DIR=#{Formula["qt"].opt_lib}/cmake/Qt6
    ]

    # Help find Qt6
    ENV["Qt6_DIR"] = "#{Formula["qt"].opt_lib}/cmake/Qt6"
    ENV.prepend_path "CMAKE_PREFIX_PATH", Formula["qt"].opt_prefix

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # Test that the binary exists and can show help/version
    assert_path_exists bin/"AppCSXCAD"
    # NOTE: Full GUI test requires display, so we just check binary exists
  end
end
