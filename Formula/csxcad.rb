# typed: false
# frozen_string_literal: true

class Csxcad < Formula
  desc "C++ library for describing geometrical objects and their properties"
  homepage "https://github.com/thliebig/CSXCAD"
  # Use git HEAD for Python bindings compatibility (v0.6.3 release missing CSPropAbsorbingBC.h)
  url "https://github.com/thliebig/CSXCAD.git",
      branch:   "master",
      revision: "d7d70ef7ea9ab91fcfd3ed2ab1b3a5a0d03b7fbe"
  version "0.6.4"
  license "LGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/vinn-ie/homebrew-openems/releases/download/v1.0"
    rebuild 1
    sha256 cellar: :any, arm64_sequoia: "7c672bfff16fc2effef566c5a2e3c1714efa00aa41df5bb3be19b7409af034ce"
  end

  head "https://github.com/thliebig/CSXCAD.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "cgal"
  depends_on "fparser"
  depends_on "hdf5"
  depends_on "vtk"

  # TinyXML is not available in Homebrew (tinyxml2 has incompatible API)
  # Bundle it as a resource
  resource "tinyxml" do
    url "https://downloads.sourceforge.net/project/tinyxml/tinyxml/2.6.2/tinyxml_2_6_2.tar.gz"
    sha256 "15bdfdcec58a7da30adc87ac2b078e4417dbe5392f3afb719f9ba6d062645593"
  end

  def install
    # Build tinyxml first and copy to source tree where it's expected
    resource("tinyxml").stage do
      # TinyXML needs STL support for CSXCAD - pass via compiler flag
      system ENV.cxx, "-c", "-O2", "-fPIC", "-DTIXML_USE_STL",
             "tinyxml.cpp", "tinyxmlparser.cpp", "tinyxmlerror.cpp", "tinystr.cpp"

      system "ar", "rcs", "libtinyxml.a",
             "tinyxml.o", "tinyxmlparser.o", "tinyxmlerror.o", "tinystr.o"

      # Install tinyxml to a location within the source tree
      (buildpath/"tinyxml_build/lib").mkpath
      (buildpath/"tinyxml_build/include").mkpath
      cp "libtinyxml.a", buildpath/"tinyxml_build/lib/"
      cp ["tinyxml.h", "tinystr.h"], buildpath/"tinyxml_build/include/"
    end

    # Also copy headers directly to the src directory so they're found during compilation
    cp buildpath/"tinyxml_build/include/tinyxml.h", buildpath/"src/"
    cp buildpath/"tinyxml_build/include/tinystr.h", buildpath/"src/"

    # In Boost 1.69+, system is header-only - patch only if Boost find_package exists (older versions)
    cmake_content = File.read("CMakeLists.txt")
    if cmake_content.include?("find_package(Boost")
      inreplace "CMakeLists.txt", /find_package\(Boost\s+[\d.]+\s+COMPONENTS\s+thread\s+system/m,
                "find_package(Boost 1.46 COMPONENTS thread"
    end

    args = std_cmake_args + %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5
      -DFPARSER_ROOT_DIR=#{Formula["fparser"].opt_prefix}
      -DHDF5_ROOT=#{Formula["hdf5"].opt_prefix}
      -DCGAL_DIR=#{Formula["cgal"].opt_lib}/cmake/CGAL
      -DVTK_DIR=#{Formula["vtk"].opt_lib}/cmake/vtk
      -DTinyXML_ROOT_DIR=#{buildpath}/tinyxml_build
      -DTinyXML_INCLUDE_DIR=#{buildpath}/tinyxml_build/include
      -DTinyXML_LIBRARY=#{buildpath}/tinyxml_build/lib/libtinyxml.a
      -DBoost_NO_BOOST_CMAKE=ON
      -DBUILD_SHARED_LIBS=ON
    ]

    # Set library paths
    ENV.prepend "LDFLAGS", "-L#{buildpath}/tinyxml_build/lib"

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Install additional headers needed for Python bindings
    # CMake install misses some headers used by Cython bindings
    Dir["src/*.h"].each do |header|
      basename = File.basename(header)
      unless (include/"CSXCAD"/basename).exist?
        (include/"CSXCAD").install header
      end
    end

    # Also install tinyxml headers and lib for dependent formulas
    (include/"tinyxml").install buildpath/"tinyxml_build/include/tinyxml.h"
    (include/"tinyxml").install buildpath/"tinyxml_build/include/tinystr.h"
    lib.install buildpath/"tinyxml_build/lib/libtinyxml.a"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <CSXCAD/CSXCAD.h>
      #include <iostream>

      int main() {
        ContinuousStructure CSX;
        std::cout << "CSXCAD loaded successfully" << std::endl;
        return 0;
      }
    CPP

    system ENV.cxx, "test.cpp", "-std=c++17",
           "-I#{include}", "-I#{Formula["fparser"].opt_include}",
           "-I#{Formula["vtk"].opt_include}",
           "-L#{lib}", "-lCSXCAD",
           "-L#{Formula["fparser"].opt_lib}", "-lfparser",
           "-o", "test"
    system "./test"
  end
end
