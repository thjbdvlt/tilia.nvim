syn region TiliaDone start="^\s*x " end="$" contains=TiliaSignDone keepend
syn region TiliaUndone start="^\s*- " end="$" contains=TiliaSignUndone,TiliaComment keepend
syn match TiliaSignDone "^\s*x" containedin=TiliaDone contained conceal cchar=✔
syn match TiliaSignUndone "^\s*-" contained containedin=TiliaUndone
syn region TiliaComment start="(" end=")" containedin=TiliaUndone contained
syn region TiliaTitle start=/"/ end=/"/ containedin=TiliaUndone contained
syn match TiliaName "[[:upper:]][[:upper:][:lower:]]*" containedin=TiliaUndone
syn match TiliaTodefineLine "^\s*\.\+\s*$"
syn match TiliaToDefine "\.\.\." containedin=TiliaTodefineLine contained
syn match TiliaDue "@[-.0-9]\+" containedin=TiliaUndone contained
syn match TiliaPriority "!\+" containedin=TiliaUndone contained
syn match TiliaPriority "?\+" containedin=TiliaUndone contained
syn region TiliaProject start="^\*" end="$"
syn match TiliaProject "\*.*" containedin=TiliaTree,TiliaUndone contained
syn match TiliaProjectSign '\*' containedin=TiliaProject contained
syn match TiliaDueSign '@' containedin=TiliaDue contained
syn region TiliaTree start="<" end="$" containedin=TiliaUndone keepend contains=TiliaTreeSign
syn match TiliaTreeSign '<'
syn match TiliaTag '\s\zs:[:[:lower:][:upper:]]\+' containedin=TiliaUndone contained
syn match TiliaTagSign ':' containedin=TiliaTag contained
syn match TiliaError "^ \+\*"
syn region TiliaComment start="^ *[^- *]" end="$" oneline

hi default link TiliaUndone Normal
hi default link TiliaDone NonText
hi default link TiliaSignDone MoreMsg
hi default link TiliaSignUndone Statement
hi default link TiliaComment Comment
hi default link TiliaHeader Title
hi default link TiliaTree NonText
hi default link TiliaDue Constant
hi default link TiliaPriority Operator
hi default link TiliaProject Title
hi default link TiliaProjectSign TiliaSignUndone
hi default link TiliaTreeSign TiliaSignUndone
hi default link TiliaDueSign TiliaSignUndone
hi default link TiliaTagSign TiliaSignUndone
hi default link TiliaTag Special
hi default link TiliaError Error
hi default link TiliaComment Comment
" Tilia: link semantic + avoid hardcoded fg/bg
hi default TiliaTitle guifg=#0087d7
hi default TiliaName gui=bold
hi default TiliaToDefine guibg=#ddffee
