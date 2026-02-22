MDS = $(filter-out README.md, $(wildcard *.md))
HTMLS = $(MDS:.md=.html)

all: $(HTMLS)

%.html: %.md template.html codapi.lua
	pandoc $< -o $@ --template=template.html --lua-filter=codapi.lua --mathjax

clean:
	rm -f $(HTMLS)

.PHONY: all clean
