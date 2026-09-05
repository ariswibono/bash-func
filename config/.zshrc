# SANITIZED BACKUP — secrets replaced with <PLACEHOLDERS>. Do NOT copy blindly over ~/.zshrc.
# Source: MacBook optimized .zshrc (nvm/pyenv lazy-load, ~0.2s startup). See bash-func README.
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="common"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic update check (saves fork on startup)
DISABLE_COMPFIX="true"  # skip slow compaudit (we use cached compdump)
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
	git
	kubectl
	)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Package Managers
eval "$(/opt/homebrew/bin/brew shellenv)"
case ":$PATH:" in
  *":/opt/homebrew/opt/libpq/bin:"*) ;;
  *) export PATH="/opt/homebrew/opt/libpq/bin:$PATH" ;;
esac

# Python build flags (only used when building python, cheap exports so keep)
export LDFLAGS="-L/opt/homebrew/opt/expat/lib"
export CPPFLAGS="-I/opt/homebrew/opt/expat/include"
# Python Environment (lazy-loaded: saves ~0.5s startup)
export PYENV_ROOT="$HOME/.pyenv"
# Static shims on PATH so `python` resolves before first pyenv load (what `pyenv init --path` did)
case ":$PATH:" in
  *":$PYENV_ROOT/shims:"*) ;;
  *) export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH" ;;
esac
__pyenv_loaded=0
__pyenv_load() {
  (( __pyenv_loaded )) && return 0
  __pyenv_loaded=1
  # Remove shims so eval'd init can re-add cleanly, then run the 3 inits once
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
}
for _cmd in pyenv python python3 pip pip3 virtualenv; do
  eval "${_cmd}() { unfunction $_cmd \$0 2>/dev/null; unset -f $_cmd 2>/dev/null; __pyenv_load; $_cmd \"\$@\"; }"
done
unset _cmd

# Node.js Environment (lazy-loaded: saves ~0.5-0.8s startup)
export NVM_DIR="$HOME/.nvm"
# Static default node on PATH so `node/npm` work before first nvm use (no fork)
if [[ -d "$NVM_DIR/versions/node/v24.11.1/bin" ]]; then
  case ":$PATH:" in
    *":$NVM_DIR/versions/node/v24.11.1/bin:"*) ;;
    *) export PATH="$NVM_DIR/versions/node/v24.11.1/bin:$PATH" ;;
  esac
fi
__nvm_loaded=0
__nvm_load() {
  (( __nvm_loaded )) && return 0
  __nvm_loaded=1
  # shellcheck disable=SC1090
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  # Replicate eager nvm_auto: activate default (or .nvmrc) on first use
  if [[ -f ".nvmrc" ]]; then
    nvm use --silent 2>/dev/null || true
  elif [[ "$(nvm current 2>/dev/null)" == "system" || "$(nvm current 2>/dev/null)" == "none" ]]; then
    nvm use default --silent 2>/dev/null || true
  fi
}
for _cmd in nvm node npm npx yarn pnpm corepack; do
  eval "${_cmd}() { unfunction $_cmd \$0 2>/dev/null; unset -f $_cmd 2>/dev/null; __nvm_load; $_cmd \"\$@\"; }"
done
unset _cmd
# Lightweight .nvmrc hook: triggers lazy load only when .nvmrc present
autoload -U add-zsh-hook
__nvm_autoload_hook() {
  if [[ -f ".nvmrc" && $__nvm_loaded -eq 0 ]]; then
    __nvm_load
    nvm use --silent 2>/dev/null
  fi
}
add-zsh-hook chpwd __nvm_autoload_hook

# Go Environment (static, no `go env` fork)
if [[ -d "/Volumes/ArisExternalDrive/Workspaces/go" ]]; then
  export GOPATH="/Volumes/ArisExternalDrive/Workspaces/go"
else
  export GOPATH="$HOME/go"
fi
case ":$PATH:" in
  *":$GOPATH/bin:"*) ;;
  *) export PATH="$PATH:$GOPATH/bin" ;;
esac

# Java Environment
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
case ":$PATH:" in
  *":$JAVA_HOME/bin:"*) ;;
  *) export PATH=$JAVA_HOME/bin:$PATH ;;
esac

