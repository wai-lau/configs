set nocompatible              " be iMproved, required
set encoding=utf-8
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" To ignore plugin indent changes, instead use:
" filetype plugin on

" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just
" :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to
" auto-approve removal

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'vim-ruby/vim-ruby'
Plugin 'vim-scripts/indentpython.vim'
Bundle 'Valloric/YouCompleteMe'
Plugin 'vim-syntastic/syntastic'
Plugin 'nvie/vim-flake8'
Plugin 'nathanaelkane/vim-indent-guides'

" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'

" All of your Plugins must be added before the following line
call vundle#end()            " required



filetype plugin indent on    " required

call plug#begin('~/.vim/plugged')
" :PlugInstall      - installs plugins
" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

call plug#end()

execute pathogen#infect()

syntax on

" set term=screen-256color
set t_ut=

syntax enable
set background=dark
let g:solarized_termcolors=256
" colorscheme solarized
colorscheme slate

let NERDTreeShowHidden=1
let g:NERDTreeWinPos = "left"
" Quit NERDTree if last pane
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

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

highlight BadWhitespace ctermfg=16 ctermbg=253 guifg=#000000 guibg=#F80000
au BufRead,BufNewFile *.rb,*.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" for use with YCM
let g:ycm_server_python_interpreter = '/usr/bin/python'
let g:syntastic_python_checkers=['flake8']

:Helptags

nnoremap + 10<C-W>+
nnoremap _ 10<C-W>-
nnoremap < 10<c-w><
nnoremap > 10<c-w>>

noremap ; :
noremap : ;

inoremap jk <Esc>

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0
autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=236
autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=0

let g:fzf_action = {
  \ 'ctrl-s': 'split',
  \ 'ctrl-t': 'vsplit' }

python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
" autocmd VimEnter,VimLeave * silent !tmux set status off
autocmd VimEnter * if &filetype !=# 'gitcommit' | NERDTree | endif
let g:NERDTreeWinSize=35
nnoremap <C-n> :NERDTreeToggle<CR>
