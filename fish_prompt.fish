# name: fairyfloss
#
# fairyfloss is a Powerline-style, Git-aware fish theme optimized for awesome, essentially stolen from bobthefish.
#
# You will need a Powerline-patched font for this to work:
#
#     https://powerline.readthedocs.org/en/latest/fontpatching.html
#
# I recommend picking one of these:
#
#     https://github.com/Lokaltog/powerline-fonts
#
# You can override some default prompt options in your config.fish:
#
#     set -g theme_display_git no
#     set -g theme_display_git_untracked no
#     set -g theme_display_git_ahead_verbose yes
#     set -g theme_display_hg yes
#     set -g theme_display_virtualenv no
#     set -g theme_display_ruby no
#     set -g theme_display_user yes
#     set -g theme_display_vi yes
#     set -g theme_display_vi_hide_mode default
#     set -g theme_avoid_ambiguous_glyphs yes
#     set -g default_user your_normal_user

set -g __ff_current_background_color NONE

# Powerline glyphs
set __fairyfloss_branch_glyph            \uE0A0
set __fairyfloss_ln_glyph                \uE0A1
set __fairyfloss_padlock_glyph           \uE0A2
set __fairyfloss_right_black_arrow_glyph \uE0B0
set __fairyfloss_right_arrow_glyph       \uE0B1
set __fairyfloss_left_black_arrow_glyph  \uE0B2
set __fairyfloss_left_arrow_glyph        \uE0B3

# Additional glyphs
set __fairyfloss_detached_glyph          \u27A6
set __fairyfloss_nonzero_exit_glyph      '! '
set __fairyfloss_superuser_glyph         '$ '
set __fairyfloss_bg_job_glyph            '% '
set __fairyfloss_hg_glyph                \u263F

# Python glyphs
set __fairyfloss_superscript_glyph       \u00B9 \u00B2 \u00B3
set __fairyfloss_virtualenv_glyph        \u25F0
set __fairyfloss_pypy_glyph              \u1D56

# Colors
set __fairyfloss_silver        f8f8f0
set __fairyfloss_dark_gray     49483e
set __fairyfloss_lavender_gray 5a5475
set __fairyfloss_shadow        3b3a32
set __fairyfloss_bg_purple     5a5475

set __fairyfloss_pink         ffb8d1
set __fairyfloss_peach        ff857f
set __fairyfloss_magenta      f92672
set __fairyfloss_deep_magenta c7054c

set __fairyfloss_pale_gold fffbe6
set __fairyfloss_goldenrod fffea0
set __fairyfloss_gold      e6c000
set __fairyfloss_deep_gold b39500

set __fairyfloss_pale_seafoam e6fff2
set __fairyfloss_seafoam      c2ffdf
set __fairyfloss_dark_seafoam 80ffbd

set __fairyfloss_dusty_lilac   efe6ff
set __fairyfloss_lilac         c5a3ff
set __fairyfloss_lavender      8076aa
set __fairyfloss_bright_purple ae81ff
set __fairyfloss_violet        63588d

# ===========================
# Helper methods
# ===========================

# function __fairyfloss_in_git -d 'Check whether pwd is inside a git repo'
#   command which git > /dev/null 2>&1; and command git rev-parse --is-inside-work-tree >/dev/null 2>&1
# end

# function __fairyfloss_in_hg -d 'Check whether pwd is inside a hg repo'
#   command which hg > /dev/null 2>&1; and command hg stat > /dev/null 2>&1
# end

function __fairyfloss_git_branch -d 'Get the current git branch (or commitish)'
  set -l ref (command git symbolic-ref HEAD ^/dev/null)
  if [ $status -gt 0 ]
    set -l branch (command git show-ref --head -s --abbrev | head -n1 ^/dev/null)
    set ref "$__fairyfloss_detached_glyph $branch"
  end
  echo $ref | sed  "s#refs/heads/#$__fairyfloss_branch_glyph #"
end

