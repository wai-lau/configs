vim9script

if !hlexists('GhostText')
  highlight GhostText ctermfg=240 guifg=#585858
endif
if empty(prop_type_get('ghost_text'))
  prop_type_add('ghost_text', {highlight: 'GhostText', override: true})
endif

var ghost_timer: number = -1
var ghost_prop_lnum: number = 0
var ghost_text: string = ''

def ClearGhost()
  if ghost_prop_lnum > 0
    prop_remove({type: 'ghost_text', all: true}, ghost_prop_lnum)
    ghost_prop_lnum = 0
    ghost_text = ''
  endif
enddef

def GetPrefix(): string
  const col = col('.')
  const line_str = getline('.')
  var start = col - 2
  while start >= 0 && line_str[start] =~ '\w'
    start -= 1
  endwhile
  return line_str[start + 1 : col - 2]
enddef

def FindMatch(prefix: string): string
  if len(prefix) < 2
    return ''
  endif
  var best = ''
  for buf in range(1, bufnr('$'))
    if !buflisted(buf) || !bufloaded(buf)
      continue
    endif
    for bline in getbufline(buf, 1, '$')
      for word in split(bline, '\W\+')
        var matches = word !=# prefix
          && len(word) > len(prefix)
          && word[: len(prefix) - 1] ==# prefix
          && len(word) > len(best)
        if matches
          best = word
        endif
      endfor
    endfor
  endfor
  return best
enddef

def ShowGhost(_t: number)
  ghost_timer = -1
  ClearGhost()
  const prefix = GetPrefix()
  const match = FindMatch(prefix)
  if empty(match)
    return
  endif
  const lnum = line('.')
  const col = col('.')
  ghost_prop_lnum = lnum
  ghost_text = match[len(prefix) :]
  prop_add(lnum, col, {type: 'ghost_text', text: ghost_text})
enddef

def OnTextChanged()
  ClearGhost()
  if ghost_timer != -1
    timer_stop(ghost_timer)
  endif
  ghost_timer = timer_start(150, ShowGhost)
enddef

def AcceptGhost(): string
  if empty(ghost_text)
    return "\<Right>"
  endif
  const accepted = ghost_text
  ClearGhost()
  return accepted
enddef

def TabComplete(): string
  if pumvisible()
    return "\<C-n>"
  elseif !empty(ghost_text)
    const accepted = ghost_text
    ClearGhost()
    return accepted
  endif
  return "\<Tab>"
enddef

augroup ghost_complete
  autocmd!
  autocmd InsertLeave * ClearGhost()
  autocmd TextChangedI * OnTextChanged()
augroup END

inoremap <expr> <Tab> TabComplete()
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"
inoremap <expr> <Right> AcceptGhost()
