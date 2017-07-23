#!/usr/bin/env python
#
# Olivier Soares
# January 2014
#
# Run unit tests
#
# The MIT License (MIT)
#
# Copyright (c)2014-2016 Olivier Soares
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


'''
  Script to diff 2 files.
  This script must be invoked from git when doing "git diff".

  To call this script automatically, add this to your ~/.gitconfig:
  [diff]
    external = <path/to/this/script.py>

  The diff program to be used will be either meld, colordiff or diff.
  If you want to use a particular program,
  set GITDIFF environment variable to it.
'''


import sys, os, time, subprocess


def print_msg(header, msg):
  '''
  Print a message.

  Args:
    header: message header
    msg   : message to write
  '''

  try:
    sys.stderr.write("[%s @ %s]: %s\n" %
                    (header, time.strftime("%Y-%m-%d %H:%M:%S"), msg))
  except IOError:
    pass


def info(msg):
  '''
  Print a message (info).

  Args:
    msg: message to write
  '''

  print_msg("Info", msg)


def warning(msg):
  '''
  Print a message (warning).

  Args:
    msg: message to write
  '''

  print_msg("Warning", msg)


def error(msg):
  '''
  Print a message (error).
  Throw an exception as well.

  Args:
    msg: message to write
  '''

  print_msg("Error", msg)
  raise Exception(msg)


def find_bin(bin, error_if_not_found = True):
  '''
  Find a binary.

  Args:
    bin               : binary name
    error_if_not_found: throw an exception if the binary is not found

  Returns:
    Path to the binary
  '''

  # Common binary directories for unix systems
  # We start by looking in ~/bin if you want to override any binary
  dirs = ["$HOME/bin"     ,
          "/bin"          , "/sbin",
          "/usr/bin"      , "/usr/sbin",
          "/usr/local/bin", "/usr/local/sbin",
          "/opt/bin"      , "/opt/sbin",
          "/opt/local/bin", "/opt/local/sbin"]

  # Look at PATH environment variable
  path = os.getenv("PATH")
  if path:
    dirs = path.split(":") + dirs

  for dir in dirs:
    dir = os.path.expandvars(os.path.realpath(dir))
    if not os.path.isdir(dir):
      continue
    bin_path = os.path.join(dir, bin)
    if os.path.isfile(bin_path):
      # Found the binary
      return bin_path

  # Binary not found
  if error_if_not_found:
    error("Can't find binary '%s'" % bin)

  return None


def diff(bin):
  '''
  Diff 2 files using a binary.
  git diff sends 8 parameters - we only need 2:
    + the original file on the repository (argv[2])
    + the current one (argv[5])

  Args:
    bin: diff binary name
  '''

  FILE_A_INDEX = 2
  FILE_B_INDEX = 5
  ARGS_COUNT   = 8
  if len(sys.argv) != ARGS_COUNT:
    error("Invalid parameters - make sure the command is invoked from git")

  bin = find_bin(bin)
  cmd = [bin, sys.argv[FILE_A_INDEX], sys.argv[FILE_B_INDEX]]
  p   = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  err, out = p.communicate()
  return err, out, p.returncode


def main():
  '''
  Main function.
  '''

  # Try to find one diff program.
  # You can define GITDIFF with your favorite diff program to pick it first.
  bins = ["meld", "colordiff", "diff", None]
  bin_default = os.getenv("GITDIFF")
  if bin_default:
    bins = [bin_default] + bins
  for bin in bins:
    if not bin or find_bin(bin, False):
      break

  if not bin:
    error("No diff binary found")
  err, out, ret = diff(bin)
  print(err)


if __name__ == "__main__":
  main()
