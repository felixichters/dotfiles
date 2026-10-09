HISTFILE="$HOME/.zsh_history"
HISTSIZE="10000"
SAVEHIST="10000"

unsetopt BEEP

autoload -Uz compinit && compinit

flake() {
	[[ -f flake.nix ]] && echo "flake.nix already exists" && return 1
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
	echo "created flake.nix"
}

precmd() {
	local d=$PWD i=''
	while [[ -n $d && ! -e $d/.git ]]; do d=${d%/*}; done
	if [[ -n $d ]]; then
		local -a lines
		lines=("${(@f)$(git --no-optional-locks -C "$d" status --porcelain --branch 2>/dev/null)}")
		local header=${lines[1]#\#\# }
		local branch=${header%%...*}
		[[ $branch == "HEAD (no branch)" ]] && branch=$(git -C "$d" rev-parse --short HEAD 2>/dev/null)
		local dirty=''
		(( ${#lines} > 1 )) && dirty='*'
		local ahead='' behind=''
		[[ $header == *'[ahead '* ]] && { ahead=${header#*'[ahead '}; ahead=${ahead%%[,\]]*}; }
		[[ $header == *'behind '* ]] && { behind=${header#*'behind '}; behind=${behind%%]*}; }
		local sync=''
		[[ -n $ahead ]] && sync+=" +${ahead}"
		[[ -n $behind ]] && sync+=" -${behind}"
		local color='green'
		[[ -n $dirty ]] && color='yellow'
		i=" %F{$color}${branch}${dirty}${sync}%f"
	fi
	[[ -n $IN_NIX_SHELL ]] && i+=' %F{green}[nix]%f'
	PROMPT="%F{cyan}%(4~|.../%3~|%~)%f$i %# "
}

path=("$HOME/.local/bin" $path)
