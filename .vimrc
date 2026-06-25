" ── Plugins ──────────────────────────────────────────────────────────────
set nocompatible
set encoding=utf-8
filetype indent plugin on

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'fatih/vim-go'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'flazz/vim-colorschemes'
Plugin 'vim-ruby/vim-ruby'
Plugin 'scrooloose/nerdtree'
Plugin 'scrooloose/nerdcommenter'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-rbenv'
Plugin 'tpope/vim-bundler'
Plugin 'pangloss/vim-javascript'
Plugin 'mxw/vim-jsx'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'blueyed/vim-diminactive'
Plugin 'robbles/logstash.vim'
Plugin 'uarun/vim-protobuf'
Plugin 'dense-analysis/ale'

call vundle#end()

" ── Settings ──────────────────────────────────────────────────────────────
syntax enable
set term=screen-256color
set t_ut=
set cmdheight=1
set number
set norelativenumber
set nowrap
set cursorline
set hls
set ignorecase
set noinfercase
set backspace=indent,eol,start
set fillchars=""
set switchbuf=split

set tabstop     =2
set softtabstop =2
set shiftwidth  =2
set expandtab

" set listchars+=space:·
set listchars+=eol:\
set listchars+=tab:⌐\
set list

set completeopt+=menuone
set completeopt-=preview
set completeopt+=longest,menuone,noselect
set shortmess+=c
set belloff+=ctrlg

" ── Plugin Config ─────────────────────────────────────────────────────────

" Airline
let g:airline_theme='bubblegum'
let g:airline_section_b = ''
let g:airline_section_x = ''
let g:airline_section_y = ''

" ALE
let g:ale_linters = {
  \ 'python': ['pylsp'],
  \ 'ruby': ['solargraph'],
  \ 'javascript': ['tsserver'],
  \ 'typescript': ['tsserver'],
  \ }
let g:ale_fixers = {}
let g:ale_fix_on_save = 0
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 0
let g:ale_completion_enabled = 1
let g:ale_completion_delay = 500

" vim-go
let g:go_highlight_structs = 1
let g:go_highlight_methods = 1
let g:go_highlight_functions = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_autosave = 1
let g:go_fmt_command = "goimports"

" NERDTree
let NERDTreeShowHidden = 1
let g:NERDTreeWinPos = "left"
let g:NERDTreeWinSize = 35
let NERDTreeMapOpenSplit = "<C-i>"
let NERDTreeMapOpenVSplit = "<C-t>"
let NERDTreeMapOpenInTab = "<C-n>"

" NERDCommenter
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDCustomDelimiters = { 'logstash': { 'left': '#','right': '' } }

" fzf
let g:fzf_action = {
  \ 'ctrl-i': 'split',
  \ 'ctrl-t': 'vsplit',
  \ 'ctrl-n': 'tab split' }

" indent-guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_auto_colors = 0

" ── Colors ────────────────────────────────────────────────────────────────
" slatedark sierra carrot seti maui
" stonewashed-256 py-darcula ayu sialoquent
" zenburn sift
colorscheme zenburn
let g:colors_name = "zenburn"

" ── Keymaps ───────────────────────────────────────────────────────────────

" Remaps
noremap ; :
noremap : ;
inoremap jk <Esc>
nnoremap <Esc><Esc> :nohls<CR>
vnoremap <Esc><Esc> <Esc>

" Editing
vnoremap p "_dP
nnoremap < v<<Esc>
nnoremap > v><Esc>
nmap <C-_> \ci
vmap <C-_> \ci
nnoremap @ orequire 'pry'; binding.pry<Esc>
nnoremap <C-e> :edit!<CR>

" Clipboard
vnoremap <C-c> "*y
nnoremap <C-c> V"*y
nnoremap <C-v> i<Esc>$<C-P>"*p<C-P>
inoremap <C-v> <Space><Esc>v<C-P>"*p<C-P><Esc>i<Right>

" Window management
nnoremap + 6<C-W>+
nnoremap _ 6<C-W>-
nnoremap - 12<c-w><
nnoremap = 12<c-w>>
nnoremap <C-a> <C-w>H
nnoremap <C-z> <C-w>L
nnoremap <C-d> :q<CR>
inoremap <C-d> <Esc>:q<CR>
vnoremap <C-d> <Esc>:q<CR>
nnoremap <M-t> :vnew<CR>
nnoremap <M-T> :tabnew<CR>

" Pane navigation (vim + tmux)
if !has('gui_running') && !has('nvim')
  execute "set <M-h>=\033h"
  execute "set <M-j>=\033j"
  execute "set <M-k>=\033k"
  execute "set <M-l>=\033l"
endif
nnoremap <M-h> :call N('h')<CR>
nnoremap <M-j> :call N('j')<CR>
nnoremap <M-k> :call N('k')<CR>
nnoremap <M-l> :call N('l')<CR>
inoremap <M-h> <Esc>:call N('h')<CR>
inoremap <M-j> <Esc>:call N('j')<CR>
inoremap <M-k> <Esc>:call N('k')<CR>
inoremap <M-l> <Esc>:call N('l')<CR>

