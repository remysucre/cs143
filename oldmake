index.html: README.md template.html codapi.lua
	pandoc $< -o $@ --template=template.html --lua-filter=codapi.lua --mathjax --toc

clean:
	rm -f index.html

.PHONY: clean