function __fairyfloss_hg_branch -d 'Get the current hg branch'
  set -l branch (command hg branch ^/dev/null)
  set -l book (command hg book | grep \* | cut -d\  -f3)
  echo "$__fairyfloss_branch_glyph $branch @ $book"
end

function __fairyfloss_pretty_parent -a current_dir -d 'Print a parent directory, shortened to fit the prompt'
  echo -n (dirname $current_dir) | sed -e 's#/private##' -e "s#^$HOME#~#" -e 's#/\(\.\{0,1\}[^/]\)\([^/]*\)#/\1#g' -e 's#/$##'
end

function __fairyfloss_git_project_dir -d 'Print the current git project base directory'
  [ "$theme_display_git" = 'no' ]; and return
  command git rev-parse --show-toplevel ^/dev/null
end

function __fairyfloss_hg_project_dir -d 'Print the current hg project base directory'
  [ "$theme_display_hg" = 'yes' ]; or return
  set d (pwd)
  while not [ $d = / ]
    if [ -e $d/.hg ]
      command hg root --cwd "$d" ^/dev/null
      return
    end
    set d (dirname $d)
  end
end

function __fairyfloss_project_pwd -a current_dir -d 'Print the working directory relative to project root'
  echo "$PWD" | sed -e "s#$current_dir##g" -e 's#^/##'
end

function __fairyfloss_git_ahead -d 'Print the ahead/behind state for the current branch'
  if [ "$theme_display_git_ahead_verbose" = 'yes' ]
    __fairyfloss_git_ahead_verbose
    return
  end

  command git rev-list --left-right '@{upstream}...HEAD' ^/dev/null | awk '/>/ {a += 1} /</ {b += 1} {if (a > 0 && b > 0) nextfile} END {if (a > 0 && b > 0) print "±"; else if (a > 0) print "+"; else if (b > 0) print "-"}'
end

function __fairyfloss_git_ahead_verbose -d 'Print a more verbose ahead/behind state for the current branch'
  set -l commits (command git rev-list --left-right '@{upstream}...HEAD' ^/dev/null)
  if [ $status != 0 ]
    return
  end

  set -l behind (count (for arg in $commits; echo $arg; end | grep '^<'))
  set -l ahead (count (for arg in $commits; echo $arg; end | grep -v '^<'))

  switch "$ahead $behind"
    case '' # no upstream
    case '0 0' # equal to upstream
      return
    case '* 0' # ahead of upstream
      echo "↑$ahead"
    case '0 *' # behind upstream
      echo "↓$behind"
    case '*' # diverged from upstream
      echo "↑$ahead↓$behind"
  end
end

# ===========================
# Segment functions
# ===========================

function __fairyfloss_start_segment -d 'Start a prompt segment'
  set -l bg $argv[1]
  set -e argv[1]
  set -l fg $argv[1]
  set -e argv[1]

  set_color normal # clear out anything bold or underline...
  set_color -b $bg
  set_color $fg $argv
  if [ "$__ff_current_background_color" = 'NONE' ]
    # If there's no background, just start one
    echo -n ' '
  else
    # If there's already a background...
    if [ "$bg" = "$__ff_current_background_color" ]
    # and it's the same color, draw a separator
      echo -n "$__fairyfloss_right_arrow_glyph "
    else
      # otherwise, draw the end of the previous segment and the start of the next
      set_color $__ff_current_background_color
      echo -n "$__fairyfloss_right_black_arrow_glyph "
      set_color $fg $argv
    end
  end
  set __ff_current_background_color $bg
end

function __fairyfloss_path_segment -a current_dir -d 'Display a shortened form of a directory'
  if [ -w "$current_dir" ]
    __fairyfloss_start_segment $__fairyfloss_lavender $__fairyfloss_silver
  else
    __fairyfloss_start_segment $__fairyfloss_magenta $__fairyfloss_silver
  end

  set -l directory
  set -l parent

  switch "$current_dir"
    case /
      set directory '/'
    case "$HOME"
      set directory '~'
    case '*'
      set parent    (__fairyfloss_pretty_parent "$current_dir")
      set parent    "$parent/"
      set directory (basename "$current_dir")
  end

  [ "$parent" ]; and echo -n -s "$parent"
  set_color fff --bold
  echo -n "$directory "
  set_color normal
