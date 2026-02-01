# Homebrew OpenEMS Tap

[Homebrew](https://brew.sh) tap for [openEMS](https://openems.de) ([github](https://github.com/thliebig/openEMS-Project)) on macOS (Apple Silicon).

## Installation

```bash
brew tap vinn-ie/openems
brew install openems
```

Without GUI: `brew install openems --without-gui`

## Python Bindings

```bash
python3 -m venv ~/openems-env && source ~/openems-env/bin/activate
pip install cython numpy matplotlib h5py setuptools

CSXCAD_INSTALL_PATH=/opt/homebrew/opt/csxcad pip install git+https://github.com/thliebig/CSXCAD.git#subdirectory=python --no-build-isolation

CSXCAD_INSTALL_PATH=/opt/homebrew/opt/csxcad OPENEMS_INSTALL_PATH=/opt/homebrew/opt/openems pip install git+https://github.com/thliebig/openEMS.git#subdirectory=python --no-build-isolation
```

MATLAB/Octave paths:
```matlab
addpath('/opt/homebrew/share/openEMS/matlab');
addpath('/opt/homebrew/share/CSXCAD/matlab');
```

## Test Installation

```bash
# Test C++ install
openEMS examples/test.xml

# Test Python bindings
python examples/test_python.py
```

## Running Tutorials

The [official tutorials](https://openems.de/index.php/Tutorials) cover antenna design, waveguides, and S-parameter extraction. Python tutorials are in the [openEMS repo](https://github.com/thliebig/openEMS/tree/master/python/Tutorials).

```bash
source ~/openems-env/bin/activate
curl -LO https://raw.githubusercontent.com/thliebig/openEMS/master/python/Tutorials/Simple_Patch_Antenna.py
python Simple_Patch_Antenna.py
```

## Uninstall

To uninstall OpenEMS and its dependencies:

```bash
brew uninstall vinn-ie/openems/openems vinn-ie/openems/appcsxcad vinn-ie/openems/qcsxcad vinn-ie/openems/csxcad vinn-ie/openems/fparser
brew untap vinn-ie/openems
brew cleanup
```
Note: Shared dependencies (qt, vtk, hdf5, etc.) are not removed. To remove them, run: `brew autoremove`