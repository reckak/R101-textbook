# read_jasp(): načtení dat a metadat ze souboru JASP (.jasp) do R
#
# Soubor .jasp je ZIP archiv. Od JASP 0.19 (jaspArchiveVersion 5) jsou data
# uložena v SQLite databázi `internal.sqlite`:
#   - DataSet_<n>  hodnoty; každá proměnná má sloupce Column_<id>_DBL
#                  (číselná hodnota) a Column_<id>_INT (klíč do tabulky Labels)
#   - Columns      názvy, popisky (title), popisy, typ měřítka, vlastní
#                  chybějící hodnoty, R kód počítaných proměnných
#   - Labels       hodnotové popisky a jejich pořadí
#   - DataSets     cesta k původnímu souboru, výchozí chybějící hodnoty
#   - Filters      filtr nastavený v JASP
# Starší archivy (data.bin + metadata.json) tato funkce nepodporuje.
#
# Potřebné balíčky: DBI, RSQLite, jsonlite, tibble; pro labels = "haven"
# také haven.
#
# Výsledek: tibble, kde
#   - nominální a ordinální proměnné jsou faktory (u ordinálních uspořádané)
#     s úrovněmi v pořadí z JASP,
#   - spojité (scale) proměnné jsou čísla; mají-li v JASP hodnotové popisky,
#     při labels = "haven" se vrátí jako haven::labelled,
#   - textové proměnné jsou znakové vektory.
# Metadata jsou v atributech:
#   - u proměnné: "label" (popisek z JASP), "description", "jasp_type",
#     "na_values" (hodnoty převedené na NA), případně "jasp_r_code",
#   - u celé tabulky: attr(x, "jasp") se seznamem informací o souboru
#     a tabulkou proměnných (attr(x, "jasp")$variables).
#
# Příklad:
#   source("scripts/read_jasp.R")
#   cyklisti <- read_jasp("data/raw/bicyclists2025.jasp")
#   attr(cyklisti, "jasp")$variables

