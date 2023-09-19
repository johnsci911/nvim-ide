; ((html) @injection.content
;     (#set! injection.language html)
;     (#set! injection.combined))
((php) @injection.content
    (#set! injection.language "php")
    (#set! injection.combined))
((parameter) @injection.content
    (#set! injection.language php))
