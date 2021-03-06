# ----------------------------------------
# Makefile for omrse
# Generated using ontology-development-kit
# ODK Version: v1.2.27
# ----------------------------------------
# IMPORTANT: DO NOT EDIT THIS FILE. To override default make goals, use omrse.Makefile instead

### Workflow
#
# Tasks to edit and release OMRSE.
#
# #### Edit
#
# 1. [Prepare release](prepare_release)
# 2. [Refresh imports](all_imports)
# 3. [Update repo to latest ODK](update_repo)


# ----------------------------------------
# Standard Constants
# ----------------------------------------
# these can be overwritten on the command line

URIBASE=                    http://purl.obolibrary.org/obo
ONT=                        omrse
ONTBASE=                    $(URIBASE)/$(ONT)
EDIT_FORMAT=                owl
SRC =                       $(ONT)-edit.$(EDIT_FORMAT)
CATALOG=                    catalog-v001.xml
ROBOT=                      robot --catalog $(CATALOG)
RELEASEDIR=                 ../..
REPORTDIR=                  reports
TMPDIR=                     tmp
SPARQLDIR =                 ../sparql
REPORT_FAIL_ON =            None
REPORT_LABEL =              -l true
REPORT_PROFILE_OPTS =       
OBO_FORMAT_OPTIONS =        
SPARQL_VALIDATION_CHECKS =   equivalent-classes owldef-self-reference
SPARQL_EXPORTS =             basic-report class-count-by-prefix edges xrefs obsoletes synonyms
ODK_VERSION_MAKEFILE =      v1.2.27

TODAY ?=                    $(shell date +%Y-%m-%d)
OBODATE ?=                  $(shell date +'%d:%m:%Y %H:%M')
VERSION=                    $(TODAY)
ANNOTATE_ONTOLOGY_VERSION = annotate -V $(ONTBASE)/releases/$(VERSION)/$@ --annotation owl:versionInfo $(VERSION)
OTHER_SRC =                 components/import_terms.owl 
ONTOLOGYTERMS =             tmp/ontologyterms.txt

FORMATS = $(sort  owl obo json owl)
FORMATS_INCL_TSV = $(sort $(FORMAT) tsv)
RELEASE_ARTEFACTS = $(sort  base full base full)

# ----------------------------------------
# Top-level targets
# ----------------------------------------

.PHONY: .FORCE

.PHONY: all
all: odkversion all_imports all_main all_subsets sparql_test all_reports all_assets

.PHONY: test
test: odkversion sparql_test all_reports
	$(ROBOT) reason --input $(SRC) --reasoner ELK  --equivalent-classes-allowed all --exclude-tautologies structural --output test.owl && rm test.owl && echo "Success"

.PHONY: odkversion
odkversion:
	echo "ODK Makefile version: $(ODK_VERSION_MAKEFILE) (this is the version of the ODK with which this Makefile was generated, not the version of the ODK you are running)" &&\
	echo "ROBOT version (ODK): " && $(ROBOT) --version

$(TMPDIR) $(REPORTDIR) :
	mkdir -p $@

## -- main targets --
##
## By default this is the cross-product of {ont, ont-base} x FORMATS

MAIN_PRODUCTS = $(sort $(foreach r,$(RELEASE_ARTEFACTS), $(ONT)-$(r)) $(ONT))
MAIN_GZIPPED = 
MAIN_FILES = $(foreach n,$(MAIN_PRODUCTS), $(foreach f,$(FORMATS), $(n).$(f))) $(MAIN_GZIPPED)

.PHONY: all_main
all_main: $(MAIN_FILES)

## -- import targets --
##
## By default this is the cross-product of IMPORT_MODULES x FORMATS


IMPORTS =  ro ogms obi apollo_sv omiabis go oae pco bfo oostt omo pno d-acts

