# typed: false
# frozen_string_literal: true

class Qcsxcad < Formula
  desc "Qt-based GUI library for CSXCAD visualization"
  homepage "https://github.com/thliebig/QCSXCAD"
  # Pinned to openEMS 0.0.36 submodule commit
  url "https://github.com/thliebig/QCSXCAD.git",
      revision: "63ac6f8c623665f06fdb35765048cb52c7190ce0"
  version "0.6.4"
  license "LGPL-3.0-or-later"

  head "https://github.com/thliebig/QCSXCAD.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "csxcad"
  depends_on "fparser"
  depends_on "qt"
  depends_on "vtk"

  def install
    # Remove deprecated CMake policy if present (not in HEAD)
    inreplace "CMakeLists.txt", /cmake_policy\s*\(\s*SET\s+CMP0020\s+OLD\s*\)/i, "", audit_result: false

    args = std_cmake_args + %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5
      -DCSXCAD_ROOT_DIR=#{Formula["csxcad"].opt_prefix}
      -DFPARSER_ROOT_DIR=#{Formula["fparser"].opt_prefix}
      -DVTK_DIR=#{Formula["vtk"].opt_lib}/cmake/vtk
      -DQt6_DIR=#{Formula["qt"].opt_lib}/cmake/Qt6
      -DBUILD_SHARED_LIBS=ON
    ]

    # Help find Qt6
    ENV["Qt6_DIR"] = "#{Formula["qt"].opt_lib}/cmake/Qt6"
    ENV.prepend_path "CMAKE_PREFIX_PATH", Formula["qt"].opt_prefix

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # Basic library presence test (GUI libs are hard to test without display)
    assert_path_exists lib/"libQCSXCAD.dylib"
  end
end
