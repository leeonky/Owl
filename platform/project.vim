#! /usr/bin/vim -S
map! <C-L> <Esc>:wa<CR>:mksession!<CR>:!clear && make retest<CR>
map <C-L> :wa<CR>:mksession!<CR>:!clear && make retest<CR>

source Session.vim

