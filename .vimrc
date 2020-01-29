set nocompatible
set encoding=utf-8
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" To ignore plugin indent changes, instead use:
" filetype plugin on

" Brief help " :PluginList       - lists configured plugins "
" :PluginInstall    - installs plugins; append `!` to update or just " :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to
" auto-approve removal

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, requirej
Plugin 'VundleVim/Vundle.vim'
Plugin 'fatih/vim-go'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'vim-syntastic/syntastic'
Plugin 'nvie/vim-flake8'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'flazz/vim-colorschemes'
Plugin 'vim-ruby/vim-ruby'
Plugin 'scrooloose/nerdcommenter'
Plugin 'tpope/vim-rails'
Plugin 'tpope/vim-rbenv'
Plugin 'tpope/vim-bundler' " see :h vundle for more details or wiki for FAQ
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
" Put your non-Plugin stuff after this line
" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'

" All of your Plugins must be added before the following line
call vundle#end()            " required

syntax on
filetype on
filetype indent on
filetype plugin on    " required

call plug#begin('~/.vim/plugged')
" :PlugInstall      - installs plugins
" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'lifepillar/vim-mucomplete'

call plug#end()

execute pathogen#infect()

set term=screen-256color
set t_ut=

syntax enable
colorscheme sierra "SlateDark Sierra carrot seti maui stonewashed-256 py-darcula
" autocmd FileType ruby colorscheme sierra
autocmd FileType go colorscheme SlateDark
autocmd FileType javascript colorscheme maui
" autocmd FileType markdown colorscheme SlateDark
" autocmd FileType sh colorscheme SlateDark

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_checkers=['flake8']

set number
set nowrap
set fillchars=""
set relativenumber

" tabstop:          Width of tab character
" softtabstop:      Fine tunes the amount of white space to be added
" shiftwidth:       Determines the amount of whitespace to add in normal mode
" expandtab:        When on uses space instead of tabs
set tabstop     =2
set softtabstop =2
set shiftwidth  =2
set expandtab

:Helptags

nnoremap + 6<C-W>+
nnoremap _ 6<C-W>-
nnoremap < 6<c-w><
nnoremap > 6<c-w>>

inoremap <C-d> <Esc>:q<CR>
nnoremap <C-d> :q<CR>
inoremap <C-w> <Esc>:w<CR>
inoremap jk <Esc>
nnoremap <C-w> :w<CR>
vnoremap <C-c> "*y
vnoremap <C-x> "*d
nmap <C-_> \ci
vmap <C-_> \ci
nnoremap œ :tabp<CR>
nnoremap ∑ :tabn<CR>
nnoremap † :tabnew<CR>
nnoremap ` :b#<CR>
nnoremap <C-e> :edit!<CR>
set pastetoggle=<C-P>
nnoremap <C-v> a <Esc>v<C-P>"*p<C-P><Esc>
inoremap <C-v> <Space><Esc>v<C-P>"*p<C-P><Esc>i

noremap ; :
noremap : ;

set hls
nnoremap \\ :nohls<CR>

let NERDTreeShowHidden=1
let g:NERDTreeWinPos = "left"
let g:NERDTreeWinSize=35
nnoremap <C-@> :NERDTreeToggle<CR>
nnoremap <C-n> :NERDTreeFind<CR>
" Quit NERDTree if last pane
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeMapOpenSplit="<C-i>"
let NERDTreeMapOpenVSplit="<C-t>"
let NERDSpaceDelims=1

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=237
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=239
autocmd VimEnter,Colorscheme * :hi BadWhitespace ctermbg=7
" autocmd VimEnter,Colorscheme * :hi Normal ctermbg=235
autocmd VimEnter,ColorScheme * match BadWhitespace /\s\+$/
autocmd FileType go   nnoremap ? :vsp<CR>:GoDef<CR>
autocmd FileType ruby,python,javascript nnoremap ? :vsp<CR><C-]>

let g:fzf_action = {
    \ 'ctrl-i': 'split',
  \ 'ctrl-t': 'vsplit',
  \ 'ctrl-n': 'tab split' }

python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup

set completeopt+=menuone
set completeopt-=preview
set completeopt+=longest,menuone,noselect
set shortmess+=c   " Shut off completion messages
set belloff+=ctrlg " If Vim beeps during completion
set noinfercase
set ignorecase
" The following line assumes `brew install llvm` in macOS
let g:clang_library_path = '/usr/local/opt/llvm/lib/libclang.dylib'
let g:clang_user_options = '-std=c++14'

let g:go_highlight_structs = 1
let g:go_highlight_methods = 1
let g:go_highlight_functions = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

" set listchars+=space:·
" set listchars+=eol:\ 
" set list

nnoremap <c-c><c-c> :exec "color " .
  \ ((g:colors_name == "sierra") ? "SlateDark" : "sierra")<CR>

:command -nargs=+ GG execute 'silent Ggrep!' '<q-args>' | cw | redraw!

:silent! ruby --version
