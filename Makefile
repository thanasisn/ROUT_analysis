## Build a single Rmd file

SHELL = /bin/bash

.DEFAULT_GOAL := render

all:       clean_all pdf
render:    pdf html
pdf:       p1 p2
html:      h1 h2 
clean_all: clean_cache clean_pdfs


OUTDIR := ~/MANUSCRIPTS/ROUT_analysis/Articles


###   test data  ####################################
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


TARGET := Create_model_2
RMD    := $(TARGET).R
PDF    := $(TARGET).pdf
HTML   := $(TARGET).html

p2: $(PDF) Makefile
$(PDF): $(RMD)
	@mkdir -p $(OUTDIR)
	@echo "Building: $@"
	@Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::pdf_document2', output_file='$@', output_dir='$(OUTDIR)')"


h2: $(HTML) Makefile
$(HTML): $(RMD)
	@mkdir -p $(OUTDIR)
	@echo "Building: $@"
	@echo "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::html_document2', output_file='$@', output_dir='$(OUTDIR)')"
	@Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::html_document2', output_file='$@', output_dir='$(OUTDIR)')"


# ###   1. raw data  ####################################
# TARGET := GHI_enh_01_raw_data
# RMD    := $(TARGET).R
# PDF    := $(TARGET).pdf
# RUNT   := ./runtime/$(TARGET).pdf
# 
# p1: $(PDF)
# $(PDF): $(RMD)
# 	@echo "Building: $@"
# 	Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::pdf_document2', output_file='$@')"
# 	@-rsync -a --prune-empty-dirs --exclude 'unnamed-chunk*' --include '*.pdf' --include '*.png' ./GHI_*/figure-latex/ ./images
# 	@-rsync -a "$@" ${LIBRARY}
# 	@#-touch article/article.qmd
# 	@-touch article/article.Rmd

###   2. ID CE  ####################################
TARGET := GHI_enh_02_ID_CE
RMD    := $(TARGET).R
PDF    := $(TARGET).pdf
RUNT   := ./runtime/$(TARGET).pdf

p2: $(PDF)
$(PDF): $(RMD)
	@echo "Building: $@"
	Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::pdf_document2', output_file='$@')"
	@-rsync -a --prune-empty-dirs --exclude 'unnamed-chunk*' --include '*.pdf' --include '*.png' ./GHI_*/figure-latex/ ./images
	@-rsync -a "$@" ${LIBRARY}
	@#-touch article/article.qmd
	@-touch article/article.Rmd




###   3. aggregate data   #################################
TARGET := GHI_enh_03_process
RMD    := $(TARGET).R
PDF    := $(TARGET).pdf
RUNT   := ./runtime/$(TARGET).pdf

p3: $(PDF)
$(PDF): $(RMD)
	@echo "Building: $@"
	Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::pdf_document2', output_file='$@')"
	@-rsync -a --prune-empty-dirs --exclude 'unnamed-chunk*' --include '*.pdf' --include '*.png' ./GHI_*/figure-latex/ ./images
	@#setsid evince    $@ &
	@-rsync -a "$@" ${LIBRARY}
	@#-touch article/article.qmd
	@-touch article/article.Rmd


###   4. investigate  data   #################################
TARGET := GHI_enh_04_investigate
RMD    := $(TARGET).R
PDF    := $(TARGET).pdf
RUNT   := ./runtime/$(TARGET).pdf

p4: $(PDF)
$(PDF): $(RMD)
	@echo "Building: $@"
	Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::pdf_document2', output_file='$@')"
	@-rsync -a --prune-empty-dirs --exclude 'unnamed-chunk*' --include '*.pdf' --include '*.png' ./GHI_*/figure-latex/ ./images
	@#setsid evince    $@ &
	@-rsync -a "$@" ${LIBRARY}
	@#-touch article/article.qmd
	@-touch article/article.Rmd




###   5. distributions  data   #################################
TARGET := GHI_enh_05_distributions
RMD    := $(TARGET).R
PDF    := $(TARGET).pdf
RUNT   := ./runtime/$(TARGET).pdf

p5: $(PDF)
$(PDF): $(RMD)
	@echo "Building: $@"
	Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::pdf_document2', output_file='$@')"
	@-rsync -a --prune-empty-dirs --exclude 'unnamed-chunk*' --include '*.pdf' --include '*.png' ./GHI_*/figure-latex/ ./images
	@#setsid evince    $@ &
	@-rsync -a "$@" ${LIBRARY}
	@#-touch article/article.qmd
	@-touch article/article.Rmd



