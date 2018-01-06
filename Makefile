
LUA     := lua
VERSION := $(shell cd src && $(LUA) -e "m = require [[LIVR/Validator]]; print(m._VERSION)")
TARBALL := lua-livr-$(VERSION).tar.gz
REV     := 1

LUAVER  := 5.3
PREFIX  := /usr/local
DPREFIX := $(DESTDIR)$(PREFIX)
LIBDIR  := $(DPREFIX)/share/lua/$(LUAVER)
INSTALL := install

all:
	@echo "Nothing to build here, you can just make install"

install:
	$(INSTALL) -m 644 -D src/LIVR/Validator.lua         $(LIBDIR)/LIVR/Validator.lua
	$(INSTALL) -m 644 -D src/LIVR/Rules/Common.lua      $(LIBDIR)/LIVR/Rules/Common.lua
	$(INSTALL) -m 644 -D src/LIVR/Rules/Meta.lua        $(LIBDIR)/LIVR/Rules/Meta.lua
	$(INSTALL) -m 644 -D src/LIVR/Rules/Modifiers.lua   $(LIBDIR)/LIVR/Rules/Modifiers.lua
	$(INSTALL) -m 644 -D src/LIVR/Rules/Numeric.lua     $(LIBDIR)/LIVR/Rules/Numeric.lua
	$(INSTALL) -m 644 -D src/LIVR/Rules/Special.lua     $(LIBDIR)/LIVR/Rules/Special.lua
	$(INSTALL) -m 644 -D src/LIVR/Rules/String.lua      $(LIBDIR)/LIVR/Rules/String.lua

uninstall:
	rm -f $(LIBDIR)/LIVR/Validator.lua
	rm -f $(LIBDIR)/LIVR/Rules/*.lua

manifest_pl := \
use strict; \
use warnings; \
my @files = qw{MANIFEST}; \
while (<>) { \
    chomp; \
    next if m{^\.}; \
    next if m{^debian/}; \
    next if m{^rockspec/}; \
    push @files, $$_; \
} \
print join qq{\n}, sort @files;

rockspec_pl := \
use strict; \
use warnings; \
use Digest::MD5; \
open my $$FH, q{<}, q{$(TARBALL)} \
    or die qq{Cannot open $(TARBALL) ($$!)}; \
binmode $$FH; \
my %config = ( \
    version => q{$(VERSION)}, \
    rev     => q{$(REV)}, \
    md5     => Digest::MD5->new->addfile($$FH)->hexdigest(), \
); \
close $$FH; \
while (<>) { \
    s{@(\w+)@}{$$config{$$1}}g; \
    print; \
}

version:
	@echo $(VERSION)

CHANGES: dist.info
	perl -i.bak -pe "s{^$(VERSION).*}{q{$(VERSION)  }.localtime()}e" CHANGES

dist.info:
	perl -i.bak -pe "s{^version.*}{version = \"$(VERSION)\"}" dist.info

tag:
	git tag -a -m 'tag release $(VERSION)' $(VERSION)

MANIFEST:
	git ls-files | perl -e '$(manifest_pl)' > MANIFEST

$(TARBALL): MANIFEST
	[ -d lua-LIVR-$(VERSION) ] || ln -s . lua-LIVR-$(VERSION)
	perl -ne 'print qq{lua-LIVR-$(VERSION)/$$_};' MANIFEST | \
	    tar -zc -T - -f $(TARBALL)
	rm lua-LIVR-$(VERSION)

dist: $(TARBALL)

rockspec: $(TARBALL)
	perl -e '$(rockspec_pl)' rockspec.in    > rockspec/lua-livr-$(VERSION)-$(REV).rockspec

rock:
	luarocks pack rockspec/lua-livr-$(VERSION)-$(REV).rockspec

deb:
	echo "lua-livr ($(shell git describe --dirty)) unstable; urgency=medium" >  debian/changelog
	echo ""                         >> debian/changelog
	echo "  * UNRELEASED"           >> debian/changelog
	echo ""                         >> debian/changelog
	echo " -- $(shell git config --get user.name) <$(shell git config --get user.email)>  $(shell date -R)" >> debian/changelog
	fakeroot debian/rules clean binary

check: test

test:
	cd src && prove --exec=$(LUA) ../test/*.t

luacheck:
	luacheck --std=max --codes src --ignore 211/_ENV
	luacheck --std=min --config .test.luacheckrc test/*.t

coverage:
	rm -f src/luacov.stats.out src/luacov.report.out
	-cd src && prove --exec="$(LUA) -lluacov" ../test/*.t
	cd src && luacov

coveralls:
	rm -f src/luacov.stats.out src/luacov.report.out
	-cd src && prove --exec="$(LUA) -lluacov" ../test/*.t
	cd src && luacov-coveralls -e /HERE/ -e test/ -e %.t$

README.html: README.md
	Markdown.pl README.md > README.html

gh-pages:
	mkdocs gh-deploy --clean

clean:
	rm -f MANIFEST *.bak src/luacov.*.out *.rockspec README.html

realclean: clean

.PHONY: test rockspec deb debclean CHANGES dist.info

