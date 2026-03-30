index.html: README.md
	pandoc $< -s -V mainfont=sans-serif -V linestretch=1.4 -o $@

clean:
	rm -f index.html

.PHONY: clean
