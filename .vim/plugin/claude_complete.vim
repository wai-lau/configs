vim9script

if !exists('g:claude_complete_model')
  g:claude_complete_model = 'claude-haiku-4-5-20251001'
endif

var response_lines: list<string> = []
var trigger_col: number = 0
var spinner_timer: number = -1
var spinner_idx: number = 0
const spinner_frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏']

def SpinnerTick(_timer: number)
  echon "\rClaude " .. spinner_frames[spinner_idx % len(spinner_frames)]
  spinner_idx += 1
enddef

def StartSpinner()
  spinner_idx = 0
  SpinnerTick(0)
  spinner_timer = timer_start(100, SpinnerTick, {repeat: -1})
enddef

def StopSpinner()
  if spinner_timer != -1
    timer_stop(spinner_timer)
    spinner_timer = -1
  endif
  echo ''
enddef

def TriggerClaude()
  if empty($ANTHROPIC_API_KEY)
    echom 'claude_complete: $ANTHROPIC_API_KEY not set'
    return
  endif

  const lnum = line('.')
  const col = col('.')
  trigger_col = col
  const start_line = max([1, lnum - 20])
  var ctx_lines = getline(start_line, lnum)
  ctx_lines[-1] = ctx_lines[-1][ : col - 2]
  const context = join(ctx_lines, "\n")

  const payload = json_encode({
    'model': g:claude_complete_model,
    'max_tokens': 512,
    'system': 'You are a code completion engine. Return ONLY a JSON array of exactly 5 different possible completions. No explanation, no markdown fences. Example: ["name", "name.upper()", "str(name)", "name or \"default\"", "repr(name)"]',
    'messages': [{'role': 'user', 'content': "Give 5 completions for:\n" .. context}]
  })

  response_lines = []
  StartSpinner()

  job_start(
    ['curl', '-s', '-X', 'POST',
      'https://api.anthropic.com/v1/messages',
      '-H', 'content-type: application/json',
      '-H', 'x-api-key: ' .. $ANTHROPIC_API_KEY,
      '-H', 'anthropic-version: 2023-06-01',
      '-d', payload],
    {
      out_cb: (_, line) => add(response_lines, line),
      close_cb: (_) => ShowCompletions()
    }
  )
enddef

def ShowCompletions()
  StopSpinner()
  try
    const resp = json_decode(join(response_lines, ''))
    if type(resp) != v:t_dict || !has_key(resp, 'content')
      echom 'Claude: unexpected response - ' .. join(response_lines, '')[ : 120]
      return
    endif
    const text = resp['content'][0]['text']
    if empty(text)
      echom 'Claude: empty response'
      return
    endif
    const options = json_decode(text)
    if type(options) != v:t_list || empty(options)
      echom 'Claude: could not parse completions'
      return
    endif
    const items = mapnew(options, (_, v) => ({word: v, menu: '[Claude]'}))
    complete(trigger_col, items)
  catch
    echom 'Claude error: ' .. v:exception
  endtry
enddef

inoremap <Nul> <ScriptCmd>TriggerClaude()<CR>
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
