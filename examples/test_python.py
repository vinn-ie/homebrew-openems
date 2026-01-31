#!/usr/bin/env python3
"""
Test script to verify openEMS Python bindings are working correctly.
This creates and runs a minimal FDTD simulation to validate the full stack.

Run with: python test_python.py
"""

import sys
import os
import tempfile
import shutil

def test_imports():
    """Test that all modules can be imported."""
    print("=== Testing imports ===")
    
    import CSXCAD
    print(f"✓ CSXCAD version: {CSXCAD.__version__}")
    
    import openEMS
    print(f"✓ openEMS version: {openEMS.__version__}")
    
    from CSXCAD import ContinuousStructure
    from CSXCAD.CSProperties import CSPropMetal, CSPropExcitation
    from openEMS import openEMS as FDTD
    from openEMS.physical_constants import C0, EPS0, MUE0
    print("✓ All submodules imported successfully")
    
    return True


def test_geometry_creation():
    """Test creating CSXCAD geometry structures."""
    print("\n=== Testing geometry creation ===")
    
    from CSXCAD import ContinuousStructure
    
    CSX = ContinuousStructure()
    
    # Set up mesh
    mesh = CSX.GetGrid()
    mesh.SetDeltaUnit(1e-3)  # mm
    
    # Create a simple 3D mesh
    mesh.AddLine('x', list(range(0, 51, 5)))
    mesh.AddLine('y', list(range(0, 51, 5)))
    mesh.AddLine('z', list(range(0, 101, 5)))
    
    # Add a metal box
    metal = CSX.AddMetal('ground_plane')
    metal.AddBox(start=[0, 0, 0], stop=[50, 50, 0], priority=10)
    
    # Add an excitation
    exc = CSX.AddExcitation('port', exc_type=0, exc_val=[0, 0, 1])
    exc.AddBox(start=[20, 20, 5], stop=[30, 30, 5], priority=5)
    
    # Verify properties were created
    props = CSX.GetAllProperties()
    assert len(props) >= 2, "Expected at least 2 properties"
    print(f"✓ Created {len(props)} geometry properties")
    print("✓ Geometry creation working correctly")
    
    return CSX


def test_fdtd_setup(CSX):
    """Test setting up FDTD simulation."""
    print("\n=== Testing FDTD setup ===")
    
    from openEMS import openEMS as FDTD
    
    # Create FDTD object with short simulation for testing
    fdtd = FDTD(NrTS=200, EndCriteria=1e-3)
    fdtd.SetCSX(CSX)
    
    # Set Gaussian excitation
    f0 = 1.5e9  # center frequency
    fc = 1e9    # 20dB cutoff frequency
    fdtd.SetGaussExcite(f0, fc)
    
    # Set boundary conditions
    fdtd.SetBoundaryCond(['PEC', 'PEC', 'PEC', 'PEC', 'MUR', 'MUR'])
    
    print("✓ FDTD solver configured successfully")
    
    return fdtd


def test_simulation_run(fdtd, CSX):
    """Test running a short FDTD simulation."""
    print("\n=== Testing simulation run ===")
    
    # Create temporary directory for simulation
    sim_path = tempfile.mkdtemp(prefix='openems_test_')
    
    try:
        # Write geometry
        CSX.Write2XML(os.path.join(sim_path, 'test.xml'))
        print(f"✓ Wrote geometry to {sim_path}/test.xml")
        
        # Run simulation (very short, just to test it works)
        fdtd.Run(sim_path, cleanup=True, verbose=0)
        print("✓ Simulation completed successfully")
        
    finally:
        # Cleanup
        if os.path.exists(sim_path):
            shutil.rmtree(sim_path)
            print(f"✓ Cleaned up temporary directory")
    
    return True


def main():
    """Run all tests."""
    print("=" * 60)
    print("openEMS Installation Test Suite")
    print("=" * 60)
    
    try:
        # Test 1: Imports
        test_imports()
        
        # Test 2: Geometry creation
        CSX = test_geometry_creation()
        
        # Test 3: FDTD setup
        fdtd = test_fdtd_setup(CSX)
        
        # Test 4: Run simulation
        test_simulation_run(fdtd, CSX)
        
        print("\n" + "=" * 60)
        print("✓ ALL TESTS PASSED - openEMS installation is working!")
        print("=" * 60)
        return 0
        
    except Exception as e:
        print(f"\n✗ TEST FAILED: {e}")
        import traceback
        traceback.print_exc()
        return 1


if __name__ == "__main__":
    sys.exit(main())

