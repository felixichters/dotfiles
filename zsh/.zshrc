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
	[[ -n $d ]] && i=' %F{8}[git]%f'
	[[ -n $IN_NIX_SHELL ]] && i+=' %F{8}[nix]%f'
	print -P "%F{42}%~%f$i"
}

PROMPT='%# '

path=("$HOME/.local/bin" $path)
