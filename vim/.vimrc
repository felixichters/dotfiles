syntax on
filetype plugin on
colorscheme habamax

set number
set cursorline
set colorcolumn=80
set laststatus=2
set list
set listchars=tab:>-,lead:.,trail:~

set autoindent
set noexpandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

set clipboard=unnamed
set incsearch
set ignorecase
set smartcase

set autoread

augroup filetype_indent
	autocmd!
	autocmd FileType c,cpp
		\ setlocal tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab
	autocmd FileType python
		\ setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
	autocmd FileType nix
		\ setlocal tabstop=2 shiftwidth=2 softtabstop=2 expandtab
augroup END

