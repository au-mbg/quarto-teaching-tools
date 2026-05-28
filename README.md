# Quarto Teaching Tools

This repository contains Quarto extensions developed to make authoring teaching materials 
more convenient. 

## Extensions

### colab-link

Adds a Google Colab link to pages that opt in with `colab: true`. The link is
generated from shared project metadata and inserted into Quarto's rendered
**Other Formats** block.

Configure the repository and notebook branch in project or profile metadata:

```yaml
filters:
  - colab-link

teaching:
  colab:
    repo: au-mbg/fysisk-biokemi
    branch: built-notebooks
    root: built_notebooks
    notebook-profile: student
```

Then mark individual documents:

```yaml
colab: true
```

By default, the generated URL points to
`built_notebooks/student/<document-basename>.ipynb`. The extension only
generates links; rendering and publishing notebooks remains the responsibility
of the course build workflow.

This can be installed with

```sh
quarto install extension au-mbg/quarto-teaching-tools/extensions/colab-link
```

### callout-solution

Adds a solution block which is only rendered when `teaching.show-solutions: true` is set in the project 
or document metadata, for example in a profile one can add

```
teaching:
  show-solutions: true
  default-solution-title: "This is a solution title"
```

And then a block like 

```
::: {.callout-solution}
This block is a solution, only shown when run when `show-solutions` is set to `true` in the document or project metadata.
```

This can be installed with 

```sh
quarto install extension au-mbg/quarto-teaching-tools/extensions/callout-solution
```

### strip-solution

Removes exercise or solution blocks based on `teaching.show-solutions`. This is useful when the same source document should produce both a student version and an instructor version.

When `teaching.show-solutions` is unset, the filter leaves the document unchanged. When it is `false`, blocks marked as solutions are removed. When it is `true`, blocks marked as exercises are removed.

For a student profile, use:

```yaml
teaching:
  show-solutions: false
```

For an instructor profile, use:

```yaml
teaching:
  show-solutions: true
```

The preferred syntax is to mark each block with `teaching: exercise` or `teaching: solution`. The filter supports both divs and code blocks:

````markdown
```python
#| teaching: exercise
print("scaffold for students")
```

```python
#| teaching: solution
print("solution for instructors")
```

::: {teaching="exercise"}
Exercise text for students.
:::

::: {teaching="solution"}
Solution text for instructors.
:::
````

The legacy boolean markers `exercise: true` and `solution: true` are still supported for existing materials. If both legacy and preferred markers are used on the same block, they must agree. Unknown `teaching` values fail the render.

Code blocks marked as exercises are not automatically assigned `eval: false`; add that option explicitly when scaffolded code should not be executed.

This can be installed with

```sh
quarto install extension au-mbg/quarto-teaching-tools/extensions/strip-solution
```
