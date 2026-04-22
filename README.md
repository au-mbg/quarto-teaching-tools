# Quarto Teaching Tools

This repository contains Quarto extensions developed to make authoring teaching materials 
more convenient. 

## Extensions

### callout-solution

Adds a solution block which is only rendered when `teaching.show-solution: true` is set in the project 
or document metadata, for example in a profile one can add

```
teaching:
  show-solutions: true
  default-solution-title: "This is a solution title"
```

And then a block like 

```
::: {.callout-solution}
This block is a solution, only shown when run when `show-solution` is set to `true` in the document or project metadata.
```

This can be installed with 

```sh
quarto install extension au-mbg/quarto-teaching-tools/extensions/solution-callout
```