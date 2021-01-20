#!/bin/bash
# Shell script to start Vim with less.vim.
# Read stdin if no arguments were given and stdin was redirected.

VIM=vim

if [[ $0 =~ gvimpager ]]; then
    VIM=gvim
fi

if test -t 1; then
  if test $# = 0; then
    if test -t 0; then
      echo "Missing filename" 1>&2
      exit
    fi
    # todo:  formatting.
    tee /tmp/man | $VIM --cmd 'let no_plugin_maps = 1' -c 'runtime! ftplugin/man.vim' -
    #tee /tmp/man | $VIM --cmd 'let no_plugin_maps = 1' -c 'runtime! macros/less.vim' -
  else
    $VIM --cmd 'let no_plugin_maps = 1' -c 'runtime! macros/less.vim' "$@"
  fi
else
  # Output is not a terminal, cat arguments or stdin
  if test $# = 0; then
    if test -t 0; then
      echo "Missing filename" 1>&2
      exit
    fi
    cat
  else
    cat "$@"
  fi
fi
