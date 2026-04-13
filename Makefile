TEMPLATE := notes/template.html
LUA      := notes/notebook.lua

NOTES_MD   := $(wildcard notes/*/*.md)
NOTES_HTML := $(NOTES_MD:.md=.html)
NOTES_PDF  := $(NOTES_MD:.md=.pdf)

HW_MD   := $(wildcard homeworks/*.md)
HW_HTML := $(HW_MD:.md=.html)

QUIZ_MD   := $(wildcard quizzzes/*.md)
QUIZ_HTML := $(QUIZ_MD:.md=.html)
QUIZ_PDF  := $(QUIZ_MD:.md=.pdf)

.PHONY: all clean

all: index.html $(NOTES_HTML) $(NOTES_PDF) $(HW_HTML) $(QUIZ_HTML) $(QUIZ_PDF)

index.html: index.md
	pandoc $< -s -V mainfont=sans-serif -V linestretch=1.4 --katex -o $@

# $* = sql/sql, so notes/$*-setup.html = notes/sql/sql-setup.html
notes/%.html: notes/%.md $(TEMPLATE) $(LUA)
	pandoc $< -o $@ --template=$(TEMPLATE) \
		$(if $(wildcard notes/$*-setup.html),--include-before-body=notes/$*-setup.html) \
		--lua-filter=$(LUA) --katex --toc

notes/%.pdf: notes/%.md $(LUA)
	pandoc $< -o $@ --lua-filter=$(LUA) -t beamer

homeworks/%.html: homeworks/%.md
	pandoc $< -s --katex -o $@

quizzzes/%.html: quizzzes/%.md
	pandoc $< -s --katex -o $@

quizzzes/%.pdf: quizzzes/%.md
	pandoc $< -s -o $@

clean:
	rm -f index.html $(NOTES_HTML) $(NOTES_PDF) $(HW_HTML) $(QUIZ_HTML) $(QUIZ_PDF)
