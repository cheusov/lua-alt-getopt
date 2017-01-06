##################################################

VERSION=		0.8.0
PROJECTNAME=		lua-alt-getopt
BIRTHDATE=		2009-01-10

LUA_LMODULES=		alt_getopt.lua

MKC_REQD=		0.20.0

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
