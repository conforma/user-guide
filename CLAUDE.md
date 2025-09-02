# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the Conforma User Guide repository, which contains documentation for Conforma (a supply chain security tool) written in AsciiDoc and built with Antora. The published documentation is available at https://conforma.dev/docs/user-guide/.

## Common Commands

### Documentation Preview
```bash
make ec-docs-preview
```
Builds a preview of the documentation by cloning the main docs repository and building the site with local changes. Note: This requires the `../conforma.github.io/antora` directory structure and dependencies.

### Screenshot Management
```bash
bin/screenshot-helper.sh    # Helper script for taking screenshots
bin/screenshot-pruner.sh    # Script to clean up unused screenshots
```

## Repository Structure

- `antora.yml` - Antora configuration file defining the documentation component
- `modules/ROOT/` - Main documentation module containing:
  - `pages/` - AsciiDoc documentation files
  - `images/` - Screenshot and image assets
  - `partials/` - Reusable AsciiDoc content snippets
  - `nav.adoc` - Navigation structure definition
- `bin/` - Utility scripts for documentation maintenance
- `Makefile` - Build automation for documentation preview

## Content Organization

The documentation is structured as follows:
- Getting Started guides (configuration, setup)
- How-to guides (Cosign usage, CLI usage, custom configurations)
- Reference material (SLSA integration, glossary)
- Troubleshooting guides (reproducing Konflux reports)

## Key Files

- `modules/ROOT/nav.adoc` - Defines the documentation navigation structure
- `modules/ROOT/partials/contents.adoc` - Contains the main content navigation menu
- Individual `.adoc` files in `pages/` contain the actual documentation content

## Development Notes

This is a documentation-only repository using Antora static site generator. Changes to `.adoc` files will be reflected in the published documentation after the preview build process.