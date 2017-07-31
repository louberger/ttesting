#Crazy makefile authored by Lou Berger <lberger@labn.net>
#Modified by Christian Hopps <chopps@chopps.org>
#The author makes no claim/restriction on use.  It is provided "AS IS".
#This file is considered a hack and not production grade by the author

DRAFT  = draft-ietf-manet-dlep-pause-extension

WITHXML2RFC := $(shell which xml2rfc > /dev/null 2>&1 ; echo $$? )

ID_DIR	     = IDs
REVS	    := $(shell \
		 sed -e '/docName="/!d;s/.*docName="\([^"]*\)".*/\1/' $(DRAFT).xml | \
		 awk -F- '{printf "%02d %02d",$$NF-1,$$NF}')
PREV_REV    := $(word 1, $(REVS))
REV	    := $(word 2, $(REVS))
OLD          = $(ID_DIR)/$(DRAFT)-$(PREV_REV)
NEW          = $(ID_DIR)/$(DRAFT)-$(REV)


%.txt: %.xml
	@if [ $(WITHXML2RFC) == 0 ] ; then 	\
		rm -f $@.prev; cp -pf $@ $@.prev ; \
		xml2rfc $< 			; \
		diff $@.prev $@ || exit 0 	; \
	fi

%.html: %.xml
	@if [ $(WITHXML2RFC) == 0 ] ; then 	\
		rm -f $@.prev; cp -pf $@ $@.prev ; \
		xml2rfc --html $< 		; \
	fi

all:	$(DRAFT).txt $(DRAFT).html

vars:
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
		-rm -f $@ 					;\
		wget http://tools.ietf.org/tools/idnits/idnits	;\
		chmod 755 idnits				;\
	fi
	idnits $(DRAFT).txt

id: $(DRAFT).txt $(DRAFT).html
	@if [ ! -e $(ID_DIR) ] ; then \
		echo "Creating $(ID_DIR) directory" 	;\
		mkdir $(ID_DIR) 			;\
		git add $(ID_DIR)			;\
	fi
	@if [ -f "$(NEW).xml" ] ; then \
		echo "" 				;\
		echo "$(NEW).xml already exists, not overwriting!" ;\
		diff -sq $(DRAFT).xml  $(NEW).xml 	;\
		echo "" 				;\
	else \
		echo "Copying to $(NEW).{xml,txt,html}" ;\
		echo "" 				;\
		cp -p $(DRAFT).xml $(NEW).xml  		;\
		cp -p $(DRAFT).txt $(NEW).txt  		;\
		cp -p $(DRAFT).html $(NEW).html  	;\
		git add $(NEW).xml $(NEW).txt  $(NEW).html ;\
		ls -lt $(DRAFT).* $(NEW).* 		;\
	fi

rmid:
	@echo "Removing:"
	@ls -l $(NEW).xml $(NEW).txt  $(NEW).html
	@echo -n "Hit <ctrl>-C to abort, or <CR> to continue: "
	@read t
	@rm -f $(NEW).xml $(NEW).txt $(NEW).html
	@git rm  $(NEW).xml $(NEW).txt $(NEW).html