# PHP/Composer
case ":$PATH:" in
  *":$HOME/.composer/vendor/bin:"*) ;;
  *) export PATH="$PATH:$HOME/.composer/vendor/bin" ;;
esac

# .NET Environment
export DOTNET_ROOT=$HOME/dotnet
case ":$PATH:" in
  *":$HOME/dotnet:"*) ;;
  *) export PATH=$PATH:$HOME/dotnet ;;
esac

# Kubernetes Tools
case ":$PATH:" in
  *":${KREW_ROOT:-$HOME/.krew}/bin:"*) ;;
  *) export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH" ;;
esac

# OpenSSL Configuration
export LDFLAGS="-L/usr/local/opt/openssl@3/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@3/include"
export PKG_CONFIG_PATH="/usr/local/opt/openssl@3/lib/pkgconfig"

# SSH Configuration (reuse agent — no new agent per tab)
if ! ssh-add -l >/dev/null 2>&1; then
  eval $(ssh-agent -s) >/dev/null 2>&1
fi
for key in ~/.ssh/personal/akuwibonoo+bitbucket.org@gmail.com ~/.ssh/personal/akuwibonoo@gmail.com ~/.ssh/personal/onboard-bifrost ~/.ssh/personal/daya-devops-sg-private-key.pem; do
  [[ -f "$key" ]] || continue
  ssh-add -l 2>/dev/null | grep -q "$(ssh-keygen -lf "$key" 2>/dev/null | awk '{print $2}')" 2>/dev/null || ssh-add "$key" >/dev/null 2>&1
done

## Shell Enhancements (deferred to post-prompt so first prompt is instant)
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=240'
__shell_enhancements_loaded=0
__load_shell_enhancements() {
  (( __shell_enhancements_loaded )) && return 0
  __shell_enhancements_loaded=1
  # Adding zsh-autosuggestions for better history
  [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  [ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
}
autoload -U add-zsh-hook
__deferred_enhancements_precmd() {
  add-zsh-hook -d precmd __deferred_enhancements_precmd
  __load_shell_enhancements
}
add-zsh-hook precmd __deferred_enhancements_precmd

# ArgoCD Aliases
alias argocd-login-onboardcrewapp="argocd login argocd.onboardcrewapp.com --username admin --password <ARGOCD_ONBOARD_PASSWORD> --grpc-web --insecure"
alias argocd-login-daya="argocd login argocd.daya.sg --username admin --password <ARGOCD_DAYA_PASSWORD> --skip-test-tls --grpc-web"

# Productivity alias
alias cat='bat'
alias vim="nvim"
alias v="nvim"
alias watch='viddy'
#alias code='agy-ide'

# Cloud Provider Functions
function unsetAllCloudKeys() {
  local keys=(
    "HW_SECRET_KEY"
    "HW_ACCESS_KEY"
    "HW_REGION_NAME"
    "AWS_ACCESS_KEY_ID"
    "AWS_SECRET_ACCESS_KEY"
    "AWS_DEFAULT_REGION"
  )

  for key in "${keys[@]}"; do
    unset "$key"
  done
}

function setDayaTerraformCredentials() {
  # Unset all keys
  unsetAllCloudKeys

  # Huawei Cloud provisioning related configuration
  export HW_SECRET_KEY="<HW_SECRET_KEY>"
  export HW_ACCESS_KEY="<HW_ACCESS_KEY>"
  export HW_REGION_NAME="ap-southeast-3"

  # AWS S3 Terraform state configuration
  export AWS_ACCESS_KEY_ID="<AWS_ACCESS_KEY_ID>"
  export AWS_SECRET_ACCESS_KEY="<AWS_SECRET_ACCESS_KEY>"
  export AWS_DEFAULT_REGION="ap-southeast-3"

  export AWS_RESPONSE_CHECKSUM_VALIDATION=when_required
  export AWS_REQUEST_CHECKSUM_CALCULATION=when_required
}

function setDayaCoreHuaweiCceAccess() {
  # Unset all keys
  unsetAllCloudKeys

  # Huawei Cloud provisioning related configuration
  export HW_SECRET_KEY="<HW_SECRET_KEY>"
  export HW_ACCESS_KEY="<HW_ACCESS_KEY>"
  export HW_REGION_NAME="ap-southeast-3"

  # AWS S3 Terraform state configuration
  export AWS_ACCESS_KEY_ID="<AWS_ACCESS_KEY_ID>"
  export AWS_SECRET_ACCESS_KEY="<AWS_SECRET_ACCESS_KEY>"
}

function loginArgocdOnboard() {
	argocd login argocd.onboardcrewapp.com --username admin --password <ARGOCD_ONBOARD_PASSWORD> --skip-test-tls --grpc-web
}

case ":$PATH:" in
  *":/Users/mataberat/bin:"*) ;;
  *) export PATH=$PATH:/Users/mataberat/bin ;;
