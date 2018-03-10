#
# ~/.bashrc
# for remote terminals

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# environment vars
export EDITOR=vi

# alias defs
alias ll='ls -hal --color=always'
alias ls='ls --color=always'
alias cb='cd $OLDPWD'
alias dmesg='dmesg --human --color=always'
alias df='df -h'
alias sr='shutdown -r 0'
alias sd='shutdown -P 0'
alias clr='clear'
alias seek='find . -xdev -name'
alias tree='tree -C'
alias grep='grep --color=always'
alias less='less -R'
alias pn='ps aux | grep'

# color defs
COL1='\[\033[0;38;5;${col1}m\]'
COL2='\[\033[0;38;5;${col2}m\]'
# prompt
PS1="$COL2[\u@\h \A \W]$$COL1 "
