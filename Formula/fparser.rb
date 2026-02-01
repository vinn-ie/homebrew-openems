# typed: false
# frozen_string_literal: true

class Fparser < Formula
  desc "Function parser library for mathematical expressions in C++"
  homepage "https://github.com/thliebig/fparser"
  # Pinned to openEMS 0.0.36 submodule commit
  url "https://github.com/thliebig/fparser.git",
      revision: "e625e262620036a52d1dc9abc122d2bf67397e40"
  version "4.5.2.1"
  license "LGPL-3.0-or-later"

  head "https://github.com/thliebig/fparser.git", branch: "master"

  depends_on "cmake" => :build

  def install
    args = std_cmake_args + %W[
      -DCMAKE_INSTALL_PREFIX=#{prefix}
      -DBUILD_SHARED_LIBS=ON
    ]

    system "cmake", "-S", ".", "-B", "build", *args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # Simple test to verify the library is installed
    (testpath/"test.cpp").write <<~CPP
      #include <fparser.hh>
      #include <iostream>

      int main() {
        FunctionParser fp;
        fp.Parse("x^2 + y^2", "x,y");
        double vals[] = {3.0, 4.0};
        double result = fp.Eval(vals);
        std::cout << "Result: " << result << std::endl;
        return (result == 25.0) ? 0 : 1;
      }
    CPP

    system ENV.cxx, "test.cpp", "-std=c++11",
           "-I#{include}", "-L#{lib}", "-lfparser",
           "-o", "test"
    system "./test"
  end
end
