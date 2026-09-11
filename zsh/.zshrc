HISTSIZE="10000"
SAVEHIST="10000"

setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

unsetopt BEEP

autoload -Uz compinit && compinit

autoload -Uz vcs_info

setopt prompt_subst
zstyle ':vcs_info:git*' formats '%F{green}%b%f%m%u%c'
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr ' %F{green}+%f'
zstyle ':vcs_info:*' unstagedstr ' %F{yellow}-%f'
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked

+vi-git-untracked() {
	local in_tree
	in_tree=$(git rev-parse --is-inside-work-tree 2>/dev/null)
	if [[ $in_tree == 'true' ]] \
	&& git status --porcelain | grep -m 1 '^??' &>/dev/null; then
		hook_com[misc]=' %F{yellow}?%f'
	fi
}

nix_indicator() {
	[[ -n "$IN_NIX_SHELL" ]] && echo '%F{green}*%f'
}

sys() {
	local host=${HOST%%.*} user=${USER}
	local dir="$HOME/.dotfiles/hosts/$host"
	case "$1" in
		clean)   sudo nix-collect-garbage -d && nix-collect-garbage -d ;;
		init)
			case "$2" in
				flake)
					[[ -f flake.nix ]] && echo "flake.nix already exists" \
					&& return 1
					cat > flake.nix << 'FLAKE'
{
  description = "dev shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
          ];
          shellHook = "echo 'done'";
        };
      });
}
FLAKE
					echo "created flake.nix" ;;
				git)
					[[ ! -d .git ]] && git init
					[[ ! -f .gitignore ]] \
					&& touch .gitignore && echo "created .gitignore"
					return 0 ;;
				"")
					sys init git; sys init flake ;;
				*)
					echo "usage: sys init [flake|git]" ;;
			esac ;;
		*)
			echo "usage: sys {init|clean}" ;;
	esac
}

precmd() {
	vcs_info
	print -P '%F{8}%n@%m%f %~ ${vcs_info_msg_0_} $(nix_indicator)'
}

PROMPT='%# '

export PATH="$HOME/.local/bin:$PATH"
