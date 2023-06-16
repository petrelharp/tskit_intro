SHELL := /bin/bash
# use bash for <( ) syntax

.PHONY : setup

tskit-intro.slides.html : setup

setup :
	$(MAKE) -C figs

include rules.mk
