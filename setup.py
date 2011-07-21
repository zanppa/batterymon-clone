#!/usr/bin/env python
# -*- coding: utf-8 -*-

from DistUtilsExtra.command import *
import glob
from distutils.core import setup

setup(name='batterymon',
      version="1.3.0",
      description='A simple battery monitor for any desktop',
      author='Denilson Sá',
      author_email='denilsonsa@gmail.com',
      url='https://github.com/denilsonsa/batterymon-clone',
      package_dir={'batterymon': ''},
      packages = ['batterymon'],
      scripts=['batterymon'],
      data_files=[
          ('share/batterymon/icons/16x16', glob.glob('icons/16x16/*.png')),
          ('share/batterymon/icons/24x24_narrow', glob.glob('icons/24x24_narrow/*.png')),
          ('share/batterymon/icons/24x24_wide', glob.glob('icons/24x24_wide/*.png')),
          ('share/batterymon/icons/default', glob.glob('icons/default/*.png')),
          ('share/batterymon/icons/gnome', glob.glob('icons/gnome/*.png')), 
      ], 
      cmdclass = { "build" : build_extra.build_extra,
                   "build_i18n" :  build_i18n.build_i18n },
      )
