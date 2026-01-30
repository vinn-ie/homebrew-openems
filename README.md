# Homebrew OpenEMS Tap

[Homebrew](https://brew.sh) tap for [openEMS](https://openems.de) on macOS (Apple Silicon).

openEMS is a free electromagnetic field solver using the EC-FDTD method for antenna design, waveguide analysis, and RF simulation.

## Installation

```bash
brew tap vincentfree/openems
brew install openems
```

Without GUI: `brew install openems --without-gui`

## Test Installation

```bash
# Test C++ install
openEMS examples/test.xml

# Test Python bindings (after installing, see below)
python examples/test_python.py
```

## Python Bindings

```bash
python3 -m venv ~/openems-env && source ~/openems-env/bin/activate
pip install cython numpy matplotlib h5py setuptools

CSXCAD_INSTALL_PATH=/opt/homebrew/opt/csxcad pip install git+https://github.com/thliebig/CSXCAD.git#subdirectory=python --no-build-isolation

CSXCAD_INSTALL_PATH=/opt/homebrew/opt/csxcad OPENEMS_INSTALL_PATH=/opt/homebrew/opt/openems pip install git+https://github.com/thliebig/openEMS.git#subdirectory=python --no-build-isolation
```

## Usage

```bash
openEMS simulation.xml      # Run simulation
AppCSXCAD model.xml         # GUI viewer
```

MATLAB/Octave paths:
```matlab
addpath('/opt/homebrew/share/openEMS/matlab');
addpath('/opt/homebrew/share/CSXCAD/matlab');
```

## Running Tutorials

The [official tutorials](https://openems.de/index.php/Tutorials) cover antenna design, waveguides, and S-parameter extraction. Python tutorials are in the [openEMS repo](https://github.com/thliebig/openEMS/tree/master/python/Tutorials).

```bash
source ~/openems-env/bin/activate
curl -LO https://raw.githubusercontent.com/thliebig/openEMS/master/python/Tutorials/Simple_Patch_Antenna.py
python Simple_Patch_Antenna.py
```

## Resources

- [openEMS Website](https://openems.de)
- [Tutorials](https://openems.de/index.php/Tutorials)

## License

openEMS: GPL-3.0 | CSXCAD: LGPL-3.0 | This tap: MIT