IMPORT_ROOTS = $(patsubst %, imports/%_import, $(IMPORTS))
IMPORT_OWL_FILES = $(foreach n,$(IMPORT_ROOTS), $(n).owl)
IMPORT_FILES = $(IMPORT_OWL_FILES)


.PHONY: all_imports
all_imports: $(IMPORT_FILES)

## -- subset targets --
##
## By default this is the cross-product of SUBSETS x FORMATS
## Note we also include TSV as a format


SUBSETS = 

SUBSET_ROOTS = $(patsubst %, subsets/%, $(SUBSETS))
SUBSET_FILES = $(foreach n,$(SUBSET_ROOTS), $(foreach f,$(FORMATS_INCL_TSV), $(n).$(f)))

.PHONY: all_subsets
all_subsets: $(SUBSET_FILES)

OBO_REPORT =  $(SRC)-obo-report $(ONT).owl-obo-report
REPORTS = $(OBO_REPORT)
REPORT_FILES = $(patsubst %, $(REPORTDIR)/%.tsv, $(REPORTS))

.PHONY: all_reports
all_reports: all_reports_onestep $(REPORT_FILES)

## -- all files/assets --

ASSETS = \
  $(IMPORT_FILES) \
  $(MAIN_FILES) \
  $(REPORT_FILES) \
  $(SUBSET_FILES)

RELEASE_ASSETS = \
  $(MAIN_FILES) \
  $(REPORT_FILES) \
  $(SUBSET_FILES)

.PHONY: all_assets
all_assets: $(ASSETS)


.PHONY: show_assets
show_assets:
	echo $(ASSETS)
	du -sh $(ASSETS)


# ----------------------------------------
# Release Management
# ----------------------------------------

CLEANFILES=$(MAIN_FILES) $(SRCMERGED)
# This should be executed by the release manager whenever time comes to make a release.
# It will ensure that all assets/files are fresh, and will copy to release folder

.PHONY: prepare_release
prepare_release: $(ASSETS) $(PATTERN_RELEASE_FILES)
	rsync -R $(RELEASE_ASSETS) $(RELEASEDIR) &&\
  rm -f $(CLEANFILES) &&\
  echo "Release files are now in $(RELEASEDIR) - now you should commit, push and make a release on your git hosting site such as GitHub or GitLab"

.PHONY: prepare_initial_release
prepare_initial_release: prepare_release
	cd $(RELEASEDIR) && git add $(RELEASE_ASSETS)

# ----------------------------------------
# Import modules
# ----------------------------------------
# Most ontologies are modularly constructed using portions of other ontologies
# These live in the imports/ folder

# ------------------------
# Imports: Seeding system 
# ------------------------

# seed.txt contains all referenced entities
IMPORTSEED=tmp/seed.txt
SRCMERGED=tmp/merged-$(SRC)
PRESEED=tmp/pre_seed.txt

$(SRCMERGED): $(SRC)
	$(ROBOT) remove --input $< --select imports --trim false \
		merge  $(patsubst %, -i %, $(OTHER_SRC)) -o $@

$(PRESEED): $(SRCMERGED)
	$(ROBOT) query -f csv -i $< --query ../sparql/terms.sparql $@.tmp &&\
	cat $@.tmp | sort | uniq >  $@


$(IMPORTSEED): $(PRESEED)
	if [ $(IMP) = true ]; then cat $(PRESEED) | sort | uniq > $@; fi


ANNOTATION_PROPERTIES=rdfs:label IAO:0000115 IAO:0000116 IAO:0000111 

# -- Generate Import Modules --
#
# This pattern uses ROBOT to generate an import module
# Generate terms.txt for each import.  (Assume OBO-style Possibly hacky step?)
# Should be able to drop this if robot can just take a big messy list of terms as input.
imports/%_terms_combined.txt: $(IMPORTSEED) imports/%_terms.txt
	if [ $(IMP) = true ]; then cat $^ | grep -v ^# | sort | uniq >  $@; fi


