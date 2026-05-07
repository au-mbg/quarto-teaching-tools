# Quarto Teaching Tools

This repository contains Quarto extensions developed to make authoring teaching materials 
more convenient. 

## Extensions

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

The filter supports both divs and code blocks:

````markdown
```python
#| exercise: true
print("scaffold for students")
```

```python
#| solution: true
print("solution for instructors")
```

::: {exercise=true}
Exercise text for students.
:::

::: {solution=true}
Solution text for instructors.
:::
````

Code blocks marked with `exercise: true` are not automatically assigned `eval: false`; add that option explicitly when scaffolded code should not be executed.

This can be installed with

```sh
quarto install extension au-mbg/quarto-teaching-tools/extensions/strip-solution
```
