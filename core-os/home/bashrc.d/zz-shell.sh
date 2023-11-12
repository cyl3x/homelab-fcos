export HISTSIZE=12000
export SAVEHIST=12000
export HISTTIMEFORMAT='%s'
export HISTIGNORE='ls:ll:cd:pwd:bg:fg:history'
export HISTCONTROL=ignoreboth:erasedups
export PROMPT_COMMAND='history -a; history -n'

bind '"\e[A": history-search-backward'
bind '"\eOA": history-previous-history'
bind '"\e[B": history-search-forward'
bind '"\eOB": next-history'
bind 'TAB:menu-complete'

bind 'set completion-ignore-case on'
bind 'set colored-stats on'
bind 'set show-all-if-ambiguous on'
bind 'set menu-complete-display-prefix on'

alias c='control'
alias ll='ls -CS -lsha --color=auto --group-directories-first'
alias ls='ls -CS --color=auto -h --group-directories-first'

if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi