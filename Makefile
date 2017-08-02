#Crazy makefile authored by Lou Berger <lberger@labn.net>
#Modified by Christian Hopps <chopps@chopps.org>
#The author makes no claim/restriction on use.  It is provided "AS IS".
#This file is considered a hack and not production grade by the author

DRAFT_BASE  = draft-ietf-manet-dlep-pause-extension
DRAFT 	    = out/$(DRAFT_BASE)

WITHXML2RFC := $(shell which xml2rfc > /dev/null 2>&1 ; echo $$? )

ID_DIR	     = IDs
REVS	    := $(shell \
		 sed -e '/docName="/!d;s/.*docName="\([^"]*\)".*/\1/' $(DRAFT_BASE).xml | \
		 awk -F- '{printf "%02d %02d",$$NF-1,$$NF}')
PREV_REV    := $(word 1, $(REVS))
REV	    := $(word 2, $(REVS))
OLD          = $(ID_DIR)/$(DRAFT_BASE)-$(PREV_REV)
NEW          = $(ID_DIR)/$(DRAFT_BASE)-$(REV)

SHELL	     = bash

out/%.txt: %.xml
	@if [ ! -e out ] ; then mkdir out ; git add out ; fi
	@if [ $(WITHXML2RFC) == 0 ] ; then 	\
		rm -f $@.prev; cp -pf $@ $@.prev > /dev/null 2>&1 ; \
		xml2rfc $< -o $@		; \
		if [ -f $@.prev ] ; then diff $@.prev $@ || exit 0 ; fi ; \
	fi

out/%.html: %.xml
	@if [ ! -e out ] ; then mkdir out ; git add out ; fi
	@if [ $(WITHXML2RFC) == 0 ] ; then 	\
		rm -f $@.prev; cp -pf $@ $@.prev > /dev/null 2>&1 ; \
		xml2rfc --html $< -o $@		; \
	fi

all:	$(DRAFT).txt $(DRAFT).html

publish: idnits
	@if git status -s out == "?? out/" ; then \
		git add out ; \
		git commit -m "Added dynamic output directory" out ;\
		fi

#for testing
vars:
	which xml2rfc
	echo WITHXML2RFC=$(WITHXML2RFC)
	echo PYTHONPATH=$(PYTHONPATH)
	echo PLUGPATH=$(PLUGPATH)
	echo PREV_REV=$(PREV_REV)
	echo REV=$(REV)
	echo OLD=$(OLD)


$(DRAFT)-diff.txt: $(DRAFT).txt 
	@echo "Generating diff of $(OLD).txt and $(DRAFT).txt > $@..."
	if [ -f  $(OLD).txt ] ; then \
		sdiff --ignore-space-change --expand-tabs -w 168 $(OLD).txt $(DRAFT).txt | \
		cut -c84-170 | sed 's/. *//'  \
		| grep -v '^ <$$' | grep -v '^<$$' > $@ ;\
	 fi

idnits: $(DRAFT).txt
	@if [ ! -f idnits ] ; then \
		rm -f $@ 					;\
		wget http://tools.ietf.org/tools/idnits/idnits	;\
		chmod 755 idnits				;\
	fi
	@if [ ! -e out ] ; then mkdir out ; git add out ; fi
	./idnits $(DRAFT).txt > out/$@.out
	@cat out/$@.out
	@grep -q 'Summary: 0 error' out/$@.out

id: $(DRAFT).txt $(DRAFT).html
	@if [ ! -e $(ID_DIR) ] ; then \
		echo "Creating $(ID_DIR) directory" 	;\
		mkdir $(ID_DIR) 			;\
		git add $(ID_DIR)			;\
	fi
	@if [ -f "$(NEW).xml" ] ; then \
		echo "" 				;\
		echo "$(NEW).xml already exists, not overwriting!" ;\
		diff -sq $(DRAFT_BASE).xml  $(NEW).xml 	;\
		echo "" 				;\
	else \
		echo "Copying to $(NEW).{xml,txt,html}" ;\
		echo "" 				;\
		cp -p $(DRAFT_BASE).xml $(NEW).xml  		;\
		cp -p $(DRAFT).txt $(NEW).txt  		;\
		cp -p $(DRAFT).html $(NEW).html  	;\
		git add $(NEW).xml $(NEW).txt $(NEW).html ;\
		ls -lt $(DRAFT).* $(NEW).* 		;\
	fi

rmid:
	@echo "Removing:"
	@ls -l $(NEW).xml $(NEW).txt  $(NEW).html
	@echo -n "Hit <ctrl>-C to abort, or <CR> to continue: "
	@read t
	@rm -f $(NEW).xml $(NEW).txt $(NEW).html
	@git rm  $(NEW).xml $(NEW).txt $(NEW).html

