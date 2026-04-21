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
    'max_tokens': 1024,
    'system': 'You are a code completion engine. Respond with ONLY a raw JSON array of 5 strings, nothing else. No markdown, no code fences, no explanation. Each string is a completion. Use \\n for newlines within strings. Example output: ["x + 1", "x - 1", "x * 2", "str(x)", "len(x)"]',
    'messages': [{'role': 'user', 'content': "Complete this code (cursor is at the end):\n" .. context}]
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
    var raw = resp['content'][0]['text']
    if empty(raw)
      echom 'Claude: empty response'
      return
    endif
    # Strip markdown code fences
    raw = substitute(raw, '^```\w*\n', '', '')
    raw = substitute(raw, '\n```$', '', '')
    raw = trim(raw)
    const parsed = json_decode(raw)
    if type(parsed) != v:t_list || empty(parsed)
      echom 'Claude: could not parse completions'
      return
    endif
    # Accept both ["str", ...] and [{"completion": "str"}, ...]
    var words: list<string> = []
    for item in parsed
      if type(item) == v:t_string
        words->add(item)
      elseif type(item) == v:t_dict
        words->add(get(item, 'completion', get(item, 'text', '')))
      endif
    endfor
    if empty(words)
      echom 'Claude: no completions extracted'
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
