# Generating backrack mount

0.) Fetch this branch, if you do not have it yet:

``git clone https://github.com/gluap/OpenBikeSensor3dPrintableCase.git --branch backrack_openscad``


1.) Init git submodules to get the required openscad packages

``git submodule init && git submodule update``

2.) Open backrack-mount.scad and edit values to fit your backrack parameters (needs: diameter of tubes and distance of the two tubes obs should be mounted to. Measure with calipers).

3.) Export stl (default: both upper and lower part in one STL, can be printed conveniently together).

4.) Print