imports/%_import.owl: mirror/%.owl imports/%_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) merge -i $< \
		query --update ../sparql/preprocess-module.ru \
		remove --base-iri $(URIBASE)"/$(shell echo $* | tr a-z A-Z)_" --axioms external --preserve-structure false --trim false \
		remove $(patsubst %, --term %, $(ANNOTATION_PROPERTIES)) -T imports/$*_terms_combined.txt --select complement \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

.PRECIOUS: imports/%_import.owl

## Module for ontology: ro

imports/ro_import.owl: mirror/ro.owl imports/ro_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query  -i $< --update ../sparql/preprocess-module.ru \
		extract -T imports/ro_terms_combined.txt --force true --individuals exclude --method BOT \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

## Module for ontology: apollo_sv

imports/apollo_sv_import.owl: mirror/apollo_sv.owl imports/apollo_sv_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) merge -i $< \
		query --update ../sparql/preprocess-module.ru \
		remove --base-iri $(URIBASE)/APOLLO_SV --axioms external --preserve-structure false --trim false \
		remove $(patsubst %, --term %, $(ANNOTATION_PROPERTIES)) -T imports/apollo_sv_terms_combined.txt --select complement \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

## Module for ontology: omiabis

imports/omiabis_import.owl: mirror/omiabis.owl
	echo "ERROR: You have configured your default module type to be custom; this behavior needs to be overwritten in omrse.Makefile!" && false
## Module for ontology: bfo

imports/bfo_import.owl: mirror/bfo.owl imports/bfo_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) query  -i $< --update ../sparql/preprocess-module.ru \
		extract -T imports/bfo_terms_combined.txt --force true --individuals exclude --method BOT \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

## Module for ontology: omo

imports/omo_import.owl: mirror/omo.owl imports/omo_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) merge -i $< \
		query --update ../sparql/preprocess-module.ru --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

## Module for ontology: pno

imports/pno_import.owl: mirror/pno.owl imports/pno_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) merge -i $< \
		query --update ../sparql/preprocess-module.ru --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi

## Module for ontology: d-acts

imports/d-acts_import.owl: mirror/d-acts.owl imports/d-acts_terms_combined.txt
	if [ $(IMP) = true ]; then $(ROBOT) merge -i $< \
		query --update ../sparql/preprocess-module.ru --update ../sparql/inject-subset-declaration.ru --update ../sparql/postprocess-module.ru \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@; fi



# ----------------------------------------
# Components
# ----------------------------------------
# Some ontologies contain external and internal components. A component is included in the ontology in its entirety.

components/%: .FORCE
	touch $@
.PRECIOUS: components/%







# ----------------------------------------
# Mirroring upstream ontologies
# ----------------------------------------
#

IMP=true # Global parameter to bypass import generation
MIR=true # Global parameter to bypass mirror generation


## ONTOLOGY: ro
## Copy of ro is re-downloaded whenever source changes
mirror/ro.trigger: $(SRC)

mirror/ro.owl: mirror/ro.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/ro.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/%.owl


## ONTOLOGY: ogms
## Copy of ogms is re-downloaded whenever source changes
mirror/ogms.trigger: $(SRC)

mirror/ogms.owl: mirror/ogms.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/ogms.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/%.owl


## ONTOLOGY: obi
## Copy of obi is re-downloaded whenever source changes
mirror/obi.trigger: $(SRC)

mirror/obi.owl: mirror/obi.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/obi.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/%.owl


## ONTOLOGY: apollo_sv
## Copy of apollo_sv is re-downloaded whenever source changes
mirror/apollo_sv.trigger: $(SRC)

mirror/apollo_sv.owl: mirror/apollo_sv.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/apollo_sv.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/%.owl


## ONTOLOGY: omiabis
## Copy of omiabis is re-downloaded whenever source changes
mirror/omiabis.trigger: $(SRC)

mirror/omiabis.owl: mirror/omiabis.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/omiabis.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/%.owl


