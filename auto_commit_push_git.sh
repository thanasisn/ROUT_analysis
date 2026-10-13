#!/usr/bin/env bash
## created on 2013-05-07
## https://github.com/thanasisn <natsisphysicist@gmail.com>

#### Auto commit and push all git repos


set +e


## list folders containing a makefile
folders=(
  "$HOME/MANUSCRIPTS/ROUT_analysis"
)

for af in "${folders[@]}"; do
  info "$af"
  if [ -d "$af" ]; then
    info "Doing: $af"
  else
    info "$af don't exist SKIP!!"
    continue
  fi

  cd "$af" || continue
  (
    ## run make with default rule
    nice -n 19 ionice -c2 -n7 make -B -f ./*[Mm]akefile -C "$af"
  ) > >(tee .automake.log) 2> >(tee .automake.err >&2)
  echo "================================="
done

## use full paths
folders=(
  "$HOME/MANUSCRIPTS/ROUT_analysis"
)

## go through main folder
for i in "${folders[@]}"; do
	echo
	info " $i "
	echo
	[ ! -d "$i" ] && echo "Not a folder: $i" && continue
	## go in the sub folders
	cd "$i" || return
	## make sure git is writeable
  chmod +w .git
	pwd
	(
		## add files we care about
		find . -type f \( -iname '*.bas' \
			-o -iname '*.Rmd'      \
			-o -iname '*.bas'      \
			-o -iname '*.bib'      \
			-o -iname '*.c'        \
			-o -iname '*.conf'     \
			-o -iname '*.cpp'      \
			-o -iname '*.cs'       \
			-o -iname '*.css'      \
			-o -iname '*.dia'      \
			-o -iname '*.dot'      \
			-o -iname '*.ex'       \
			-o -iname '*.f90'      \
			-o -iname '*.frm'      \
			-o -iname '*.gnu'      \
			-o -iname '*.gp'       \
			-o -iname '*.h'        \
			-o -iname '*.jl'       \
			-o -iname '*.list'     \
			-o -iname '*.lua'      \
			-o -iname '*.makefile' \
			-o -iname '*.md'       \
			-o -iname '*.nix'      \
			-o -iname '*.par'      \
			-o -iname '*.pbs'      \
			-o -iname '*.py'       \
			-o -iname '*.qgs'      \
			-o -iname '*.qmd'      \
			-o -iname '*.r'        \
			-o -iname '*.rmd'      \
			-o -iname '*.png'      \
			-o -iname '*.png'      \
			-o -iname '*.sh'       \
			-o -iname '*.tex'      \
			-o -iname '*.txt'      \
			-o -iname '*.vim'      \
			-o -iname '*.yaml'     \
			-o -iname '*.yml'      \
			-o -iname 'flake.lock' \
			-o -iname 'makefile'   \) -print0 |
			xargs -t -0 git add -f
		## commit and push
		git commit -uno -a -m "Commit $(date +'%F %R')"
		git push -f
		git push -f --tag
		git maintenance run --auto
	) > >(tee .autogit.log) 2> >(tee .autogit.err >&2)
done

echo
echo "LOGFILE: $LOG_FILE"
echo "ERRFILE: $ERR_FILE"

exit 0