read_jasp <- function(path,
                      labels = c("factor", "haven", "none"),
                      user_na = FALSE,
                      apply_filter = FALSE) {
  labels <- match.arg(labels)
  for (pkg in c("DBI", "RSQLite", "jsonlite", "tibble")) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop("Chybí balíček '", pkg, "'. Nainstalujte jej: install.packages(\"",
           pkg, "\")", call. = FALSE)
    }
  }
  if (labels == "haven" && !requireNamespace("haven", quietly = TRUE)) {
    stop("Pro labels = \"haven\" je potřeba balíček 'haven'.", call. = FALSE)
  }
  if (!file.exists(path)) stop("Soubor neexistuje: ", path, call. = FALSE)

  # --- rozbalení archivu ----------------------------------------------------
  tmp <- tempfile("jasp_")
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  obsah <- utils::unzip(path, list = TRUE)$Name
  if (!"internal.sqlite" %in% obsah) {
    stop("V archivu chybí 'internal.sqlite'. Jde nejspíš o soubor ze starší ",
         "verze JASP (< 0.19); otevřete jej v aktuálním JASP a uložte znovu, ",
         "nebo data z JASP exportujte do CSV.", call. = FALSE)
  }
  utils::unzip(path, files = intersect(c("internal.sqlite", "manifest.json"), obsah),
               exdir = tmp)
  manifest <- if (file.exists(file.path(tmp, "manifest.json"))) {
    jsonlite::read_json(file.path(tmp, "manifest.json"))
  } else {
    list()
  }

  con <- DBI::dbConnect(RSQLite::SQLite(), file.path(tmp, "internal.sqlite"))
  on.exit(DBI::dbDisconnect(con), add = TRUE, after = FALSE)
  q <- function(sql) DBI::dbGetQuery(con, sql)

  datasety <- q("SELECT * FROM DataSets ORDER BY id")
  if (nrow(datasety) == 0) stop("Soubor neobsahuje žádná data.", call. = FALSE)
  ds_id <- datasety$id[1]
  sloupce <- q(paste("SELECT * FROM Columns WHERE dataSet =", ds_id, "ORDER BY colIdx"))
  hodnoty <- q(paste0("SELECT * FROM DataSet_", ds_id, " ORDER BY rowNumber"))
  popisky <- q("SELECT * FROM Labels ORDER BY columnId, ordering")

  # --- pomocné funkce -------------------------------------------------------
  na_z_json <- function(json) {
    if (is.null(json) || is.na(json) || !nzchar(json) || trimws(json) == "null") {
      return(NULL)
    }
    x <- jsonlite::fromJSON(json)
    list(custom = isTRUE(x$custom), strings = as.character(unlist(x$strings)))
  }
  puvodni_hodnota <- function(json) {
    vapply(json, function(j) {
      v <- tryCatch(jsonlite::fromJSON(j), error = function(e) NA)
      if (length(v) == 0 || is.null(v)) NA_character_ else as.character(v)
    }, character(1), USE.NAMES = FALSE)
  }
  prazdny <- function(x) is.na(x) | !nzchar(x)

  na_dataset <- na_z_json(datasety$emptyValuesJson[1])

  # --- převod jednotlivých proměnných ---------------------------------------
  vysledek <- list()
  prehled <- vector("list", nrow(sloupce))

  for (i in seq_len(nrow(sloupce))) {
    s <- sloupce[i, ]
    dbl <- hodnoty[[paste0("Column_", s$id, "_DBL")]]
    int <- hodnoty[[paste0("Column_", s$id, "_INT")]]
    lab <- popisky[popisky$columnId == s$id, , drop = FALSE]
    lab$puvodni <- puvodni_hodnota(lab$originalValueJson)
    lab$text <- ifelse(prazdny(lab$label), lab$puvodni, lab$label)
    typ <- s$columnType

    # chybějící hodnoty: vlastní pro proměnnou, jinak výchozí pro soubor
    na_sloupec <- na_z_json(s$emptyValuesJson)
    na_def <- if (!is.null(na_sloupec) && na_sloupec$custom) na_sloupec else na_dataset
    na_retezce <- if (is.null(na_def)) character() else na_def$strings
    na_num <- suppressWarnings(as.numeric(na_retezce))
    na_num <- na_num[!is.na(na_num)]

    # Číselná hodnota (DBL); NaN v JASP odpovídá chybějící hodnotě.
    num <- dbl
    num[is.nan(num)] <- NA
    je_na <- num %in% na_num
    # textová hodnota podle klíče (INT) do tabulky Labels
    pozice <- match(int, lab$value)
    txt <- lab$text[pozice]
    puv <- lab$puvodni[pozice]
    je_na <- je_na | (!is.na(puv) & puv %in% na_retezce)
    je_text <- all(is.na(num) | is.na(int) | int < 0) && any(!is.na(puv))

    if (!user_na) {
      num[je_na] <- NA
      txt[je_na] <- NA
    }
    lab_platne <- if (user_na) lab else lab[!(lab$puvodni %in% na_retezce), , drop = FALSE]

    if (typ %in% c("nominal", "ordinal") && labels == "factor") {
      x <- factor(txt, levels = unique(lab_platne$text), ordered = typ == "ordinal")
    } else if (typ %in% c("nominal", "ordinal", "nominalText") && je_text) {
      x <- txt
    } else {
      x <- num
      ma_popisky <- !prazdny(lab_platne$label)
      if (labels == "haven" && any(ma_popisky)) {
        kody <- suppressWarnings(as.numeric(lab_platne$puvodni[ma_popisky]))
        names(kody) <- lab_platne$label[ma_popisky]
        x <- haven::labelled(x, labels = kody[!is.na(kody)])
      } else if (labels == "factor" && any(ma_popisky)) {
        # spojitá proměnná s popisky (např. pohlaví označené jako scale):
        # data ponecháme číselná a popisky uložíme do atributu
        kody <- suppressWarnings(as.numeric(lab_platne$puvodni[ma_popisky]))
        names(kody) <- lab_platne$label[ma_popisky]
        attr(x, "value_labels") <- kody
      }
    }

    attr(x, "label") <- if (prazdny(s$title)) NULL else s$title
    if (!prazdny(s$description)) attr(x, "description") <- s$description
    attr(x, "jasp_type") <- typ
    if (length(na_retezce)) attr(x, "na_values") <- na_retezce
    if (!prazdny(s$rCode)) attr(x, "jasp_r_code") <- s$rCode

    vysledek[[s$name]] <- x
    prehled[[i]] <- data.frame(
      name = s$name,
      title = if (prazdny(s$title)) NA_character_ else s$title,
      jasp_type = typ,
      r_class = paste(class(x), collapse = "/"),
      n_value_labels = sum(!prazdny(lab$label)),
      na_values = paste(na_retezce, collapse = ", "),
      n_missing = sum(is.na(x)),
      computed = !prazdny(s$codeType),
      stringsAsFactors = FALSE
    )
  }

  out <- tibble::as_tibble(vysledek)

  # --- filtr z JASP ---------------------------------------------------------
  filtr_sloupec <- grep("^Filter_", names(hodnoty), value = TRUE)[1]
  filtr <- if (!is.na(filtr_sloupec)) hodnoty[[filtr_sloupec]] == 1 else rep(TRUE, nrow(out))
  filtry <- tryCatch(q(paste("SELECT * FROM Filters WHERE dataSet =", ds_id)),
                     error = function(e) NULL)
  if (apply_filter) out <- out[filtr, , drop = FALSE]

  attr(out, "jasp") <- list(
    file = normalizePath(path, winslash = "/"),
    jasp_version = manifest$jaspVersion,
    archive_version = manifest$jaspArchiveVersion,
    original_data_file = datasety$dataFilePath[1],
    description = datasety$description[1],
    na_values = if (is.null(na_dataset)) character() else na_dataset$strings,
    filter_r_code = if (!is.null(filtry) && nrow(filtry)) filtry$rFilter[1] else NULL,
    rows_passing_filter = sum(filtr),
    filter_applied = apply_filter,
    variables = tibble::as_tibble(do.call(rbind, prehled))
  )
  out
}
