# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# =============================================================================
# Prompt
if [[ $SHELL =~ .*/bash ]]
then
	export PS1=''

	# user@hostname
	export PS1+='\[$((($(id -u) == 0)) && printf "\033[1;91m" || printf "\033[1;95m")\]\u@\h'

	# date
	#export PS1+='\[\033[0;90m\]\D{%Y-%m-%d@%H:%M:%S}'

	# virtualenv
	export VIRTUAL_ENV_DISABLE_PROMPT=1
	export PS1+='\[\033[1;94m\]$([[ -n "$VIRTUAL_ENV" ]] && printf " (${VIRTUAL_ENV##*/})") '

	# cwd
	export PS1+='\[\033[1;93m\]$(printf "${PWD/#$HOME/\~}") '

	# git
	export GIT_PS1_SHOWDIRTYSTATE=true
	export GIT_PS1_SHOWSTASHSTATE=true
	export GIT_PS1_SHOWUNTRACKEDFILES=
	export GIT_PS1_SHOWUPSTREAM='auto'
	#export GIT_PS1_STATESEPARATOR=
	#export GIT_PS1_COMPRESSSPARSESTATE=
	#export GIT_PS1_OMITSPARSESTATE=
	export GIT_PS1_DESCRIBE_STYLE='branch'
	export GIT_PS1_SHOWCOLORHINTS=
	export GIT_PS1_HIDE_IF_PWD_IGNORED=true
	git_info() {
		#git_ps1=$(__git_ps1)
		# Avec '%s' pour ne pas avoir les parenth??ses
		git_ps1=$(__git_ps1 '%s')
		if [[ -n "$git_ps1" ]]
		then
			if [[ "$git_ps1" =~ GIT_DIR ]]
			then  # dans .git
				echo -n "($git_ps1)"
			else  # pas dans .git : fichiers non-suivis ?
				untracked=$(git status -s | grep "^??" | wc -l)
				untracked=$(printf '%d' $untracked)
				if ((untracked > 0))
				then  # ??? fichiers non-suivis
					echo -n "($git_ps1 ?$untracked)"
				else  # aucun fichier non-suivi
					echo -n "($git_ps1)"
				fi
			fi
		fi
		exit 0
	}
	# Exportation des fonctions n??cessaire au prompt, sinon, le terminal
	# ne les trouve pas pour cr????er le prompt quand on est dans un virtenv.
	export -f __git_ps1 __git_eread
	export -f git_info
	export PS1+='$((($(id -u) != 0)) && { [[ "$(git_info)" =~ GIT_DIR ]] && printf "%s" "\[\033[1;91m\]$(git_info)" || printf "%s" "\[\033[1;96m\]$(git_info)" ; })'

	# $ ou #
	export PS1+='\n\[\033[0m\]\$ '
fi