###   6. investigate  SZA   #################################
TARGET := GHI_enh_06_sza
RMD    := $(TARGET).R
PDF    := $(TARGET).pdf
RUNT   := ./runtime/$(TARGET).pdf

p6: $(PDF)
$(PDF): $(RMD)
	@echo "Building: $@"
	Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::pdf_document2', output_file='$@')"
	@-rsync -a --prune-empty-dirs --exclude 'unnamed-chunk*' --include '*.pdf' --include '*.png' ./GHI_*/figure-latex/ ./images
	@#setsid evince    $@ &
	@-rsync -a "$@" ${LIBRARY}
	@#-touch article/article.qmd
	@-touch article/article.Rmd




###   7. investigate  Aerosols   #################################
TARGET := GHI_enh_07_Aerosols
RMD    := $(TARGET).R
PDF    := $(TARGET).pdf
RUNT   := ./runtime/$(TARGET).pdf

p7: $(PDF)
$(PDF): $(RMD)
	@echo "Building: $@"
	Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::pdf_document2', output_file='$@')"
	@-rsync -a --prune-empty-dirs --exclude 'unnamed-chunk*' --include '*.pdf' --include '*.png' ./GHI_*/figure-latex/ ./images
	@#setsid evince    $@ &
	@-rsync -a "$@" ${LIBRARY}
	@#-touch article/article.qmd
	@-touch article/article.Rmd


###   7b. investigate  Aerosols   #################################
TARGET := GHI_enh_07_Aerosols_BR_CIM
RMD    := $(TARGET).R
PDF    := $(TARGET).pdf
RUNT   := ./runtime/$(TARGET).pdf

p7b: $(PDF)
$(PDF): $(RMD)
	@echo "Building: $@"
	Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::pdf_document2', output_file='$@')"
	@-rsync -a --prune-empty-dirs --exclude 'unnamed-chunk*' --include '*.pdf' --include '*.png' ./GHI_*/figure-latex/ ./images
	@#setsid evince    $@ &
	@-rsync -a "$@" ${LIBRARY}
	@#-touch article/article.qmd
	@-touch article/article.Rmd


###   8. investigate  Aerosols   #################################
TARGET := GHI_enh_08_validation
RMD    := $(TARGET).R
PDF    := $(TARGET).pdf
RUNT   := ./runtime/$(TARGET).pdf

p8: $(PDF)
$(PDF): $(RMD)
	@echo "Building: $@"
	Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::pdf_document2', output_file='$@')"
	@-rsync -a --prune-empty-dirs --exclude 'unnamed-chunk*' --include '*.pdf' --include '*.png' ./GHI_*/figure-latex/ ./images
	@#setsid evince    $@ &
	@-rsync -a "$@" ${LIBRARY}
	@#-touch article/article.qmd
	@-touch article/article.Rmd

###   9. investigate  Aerosols   #################################
TARGET := GHI_enh_09_water_ozone
RMD    := $(TARGET).R
PDF    := $(TARGET).pdf
RUNT   := ./runtime/$(TARGET).pdf

p9: $(PDF)
$(PDF): $(RMD)
	@echo "Building: $@"
	Rscript -e "rmarkdown::find_pandoc(dir = '/usr/lib/rstudio/resources/app/bin/quarto/bin/tools'); rmarkdown::render('$?', output_format='bookdown::pdf_document2', output_file='$@')"
	@-rsync -a --prune-empty-dirs --exclude 'unnamed-chunk*' --include '*.pdf' --include '*.png' ./GHI_*/figure-latex/ ./images
	@#setsid evince    $@ &
	@-rsync -a "$@" ${LIBRARY}
	@#-touch article/article.qmd
	@-touch article/article.Rmd





upload:
	-./upload.sh

clean_cache:
	# trash -f  ./Article_cache
	trash -f  ./GHI_enh_02_ID_CE_files
	trash -f  ./GHI_enh_03_process_files
	trash -f  ./GHI_enh_04_investigate_files
	trash -f  ./GHI_enh_05_distributions_files
	trash -f  ./runtime/*.*

clean_pdfs:
	trash -f    ./GHI_enh_01_raw_data.pdf
	trash -f    ./GHI_enh_02_ID_CE.pdf
	trash -f    ./DHI_GHI_3_trends_consistency.pdf

