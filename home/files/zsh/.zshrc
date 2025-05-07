# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [ -n "${GHOSTTY_RESOURCES_DIR}" ]; then
  source "${GHOSTTY_RESOURCES_DIR}/shell-integration/zsh/ghostty-integration"
fi

[ -f "$ZDOTDIR/.aliasrc" ] && source "$ZDOTDIR/.aliasrc"
[ -f "$ZDOTDIR/.optionrc" ] && source "$ZDOTDIR/.optionrc"
[ -f "$ZDOTDIR/.pluginrc" ] && source "$ZDOTDIR/.pluginrc"

export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_CTRL_T_OPTS="--walker-skip .git,node_modules,target --preview 'bat -n --color=always --line-range=:500 {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"

HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups
setopt nobeep

bindkey -e
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
bindkey '^[[3~' delete-char
bindkey '^[[3;5~' kill-word
bindkey '^H' backward-kill-word
bindkey '^[[1;5D' backward-word 
bindkey '^[[1;5C' forward-word
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

zstyle :compinstall filename '$ZDOTDIR/.zshrc'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons=always $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

autoload -Uz compinit; compinit

source "$ZDOTDIR/plugins/powerlevel10k/powerlevel10k.zsh-theme"
source "$ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZDOTDIR/plugins/fzf-tab/fzf-tab.plugin.zsh"

# FPATH=($ZDOTDIR/zsh-completions/src $FPATH)

# To customize prompt, run `p10k configure` or edit "$ZDOTDIR/.p10k.zsh"
[[ -f "$ZDOTDIR/.p10k.zsh" ]] && source "$ZDOTDIR/.p10k.zsh"


if command -v direnv &>/dev/null; then
	eval "$(direnv hook zsh)"
fi

if command -v fzf &>/dev/null; then
	eval "$(fzf --zsh)"
fi

if command -v zoxide &>/dev/null; then
	eval "$(zoxide init --cmd cd zsh)"
fi


# Should be sourced last
source "$ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
