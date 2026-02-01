# typed: false
# frozen_string_literal: true

class Openems < Formula
  desc "Free and open electromagnetic field solver using EC-FDTD method"
  homepage "https://openems.de"
  # Use git HEAD for Python bindings compatibility
  url "https://github.com/thliebig/openEMS.git",
      branch:   "master",
      revision: "f99c95d0c96de393b2f6c1d6d7c4dc2ab62ab3b9"
  version "0.0.37"
  license "GPL-3.0-or-later"

  head "https://github.com/thliebig/openEMS.git", branch: "master"

  option "without-gui", "Build without GUI components (AppCSXCAD)"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "csxcad"
  depends_on "fparser"
  depends_on "hdf5"
  depends_on "vtk"

  # GUI dependencies (default: enabled)
  depends_on "appcsxcad" => :recommended
  depends_on "qcsxcad" => :recommended
  depends_on "qt" => :recommended

  # TinyXML bundled (not available in Homebrew, tinyxml2 has incompatible API)
  resource "tinyxml" do
    url "https://downloads.sourceforge.net/project/tinyxml/tinyxml/2.6.2/tinyxml_2_6_2.tar.gz"
    sha256 "15bdfdcec58a7da30adc87ac2b078e4417dbe5392f3afb719f9ba6d062645593"
  end

  def install
    # Build tinyxml first (if not using from csxcad)
    resource("tinyxml").stage do
      # TinyXML needs STL support - pass via compiler flag
      system ENV.cxx, "-c", "-O2", "-fPIC", "-DTIXML_USE_STL",
             "tinyxml.cpp", "tinyxmlparser.cpp", "tinyxmlerror.cpp", "tinystr.cpp"

      system "ar", "rcs", "libtinyxml.a",
             "tinyxml.o", "tinyxmlparser.o", "tinyxmlerror.o", "tinystr.o"

      (buildpath/"tinyxml_install/lib").mkpath
      (buildpath/"tinyxml_install/include").mkpath
      cp "libtinyxml.a", buildpath/"tinyxml_install/lib/"
      cp ["tinyxml.h", "tinystr.h"], buildpath/"tinyxml_install/include/"
    end

    # In Boost 1.69+, system is header-only - remove system from Boost components if present
    cmake_content = File.read("CMakeLists.txt")
    if cmake_content.include?("COMPONENTS system")
      inreplace "CMakeLists.txt", "COMPONENTS system thread", "COMPONENTS thread"
    end

    args = std_cmake_args + %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DCMAKE_POLICY_VERSION_MINIMUM=3.5
      -DCMAKE_CXX_FLAGS=-I#{buildpath}/tinyxml_install/include\ -DTIXML_USE_STL
      -DFPARSER_ROOT_DIR=#{Formula["fparser"].opt_prefix}
      -DCSXCAD_ROOT_DIR=#{Formula["csxcad"].opt_prefix}
      -DHDF5_ROOT=#{Formula["hdf5"].opt_prefix}
      -DVTK_DIR=#{Formula["vtk"].opt_lib}/cmake/vtk
      -DTinyXML_ROOT_DIR=#{buildpath}/tinyxml_install
      -DTinyXML_INCLUDE_DIR=#{buildpath}/tinyxml_install/include
      -DTinyXML_LIBRARY=#{buildpath}/tinyxml_install/lib/libtinyxml.a
      -DBoost_NO_BOOST_CMAKE=ON
      -DBUILD_SHARED_LIBS=ON
      -DWITH_MPI=OFF
    ]

    # Set library paths and enable STL for tinyxml
    ENV.prepend "CXXFLAGS", "-I#{buildpath}/tinyxml_install/include -DTIXML_USE_STL"
    ENV.prepend "LDFLAGS", "-L#{buildpath}/tinyxml_install/lib"

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Install headers for Python bindings
    (include/"openEMS").mkpath
    Dir["openEMS/*.h"].each { |h| (include/"openEMS").install h }
    Dir["Common/*.h"].each { |h| (include/"openEMS").install h }
    Dir["FDTD/*.h"].each { |h| (include/"openEMS").install h }
    Dir["tools/*.h"].each { |h| (include/"openEMS").install h }
  end

  def caveats
    s = <<~EOS
      openEMS has been installed!

      To use openEMS with MATLAB/Octave, add the following to your path:
        addpath('#{opt_share}/openEMS/matlab');
        addpath('#{Formula["csxcad"].opt_share}/CSXCAD/matlab');

      Example simulations can be found in the openEMS tutorials:
        https://openems.de/index.php/Tutorials

    EOS

    s += if build.without? "gui"
      <<~EOS
        NOTE: GUI support was disabled. To visualize results, you can:
        - Use ParaView to open VTK files
        - Rebuild with: brew reinstall openems --with-gui

      EOS
    else
      <<~EOS
        To launch the GUI viewer:
          AppCSXCAD

      EOS
    end

    s
  end

  test do
    # Test that openEMS binary runs
    system bin/"openEMS", "--help"

    # Create a minimal test simulation
    (testpath/"test.xml").write <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <openEMS>
        <FDTD NumberOfTimesteps="10" endCriteria="1e-6">
          <Excitation Type="0" f0="1e9" fc="0.5e9"/>
          <BoundaryCond xmin="PEC" xmax="PEC" ymin="PEC" ymax="PEC" zmin="PEC" zmax="PEC"/>
        </FDTD>
        <ContinuousStructure>
          <BackgroundMaterial Epsilon="1" Mue="1"/>
          <RectilinearGrid DeltaUnit="1e-3">
            <XLines>0,10,20,30,40,50</XLines>
            <YLines>0,10,20,30,40,50</YLines>
            <ZLines>0,10,20,30,40,50</ZLines>
          </RectilinearGrid>
        </ContinuousStructure>
      </openEMS>
    XML

    # Run a quick simulation (should complete without error)
    system bin/"openEMS", testpath/"test.xml"
  end
end
