TEMPLATE := notes/template.html
LUA      := notes/notebook.lua

NOTES_MD         := $(wildcard notes/*/*.md)
NOTES_HTML       := $(NOTES_MD:.md=.html)
NOTES_PDF        := $(NOTES_MD:.md=.pdf)
NOTES_ANNOT_PDF  := $(NOTES_MD:.md=-notes.pdf)

HW_MD   := $(wildcard homework/*.md)
HW_HTML := $(HW_MD:.md=.html)

.PHONY: all notes clean

all: index.html $(NOTES_HTML) $(NOTES_PDF) $(HW_HTML)

index.html: index.md
	pandoc $< -s -V mainfont=sans-serif -V linestretch=1.4 --katex -o $@

# $* = sql/sql, so notes/$*-setup.html = notes/sql/sql-setup.html
notes/%.html: notes/%.md $(TEMPLATE) $(LUA)
	pandoc $< -o $@ --template=$(TEMPLATE) \
		$(if $(wildcard notes/$*-setup.html),--include-before-body=notes/$*-setup.html) \
		--lua-filter=$(LUA) --katex --toc

notes/%.pdf: notes/%.md $(LUA)
	pandoc $< -o $@ --lua-filter=$(LUA) -t beamer

notes/%-notes.pdf: notes/%.md $(LUA)
	pandoc $< -o $@ --lua-filter=$(LUA) -t beamer -V classoption=notes

notes: $(NOTES_ANNOT_PDF)

homework/%.html: homework/%.md
	pandoc $< -s --katex -o $@

clean:
	rm -f index.html $(NOTES_HTML) $(NOTES_PDF) $(NOTES_ANNOT_PDF) $(HW_HTML)
