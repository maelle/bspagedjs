# the nice HTML book
bookdown::render_book("index.Rmd")

# the place where we tweak, merge and print HTMLs
if (fs::dir_exists("docs2")) fs::dir_delete("docs2")
fs::dir_copy("docs", "docs2")

htmls <- fs::dir_ls("docs2", glob = "*.html")

tweak_page <- function(page_path) {
  # put TOC at the beginning and fix text
  page <- xml2::read_html(page_path)
  page_toc <- xml2::xml_find_first(page, ".//nav[@id='toc']")
  toc_title <- xml2::xml_find_first(page_toc, "h2")
  xml2::xml_text(toc_title) <- "In this chapter"
  source_title <- xml2::xml_find_first(page_toc, "//a[@id='book-edit']")
  xml2::xml_text(source_title) <- "Edit this chapter"

  xml2::xml_add_sibling(
    xml2::xml_find_first(page, ".//main[@id='content']//h1"),
    page_toc,
    where = "after"
    )
  xml2::xml_remove(page_toc)

  # fix cross-refs
  hrefs <- xml2::xml_find_all(page, ".//a")
  xml2::xml_attr(hrefs, "href") <- gsub("^.*\\.html#", "#", xml2::xml_attr(hrefs, "href"))

  xml2::write_html(page, page_path)
}

lapply(htmls, tweak_page)

# Now we'll add the main content of all pages to index dot html
page1 <- xml2::read_html("docs2/index.html")



get_contents <- function(page_path, main = xml2::xml_find_first(page1, ".//main[@id='content']")) {
  page <- xml2::read_html(page_path)
  contents <-  xml2::xml_contents(xml2::xml_find_first(page, ".//main[@id='content']"))

  for (i in contents) {
    xml2::xml_add_child(main, i)
  }
}

# Important to get HTMLs in the right order, thanks book TOC
ordered_htmls <- xml2::xml_attr(
  xml2::xml_find_all(page1, ".//ul[contains(@class, 'book-toc')]//li//a"),
  "href"
)
ordered_htmls <- ordered_htmls[ordered_htmls!="index.html"]
ordered_htmls <- file.path("docs2", ordered_htmls)

lapply(ordered_htmls, get_contents)

# fix toc links
toc <- xml2::xml_find_first(page1, ".//nav")
active <- xml2::xml_find_first(toc, ".//a[@class='active']")
xml2::xml_attr(active, "class") <- ''
toc_links <- xml2::xml_find_all(toc, ".//a[@class='']")
xml2::xml_attr(toc_links, "href") <- paste0(
  "#",
  gsub(
    "\\.html$",
    "",
    xml2::xml_attr(toc_links, "href")
  )
)
# fix first anchor
xml2::xml_attr(toc_links[1], "href") <- xml2::xml_attr(xml2::xml_find_first(page1, ".//a[@class='anchor']"), "href")

for (i in rev(xml2::xml_contents(toc))) {

  xml2::xml_add_sibling(
    xml2::xml_child(xml2::xml_find_first(page1, ".//main[@id='content']")),
    i,
    .where = "before"
  )
}


xml2::write_html(page1, "docs2/index.html")

# Print!
system("pagedjs-cli ./docs2/index.html -o docs/result.pdf -w 227 -h 291")
