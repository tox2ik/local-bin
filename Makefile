repo=https://raw.githubusercontent.com/tox2ik/local-bin
tag=v2022

ln:
	find .probably-useful -type f | xargs -n1 ln -s

windows:
	git config core.symlinks true

v2022-url:
	find    .probably-useful -type f | xargs -I% echo $(repo)/$(tag)/% | tee .probably-useful/.urls
	git add .probably-useful/.urls Makefile
	git commit -m 'update urls'

v2022: v2022-url
	git tag v2022  -f ; git push --tags  -f  github ; git push  github

v2022-install:
	@echo 'curl $(repo)/$(tag)/.probably-useful/.urls | xargs -n1 curl -sO'

lint:
	file * | grep Bourne-Again |awk -F: '{print $$1}' |sort| xargs -P 16 -n1 shellcheck-count  | sort -k 3,3n

