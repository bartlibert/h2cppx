if(exists('b:h2cppx')) | finish | endif

let b:h2cppx = 1

if(exists('g:h2cppx'))
    finish
endif

let g:h2cppx = 1

"config variable
if(exists('g:h2cppx_python_path'))
    let s:python_path = g:h2cppx_python_path
else
    let s:python_path = 'python'
endif
if(exists('g:h2cppx_postfix'))
    let s:postfix = substitute(g:h2cppx_postfix,'\.','','')
else
    let s:postfix = 'cpp'
endif
if(exists('g:h2cppx_template'))
    let s:template_file = g:h2cppx_template
else
    let s:template_file = 'template1'
endif


if(system(s:python_path . ' -c "import sys; print sys.version_info[0]"') !=? "2\n")
    echohl WarningMsg | echomsg 'load h2cppx faild,python2.x is must need for h2cppx.' | echohl None
    finish
endif

let s:installed_directory = expand('<sfile>:p:h:h')
let s:h2cppx_dir = s:installed_directory . '/h2cppx'
let s:h2cppx_path= s:h2cppx_dir . '/h2cppx.py'

if (stridx(s:template_file,'/') != 0)
    let s:template_file= s:installed_directory . '/h2cppx/template/' . s:template_file
endif

function s:get_search_list()
    let l:config_file = findfile('.h2cppx_conf', '.;')
    if (l:config_file !=# '')
        let l:config_file = fnamemodify(l:config_file,':p')
        let l:config_dir  = fnamemodify(l:config_file, ':p:h')
        let l:search_list = readfile(l:config_file)
        let l:i = 0
        while l:i < len(l:search_list)
            if (stridx(l:search_list[l:i],'/') != 0)
                let l:search_list[l:i] = l:config_dir . '/' . l:search_list[l:i]
        endif
            let l:i = l:i + 1
    endwhile
    else
        let l:search_list = []
    endif
    return l:search_list
endfunction

"get full path
function s:fullpath(path)
    let l:dir = a:path
    let l:dir = fnamemodify(l:dir, ':p')
    if strlen(l:dir)!=0 && (stridx(l:dir,'/')!=0)
        let l:dir = fnamemodify('.',':p') . l:dir
    endif
    if strridx(l:dir,'/') != (strlen(l:dir)-1)
        let l:dir = l:dir . '/'
    endif
    return l:dir
endfunction

"full generate cpp file
function s:h2cppx(header_file, isClipboard)
    let l:filename = expand('%:t:r') . '.' . s:postfix
    let l:cpp_file = findfile(l:filename, join(s:get_search_list(),','))

    let l:cmd = printf('%s "%s" -t "%s" "%s" ', s:python_path, s:h2cppx_path, s:template_file, a:header_file)
    if ! (a:isClipboard == 1)
        if l:cpp_file ==# ''
            let l:dir = input('Cpp File not find, please enter the new file output directory: ')
            let l:cpp_file = s:fullpath(l:dir) . l:filename
        endif
        let l:cmd = l:cmd . ' -o ' . l:cpp_file
    endif
    let l:content = system(l:cmd)

    while 1
        if v:shell_error == 0
            if a:isClipboard == 1
                call setreg('"+', l:content )
                echo 'Define code already copy to your clipboard,use p to paster!'
            else
                echo 'Generate file ' . l:cpp_file . ' successful!'
            endif
        elseif v:shell_error == 1
            echo l:content
        elseif v:shell_error == 2
            echo l:content
        elseif v:shell_error == 3
            echo l:content
        elseif v:shell_error == 4
            let l:ans = input('file already exisit, force overwrite it?(yes/no): ')
            if l:ans ==? 'yes' || l:ans ==? 'y'
                let l:cmd = printf('%s "%s" "%s" -t "%s" -o "%s" -f', s:python_path, s:h2cppx_path, a:header_file, s:template_file, l:cpp_file)
                let l:content = system(l:cmd)
                continue
            endif
        elseif v:shell_error == 5
            echohl WarningMsg | echo "IO error\n" . l:content | echohl None
        endif
        break
    endwhile
endfunction

function s:h2cppx_line(header_file, line_number, isClipboard)
    let l:ln = a:line_number
    let l:filename = expand('%:t:r') . '.' . s:postfix
    let l:cpp_file = findfile(l:filename, join(s:get_search_list(),','))

    let l:cmd = printf('%s "%s" "%s" -t "%s" -ln %d -a', s:python_path, s:h2cppx_path, a:header_file, s:template_file, l:ln)
    if ! (a:isClipboard == 1)
        if l:cpp_file ==# ''
            let l:dir = input('Cpp File not find, please enter the new file output directory: ')
            let l:cpp_file = s:fullpath(l:dir) . l:filename
        endif
        let l:cmd = l:cmd . ' -o ' . l:cpp_file
    endif
    let l:content = system(l:cmd)

    while 1
        if v:shell_error == 0
            if a:isClipboard == 1
                call setreg('"+', l:content . "\n")
                echo 'Define code already copy to your clipboard,use p to paster!'
            else
                echo 'write file ' . l:cpp_file . ' successful!'
            endif
        elseif v:shell_error == 1
            echo l:content
        elseif v:shell_error == 2
            echohl WarningMsg | echo l:content | echohl None
        elseif v:shell_error == 3
            echohl WarningMsg | echo l:content | echohl None
        elseif v:shell_error == 4
            "let ans = input("file already exisit, append to file tail?(yes/no): ")
            "if toupper(ans) == "YES" || toupper(ans) == "Y"
            "    let cmd = printf('%s "%s" "%s" -ln %d -a', s:python_path, s:h2cppx_path, a:header_file, ln)
            "    let content = system(cmd)
            "    continue
            "endif
        elseif v:shell_error == 5
            echohl WarningMsg | echo "IO error\n" . l:content | echohl None
        endif
        break
    endwhile
endfunction

function s:h2cppx_auto(header_file)
    let l:search_path = ''
    let l:filename = expand('%:t:r') . '.' . s:postfix
    let l:cpp_file = findfile(l:filename, join(s:get_search_list(),','))

    let l:cmd = printf('%s "%s" -t "%s" "%s" -auto -p %s ', s:python_path, s:h2cppx_path, s:template_file, a:header_file, s:postfix)
    if len(s:get_search_list()) != 0
        let l:cmd = l:cmd . '--search-path=' . join(s:get_search_list(),',')
    endif

    if l:cpp_file ==# ''
        let l:dir = input('Cpp File not find, please enter the new file output directory: ')
        let l:cmd = l:cmd . ' --output-path=' . s:fullpath(l:dir)
    endif
    let l:content = system(l:cmd)

    while 1
        if v:shell_error == 0
            "let filename = expand('%:t:r') . "." . s:postfix
            "echo "Append code to " . filename . " successful!"
            echo l:content
        elseif v:shell_error == 1
            echo l:content
        elseif v:shell_error == 2
            echo l:content
        elseif v:shell_error == 3
            echo l:content
        elseif v:shell_error == 4
            echohl WarningMsg | echo 'unknow error' | echohl None
        elseif v:shell_error == 5
            echohl WarningMsg | echo "IO error\n" . l:content | echohl None
        endif
        break
    endwhile
endfunction

function H2cppxLine(isClipboard)
    call s:h2cppx_line(expand('%:p'), line('.'), a:isClipboard)
endfunction

function H2cppx(isClipboard)
    call s:h2cppx(expand('%:p'), a:isClipboard)
endfunction

function H2cppxAuto()
    call s:h2cppx_auto(expand('%:p'))
endfunction


"generate cpp define and put in cpp file
command! -buffer -nargs=0 H2cppx call H2cppx(0)
command! -buffer -nargs=0 H2cppxLine call H2cppxLine(0)
"generate cpp define and put in clipboard
command! -buffer -nargs=0 CpH2cppx call H2cppx(1)
command! -buffer -nargs=0 CpH2cppxLine call H2cppxLine(1)
"auto generate cpp define
command! -buffer -nargs=0 H2cppxAuto call H2cppxAuto()

