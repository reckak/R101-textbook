# Fictional Czech responses for demonstrating a Windows-1250 text import.
# Run from the repository root. Keep the exported bytes unchanged in Git.
text <- c(
  "id,odpoved",
  "001,Při zkoušce se často cítím napjatě.",
  "002,O svých pocitech mluvím s blízkými lidmi.",
  "003,V případě potřeby dokážu požádat o pomoc.",
  "004,Někdy je těžké vyjádřit vlastní přání.",
  "005,Rád si před náročným úkolem odpočinu.",
  "006,Důvěřuji svým blízkým a přátelům."
)
bytes <- iconv(paste0(paste(text, collapse = "\r\n"), "\r\n"),
               from = "UTF-8", to = "Windows-1250", toRaw = TRUE)[[1]]
stopifnot(!is.null(bytes))
writeBin(bytes, "data/raw/ceske_odpovedi.csv")
