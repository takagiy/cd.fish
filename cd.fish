function com_github_takagiy_cd_cd_impl
  set -l path_ (realpath $argv) &&
  if set -l i_ (contains -i $path_ $com_github_takagiy_cd_fish_history)
    set -e com_github_takagiy_cd_fish_history[$i_]
  end &&
  if not string match --all $path_ $HOME > /dev/null
    set -Ua com_github_takagiy_cd_fish_history $path_
  end &&
  builtin cd $argv
end

function cd --description "Change directory"
  for arg in $argv
    if [ $arg = "--clear-history" ]
      set -U com_github_takagiy_cd_fish_history (seq 0)
      return
    end
  end
  if count $argv > /dev/null
    com_github_takagiy_cd_cd_impl $argv
  else
    :
    set -l history_ $com_github_takagiy_cd_fish_history &&
    set -l children_ (find -maxdepth 1 -type d | sort) &&
    set -l dest_ (string join \n $children_ $history_ $HOME .. | fzf --tac --height 50%) &&
    com_github_takagiy_cd_cd_impl $dest_
  end
end