" NERDTree
nnoremap <C-@> :NERDTreeToggle<CR>
nnoremap <C-n> :NERDTreeFind<CR>

" Tab navigation
noremap <M-1> 1gt
noremap <M-2> 2gt
noremap <M-3> 3gt
noremap <M-4> 4gt
noremap <M-5> 5gt

" Visual selection
vnoremap j jg_
vnoremap k k0
vnoremap G Gg_
vnoremap <Tab> $h
vnoremap <S-Tab> _
nnoremap d<Tab> d$
nnoremap d<S-Tab> d^

" Repeat / jump
nnoremap <Tab> .
nnoremap <M-o> <Tab>

" Search / grep
vnoremap <C-g> y/<C-R>"<CR>:lclose<CR>:GG <C-R>"<CR>
vnoremap <C-f> y/<C-R>"<CR>
nnoremap <C-g> :w<CR>:GoVet<CR>:ccl<CR>:cw 12
nnoremap <c-c><c-c> :exec "color " . ((g:colors_name == "zenburn") ? "sift" : "zenburn")<CR>

" Go to definition
autocmd FileType go nnoremap <buffer> } :vsp<CR>:GoDef<CR><C-w>T
autocmd FileType go nnoremap <buffer> " :GoDef<CR>
autocmd FileType go nnoremap <buffer> ? :vsp<CR>:GoDef<CR><C-w>x<C-w>l
autocmd FileType ruby,python,javascript,typescript nnoremap <buffer> } :ALEGoToDefinition -tab<CR>
autocmd FileType ruby,python,javascript,typescript nnoremap <buffer> " :ALEGoToDefinition<CR>
autocmd FileType ruby,python,javascript,typescript nnoremap <buffer> ? :ALEGoToDefinition -vsplit<CR>

" ── Commands ──────────────────────────────────────────────────────────────
:command -nargs=+ GG execute "silent Ggrep! ".shellescape(<q-args>)." -- '*.".expand('%:e')."'" | cw | redraw!
:command -nargs=+ GGG execute "silent Ggrep! ".shellescape(<q-args>) | cw | redraw!
:command GGGG execute "silent Ggrep! ".shellescape('#····') | cw | redraw!
:command DIFF execute 'windo diffthis'
:command DOFF execute 'windo diffoff'

" ── Functions ─────────────────────────────────────────────────────────────
function! N(dir)
  let prev = winnr()
  execute "wincmd " . a:dir
  if winnr() == prev
    let dmap = {'h': '-L', 'j': '-D', 'k': '-U', 'l': '-R'}
    if has('nvim')
      call jobstart(['tmux', 'select-pane', dmap[a:dir]])
    else
      call job_start(['tmux', 'select-pane', dmap[a:dir]])
    endif
  endif
endfunction

function HashTags()
  nnoremap t A     #····<Esc>0
  nnoremap T V:s/\ \ \ \ \ \#····/<CR>:nohls<CR>
  nnoremap ¥ /.*\ \ \ \ \ \#····$<CR>
  nnoremap Á :%s/\ \ \ \ \ \#····$//g<CR>:nohls<CR>
endfunction

function NormalTags()
  nnoremap t A     //····<Esc>0
  nnoremap T V:s/\ \ \ \ \ \/\/····/<CR>:nohls<CR>
  nnoremap ¥ /.*\ \ \ \ \ \/\/····$<CR>
  nnoremap Á :%s/\ \ \ \ \ \/\/····$//g<CR>:nohls<CR>
endfunction

function AdjustColors()
  source ~/.vim/default_colors.vim
  silent! AirlineRefresh
endfunction

function OpenQF()
  eval feedkeys(getwininfo(win_getid())[0]['loclist'] ? "\<CR>" : "\<CR>\<C-w>L:cclose\<CR>:lclose\<CR>:cw\<CR>\<C-w>kI\<Esc>l", 'n')
endfunction

" ── Autocommands ──────────────────────────────────────────────────────────

" Filetype colors
autocmd BufEnter *.rb                  colorscheme zenburn    | call HashTags()     | call AdjustColors()
autocmd BufLeave *.rb                  call NormalTags()
autocmd BufEnter *.py                  colorscheme sialoquent | call AdjustColors()
autocmd BufEnter *.go                  colorscheme sift       | call AdjustColors()
autocmd BufEnter *.*rc                 colorscheme zenburn    | call AdjustColors()
autocmd BufEnter *.yml,*.yaml          colorscheme sift       | call AdjustColors() | so ~/.vim/yaml.vim
autocmd BufEnter *.ts,*.tsx,*.js       colorscheme sift       | call AdjustColors()
autocmd BufEnter *.conf                colorscheme sift       | call AdjustColors() | so ~/.vim/syntax/logstash.vim
autocmd! colorscheme * call AdjustColors()

" NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Quickfix
autocmd FileType qf setlocal wrap
autocmd FileType qf nnoremap <buffer> <CR> :call OpenQF()<CR>

" ── Init ──────────────────────────────────────────────────────────────────
call NormalTags()
call AdjustColors()
