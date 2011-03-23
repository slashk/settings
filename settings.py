#!/usr/bin/env python

# copyright 2011, Ken Pepple

import getopt
import os
import shutil
import sys

local_files = {
    '.irbrc' : 'irbrc',
    '.bash_profile' : 'bash_profile',
    '.bazaar/bazaar.conf' : 'bazaar.conf',
    '.autotest' : 'autotest',
    '.gemrc' : 'gemrc',
    '.gitconfig' : 'gitconfig',
    '.vimrc' : 'vimrc',
    '.vimrc.local' : 'vimrc.local'
}

def get_local_files(config_files, verbose):
    for (source, destination) in config_files.iteritems():
        full_source_path = os.path.join(os.environ['HOME'],source)
        try:
            shutil.copy(full_source_path, destination)
        except:
            print "copy failed: %s to %s" % (full_source_path, destination)
            sys.exit(1)
        else:
            if verbose == True:
                print ("%s copied to %s" % (full_source_path, destination))

def put_local_files(config_files, verbose):
    for (destination, source) in config_files.iteritems():
        full_destination_path = os.path.join(os.environ['HOME'],source)
        shutil.copy(source, full_destination_path)
        if verbose:
            print ("%s copied to %s" % (source, full_destination_path)) 

def usage():
    print "$ settings.py -h -p -v"
    print "     -h prints this help message"
    print "     -p copies files to instead of from home directory"
    print "     -v verbose output"
    print "this script requires your $home environment to be set"

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "hpv", ["help", "put", "verbose"])
    except getopt.GetoptError, err:
        print str(err) 
        usage()
        sys.exit(2)
    verbose = False
    getfiles = True
    for o, a in opts:
        if o == "-v":
            verbose = True
        elif o in ("-h", "--help"):
            usage()
            sys.exit()
        elif o in ("-p", "--put"):
            getfiles = False
    if getfiles:
        get_local_files(local_files, verbose)
    else:
        put_local_files(local_files, verbose)


if __name__ == "__main__":
    main()