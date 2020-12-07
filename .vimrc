set nocompatible
set encoding=utf-8
filetype indent plugin on

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
" call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, require Plugin 'VundleVim/Vundle.vim'
Plugin 'fatih/vim-go'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'vim-syntastic/syntastic'
Plugin 'nvie/vim-flake8'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'flazz/vim-colorschemes'
Plugin 'vim-ruby/vim-ruby'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-rbenv'
Plugin 'tpope/vim-bundler' " see :h vundle for more details or wiki for FAQ
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes' " Put your non-Plugin stuff after this line
" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'

" All of your Plugins must be added before the following line
call vundle#end()            " required

" source /Users/wai/.vim/vim-scrollbar/plugin/scrollbar.vim
" Default characters to use in the scrollbar.
" let g:scrollbar_thumb='#'
" let g:scrollbar_clear='|'

syntax enable
set term=screen-256color
set t_ut=

let g:airline_theme='fruit_punch'
let g:airline_section_b = ''
let g:airline_section_x = ''
let g:airline_section_y = ''

" Syntastic options
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_checkers=['flake8']

let g:fzf_action = {
	\ 'ctrl-i': 'split',
	\ 'ctrl-t': 'vsplit',
	\ 'ctrl-n': 'tab split' }

" Autocomplete options
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
set listchars+=eol:\ 
set listchars+=tab:⌐\ 
set list
"
" tabstop:          Width of tab character
" softtabstop:      Fine tunes the amount of white space to be added
" shiftwidth:       Determines the amount of whitespace to add in normal mode
" expandtab:        When on uses space instead of tabs
set tabstop     =2
set softtabstop =2
set shiftwidth  =2
set number
set nowrap
set fillchars=""
set norelativenumber
set backspace=indent,eol,start
set hls
set cursorline

" No shift for commands
noremap ; :
noremap : ;

" Stop it vim
inoremap jk <Esc>
nnoremap <Esc><Esc> :nohls<CR>
vnoremap <Esc><Esc> <Esc>

" Resize the vim windows
nnoremap + 6<C-W>+
nnoremap _ 6<C-W>-
nnoremap - 12<c-w><
nnoremap = 12<c-w>>

" Add or remove indent
nnoremap < v<<Esc>
nnoremap > v><Esc>

" Move window to left/right
nnoremap <C-a> <C-w>H
nnoremap <C-z> <C-w>L

" Ctrl+d to quit
nnoremap <C-d> :q<CR>
inoremap <C-d> <Esc>:q<CR>
vnoremap <C-d> <Esc>:q<CR>

" Going to the end/beginning of the line when selecting
vnoremap j jg_
vnoremap k k0
vnoremap G Gg_
nnoremap G Gg_

" Commenting
nmap <C-_> \ci
vmap <C-_> \ci

" Pry
nnoremap @ orequire 'pry'; binding.pry<Esc>

" Refresh the buffer
nnoremap <C-e> :edit!<CR>

set pastetoggle=<C-P>
" Using the native clipboard
vnoremap <C-c> "*y
" Paste on next line
nnoremap <C-v> i<Esc>$<C-P>"*p<C-P>
nnoremap <C-c> V"*y
" Paste right here
inoremap <C-v> <Space><Esc>v<C-P>"*p<C-P><Esc>i<Right>

" Alt-T
nnoremap † :vnew<CR>
" Alt-Shift-T
nnoremap ˇ :tabnew<CR>

" Select forwards or back without reaching for the number 4/6
vnoremap <Tab> $h
vnoremap <S-Tab> _
nnoremap d<Tab> d$
nnoremap d<S-Tab> d^

" Tab navigation, tbh idk how to get to tab 6
noremap å 1gt
noremap ß 2gt
noremap ∂ 3gt
noremap ƒ 4gt
noremap © 5gt

" Repeat
nnoremap <Tab> .

" Alt-O to undo Ctrl-O
nnoremap ø <Tab>

" The big GoVet
nnoremap <C-g> :w<CR> :GoVet<CR>

nnoremap <c-c><c-c> :exec "color " . ((g:colors_name == "sierra") ? "sialoquent" : "sierra")<CR>
let g:colors_name = "sierra"

" Use GoDef for Go definitions
autocmd FileType go nnoremap <buffer> " :vsp<CR>:GoDef<CR><C-w>T
autocmd FileType go nnoremap <buffer> ? :vsp<CR>:GoDef<CR><C-w>x<C-w>l
autocmd FileType ruby,python,javascript nnoremap <buffer> " :vsp<CR><C-]><C-w>T
autocmd FileType ruby,python,javascript nnoremap <buffer> ? :vsp<CR><C-]><C-w>x<C-w>l

" Seaching through the whole directory
:command -nargs=+ GG execute "silent Ggrep! ".shellescape(<q-args>)." -- '*.".expand('%:e')."'" | cw | redraw!
" Global Search Highlighted Text
vnoremap <C-g> y/<C-R>"<CR>:lclose<CR>:GG <C-R>"<CR>
vnoremap <C-f> y/<C-R>"<CR>

" Show diff between windows
:command DIFF execute 'windo diffthis'
:command DOFF execute 'windo diffoff'

" NERDTree settings
let NERDTreeShowHidden=1
let g:NERDTreeWinPos = "left"
let g:NERDTreeWinSize=35
nnoremap <C-@> :NERDTreeToggle<CR>
nnoremap <C-n> :NERDTreeFind<CR>
" Quit NERDTree if last pane
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeMapOpenSplit="<C-i>"
let NERDTreeMapOpenVSplit="<C-t>"
let NERDTreeMapOpenInTab="<C-n>"
let NERDSpaceDelims=1

let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0

" Open Quickfix in Vertical Split
set switchbuf=split

" Set wrap and show 10 quickfix lines by default
autocmd FileType qf setlocal wrap
autocmd FileType qf nnoremap <buffer> <CR> :call OpenQF()<CR>
function OpenQF()
	eval feedkeys(getwininfo(win_getid())[0]['loclist'] ? "\<CR>" : "\<CR>\<C-w>L:cclose\<CR>:lclose\<CR>:cw\<CR>\<C-w>kI\<Esc>l", 'n')
endfunction

let g:go_fmt_autosave=0
let g:go_asmfmt_autosave=0
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }
let g:syntastic_go_checkers = ['golint', 'govet', 'golangci-lint']
let g:syntastic_go_gometalinter_args = ['--disable-all', '--enable=errcheck']
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }
" let g:go_list_type = "quickfix"


function AdjustColors()
	source ~/.vim/default_colors.vim
	AirlineRefresh
endfunction

" Syntax for yamls
au BufNewFile,BufRead *.yaml,*.yml so ~/.vim/yaml.vim

autocmd BufEnter *.rb                  colorscheme sierra     | call AdjustColors()
autocmd BufEnter *.py                  colorscheme sialoquent | call AdjustColors()
autocmd BufEnter *.go                  colorscheme sialoquent | call AdjustColors()
autocmd BufEnter *.*rc                 colorscheme zenburn    | call AdjustColors()
autocmd BufEnter *.yml,*.yaml          colorscheme sift       | call AdjustColors()
autocmd BufEnter *.ts,*.tsx,*.js       colorscheme sift       | call AdjustColors()

" Cool colors
" slatedark sierra carrot seti maui
" stonewashed-256 py-darcula ayu sialoquent
" zenburn sift
colorscheme sierra
let g:colors_name = "sierra"
autocmd! colorscheme * call AdjustColors()
