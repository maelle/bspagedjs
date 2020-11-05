bookdown::render_book(".")

page_path <- "docs/intro.html"

tweak_page <- function(page_path) {
  # put TOC at the begging
  page <- xml2::read_html(page_path)
  page_toc <- xml2::xml_find_first(page, ".//nav[@id='toc']")
  xml2::xml_add_sibling(
    xml2::xml_find_first(page, ".//main[@id='content']//h1"),
    page_toc,
    where = "after"
    )
  xml2::xml_remove(page_toc)
  xml2::write_html(page, page_path)
}

tweak_page(page_path)

system("pagedjs-cli ./docs/intro.html -o docs/result.pdf")
