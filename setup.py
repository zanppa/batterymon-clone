#!/usr/bin/env python
# -*- coding: utf-8 -*-

from distutils.core import setup
from distutils.dep_util import newer
from distutils.log import info
from distutils.command.build import build
from distutils.command.install_data import install_data
from distutils.command.clean import clean
import sys
import subprocess
import glob
import os
import shutil

if sys.hexversion < 0x02050000:
    sys.exit("sorry, python 2.5 or higher is required")

try:
    subprocess.Popen(['msgfmt'], stderr=subprocess.PIPE)
except OSError:
    sys.exit("couldn't run msgfmt, please make sure gettext is installed")


mo_files = []

class build_with_i18n(build):
    def run(self):
        for po in glob.glob('po/*.po'):
            lang = os.path.basename(po)[:-3]
            mo_dir = os.path.join(self.build_base, 'locale', lang, 'LC_MESSAGES')
            mo = os.path.join(mo_dir, 'batterymon.mo')
            if not os.path.isdir(mo_dir):
                info("creating %s" % mo_dir)
                os.makedirs(mo_dir)
            if newer(po, mo):
                info("compiling %s to %s" % (po, mo))
                subprocess.Popen(['msgfmt', '-o', mo, po])
            lang_dir = os.path.join('share', 'locale', lang, 'LC_MESSAGES')
            mo_files.append((lang_dir, [mo]))
        build.run(self)

class install_data_with_i18n(install_data):
    def run(self):
        self.data_files.extend(mo_files)
        install_data.run(self)

class clean_with_i18n(clean):
    def run(self):
        clean.run(self)
        locale_dir = os.path.join(self.build_base, 'locale')
        if self.all and os.path.exists(locale_dir):
            info("removing %s (and everything under it)" % locale_dir)
            try:
                shutil.rmtree(locale_dir)
            except:
                pass

setup(name='batterymon',
      version="1.4.2",
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
      cmdclass = {
	      'build': build_with_i18n,
	      'install_data': install_data_with_i18n,
	      'clean': clean_with_i18n,
      }
)
