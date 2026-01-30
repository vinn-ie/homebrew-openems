#!/usr/bin/env python3
"""
Test script to verify openEMS Python bindings are working.
Run with: python test_python.py
"""

from CSXCAD import ContinuousStructure
from openEMS import openEMS

# Create structure
CSX = ContinuousStructure()
mesh = CSX.GetGrid()
mesh.SetDeltaUnit(1e-3)
mesh.AddLine('x', [0, 10, 20])
mesh.AddLine('y', [0, 10, 20])
mesh.AddLine('z', [0, 10, 20])

# Create solver
FDTD = openEMS(NrTS=100, EndCriteria=1e-4)
FDTD.SetCSX(CSX)

print("CSXCAD version:", __import__('CSXCAD').__version__)
print("openEMS version:", __import__('openEMS').__version__)
print("Python bindings working correctly")
