;; extends

; AlpineJS attributes
(attribute
  (attribute_name) @_attr
    (#lua-match? @_attr "^x%-%l")
    (#not-any-of? @_attr "x-teleport" "x-ref" "x-transition")
  (quoted_attribute_value
    (attribute_value) @injection.content)
  (#set! injection.language "javascript"))

; Blade escaped JS attributes
; <x-foo ::bar="baz" />
(element
  (_
    (tag_name) @_tag
      (#lua-match? @_tag "^x%-%l")
  (attribute
    (attribute_name) @_attr
      (#lua-match? @_attr "^::%l")
    (quoted_attribute_value
      (attribute_value) @injection.content)
    (#set! injection.language "javascript"))))

; Blade PHP attributes
; <x-foo :bar="$baz" />
(element
  (_
    (tag_name) @_tag
      (#lua-match? @_tag "^x%-%l")
    (attribute
      (attribute_name) @_attr
        (#lua-match? @_attr "^:%l")
      (quoted_attribute_value
        (attribute_value) @injection.content)
      (#set! injection.language "php_only"))))

;; Babel JSX inside <script type="text/babel">
(script_element
  (attribute
    (attribute_name) @attr-name
    (#eq? @attr-name "type")
    (attribute_value) @attr-value
    (#eq? @attr-value "\"text/babel\""))
  (script_content) @jsx)
  (#set! injection.language "tsx")

