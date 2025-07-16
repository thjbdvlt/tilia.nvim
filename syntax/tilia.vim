syn region TodoDone start="^\s*x " end="$" contains=TodoSignDone keepend
syn region TodoUndone start="^\s*- " end="$" contains=TodoSignUndone,TodoComment keepend
syn match TodoSignDone "^\s*x" containedin=TodoDone contained conceal cchar=✔
syn match TodoSignUndone "^\s*-" contained containedin=TodoUndone
syn region TodoComment start="(" end=")" containedin=TodoUndone contained
syn region TodoTitle start=/"/ end=/"/ containedin=TodoUndone contained
syn match TodoName "[[:upper:]][[:upper:][:lower:]]*" containedin=TodoUndone
syn match TodoTodefineLine "^\s*\.\+\s*$"
syn match TodoToDefine "\.\.\." containedin=TodoTodefineLine contained
syn region TodoHeader start="^\s*[*#]" end="$"
syn match TodoDue "@[-.0-9]\+" containedin=TodoUndone contained
syn match TodoPriority "!\+" containedin=TodoUndone contained
syn match TodoPriority "?\+" containedin=TodoUndone contained
syn match TodoProject "\*.*" containedin=TodoTree,TodoUndone
syn match TodoProjectSign '\*' containedin=TodoProject contained
syn match TodoDueSign '@' containedin=TodoDue contained
syn region TodoTree start="<" end="$" containedin=TodoUndone keepend contains=TodoTreeSign
syn match TodoTreeSign '<'
syn match TodoTag '\s\zs:[:[:lower:][:upper:]]\+' containedin=TodoUndone contained
syn match TodoTagSign ':' containedin=TodoTag contained

hi default link TodoUndone Normal
hi default link TodoDone NonText
hi default link TodoSignDone MoreMsg
hi default link TodoSignUndone Statement
hi default link TodoComment Comment
hi default link TodoHeader Title
hi default link TodoTree NonText
hi default link TodoDue Constant
hi default link TodoPriority Operator
hi default link TodoProject Title
hi default link TodoProjectSign TodoSignUndone
hi default link TodoTreeSign TodoSignUndone
hi default link TodoDueSign TodoSignUndone
hi default link TodoTagSign TodoSignUndone
hi default link TodoTag Special
" TODO: link semantic + avoid hardcoded fg/bg
hi default TodoTitle guifg=#0087d7
hi default TodoName gui=bold
hi default TodoToDefine guibg=#ddffee
