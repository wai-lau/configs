vim9script

if !exists('g:claude_complete_model')
  g:claude_complete_model = 'claude-haiku-4-5-20251001'
endif

var response_lines: list<string> = []
var trigger_col: number = 0

def TriggerClaude()
  if empty($ANTHROPIC_API_KEY)
    echom 'claude_complete: $ANTHROPIC_API_KEY not set'
    return
  endif

  const lnum = line('.')
  const col = col('.')
  trigger_col = col
  const start_line = max([1, lnum - 50])
  var ctx_lines = getline(start_line, lnum)
  ctx_lines[-1] = ctx_lines[-1][ : col - 2]
  const context = join(ctx_lines, "\n")

  const payload = json_encode({
    'model': g:claude_complete_model,
    'max_tokens': 2048,
    'system': "You are a code completion engine. Provide exactly 3 completions separated by the delimiter\n<<<NEXT>>>\nEach completion should be substantial — complete the function body, block, or logical chunk. Match indentation and style exactly. No explanation, no markdown, no preamble. Output only the completions and delimiters.",
    'messages': [{'role': 'user', 'content': "Complete this code (cursor at end):\n" .. context}]
  })

  response_lines = []
  echom 'Claude...'

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
  try
    const resp = json_decode(join(response_lines, ''))
    if type(resp) != v:t_dict || !has_key(resp, 'content')
      echom 'Claude: unexpected response - ' .. join(response_lines, '')[ : 120]
      return
    endif
    const raw = resp['content'][0]['text']
    if empty(raw)
      echom 'Claude: empty response'
      return
    endif
    const words = filter(
      map(split(raw, '<<<NEXT>>>'), (_, v) => trim(v)),
      (_, v) => !empty(v)
    )
    if empty(words)
      echom 'Claude: no completions found'
      return
    endif
    echom ''
    const items = mapnew(words, (_, v) => ({
      word: v,
      abbr: substitute(v, '\n.*', '…', ''),
      menu: '[Claude]'
    }))
    complete(trigger_col, items)
  catch
    echom 'Claude error: ' .. v:exception
  endtry
enddef

inoremap <Nul> <ScriptCmd>TriggerClaude()<CR>
