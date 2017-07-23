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
  Script to keep 2 directories in sync,
  one being the encrypted version of the second one.
'''


import sys, os, time, getpass


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


def syntax(msg):
  '''
  Print a message (syntax).

  Args:
    msg: message to write
  '''

  print_msg("Syntax", msg)
  exit(0)


def print_syntax():
  syntax("%s [-e/-d] <src_dir> <dst_dir>" % sys.argv[0])


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


def create_dir(dir):
  '''
  Create safely a directory.

  Args:
    dir: directory to create
  '''

  if os.path.isdir(dir):
    return
  try:
    os.makedirs(dir)
  except(Exception, e):
    error("Can't create directory '%s' (%s)" % (dir, e))


def delete_file(file):
  '''
  Delete safely a file.

  Args:
    file: file to delete
  '''

  if not os.path.isfile(file):
    return
  try:
    os.remove(file)
  except(Exception, e):
    error("Can't delete file '%s' (%s)" % (file, e))


def encrypt(dir_src, dir_dst, passwd = None):
  '''
  Encrypt a directory.

  Args:
    dir_src: source directory
    dir_dst: destination directory
    passwd : password (None = will be asked)
  '''

  dir_src = os.path.abspath(dir_src)
  if not os.path.isdir(dir_src):
    error("%s is not a valid directory" % dir_src)

  if not passwd:
    passwd = getpass.getpass("Enter a password:")
    if passwd != getpass.getpass("Retype your password:"):
      error("Password does not match")

  dir_dst = os.path.abspath(dir_dst)
  create_dir(dir_dst)

  files = []
  dirs  = []
  for f in os.listdir(dir_src):
    ff = os.path.join(dir_src, f)
    if os.path.isfile(ff):
      files.append(f)
    if os.path.isdir(ff):
      dirs.append(f)

  files.sort()
  dirs.sort()

  if len(files):
    files_list = ""
    for file in files:
      files_list += " '%s'" % file
    tarball = "%s.tar.gz" % os.path.basename(dir_src)
    tar_path = os.path.join(dir_dst, tarball)
    tar_bin = find_bin("tar")
    cmd = "%s cPzf '%s' -C '%s'%s" % (tar_bin, tar_path, dir_src, files_list)
    os.system(cmd)
    gpg_bin = find_bin("gpg")
    cmd = "%s --no-verbose -q --yes --compress-algo 1 --cipher-algo "\
          "AES256 --passphrase '%s' -c '%s'" % (gpg_bin, passwd, tar_path)
    os.system(cmd)
    delete_file(tar_path)
    gpg_path = tar_path + ".gpg"
    if not os.path.isfile(gpg_path):
      error("Can't encrypt file '%s'" % tar_path)
    info("Directory '%s' encrypted to %s" % (dir_src, gpg_path))

  for dir in dirs:
    encrypt(os.path.join(dir_src, dir), os.path.join(dir_dst, dir), passwd)


def decrypt(dir_src, dir_dst, passwd = None):
  '''
  Decrypt a directory.

  Args:
    dir_src: source directory
    dir_dst: destination directory
    passwd : password (None = will be asked)
  '''

  dir_src = os.path.abspath(dir_src)
  if not os.path.isdir(dir_src):
    error("%s is not a valid directory" % dir_src)

  if not passwd:
    passwd = getpass.getpass("Enter a password:")

  dir_dst = os.path.abspath(dir_dst)
  create_dir(dir_dst)

  files = []
  dirs  = []
  for f in os.listdir(dir_src):
    ff = os.path.join(dir_src, f)
    if os.path.isfile(ff):
      files.append(f)
    if os.path.isdir(ff):
      dirs.append(f)

  files.sort()
  dirs.sort()

  if len(files):
    if len(files) == 1:
      gpg_path = os.path.join(dir_src, files[0])
      tar_path = os.path.splitext(gpg_path)[0]
      file_ext = os.path.splitext(gpg_path)[1]
      if file_ext == ".gpg":
        tar_path = os.path.join(dir_dst, os.path.basename(tar_path))
        gpg_bin = find_bin("gpg")
        cmd = "%s --no-verbose -q --yes --passphrase '%s' --output "\
              "'%s' '%s'" % (gpg_bin, passwd, tar_path, gpg_path)
        os.system(cmd)
        if os.path.isfile(tar_path):
          tar_bin = find_bin("tar")
          cmd = "%s xPzf '%s' -C '%s'" % (tar_bin, tar_path, dir_dst)
          os.system(cmd)
          delete_file(tar_path)
          info("File '%s' decrypted to '%s'" % (gpg_path, dir_dst))
        else:
          warning("Can't decrypt file '%s'" % gpg_path)
      else:
        warning("File '%s' does not seem to be an encrypted file" %
                gpg_path)
    else:
      warning("Directory '%s' should only contain 1 file" % dir_src)

  for dir in dirs:
    decrypt(os.path.join(dir_src, dir), os.path.join(dir_dst, dir), passwd)


def main():
  '''
  Main function.
  '''

  if len(sys.argv) < 4:
    print_syntax()

  if sys.argv[1] == "-e":
    encrypt(sys.argv[2], sys.argv[3])
  elif sys.argv[1] == "-d":
    decrypt(sys.argv[2], sys.argv[3])
  else:
    print_syntax()


if __name__ == "__main__":
  main()
