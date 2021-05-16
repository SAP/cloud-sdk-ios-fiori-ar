#!/usr/bin/python
import os
import os

package = "pbxproj"

try:
    from pbxproj import XcodeProject
except:
    os.system("pip install "+ package)

from pbxproj import XcodeProject
import sys

project = XcodeProject.load('./FioriARKit.xcodeproj/project.pbxproj')
project.add_run_script('bash scripts/runSwiftLintCheck.sh', target_name='FioriARKit')
project.save()
