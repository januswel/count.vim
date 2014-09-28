" vim plugin file
" Filename:     count.vim
" Maintainer:   janus_wel <janus.wel.3@gmail.com>
" Dependencies: {{{1
"   This plugin requires following files
"
"   - https://github.com/januswel/jwlib.git
"       - autoload/jwlib/buf.vim
" License:      MIT License {{{1
"   See under URL.  Note that redistribution is permitted with LICENSE.
"   http://github.com/januswel/dotfiles/vimfiles/LICENSE

" preparations {{{1
" check if this plugin is already loaded or not
if exists('loaded_count')
    finish
endif
let loaded_count = 1

" reset the value of 'cpoptions' for portability
let s:save_cpoptions = &cpoptions
set cpoptions&vim

" main {{{1
" constants {{{2
let s:maps = [
            \   {
            \       'kind': 'nmap',
            \       'key': '<unique><Leader>cn',
            \       'rhs': '<Plug>(count-in-buffer)',
            \   },
            \   {
            \       'kind': 'nmap',
            \       'key': '<unique><Leader>ci',
            \       'rhs': '<Plug>(count-in-buffer-input)',
            \   },
            \   {
            \       'kind': 'vmap',
            \       'key': '<unique><Leader>cn',
            \       'rhs': '<Plug>(count-in-highlighted)',
            \   },
            \   {
            \       'kind': 'vmap',
            \       'key': '<unique><Leader>ci',
            \       'rhs': '<Plug>(count-in-highlighted-input)',
            \   },
            \ ]
lockvar s:maps

" mappings {{{2
" check global variables that specify the plugin is allowed to define mappings
if !(exists('no_plugin_maps') && no_plugin_maps)
            \ && !(exists('no_count_maps') && no_count_maps)

    for map in s:maps
        if !hasmapto(map['rhs'])
            execute map['kind'] . ' ' . map['key'] . ' '. map['rhs']
        endif
    endfor
endif

" <script> and <SID> are used by vim internally
" consider to use :silent if you inhibit messages from vim
nnoremap <silent><Plug>(count) :%call <SID>CountInBuffer('', 0)<CR>
nnoremap <silent><Plug>(count-input) :%call <SID>CountInBuffer('', 1)<CR>
vnoremap <silent><Plug>(count-in-highlighted) :call <SID>CountInHighlighted('', 0)<CR>
vnoremap <silent><Plug>(count-in-highlighted-input) :call <SID>CountInHighlighted('', 1)<CR>

" commands {{{2
" use exists() to check the command is already defined or not
" return value 2 tells that the command matched completely exists
if exists(':Count') != 2
    command -nargs=? -range=% -bang Count <line1>,<line2>call <SID>CountInBuffer('<args>', 0)
endif

" functions {{{2
function! s:CountInBuffer(pattern, needs_input) range " {{{3
    let pattern = s:GetPattern(a:pattern, a:needs_input)

    let cmd = printf('%s,%ss/%s/&/gne', a:firstline, a:lastline, pattern)
    redir => cmd_result
    silent execute cmd
    redir END

    if cmd_result != ''
        let numof_patterns = substitute(substitute(cmd_result, '\n', '', 'g'), ' match\(es\)\? on \d\+ lines\?', '', '')
    else
        let numof_patterns = 0
    endif

    echo numof_patterns . ' found /' . pattern . '/'
endfunction

function! s:CountInHighlighted(pattern, needs_input) range " {{{3
    " The "range" is required to avoid calling this function for each line

    let pattern = s:GetPattern(a:pattern, a:needs_input)

    " KLUDGE: this is very slow
    let previous = jwlib#buf#GetVisualHighlighted()
    let replaced = substitute(previous, pattern, '', '')
    let numof_patterns = 0
    while previous != replaced
        let numof_patterns += 1
        let previous = replaced
        let replaced = substitute(previous, pattern, '', '')
    endwhile

    echo numof_patterns . ' found /' . pattern . '/'
endfunction

function! s:GetPattern(pattern, needs_input) " {{{3
    if a:needs_input == 1
        let pattern = input('pat? ')
        if pattern ==# ''
            let pattern = @/
        endif
        return pattern
    endif

    if a:pattern ==# ''
        return @/
    else
        return a:pattern
    endif
endfunction

" post-processings {{{1
" restore the value of 'cpoptions'
let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions

" }}}1
" vim: ts=4 sw=4 sts=0 et fdm=marker fdc=3
