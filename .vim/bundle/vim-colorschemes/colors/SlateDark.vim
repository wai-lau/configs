"%% SiSU Vim color file
" SlateDark Maintainer: Rudra Banerjee <bnrj.rudra@yahoo.com>
" Originally inspired from Slate by Ralph Amissah
:set t_Co=256
:set background=dark
highlight clear
if version > 580
 hi clear
 if exists("syntax_on")
 syntax reset
 endif
endif
let colors_name = "SlateDark"
hi Normal ctermfg=254 ctermbg=235
hi VertSplit ctermfg=234 ctermbg=234 guibg=NONE
hi Folded guibg=black guifg=grey40 ctermfg=grey ctermbg=darkgrey
hi FoldColumn guibg=black guifg=grey20 ctermfg=4 ctermbg=7
hi IncSearch guifg=green guibg=black cterm=none ctermfg=yellow ctermbg=green
hi ModeMsg guifg=goldenrod cterm=none ctermfg=208
hi MoreMsg guifg=SeaGreen ctermfg=darkgreen
hi NonText guifg=RoyalBlue guibg=grey15 cterm=bold ctermfg=33
hi Question guifg=springgreen ctermfg=green
hi Search guibg=peru guifg=wheat cterm=none ctermfg=grey ctermbg=blue
hi Search guifg=#ffffdf guibg=NONE gui=reverse    ctermfg=230    ctermbg=NONE  cterm=reverse
hi SpecialKey guifg=yellowgreen ctermfg=darkgreen
hi StatusLine guibg=#c2bfa5 guifg=black gui=none cterm=bold,reverse
hi StatusLineNC guibg=#c2bfa5 guifg=grey40 gui=none cterm=reverse
hi Title guifg=gold gui=bold cterm=bold ctermfg=yellow
hi Statement guifg=CornflowerBlue ctermfg=81
hi Visual gui=none guifg=khaki guibg=olivedrab cterm=reverse
hi WarningMsg guifg=salmon ctermfg=1
hi String guifg=SkyBlue ctermfg=183
hi Comment term=bold ctermfg=3 guifg=grey40
hi Constant guifg=#ffa0a0 ctermfg=220
hi Special guifg=darkkhaki ctermfg=208
hi Identifier guifg=salmon ctermfg=red
hi Include guifg=red ctermfg=red
hi PreProc guifg=red guibg=white ctermfg=red
hi Operator guifg=Red ctermfg=Red
hi Define guifg=gold gui=bold ctermfg=214
hi Type guifg=CornflowerBlue ctermfg=40
hi Function guifg=navajowhite ctermfg=39
hi Structure guifg=green ctermfg=green
hi LineNr guifg=grey50 ctermfg=8
hi Ignore guifg=grey40 cterm=bold ctermfg=7
hi Todo guifg=orangered guibg=yellow2
hi Directory ctermfg=cyan
hi ErrorMsg cterm=bold guifg=White guibg=Red cterm=bold ctermfg=7 ctermbg=1
hi VisualNOS cterm=bold,underline
hi WildMenu ctermfg=0 ctermbg=3
hi DiffAdd ctermbg=4
hi DiffChange ctermbg=5
hi DiffDelete cterm=bold ctermfg=4 ctermbg=6
hi DiffText cterm=bold ctermbg=1
hi Underlined cterm=underline ctermfg=5
hi Error guifg=White guibg=Red cterm=bold ctermfg=7 ctermbg=1
hi SpellErrors cterm=bold ctermfg=7 ctermbg=1 gui=undercurl,bold
hi IndentGuidesOdd  ctermbg=239 ctermfg=235
hi IndentGuidesEven ctermbg=238 ctermfg=235
hi BadWhitespace ctermbg=196

