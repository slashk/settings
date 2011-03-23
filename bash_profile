# my personal bashrc

# rails specific stuff
alias sc='./script/console'
alias remotemac='ssh -L 5900:localhost:5900 minimac'
alias g='git '
alias gs='git status'
alias gb='git branch'
alias gc='git commit'
alias gt='git log --abbrev-commit --pretty="%ai %s (%ae #%h)" -n 10'
alias twt='twitter '
alias h=history
alias trcli='transmission-remote-cli.py'
alias b='bzr '
alias bs='bzr status'
alias bt='bzr top'

export PATH=$PATH:/usr/local/mysql/bin

export CLICOLOR=1

# for virtualenvwrapper support (python)
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

PATH=${PATH}:/Users/kpepple/bin
export PATH

# Setting PATH for MacPython 2.6
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/2.6/bin:${PATH}"
export PATH