## ONTOLOGY: go
## Copy of go is re-downloaded whenever source changes
mirror/go.trigger: $(SRC)

mirror/go.owl: mirror/go.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/go.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/%.owl


## ONTOLOGY: oae
## Copy of oae is re-downloaded whenever source changes
mirror/oae.trigger: $(SRC)

mirror/oae.owl: mirror/oae.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/oae.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/%.owl


## ONTOLOGY: pco
## Copy of pco is re-downloaded whenever source changes
mirror/pco.trigger: $(SRC)

mirror/pco.owl: mirror/pco.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/pco.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/%.owl


## ONTOLOGY: bfo
## Copy of bfo is re-downloaded whenever source changes
mirror/bfo.trigger: $(SRC)

mirror/bfo.owl: mirror/bfo.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/bfo.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/%.owl


## ONTOLOGY: oostt
## Copy of oostt is re-downloaded whenever source changes
mirror/oostt.trigger: $(SRC)

mirror/oostt.owl: mirror/oostt.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/oostt.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/%.owl


## ONTOLOGY: omo
## Copy of omo is re-downloaded whenever source changes
mirror/omo.trigger: $(SRC)

mirror/omo.owl: mirror/omo.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I $(URIBASE)/omo.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/%.owl


## ONTOLOGY: pno
## Copy of pno is re-downloaded whenever source changes
mirror/pno.trigger: $(SRC)

mirror/pno.owl: mirror/pno.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I http://purl.obolibrary.org/obo/iao/pno.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/%.owl


## ONTOLOGY: d-acts
## Copy of d-acts is re-downloaded whenever source changes
mirror/d-acts.trigger: $(SRC)

mirror/d-acts.owl: mirror/d-acts.trigger
	if [ $(MIR) = true ] && [ $(IMP) = true ]; then $(ROBOT) convert -I http://purl.obolibrary.org/obo/iao/d-acts/release/2020-10-14/d-acts.owl -o $@.tmp.owl && mv $@.tmp.owl $@; fi
.PRECIOUS: mirror/%.owl



# ----------------------------------------
# Subsets
# ----------------------------------------
subsets/%.tsv: subsets/%.owl
	$(ROBOT) query -f tsv -i $< -s ../sparql/labels.sparql $@
subsets/%.owl: $(ONT).owl
	owltools --use-catalog $< --extract-ontology-subset --fill-gaps --subset $* -o $@.tmp.owl && mv $@.tmp.owl $@


