# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the Conforma User Guide repository, which contains documentation for Conforma (a supply chain security tool) written in AsciiDoc and built with Antora. The published documentation is available at https://conforma.dev/docs/user-guide/.

## Common Commands

### Documentation Validation
```bash
make validate-docs
```
Lightweight validation that works without external repositories or network access. Checks:
- AsciiDoc syntax errors (requires `asciidoctor`; skips gracefully if not installed)
- Broken `xref:` references to non-existent pages within this component
- Broken `include::` references to non-existent partials
- Navigation references to non-existent pages

Run this after editing any `.adoc` file to catch errors before pushing.

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

## AsciiDoc Content Conventions

- **Replaceable values:** In shell or YAML source blocks, set `subs="+quotes"` and write values the reader must replace as `__<name>__`. For example, `[,shell,subs="+quotes"]` with `oc get integrationtestscenario __<testname>__`, or `[,yaml,subs="+quotes"]` with `value: __<managed-namespace>/<ecp-name>__`. The underscores render placeholders in italics. Avoid bare `<name>` placeholders in new source blocks.
- **Page titles:** Use sentence case for new page titles, for example `= Catching policy violations early with integration tests`. For numbered procedures, keep headings consistent, as in `=== Step 1: Find your release policy configuration` and `=== Step 2: Create a non-blocking integration test`. Some older pages use title case.
- **Navigation entries:** Match the page title's sentence-case capitalization when adding an entry. For example, `xref:early-policy-violations.adoc[Catching policy violations early with integration tests]` matches that page's title. A shorter label may use fewer words.
- **Admonitions:** Use the forms already present in this guide: `NOTE:`, `TIP:`, and `WARNING:`. For example, `NOTE: Conforma was previously known as "Enterprise Contract".` Do not introduce `IMPORTANT:` or `CAUTION:`.
- **Cross-references:** Use Antora `xref:page.adoc[label]` within this component, for example `xref:cli.adoc[command line use]`. For another component, include its component and module: `xref:policy:ROOT:release_policy.adoc[policies]`.
- **Code block language:** Put the Antora shorthand `[,language]` immediately before the `----` block delimiter, for example `[,yaml]` or `[,shell]`. Add `subs="+quotes"` when the block contains replaceable values.

## Development Notes

This is a documentation-only repository using Antora static site generator. Changes to `.adoc` files will be reflected in the published documentation after the preview build process.
