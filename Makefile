XML_INFO_FILE := info.xml

TEX_FILES := $(shell ls | grep .tex.template$ )
TEX_OUT := $(patsubst %.tex.template, %.tex, $(TEX_FILES))

HTML_FILES := $(shell ls | grep .html.template$ )
HTML_OUT := $(patsubst %.html.template, %.html, $(HTML_FILES))

default: $(TEX_OUT) $(HTML_OUT)

$(TEX_OUT): %.tex: %.tex.template %.tex.xform
	perl ./resume.pl $(XML_INFO_FILE) $*.tex.template $*.tex.xform >$@
	pdflatex $@

$(HTML_OUT): %.html: %.html.template %.html.xform
	perl ./resume.pl $(XML_INFO_FILE) $*.html.template $*.html.xform >$@

clean:
	rm -f $(TEX_OUT) $(HTML_OUT)