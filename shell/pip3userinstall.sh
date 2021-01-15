#/usr/bin/env bash

#Installs the missing python modules locally with pip3.6
pip3 install --user --upgrade numpy
pip3 install --user --upgrade numpydoc
pip3 install --user --upgrade matplotlib
pip3 install --user --upgrade joblib
pip3 install --user --upgrade scipy
pip3 install --user --upgrade pandas
pip3 install --user --upgrade sphinx
pip3 install --user --upgrade sphinx_rtd_theme

exit 0

