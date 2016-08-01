function fish_greeting -d "what's up, fish?"
  set_color $fish_color_autosuggestion[1]
  set_color normal
  set -g fish_color_normal f8f8f0            # silver
  set -g fish_color_command ffb8d1           # pink
  set -g fish_color_quote fffea0             # goldenrod
  set -g fish_color_redirection f8f8f0       # silver
  set -g fish_color_end f8f8f0               # silver
  set -g fish_color_param c5a3ff             # lilac
  set -g fish_color_comment e6c000           # gold
  set -g fish_color_match c2ffdf             # seafoam
  set -g fish_color_search_match e6c000      # gold
  set -g fish_color_operator c5a3ff          # lilac
  set -g fish_color_escape ff857f            # peach
  set -g fish_color_autosuggestion 3b3a32    # shadow
  set -g fish_color_error f92672             # magenta
end