# ----------------------------------------
# Release
# ----------------------------------------
# copy from staging area (this directory) to top-level
.PHONY: release
release: $(ONT).owl $(ONT).obo
	cp $^ $(RELEASEDIR) && cp imports/* $(RELEASEDIR)/imports

# ----------------------------------------
# Sparql queries: Q/C
# ----------------------------------------

# these live in the ../sparql directory, and have suffix -violation.sparql
# adding the name here will make the violation check live.
# NOTE: these will soon be phased out and replaced by robot-report

#  run all violation checks
SPARQL_VALIDATION_QUERIES = $(foreach V,$(SPARQL_VALIDATION_CHECKS),$(SPARQLDIR)/$(V)-violation.sparql)
sparql_test: $(SRC) catalog-v001.xml | $(REPORTDIR)
ifneq ($(SPARQL_VALIDATION_QUERIES),)
	$(ROBOT) verify  --catalog catalog-v001.xml -i $< --queries $(SPARQL_VALIDATION_QUERIES) -O $(REPORTDIR)
endif

# ----------------------------------------
# ROBOT report
# ----------------------------------------
$(REPORTDIR)/%-obo-report.tsv: % | $(REPORTDIR)
	$(ROBOT) report -i $< $(REPORT_LABEL) $(REPORT_PROFILE_OPTS) --fail-on $(REPORT_FAIL_ON) --print 5 -o $@

# ----------------------------------------
# Sparql queries: Exports
# ----------------------------------------

SPARQL_EXPORTS_ARGS = $(foreach V,$(SPARQL_EXPORTS),-s $(SPARQLDIR)/$(V).sparql $(REPORTDIR)/$(V).tsv)
# This combines all into one single command

.PHONY: all_reports_onestep
all_reports_onestep: $(SRC)
ifneq ($(SPARQL_EXPORTS_ARGS),)
	$(ROBOT) query -f tsv -i $< $(SPARQL_EXPORTS_ARGS)
endif

# ----------------------------------------
# Release artefacts: export formats
# ----------------------------------------


$(ONT)-base.obo: $(ONT)-base.owl
	$(ROBOT) convert --input $< --check false -f obo $(OBO_FORMAT_OPTIONS) -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@ && rm $@.tmp.obo
$(ONT)-base.json: $(ONT)-base.owl
	$(ROBOT) annotate --input $< --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
		convert --check false -f json -o $@.tmp.json &&\
	jq -S 'walk(if type == "array" then sort else . end)' $@.tmp.json > $@ && rm $@.tmp.json
$(ONT)-full.obo: $(ONT)-full.owl
	$(ROBOT) convert --input $< --check false -f obo $(OBO_FORMAT_OPTIONS) -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@ && rm $@.tmp.obo
$(ONT)-full.json: $(ONT)-full.owl
	$(ROBOT) annotate --input $< --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
		convert --check false -f json -o $@.tmp.json &&\
	jq -S 'walk(if type == "array" then sort else . end)' $@.tmp.json > $@ && rm $@.tmp.json
# We always want a base - even if it is not explicitly configured..
# We always want a full release - even if it is not explicitly configured..
# ----------------------------------------
# Release artefacts: main release artefacts
# ----------------------------------------

$(ONT).owl: $(ONT)-full.owl
	$(ROBOT) annotate --input $< --ontology-iri $(URIBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
		convert -o $@.tmp.owl && mv $@.tmp.owl $@

$(ONT).obo: $(ONT).owl
	$(ROBOT) convert --input $< --check false -f obo $(OBO_FORMAT_OPTIONS) -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@ && rm $@.tmp.obo
$(ONT).json: $(ONT)-full.owl
	$(ROBOT) annotate --input $< --ontology-iri $(URIBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
		convert --check false -f json -o $@.tmp.json &&\
	jq -S 'walk(if type == "array" then sort else . end)' $@.tmp.json > $@ && rm $@.tmp.json
# -----------------------------------------------------
# Release artefacts: variants (base, full, simple, etc)
# -----------------------------------------------------

$(ONTOLOGYTERMS): $(SRC) $(OTHER_SRC)
	touch $(ONTOLOGYTERMS) && \
	$(ROBOT) query --use-graphs true -f csv -i $< --query ../sparql/omrse_terms.sparql $@










# base: OTHER sources of interest, such as definitions owl
$(ONT)-base.owl: $(SRC) $(OTHER_SRC)
	$(ROBOT) remove --input $< --select imports --trim false \
		merge $(patsubst %, -i %, $(OTHER_SRC)) \
		annotate --link-annotation http://purl.org/dc/elements/1.1/type http://purl.obolibrary.org/obo/IAO_8000001 \
		--ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
		--output $@.tmp.owl && mv $@.tmp.owl $@

# Full: The full artefacts with imports merged, reasoned
$(ONT)-full.owl: $(SRC) $(OTHER_SRC)
	$(ROBOT) merge --input $< \
		reason --reasoner ELK --equivalent-classes-allowed all --exclude-tautologies structural \
		relax \
		reduce -r ELK \
		annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@





.PHONY: validate_idranges
validate_idranges:
	amm ../scripts/validate_id_ranges.sc omrse-idranges.owl

.PHONY: update_repo
update_repo:
	sh ../scripts/update_repo.sh

include omrse.Makefile