vim9script

# Configurable model — override with: let g:claude_complete_model = '...'
if !exists('g:claude_complete_model')
  g:claude_complete_model = 'claude-haiku-4-5-20251001'
endif

var response_lines: list<string> = []

def TriggerClaude()
  if empty($ANTHROPIC_API_KEY)
    echom 'claude_complete: $ANTHROPIC_API_KEY not set'
    return
  endif

  const lnum = line('.')
  const col = col('.')
  const start_line = max([1, lnum - 20])
  var ctx_lines = getline(start_line, lnum)
  ctx_lines[-1] = ctx_lines[-1][ : col - 2]
  const context = join(ctx_lines, "\n")

  const payload = json_encode({
    'model': g:claude_complete_model,
    'max_tokens': 256,
    'system': 'You are a code completion engine. Output ONLY the completion text with no explanation and no markdown fences.',
    'messages': [{'role': 'user', 'content': "Complete this code:\n" .. context}]
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
      close_cb: (_) => InsertCompletion()
    }
  )
enddef

def InsertCompletion()
  try
    const resp = json_decode(join(response_lines, ''))
    if type(resp) != v:t_dict || !has_key(resp, 'content')
      echom 'Claude: unexpected response - ' .. join(response_lines, '')[ : 120]
      return
    endif
    const text = resp['content'][0]['text']
    if empty(text)
      echom 'Claude: empty completion'
      return
    endif
    echom ''
    feedkeys(text, 'n')
  catch
    echom 'Claude error: ' .. v:exception
  endtry
enddef

inoremap <Nul> <Cmd>call TriggerClaude()<CR>