end

function __fairyfloss_finish_segments -d 'Close open prompt segments'
  if [ -n $__ff_current_background_color -a $__ff_current_background_color != 'NONE' ]
    set_color -b normal
    set_color $__ff_current_background_color
    echo -n "$__fairyfloss_right_black_arrow_glyph "
    set_color normal
  end
  set -g __ff_current_background_color NONE
end


# ===========================
# Theme components
# ===========================

function __fairyfloss_prompt_status -d 'Display symbols for a non zero exit status, root and background jobs'
  set -l nonzero
  set -l superuser
  set -l bg_jobs

  # Last exit was nonzero
  if [ $status -ne 0 ]
    set nonzero $__fairyfloss_nonzero_exit_glyph
  end

  # if superuser (uid == 0)
  if [ (id -u $USER) -eq 0 ]
    set superuser $__fairyfloss_superuser_glyph
  end

  # Jobs display
  if [ (jobs -l | wc -l) -gt 0 ]
    set bg_jobs $__fairyfloss_bg_job_glyph
  end

  if [ "$nonzero" -o "$superuser" -o "$bg_jobs" ]
    __fairyfloss_start_segment fff 000
    if [ "$nonzero" ]
      set_color $__fairyfloss_magenta --bold
      echo -n $__fairyfloss_nonzero_exit_glyph
    end

    if [ "$superuser" ]
      set_color $__fairyfloss_gold --bold
      echo -n $__fairyfloss_superuser_glyph
    end

    if [ "$bg_jobs" ]
      set_color $__fairyfloss_seafoam --bold
      echo -n $__fairyfloss_bg_job_glyph
    end

    set_color normal
  end
end

function __fairyfloss_prompt_user -d 'Display actual user if different from $default_user'
  if [ "$theme_display_user" = 'yes' ]
    if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
      __fairyfloss_start_segment $__fairyfloss_seafoam $__fairyfloss_bg_purple
      echo -n -s (whoami) '@' (hostname | cut -d . -f 1) ' '
    end
  end
end

function __fairyfloss_prompt_hg -a current_dir -d 'Display the actual hg state'
  set -l dirty (command hg stat; or echo -n '*')

  set -l flags "$dirty"
  [ "$flags" ]; and set flags ""

  set -l flag_bg $__fairyfloss_seafoam
  set -l flag_fg $__fairyfloss_bg_purple
  if [ "$dirty" ]
    set flag_bg $__fairyfloss_magenta
    set flag_fg fff
  end

  __fairyfloss_path_segment $current_dir

  __fairyfloss_start_segment $flag_bg $flag_fg
  echo -n -s $__fairyfloss_hg_glyph ' '

  __fairyfloss_start_segment $flag_bg $flag_fg --bold
  echo -n -s (__fairyfloss_hg_branch) $flags ' '
  set_color normal

  set -l project_pwd  (__fairyfloss_project_pwd $current_dir)
  if [ "$project_pwd" ]
    if [ -w "$PWD" ]
      __fairyfloss_start_segment 333 999
    else
      __fairyfloss_start_segment $__fairyfloss_magenta $__fairyfloss_silver
    end

    echo -n -s $project_pwd ' '
  end
end

