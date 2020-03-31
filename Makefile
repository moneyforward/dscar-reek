NAMESPACE = moneyforward
ORB = $(NAMESPACE)/dscar-reek
VERSION = dev:alpha
SEGMENT = patch
ORB_YAML_PATH = dist/orb.yml

$(ORB_YAML_PATH): src/*.yml src/*/*.yml
	mkdir -p `dirname $(ORB_YAML_PATH)`
	yamllint ./src
	circleci config pack src/ | tee $(ORB_YAML_PATH) | circleci orb validate - || rm -f $(ORB_YAML_PATH)

.PHONY: publish
publish: dist/orb.yml
	circleci orb publish $(ORB_YAML_PATH) $(ORB)@$(VERSION)

.PHONY: publish-increment
publish-increment: dist/orb.yml
	circleci orb publish increment $(ORB_YAML_PATH) $(ORB) $(SEGMENT)

.PHONY: publish-promote
publish-promote: dist/orb.yml
	circleci orb publish promote $(ORB)@$(VERSION) $(SEGMENT)

.PHONY: info
info:
	circleci orb info $(ORB)

.PHONY: process
process: dist/orb.yml
	circleci orb process $(ORB_YAML_PATH)

.PHONY: create
create:
	circleci orb create $(ORB)

.INTERMEDIATE: .circleci/compiled-config.yml
.circleci/compiled-config.yml: publish
	circleci config process .circleci/config.yml > $@

.PHONY: integration-test-1
integration-test-1: .circleci/compiled-config.yml
	circleci local execute -c $< --job $@
