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

