# Colab-link Extension For Quarto

Adds a Google Colab link to Quarto HTML pages that opt in with `colab: true`.
The link is generated from shared project metadata and inserted into Quarto's
rendered **Other Formats** block.

Install with:

```sh
quarto install extension au-mbg/quarto-teaching-tools/extensions/colab-link
```

Add project or profile metadata:

```yaml
filters:
  - colab-link

teaching:
  colab:
    repo: au-mbg/fysisk-biokemi
    branch: built-notebooks
    root: built_notebooks
    notebook-profile: student
    text: Open in Google Colab
    icon: box-arrow-up-right
```

Then opt in from a document:

```yaml
---
title: Week 44
colab: true
---
```

The generated URL has this form:

```text
https://colab.research.google.com/github/{repo}/blob/{branch}/{root}/{notebook-profile}/{document-basename}.ipynb
```

By default, all pages link to the `student` notebook profile. The extension
only generates links; rendering notebooks and publishing them to the configured
branch must be handled by the course build workflow.
