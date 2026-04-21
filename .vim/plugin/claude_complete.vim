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
    'system': "Complete the code at the cursor. Output exactly 3 different completions separated by a line containing only ---\nEach completion is raw code, may be multiple lines, matches indentation exactly. No markdown, no fences, no explanation.",
    'messages': [{'role': 'user', 'content': context}]
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
      out_cb: (_, ln) => add(response_lines, ln),
      close_cb: (_) => ShowCompletion()
    }
  )
enddef

def ShowCompletion()
  try
    const resp = json_decode(join(response_lines, ''))
    if type(resp) != v:t_dict || !has_key(resp, 'content')
      echom 'Claude: unexpected response - ' .. join(response_lines, '')[ : 120]
      return
    endif
    var text = resp['content'][0]['text']
    if empty(text)
      echom 'Claude: empty response'
      return
    endif
    # Strip any markdown fences Claude ignores instructions about
    # Strip any markdown fences
    text = substitute(text, '```[^\n]*\n', '', 'g')
    text = substitute(text, '\n```', '', 'g')
    const words = filter(
      map(split(text, '\n---\n'), (_, v) => trim(v)),
      (_, v) => !empty(v)
    )
    echom ''
    complete(trigger_col, mapnew(words, (_, v) => ({
      word: v,
      abbr: substitute(v, '\n.*', '…', ''),
      menu: '[Claude]'
    })))
  catch
    echom 'Claude error: ' .. v:exception
  endtry
enddef

inoremap <Nul> <ScriptCmd>TriggerClaude()<CR>
