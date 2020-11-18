set nocompatible
set encoding=utf-8
filetype indent plugin on
"
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
Plugin 'vim-airline/vim-airline-themes'
" Put your non-Plugin stuff after this line
" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'

" All of your Plugins must be added before the following line
call vundle#end()            " required

" source /Users/wai/.vim/vim-scrollbar/plugin/scrollbar.vim
" Default characters to use in the scrollbar.
" let g:scrollbar_thumb='#'
" let g:scrollbar_clear='|'

set term=screen-256color
set t_ut=

syntax enable
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:airline_theme='fruit_punch'

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_checkers=['flake8']

set number
set nowrap
set fillchars=""
set norelativenumber

" tabstop:          Width of tab character
" softtabstop:      Fine tunes the amount of white space to be added
" shiftwidth:       Determines the amount of whitespace to add in normal mode
" expandtab:        When on uses space instead of tabs
set tabstop     =2
set softtabstop =2
set shiftwidth  =2

nnoremap + 6<C-W>+
nnoremap _ 6<C-W>-
nnoremap - 12<c-w><
nnoremap = 12<c-w>>
nnoremap < v<<Esc>
nnoremap > v><Esc>
nnoremap <C-a> <C-w>H
nnoremap <C-z> <C-w>L

nnoremap <C-d> :q<CR>
inoremap <C-d> <Esc>:q<CR>
vnoremap <C-d> <Esc>:q<CR>
inoremap jk <Esc>
vnoremap j j$
vnoremap k k$
nnoremap <C-c> V"*y
vnoremap <C-c> "*y
nnoremap <C-x> V"*d
vnoremap <C-x> "*d
nnoremap G G$
vnoremap G G$
nmap <C-_> \ci
vmap <C-_> \ci
nnoremap ` :b#<CR>
nnoremap <C-e> :edit!<CR>
set pastetoggle=<C-P>
nnoremap <C-v> a <Esc>v<C-P>"*p<C-P><Esc>
inoremap <C-v> <Space><Esc>v<C-P>"*p<C-P><Esc>i
nnoremap † :vnew<CR>
vnoremap <Tab> $
vnoremap <S-Tab> ^

noremap å 1gt
noremap ß 2gt
noremap ∂ 3gt
noremap ƒ 4gt
noremap © 5gt
nnoremap ˇ :tabnew<CR>
nnoremap <Tab> .
nnoremap ø <Tab>

noremap ; :
noremap : ;

set hls
nnoremap \\ :nohls<CR>
nnoremap <C-g> :w<CR> :GoVet<CR>

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
autocmd FileType go nnoremap " :GoDef<CR>
autocmd FileType ruby,python,javascript nnoremap " <C-]>
autocmd FileType go nnoremap ? :vsp<CR>:GoDef<CR>
autocmd FileType ruby,python,javascript nnoremap ? :vsp<CR><C-]>


let g:fzf_action = {
  \ 'ctrl-i': 'split',
  \ 'ctrl-t': 'vsplit',
  \ 'ctrl-n': 'tab split' }

" python3 from powerline.vim import setup as powerline_setup
" python3 powerline_setup()
" python3 del powerline_setup

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

nnoremap <c-c><c-c> :exec "color " .
  \ ((g:colors_name == "sierra") ? "sialoquent" : "sierra")<CR>
let g:colors_name = "sierra"

:command -nargs=+ GG execute 'silent Ggrep!' '<q-args>' | cw | redraw!
:command DIFF execute 'windo diffthis'
:command DOFF execute 'windo diffoff'

:set switchbuf+=split

let g:go_fmt_autosave=0
let g:go_asmfmt_autosave=0
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }
let g:syntastic_go_checkers = ['golint', 'govet', 'golangci-lint']
let g:syntastic_go_gometalinter_args = ['--disable-all', '--enable=errcheck']
let g:syntastic_mode_map = { 'mode': 'active', 'passive_filetypes': ['go'] }
let g:go_list_type = "quickfix"

autocmd FileType qf setlocal wrap
autocmd FileType qf 10wincmd_

function AdjustColors()
	highlight! Visual               guifg=#5f8787  guibg=NONE     gui=reverse  ctermfg=66    ctermbg=NONE  cterm=reverse
	highlight! Search               guifg=#ffffdf  guibg=NONE     gui=reverse  ctermfg=230   ctermbg=NONE  cterm=reverse

	highlight! Normal               guifg=#e4e4e4  guibg=#303030  gui=NONE     ctermfg=251   ctermbg=234   cterm=NONE

	highlight! TabLineFill          guifg=NONE     guibg=#262626  gui=NONE     ctermfg=NONE  ctermbg=235   cterm=NONE
	highlight! TabLineSel           guifg=#eeeeee  guibg=#262626  gui=NONE     ctermfg=255   ctermbg=245   cterm=NONE
	highlight! TabLine              guifg=#767676  guibg=#262626  gui=NONE     ctermfg=243   ctermbg=235   cterm=NONE

	highlight! StatusLineNC         guifg=#767676  guibg=#000000  gui=NONE     ctermfg=243   ctermbg=0     cterm=NONE

	highlight! VertSplit            guifg=#767676  guibg=#262626  gui=NONE     ctermfg=243   ctermbg=0     cterm=NONE
	highlight! LineNr               guifg=#767676  guibg=#262626  gui=NONE     ctermfg=243   ctermbg=235   cterm=NONE

	highlight! NonText              guifg=#444444  guibg=NONE     gui=NONE     ctermfg=238   ctermbg=NONE  cterm=NONE
	highlight! SpecialKey           guifg=#444444  guibg=NONE     gui=NONE     ctermfg=238   ctermbg=NONE  cterm=NONE

	highlight! Pmenu                guifg=#767676  guibg=#262626  gui=NONE     ctermfg=243   ctermbg=235   cterm=NONE
	highlight! PmenuSel             guifg=#eeeeee  guibg=#262626  gui=NONE     ctermfg=255   ctermbg=235   cterm=NONE
	highlight! PmenuSbar            guifg=#262626  guibg=#262626  gui=NONE     ctermfg=235   ctermbg=235   cterm=NONE
	highlight! PmenuThumb           guifg=#262626  guibg=#262626  gui=NONE     ctermfg=235   ctermbg=235   cterm=NONE

	highlight! Comment              guifg=#767676  guibg=NONE     gui=NONE     ctermfg=244   ctermbg=NONE  cterm=NONE

	highlight! IndentGuidesOdd  ctermbg=239 ctermfg=235
	highlight! IndentGuidesEven ctermbg=238 ctermfg=235

	highlight! Scrollbar_Clear ctermfg=green ctermbg=black guifg=green guibg=black cterm=none
	highlight! Scrollbar_Thumb ctermfg=darkgreen ctermbg=darkgreen guifg=darkgreen guibg=darkgreen cterm=reverse

	highlight! BonusLight ctermbg=196
	match BonusLight /\s\+$\|binding.pry/ 

	AirlineRefresh
endfunction

"slatedark sierra carrot seti maui
"stonewashed-256 py-darcula ayu sialoquent
"zenburn sift

au BufNewFile,BufRead *.yaml,*.yml so ~/.vim/yaml.vim

autocmd BufEnter *.rb                  colorscheme sierra        | call AdjustColors()
autocmd BufEnter *.py                  colorscheme sialoquent    | call AdjustColors()
autocmd BufEnter *.go                  colorscheme sialoquent    | call AdjustColors()
autocmd BufEnter *.*rc                 colorscheme zenburn       | call AdjustColors()
autocmd BufEnter *.yml,*.yaml          colorscheme sift          | call AdjustColors()
autocmd BufEnter *.ts,*.tsx,*.js       colorscheme sift          | call AdjustColors()

colorscheme sierra
let g:colors_name = "sierra"
autocmd! colorscheme * call AdjustColors()

set backspace=indent,eol,start
