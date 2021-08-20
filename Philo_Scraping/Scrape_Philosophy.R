library(rvest)
library(tidyverse)
library(wordcloud)
library(tm)
library(wordcloud2)
library(RColorBrewer)
library(lubridate)
library(stringr)
library(jiebaR)
library(gridExtra)

options("encoding" = "UTF-8")

#get the most popular
url <- "https://philomedium.com/content/today"
philo <- "https://philomedium.com"

h <- read_html(url)

#get blog web
blogs <- h %>%
  html_nodes("[class='views-field views-field-title']") %>%
  html_nodes("a") %>%
  html_attr("href")

blog_which <- blogs %>% str_which("^/blog")
blog_h <- blogs[blog_which]

#get blog title
blog_title <- h %>%
  html_nodes("[class='views-field views-field-title']") %>%
  html_nodes("a") %>%
  html_text() %>%
  .[blog_which]

#get each html link
links <- paste0(philo, blog_h)

#define cutter
cutter <- worker(user = "new_words.txt", stop_word = "stop_words.txt", encoding = "UTF-8")

#scrape each individually
body2 <- NULL
for (i in 1:length(links)){
  body2[i] <- read_html(links[i]) %>%
    html_nodes(".field-body") %>%
    html_text()%>%
    str_remove_all("[0-9<>]") %>% 
    paste0(body2[i], collapse = "")
  words <- cutter[body2[i]]
  txt_freq <- freq(words)
  txt_freq <- arrange(txt_freq, desc(freq))
  graph <- wordcloud2(filter(txt_freq, freq > 1), 
                           minSize = 2, fontFamily = "Microsoft YaHei", size = 1)
  print(graph)
}

#create a null body for loop
body <- NULL
#create alrogether cloud
for (i in 1:length(links)){
  body[i] <- read_html(links[i]) %>%
    html_nodes(".field-body") %>%
    html_text()%>%
    str_remove_all("[0-9<>]") %>% 
    paste0(body[i], collapse = "")
  body <- paste0(body[i], body, collapse = "")
}
words <- cutter[body]
txt_freq <- freq(words)
txt_freq <- arrange(txt_freq, desc(freq))
wordcloud2(filter(txt_freq, freq > 1), 
           minSize = 2, fontFamily = "Microsoft YaHei", size = 1)