esac

alias start-cloudflare='sudo /Applications/Cloudflare\ WARP.app/Contents/Resources/CloudflareWARP'
export LDFLAGS="-L/opt/homebrew/opt/libomp/lib"
export CPPFLAGS="-I/opt/homebrew/opt/libomp/include"

# NOTE: Tahoe one-time fixes below are intentionally NOT run per-shell (they were
# forking `defaults`+`launchctl` on every new tab). Run once manually if needed:
#   defaults write -g NSAutoFillHeuristicControllerEnabled -bool false
#   launchctl setenv CHROME_HEADLESS 1
#   defaults write com.apple.finder CreateDesktop -bool false

# nvm bash_completion is loaded lazily via __nvm_load (see Node.js section)

# pnpm (single canonical block; store override preserved)
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*|*":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME:$PNPM_HOME/bin:$PATH" ;;
esac
# Conditional pnpm store location
if [[ -d "/Volumes/ArisExternalDrive/Workspaces" ]]; then
  export PNPM_STORE_PATH="/Volumes/ArisExternalDrive/Workspaces/karsalabs/karsalms/.pnpm_store"
fi

# Mataberat Bash functions, aliases, and helpers script
[ -f "$HOME/bash-func/func.sh" ] && source "$HOME/bash-func/func.sh"
[ -f "$HOME/bash-func/config.sh" ] && source "$HOME/bash-func/config.sh"

# Backup zshrc
# Auto-backup .zshrc ke external drive (non-blocking & silent)
if [[ -d "/Volumes/ArisExternalDrive/Workspaces" ]]; then
  if [[ ! -f "/Volumes/ArisExternalDrive/Workspaces/.zshrc_mac_backup" ]] || ! cmp -s "$HOME/.zshrc" "/Volumes/ArisExternalDrive/Workspaces/.zshrc_mac_backup"; then
    cp "$HOME/.zshrc" "/Volumes/ArisExternalDrive/Workspaces/.zshrc_mac_backup" &>/dev/null &!
  fi
fi

# Added by Antigravity (guarded against nested-shell duplication)
case ":$PATH:" in
  *":/Users/mataberat/.antigravity/antigravity/bin:"*) ;;
  *) export PATH="/Users/mataberat/.antigravity/antigravity/bin:$PATH" ;;
esac
case ":$PATH:" in
  *":/opt/homebrew/opt/mysql-client/bin:"*) ;;
  *) export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH" ;;
esac

# Added by Antigravity IDE
case ":$PATH:" in
  *":/Users/mataberat/.antigravity-ide/antigravity-ide/bin:"*) ;;
  *) export PATH="/Users/mataberat/.antigravity-ide/antigravity-ide/bin:$PATH" ;;
esac

case ":$PATH:" in
  *":/Users/mataberat/.local/bin:"*) ;;
  *) export PATH="/Users/mataberat/.local/bin:$PATH" ;;
esac
# Go bin already on PATH via GOPATH block above (no `go env` fork here)

# Ensure nvm default node wins over brew system node (eager nvm_auto did this at
# startup; static prepend above got buried by later prepends). Move to front.
if [[ -d "$NVM_DIR/versions/node/v24.11.1/bin" ]]; then
  path=("$NVM_DIR/versions/node/v24.11.1/bin" ${path:#$NVM_DIR/versions/node/v24.11.1/bin})
fi

# Penpot MCP token for KarsaLMS UI/UX agent

# opencode: stop scanning external skill dirs (used skills symlinked into ~/.config/opencode/skills/external)
export OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1
export OPENCODE_DISABLE_EXTERNAL_SKILLS=1
