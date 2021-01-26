## Customize Makefile settings for omrse
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile


####################################
#### Handling OBO format error #####
# OBO format does not handle at all inverse property expressions in class expressions


tmp/$(ONT).ofn: $(ONT)-full.owl
	$(ROBOT) convert -i $< -o $@
	sed -i -E '/^SubClassOf.*ObjectInverseOf/d' $@
	
tmp/%.ofn: %.owl
	$(ROBOT) convert -i $< -o $@
	sed -i -E '/^SubClassOf.*ObjectInverseOf/d' $@

$(ONT).obo: tmp/$(ONT).ofn
	$(ROBOT) convert --input $< --check false -f obo $(OBO_FORMAT_OPTIONS) -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@ && rm $@.tmp.obo

$(ONT)-full.obo: tmp/$(ONT).ofn
	$(ROBOT) convert --input $< --check false -f obo $(OBO_FORMAT_OPTIONS) -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@ && rm $@.tmp.obo

$(ONT)-base.obo: tmp/$(ONT)-base.ofn
	$(ROBOT) convert --input $< --check false -f obo $(OBO_FORMAT_OPTIONS) -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@ && rm $@.tmp.obo

$(ONT)-simple.obo: tmp/$(ONT)-simple.ofn
	$(ROBOT) convert --input $< --check false -f obo $(OBO_FORMAT_OPTIONS) -o $@.tmp.obo && grep -v ^owl-axioms $@.tmp.obo > $@ && rm $@.tmp.obo

b:
	jq --version

a: 
	$(ROBOT) annotate --input ../../$(ONT)-base.owl --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
		convert --check false -f json -o $@.tmp.json &&\
	jq -S 'walk(if type == "array" then sort else . end)' $@.tmp.json > $@ && rm $@.tmp.json

tmp/$(ONT)-build.owl:
	cp ../../$(ONT).owl $@

tmp/$(ONT)-release.owl:
	$(ROBOT) merge -I http://purl.obolibrary.org/obo/omrse.owl -o $@

reports/release-diff.txt: tmp/$(ONT)-release.owl tmp/$(ONT)-build.owl
	$(ROBOT) diff --left $< --right tmp/$(ONT)-build.owl -o $@

diff: reports/release-diff.txt
	
	
	
# ----------------------------------------
# Pipeline for removing a merged ontology
# and replacing by dynamic import
# ----------------------------------------

# 1. make seed of all terms currently used in the ontology, for example all HP terms. 
# For this you need to create the respective xyz_terms.sparql query.

# this is only used to create initial term list and then never again
%_terms_in_src: $(SRC) $(SPARQLDIR)/%_terms.sparql
	$(ROBOT) query -i $< --use-graphs true -q $(SPARQLDIR)/$*_terms.sparql tmp/$*_terms.txt

tmp/filtered-%-mirror.owl: mirror/%.owl tmp/%_terms.txt
	$(ROBOT) filter -i mirror/$*.owl -T tmp/$*_terms.txt --trim false -o $@

tmp/edit-without-%.owl: $(SRC) tmp/filtered-%-mirror.owl
	$(ROBOT) remove -i $< --select imports --trim false unmerge -i tmp/filtered-$*-mirror.owl -o $@

tmp/remaining-%.ofn: tmp/edit-without-%.owl tmp/%_terms.txt
	$(ROBOT) filter -i $< --term-file tmp/$*_terms.txt --trim false -o $@

#These are only the x-refs that are NOT in the ontology mirror
tmp/preserve-axioms-%.ttl: tmp/remaining-%.ofn
	$(ROBOT) query -i $< -c $(SPARQLDIR)/preserve_$*_axioms.sparql $@

tmp/preserve-axioms-%.owl: tmp/preserve-axioms-%.ttl
	$(ROBOT) convert -i $< -f owl -o $@

# 2. Dump all axioms from the ontology apart from the set of preserved axioms. 
# Preserved axioms are extracted using the preserve_xyz_axioms.sparql query (for example xrefs.)

dump_%: $(SRC) tmp/preserve-axioms-%.owl
	$(ROBOT) remove -i $< -T tmp/$*_terms.txt --axioms "annotation" --trim true  --preserve-structure false \
		remove -T tmp/$*_terms.txt --trim false --preserve-structure false \
		merge -i tmp/preserve-axioms-$*.owl --collapse-import-closure false -o $(SRC)
		
#tmp/edit-functional.owl: $(SRC)
#	$(ROBOT) convert -i $(SRC) -f ofn -o $@


#############
## TO DO ####
#############
	
EFO_MASTER=https://raw.githubusercontent.com/EBISPOT/efo/master/src/ontology/edit.owl

master-$(SRC):
	wget $(EFO_MASTER) -O $@

efo_edit_git_diff.txt:
	git diff $(SRC) > efo_edit_git_diff.txt

efo_edit_robot_diff.txt: master-$(SRC) $(SRC)
	$(ROBOT) diff --left $(SRC) --right master-$(SRC) -o $@

edit_diff: efo_edit_git_diff.txt efo_edit_robot_diff.txt

