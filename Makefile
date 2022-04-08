ln:
	find .probably-useful -type f | xargs -n1 ln -s

v2022-url:
	find .probably-useful -type f | xargs -I% echo https://raw.githubusercontent.com/tox2ik/local-bin/v2022/% | tee .probably-useful/.urls
	git add .probably-useful/.urls Makefile
	git commit -m 'update urls'

v2022: v2022-url
	git tag v2022  -f ; git push --tags  -f  github ; git push  github

v2022-install:
	@echo 'curl https://raw.githubusercontent.com/tox2ik/local-bin/v2022/.probably-useful/.urls | xargs -n1 curl -sO'
