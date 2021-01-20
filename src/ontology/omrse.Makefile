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