
# generic slide stuff

MATHJAX = https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js
# change this to the location of your local MathJax.js library
LOCAL_MATHJAX = /usr/share/javascript/mathjax/MathJax.js

# may want to add "--self-contained" to the following
PANDOC_OPTS = --standalone # --self-contained
MATHJAX_OPTS = --mathjax=$(MATHJAX)?config=TeX-AMS-MML_HTMLorMML 
LOCAL_MATHJAX_OPTS = --mathjax=$(LOCAL_MATHJAX)?config=TeX-AMS-MML_HTMLorMML
# optionally add in a latex file with macros
LATEX_MACROS = macros.tex
ifeq ($(wildcard $(LATEX_MACROS)),)
	# macros file isn't there
else
	PANDOC_OPTS += -H .pandoc.$(LATEX_MACROS)
endif

setup : .pandoc.$(LATEX_MACROS) 

.pandoc.$(LATEX_MACROS) : $(LATEX_MACROS)
	(echo '<div style="display: none">'; echo '\['; cat $(LATEX_MACROS); echo '\]'; echo '</div>') > $@

%.html : %.Rmd
	Rscript -e 'knitr::knit_patterns[["set"]]($(KNITR_PATTERNS)); templater::render_template("$<", output="$@", change.rootdir=TRUE, clean=FALSE)'

%.html : %.md .pandoc.$(LATEX_MACROS)
	pandoc -o $@ $(PANDOC_OPTS) $(MATHJAX_OPTS) $<

%.local.html : %.md .pandoc.$(LATEX_MACROS)
	pandoc -o $@ $(PANDOC_OPTS) $(LOCAL_MATHJAX_OPTS) $<

%.md : %.Rmd
	Rscript -e 'knitr::knit_patterns[["set"]]($(KNITR_PATTERNS)); templater::render_template("$<", output="$@", change.rootdir=TRUE)'

%.pdf : %.md
	pandoc -o $@ -t latex $<


## VARIOUS SLIDE METHODS
REVEALJS_OPTS = -t revealjs -V theme=simple -V slideNumber=true -V transition=none -H resources/adjust-revealjs.style --slide-level 2
SLIDES_OPTS = $(REVEALJS_OPTS)

%.slides.html : %.md .pandoc.$(LATEX_MACROS)
	pandoc -o $@ $(SLIDES_OPTS) $(PANDOC_OPTS) $(MATHJAX_OPTS) $<

%.local.slides.html : %.md .pandoc.$(LATEX_MACROS)
	pandoc -o $@ $(SLIDES_OPTS) $(PANDOC_OPTS) $(LOCAL_MATHJAX_OPTS) $<

## 
# Graphics whatnot

# save inkscape svg files as .ink.svg and this'll do the right thing
%.svg : %.ink.svg
	inkscape $< --export-plain-svg=$@

%.pdf : %.ink.svg
	# inkscape $< --export-filename=$@
	./svg2pdf.sh $< $@

%.svg : %.pdf
	inkscape $< --export-plain-svg=$@

%.png : %.pdf
	convert -density 300 $< -flatten $@

%.png : %.svg
	convert -density 300 $< -flatten $@
