##################################################

VERSION=		0.7.0
PROJECTNAME=		lua-alt-getopt
BIRTHDATE=		2009-01-10

LUA_LMODULES=		alt_getopt.lua

##################################################
.PHONY: test
test:
	@echo 'running tests...'; \
	ln -f -s ${.CURDIR}/alt_getopt.lua ${.CURDIR}/tests; \
	export OBJDIR=${.OBJDIR}; \
	if cd ${.CURDIR}/tests && ./test.sh; \
	then echo '   succeeded'; \
	else echo '   failed'; false; \
	fi

.include <mkc.files.mk>
