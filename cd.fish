function com_github_takagiy_cd_fish_cd_impl
  set -l path_ (realpath $argv) &&
  if set -l i_ (contains -i $path_ $com_github_takagiy_cd_fish_history)
    set -e com_github_takagiy_cd_fish_history[$i_]
  end &&
  if [ $path_ != $HOME ]
    set -Ua com_github_takagiy_cd_fish_history $path_
  end &&
  builtin cd $argv
end

function com_github_takagiy_cd_fish_clear_history
  set -U com_github_takagiy_cd_fish_history (seq 0)
end

function cd --description "Change directory"
  set -l argv_noflags_ (seq 0)
  set -l include_history_ 1
  set -l include_home_ 1
  set -l repeat_ 1
  for arg in $argv
    if [ $arg = "--clear-history" ]
      com_github_takagiy_cd_fish_clear_history
      return
    else if [ $arg = "--no-history" ]
      set include_history_ 0
    else if [ $arg = "--no-home" ]
      set include_home_ 0
    else if [ $arg = "--no-repeat" ]
      set repeat_ 0
    else
      set -a argv_noflags_ $arg
    end
  end
  if not set -q com_github_takagiy_cd_fish_history
    com_github_takagiy_cd_fish_clear_history
  end
  if count $argv_noflags_ > /dev/null
    com_github_takagiy_cd_fish_cd_impl $argv_noflags_
  else
    set -l selections_ (seq 0) &&
    set -a selections_ (find -maxdepth 1 -type d | sort | tail +2) &&
    if [ $include_history_ = 1 ]
      set -a selections_ $com_github_takagiy_cd_fish_history
    end &&
    if [ $include_home_ = 1 ]
      set -a selections_ $HOME
    end &&
    set -a selections_ . .. &&
    set -l dest_ (string join \n $selections_ | fzf --tac --height 50%) &&
    if [ $dest_ = "." ] || not string match ".*" $dest_
      com_github_takagiy_cd_fish_cd_impl $dest_
    else
      builtin cd $dest_
    end &&
    if string match '.*' $dest_ > /dev/null && [ $dest_ != "." ] && [ $repeat_ = 1 ]
      cd --no-home --no-history
    end
  end
end
