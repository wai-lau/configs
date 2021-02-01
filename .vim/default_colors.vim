highlight! Search               ctermfg=11     ctermbg=0     cterm=bold
highlight! Visual               ctermfg=75     ctermbg=NONE  cterm=reverse

highlight! Normal               ctermfg=252    ctermbg=235   cterm=NONE
highlight! NonText              ctermfg=252    ctermbg=235   cterm=NONE
highlight! SpecialKey           ctermfg=252    ctermbg=235   cterm=NONE

highlight! TabLineFill          ctermfg=NONE   ctermbg=240   cterm=NONE
highlight! TabLineSel           ctermfg=0      ctermbg=245   cterm=NONE
highlight! TabLine              ctermfg=250    ctermbg=240   cterm=NONE

highlight! StatusLine           ctermfg=NONE   ctermbg=245   cterm=NONE
highlight! StatusLineNC         ctermfg=NONE   ctermbg=245   cterm=NONE

highlight! VertSplit            ctermfg=243    ctermbg=245   cterm=NONE
highlight! LineNr               ctermfg=243    ctermbg=237   cterm=NONE

highlight! CursorLine           ctermfg=NONE   ctermbg=0     cterm=underline
highlight! Comment              ctermfg=245    ctermbg=NONE  cterm=NONE

highlight! IndentGuidesOdd      ctermbg=241    ctermfg=0
highlight! IndentGuidesEven     ctermbg=239    ctermfg=0

highlight! QuickFixLine         ctermfg=NONE   ctermbg=NONE  cterm=bold

" highlight! Scrollbar_Clear ctermfg=green ctermbg=black guifg=green guibg=black cterm=none
" highlight! Scrollbar_Thumb ctermfg=darkgreen ctermbg=darkgreen guifg=darkgreen guibg=darkgreen cterm=reverse

highlight! BonusLight ctermfg=10 cterm=reverse

highlight! ColorColumn            ctermbg=238
highlight! SpellBad               guifg=#ff0000  guibg=NONE     gui=undercurl  ctermfg=196    ctermbg=NONE  cterm=undercurl

" match BonusLight /\s\+$\|binding.pry/
match BonusLight /binding.pry\|.*     \/\/····$/
match BonusLight /binding.pry\|.*     \/\/····$\|.*     \#····$/
