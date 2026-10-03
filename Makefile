## Build a single Rmd file

SHELL = /bin/bash

.DEFAULT_GOAL := render

all:       pdf html
render:    pdf html
pdf:       p1 p2
html:      h1 h2 


OUTDIR := ~/MANUSCRIPTS/ROUT_analysis/Articles


##  Build single year prediction  ------------------------------------
TARGET := Create_model
RMD    := $(TARGET).R
PDF    := $(TARGET).pdf
HTML   := $(TARGET).html

p1: $(PDF) Makefile
$(PDF): $(RMD)
	@mkdir -p $(OUTDIR)
	@echo "Building: $@"
	@Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::pdf_document2', output_file='$@', output_dir='$(OUTDIR)')"


h1: $(HTML) Makefile
$(HTML): $(RMD)
	@mkdir -p $(OUTDIR)
	@echo "Building: $@"
	@echo "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::html_document2', output_file='$@', output_dir='$(OUTDIR)')"
	@Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::html_document2', output_file='$@', output_dir='$(OUTDIR)')"



##  Build multi years prediction  ------------------------------------
TARGET2 := Create_model_2
RMD2    := $(TARGET2).R
PDF2    := $(TARGET2).pdf
HTML2   := $(TARGET2).html

p2: $(PDF2) Makefile
$(PDF2): $(RMD2)
	@mkdir -p $(OUTDIR)
	@echo "Building: $@"
	@Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::pdf_document2', output_file='$@', output_dir='$(OUTDIR)')"


h2: $(HTML2) Makefile
$(HTML2): $(RMD2)
	@mkdir -p $(OUTDIR)
	@echo "Building: $@"
	@echo "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::html_document2', output_file='$@', output_dir='$(OUTDIR)')"
	@Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::html_document2', output_file='$@', output_dir='$(OUTDIR)')"