function __fairyfloss_prompt_git -a current_dir -d 'Display the actual git state'
  set -l dirty   (command git diff --no-ext-diff --quiet --exit-code; or echo -n '*')
  set -l staged  (command git diff --cached --no-ext-diff --quiet --exit-code; or echo -n '~')
  set -l stashed (command git rev-parse --verify --quiet refs/stash >/dev/null; and echo -n '$')
  set -l ahead   (__fairyfloss_git_ahead)

  set -l new ''
  set -l show_untracked (git config --bool bash.showUntrackedFiles)
  if [ "$theme_display_git_untracked" != 'no' -a "$show_untracked" != 'false' ]
    set new (command git ls-files --other --exclude-standard --directory --no-empty-directory)
    if [ "$new" ]
      if [ "$theme_avoid_ambiguous_glyphs" = 'yes' ]
        set new '...'
      else
        set new '…'
      end
    end
  end

  set -l flags "$dirty$staged$stashed$ahead$new"
  [ "$flags" ]; and set flags " $flags"

  set -l flag_bg $__fairyfloss_seafoam
  set -l flag_fg $__fairyfloss_bg_purple
  if [ "$dirty" -o "$staged" ]
    set flag_bg $__fairyfloss_magenta
    set flag_fg $__fairyfloss_silver
  else if [ "$stashed" ]
    set flag_bg $__fairyfloss_gold
    set flag_fg $__fairyfloss_pale_goldenrod
  end
  
  __fairyfloss_path_segment $current_dir
  
  __fairyfloss_start_segment $flag_bg $flag_fg --bold
  echo -n -s (__fairyfloss_git_branch) $flags ' '
  set_color normal

  set -l project_pwd (__fairyfloss_project_pwd $current_dir)
  if [ "$project_pwd" ]
    if [ -w "$PWD" ]
      __fairyfloss_start_segment 333 999
    else
      __fairyfloss_start_segment $__fairyfloss_magenta $__fairyfloss_silver
    end

    echo -n -s $project_pwd ' '
  end
end

function __fairyfloss_prompt_dir -d 'Display a shortened form of the current directory'
  __fairyfloss_path_segment "$PWD"
end

function __fairyfloss_prompt_vi -d 'Display vi mode'
  [ "$theme_display_vi" = 'yes' -a "$fish_bind_mode" != "$theme_display_vi_hide_mode" ]; or return
  switch $fish_bind_mode
  case default
    __fairyfloss_start_segment $__fairyfloss_bg_purple $__fairyfloss_silver --bold
    echo -n -s 'N '
  case insert
    __fairyfloss_start_segment $__fairyfloss_pale_seafoam $__fairyfloss_lavender_gray --bold
    echo -n -s 'I '
  case visual
    __fairyfloss_start_segment $__fairyfloss_pale_goldenrod $__fairyfloss_deep_gold --bold
    echo -n -s 'V '
  end
  set_color normal
end

function __fairyfloss_virtualenv_python_version -d 'Get current python version'
  set -l python_version (readlink (which python))
  switch "$python_version"
  case 'python2*'
    echo $__fairyfloss_superscript_glyph[2]
  case 'python3*'
    echo $__fairyfloss_superscript_glyph[3]
  case 'pypy*'
    echo $__fairyfloss_pypy_glyph
  end
end

function __fairyfloss_prompt_virtualfish -d "Display activated virtual environment (only for virtualfish, virtualenv's activate.fish changes prompt by itself)"
  [ "$theme_display_virtualenv" = 'no' -o -z "$VIRTUAL_ENV" ]; and return
  set -l version_glyph (__fairyfloss_virtualenv_python_version)
  if [ "$version_glyph" ]
    __fairyfloss_start_segment $__fairyfloss_seafoam $__fairyfloss_silver
    echo -n -s $__fairyfloss_virtualenv_glyph $version_glyph
  end
  __fairyfloss_start_segment $__fairyfloss_seafoam $__fairyfloss_silver --bold
  echo -n -s (basename "$VIRTUAL_ENV") ' '
  set_color normal
end

# ===========================
# Apply theme
# ===========================

function fish_prompt -d 'fairyfloss, a fish theme optimized for Liss'
  __fairyfloss_prompt_status
  __fairyfloss_prompt_vi
  __fairyfloss_prompt_user

  set -l git_root (__fairyfloss_git_project_dir)
  set -l hg_root  (__fairyfloss_hg_project_dir)
  if [ (echo "$hg_root" | wc -c) -gt (echo "$git_root" | wc -c) ]
    __fairyfloss_prompt_hg $hg_root
  else if [ "$git_root" ]
    __fairyfloss_prompt_git $git_root
  else
    __fairyfloss_prompt_dir
  end

  __fairyfloss_finish_segments
end
