" History
set history=1000

" Auto read when a file changes
set autoread

" Syntax color
syntax on
try
  colorscheme desert
catch
endtry

" Use the mouse
set mouse=r

" Add line numbers
set number

" No backup
set nobackup
set nowb
set noswapfile

" Encoding
set encoding=utf8
set ffs=unix,dos,mac

" Replace tab with spaces
set expandtab
set smarttab

" 1 tab = 2 spaces
set tabstop=2
set softtabstop=2
set shiftwidth=2

" Automatic indentation
set autoindent
set smartindent
set wrap

" Set 4 lines to the cursor
set so=4

" English
let $LANG='en'
set langmenu=en
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim

" Turn on the wild menu
set wildmenu

" Ignore compiled files
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
  set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
  set wildignore+=.git\*,.hg\*,.svn\*
endif

" Show current position
set ruler

" Command bar height
set cmdheight=2

" Buffer abandoned = hidden
set hid

" Make backspace work
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Modern search
set incsearch

" Perf
set lazyredraw

" For regular expressions
set magic

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Add left margin
set foldcolumn=1

" Display a vertical line at 79 chars
if exists('+colorcolumn')
  set colorcolumn=79
endif

" Always show the status line
set laststatus=2

" Format the status line
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l

" Returns true if paste mode is enabled
function! HasPaste()
  if &paste
    return 'PASTE MODE  '
  endif
  return ''
endfunction
