
#----------------------------------------------------------------------------
# Build a preview of the docs published at https://enterprisecontract.dev/docs/
# including the current changes in this local repo.
#
# Fixme maybe: Unfortunately the docs built using this method have broken
# stylesheet links when viewed with a local file:// url.
#
# Usage:
#   make ec-docs-preview
#
# See also the Makefile in the enterprise-contract.github.io repo which has
# similar scripts for doing local docs preview builds.
#
HACBS_DOCS_DIR=../conforma.github.io/antora
HACBS_DOCS_REPO=git@github.com:conforma/conforma.github.io.git
$(HACBS_DOCS_DIR):
	mkdir $(HACBS_DOCS_DIR) && cd $(HACBS_DOCS_DIR) && git clone $(HACBS_DOCS_REPO) .

CURRENT_BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
ec-docs-preview: $(HACBS_DOCS_DIR) ## Build a preview of the documentation
	cd $(HACBS_DOCS_DIR) && \
	  yq e -i '.content.sources[] |= select(.url == "*user-guide*").url |= "../../user-guide"' antora-playbook.yml && \
	  yq e -i '.content.sources[] |= select(.url == "*user-guide*").branches |= "$(CURRENT_BRANCH)"' antora-playbook.yml && \
	  npm ci && npm run build
