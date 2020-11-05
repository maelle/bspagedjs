This is a minimal example of a book based on R Markdown and **bookdown** (https://github.com/rstudio/bookdown).

This uses the `bs4_book()` template for HTML and then for getting a PDF

* tweaks of the HTML and merging of all chapters
* some print CSS, see [stylesheet](style.css)
* pagedjs-cli.

See [build.R](build.R)

Why use this and not LaTeX?

* procrastination? :see_no_evil:
* not having to redefine colors, environments for the LaTeX output
* not having to knit the same Rmd's twice for the two outputs (which also excludes using pagedown).

Why not pagedown?

* I want a non paginated HTML in the browser, and I want the PDF to be pre-generated.


## What's needed?

* dev bookdown and co to use `bs4_book()`
* a stylesheet with print CSS
* mathjax without loading messages see [mathjax.html](mathjax.html) (or no mathjax if your book does not feature equations)

So in `_output.yml` e.g.

```yaml
bookdown::bs4_book:
  theme:
    bootswatch: "litera"
    primary: "#982a31"
    fg: "#2b2121"
    bg: "#ffffff"
  repo: https://github.com/maelle/bspagedjs
  css: style.css
  mathjax: NULL
  includes:
    in_header: mathjax.html
```

* pagedjs-cli (locally, or using GitHub Actions)
