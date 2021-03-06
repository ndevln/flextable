#' @title set column formatter functions
#' @description Define formatter functions associated to each column key.
#' Functions have a single argument (the vector) and are returning the formatted
#' values as a character vector.
#' @param x a flextable object
#' @param ... Name-value pairs of functions, names should be existing col_key values
#' @param values a list of name-value pairs of functions, names should be existing col_key values.
#' If values is supplied argument \code{...} is ignored.
#' @param part partname of the table (one of 'body' or 'header' or 'footer')
#' @examples
#' ft <- flextable( head( iris ) )
#' ft <- set_formatter( x = ft,
#'         Sepal.Length = function(x) sprintf("%.02f", x),
#'         Sepal.Width = function(x) sprintf("%.04f", x)
#'       )
#' ft <- theme_vanilla( ft )
#' ft
#' @export
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_set_formatter_1.png}{options: width=50\%}}
#' @family cells formatters
set_formatter <- function(x, ..., values = NULL, part = "body"){


  if(!inherits(x, "flextable"))
    stop("argument `x` of function `set_formatter` should be a flextable object")

  part <- match.arg(part, c("body", "header", "footer"), several.ok = FALSE )

  if( is.null(values) ){
    values <- list(...)
  }
  col_keys <- intersect(names(values), x[[part]]$col_keys)

  for(key in col_keys){
    dat <- x[[part]]$dataset[, key]
    chk <- as_chunk(values[[key]](dat))
    x <- compose(x, j = key, value = as_paragraph(chk), part = part )
  }

  x
}


#' @export
#' @rdname set_formatter
#' @section set_formatter_type:
#' \code{set_formatter_type} is an helper function to quickly define
#' formatter functions regarding to column types.
#' @param fmt_double,fmt_integer arguments used by \code{sprintf} to
#' format double and integer columns.
#' @param fmt_date,fmt_datetime arguments used by \code{format} to
#' format date and date time columns.
#' @param false,true string to be used for logical columns
#' @param na_str string for NA values
#' @family cells formatters
set_formatter_type <- function(x, fmt_double = "%.03f", fmt_integer = "%.0f",
                               fmt_date = "%Y-%m-%d", fmt_datetime = "%Y-%m-%d %H:%M:%S",
                               true = "true", false = "false",
                               na_str = ""){

  stopifnot(inherits(x, "flextable"))

  col_keys <- x[["body"]]$col_keys
  for( varname in col_keys){
    x <- compose(x = x, j = varname, value = as_paragraph(as_chunk(
      format_fun(get(varname), na_string = na_str,
                 fmt_double = fmt_double,
                 fmt_integer = fmt_integer,
                 fmt_date = fmt_date,
                 fmt_datetime = fmt_datetime,
                 true = true, false = false)
      )), part = "body" )
  }
  x
}

#' @export
#' @title format character cells
#' @description Format character cells in a flextable.
#' @param x a flextable object
#' @param i rows selection
#' @param j columns selection.
#' @param na_str string to be used for NA values
#' @param prefix,suffix string to be used as prefix or suffix
#' @family cells formatters
#' @examples
#' dat <- iris
#' z <- flextable(head(dat))
#' ft <- colformat_char(
#'   x = z, j = "Species", suffix = "!")
#' z <- autofit(z)
#' z
colformat_char <- function(
  x, i = NULL, j = NULL,
  na_str = get_flextable_defaults()$na_str,
  prefix = "", suffix = ""){

  stopifnot(inherits(x, "flextable"))

  quo_fun <- quo(format_fun.character(
    x, na_str = na_str, prefix = prefix, suffix = suffix
  ))
  fun_ <- new_function(
    pairlist2(x = , na_str = na_str, prefix = prefix, suffix = suffix),
    get_expr(quo_fun))

  col_keys <- filter_col_keys(x, j, function(x) is.character(x) || is.factor(x))
  docall_display(col_keys, fun_, x, i = i)
}

#' @export
#' @title format numeric cells
#' @description Format numeric cells in a flextable.
#' @inheritParams colformat_char
#' @param big.mark,digits,decimal.mark see [format()]
#' @family cells formatters
#' @examples
#' dat <- mtcars
#' ft <- flextable(head(dat))
#' ft <- colformat_double(x = ft,
#'   big.mark=",", digits = 2, na_str = "N/A")
#' autofit(ft)
#' @importFrom rlang new_function quo get_expr pairlist2
colformat_double <- function(
  x, i = NULL, j = NULL,
  big.mark = get_flextable_defaults()$big.mark,
  decimal.mark = get_flextable_defaults()$decimal.mark,
  digits = get_flextable_defaults()$digits,
  na_str = get_flextable_defaults()$na_str,
  prefix = "", suffix = ""){

  stopifnot(inherits(x, "flextable"))

  col_keys <- filter_col_keys(x, j, is.double)

  quo_fun <- quo(format_fun.double(
    x, big.mark = big.mark, decimal.mark = decimal.mark,
    digits = digits, na_str = na_str, prefix = prefix, suffix = suffix
  ))
  fun_ <- new_function(
    pairlist2(x = , big.mark = big.mark, decimal.mark = decimal.mark,
              digits = digits, na_str = na_str, prefix = prefix, suffix = suffix),
    get_expr(quo_fun))

  docall_display(col_keys, fun_, x, i = i)
}
#' @export
#' @title format numeric cells
#' @description Format numeric cells in a flextable.
#' @inheritParams colformat_char
#' @param big.mark,digits,decimal.mark see [format()]
#' @family cells formatters
#' @examples
#' dat <- mtcars
#' ft <- flextable(head(dat))
#' ft <- colformat_num(x = ft,
#'   big.mark=",", digits = 2, na_str = "N/A")
#' ft <- autofit(ft)
#' ft
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_colformat_num_1.png}{options: width=50\%}}
colformat_num <- function(
  x, i = NULL, j = NULL,
  big.mark = get_flextable_defaults()$big.mark,
  decimal.mark = get_flextable_defaults()$decimal.mark,
  digits = get_flextable_defaults()$digits,
  na_str = get_flextable_defaults()$na_str,
  prefix = "", suffix = ""){

  stopifnot(inherits(x, "flextable"))
  col_keys <- filter_col_keys(x, j, is.numeric)

  quo_fun <- quo(format_fun.default(
    x, big.mark = big.mark, decimal.mark = decimal.mark,
    digits = digits, na_str = na_str, prefix = prefix, suffix = suffix
  ))
  fun_ <- new_function(
    pairlist2(x = , big.mark = big.mark, decimal.mark = decimal.mark,
              digits = digits, na_str = na_str, prefix = prefix, suffix = suffix),
    get_expr(quo_fun))

  docall_display(col_keys, fun_, x, i = i)
}

#' @title format date cells
#' @description Format date cells in a flextable.
#' @inheritParams colformat_char
#' @param fmt_date see [strptime()]
#' @family cells formatters
#' @export
#' @examples
#' dat <- data.frame(z = Sys.Date() + 1:3,
#'   w = Sys.Date() - 1:3)
#' ft <- flextable(dat)
#' ft <- colformat_date(x = ft)
#' ft <- autofit(ft)
#' ft
colformat_date <- function(
  x, i = NULL, j = NULL,
  fmt_date = get_flextable_defaults()$fmt_date,
  na_str = get_flextable_defaults()$na_str,
  prefix = "", suffix = ""){

  stopifnot(inherits(x, "flextable"))

  col_keys <- filter_col_keys(x, j, function(x) inherits(x, c("Date", "POSIXt")) )

  quo_fun <- quo(format_fun.Date(
    x, fmt_date = fmt_date, na_str = na_str, prefix = prefix, suffix = suffix))
  fun_ <- new_function(
    pairlist2(x = , fmt_date = fmt_date, na_str = na_str, prefix = prefix, suffix = suffix),
    get_expr(quo_fun))

  docall_display(col_keys, fun_, x, i = i)
}

#' @title format datetime cells
#' @description Format datetime cells in a flextable.
#' @inheritParams colformat_char
#' @param fmt_datetime see [strptime()]
#' @family cells formatters
#' @export
#' @examples
#' dat <- data.frame(z = Sys.time() + (1:3)*24,
#'   w = Sys.Date() - (1:3)*24)
#' ft <- flextable(dat)
#' ft <- colformat_datetime(x = ft)
#' ft <- autofit(ft)
#' ft
colformat_datetime <- function(
  x, i = NULL, j = NULL,
  fmt_datetime = get_flextable_defaults()$fmt_datetime,
  na_str = get_flextable_defaults()$na_str,
  prefix = "", suffix = ""){

  stopifnot(inherits(x, "flextable"))

  col_keys <- filter_col_keys(x, j, function(x) inherits(x, c("Date", "POSIXt")) )

  quo_fun <- quo(format_fun.POSIXt(
    x, fmt_datetime = fmt_datetime, na_str = na_str, prefix = prefix, suffix = suffix))
  fun_ <- new_function(
    pairlist2(x = , fmt_datetime = fmt_datetime, na_str = na_str, prefix = prefix, suffix = suffix),
    get_expr(quo_fun))

  docall_display(col_keys, fun_, x, i = i)
}

#' @title format integer cells
#' @description Format integer cells in a flextable.
#' @inheritParams colformat_char
#' @param big.mark see [format()]
#' @family cells formatters
#' @export
#' @examples
#' z <- flextable(head(mtcars))
#' j <- c("vs", "am", "gear", "carb")
#' z <- colformat_int(x = z, j = j, prefix = "# ")
#' z
colformat_int <- function(
  x, i = NULL, j = NULL,
  big.mark = get_flextable_defaults()$big.mark,
  na_str = get_flextable_defaults()$na_str,
  prefix = "", suffix = ""){

  stopifnot(inherits(x, "flextable"))

  col_keys <- filter_col_keys(x, j, is.integer)

  quo_fun <- quo(format_fun.integer(
    x, big.mark = big.mark, na_str = na_str, prefix = prefix, suffix = suffix))
  fun_ <- new_function(
    pairlist2(x = , big.mark = big.mark, na_str = na_str, prefix = prefix, suffix = suffix),
    get_expr(quo_fun))

  docall_display(col_keys, fun_, x, i = i)
}

#' @title format logical cells
#' @description Format logical cells in a flextable.
#' @inheritParams colformat_char
#' @param false,true string to be used for logical
#' @family cells formatters
#' @export
#' @examples
#' dat <- data.frame(a = c(TRUE, FALSE), b = c(FALSE, TRUE))
#'
#' z <- flextable(dat)
#' z <- colformat_lgl(x = z, j = c("a", "b"))
#' autofit(z)
colformat_lgl <- function(
  x, i = NULL, j = NULL,
  true = "true", false = "false",
  na_str = get_flextable_defaults()$na_str,
  prefix = "", suffix = ""){

  stopifnot(inherits(x, "flextable"))

  col_keys <- filter_col_keys(x, j, is.logical)

  quo_fun <- quo(format_fun.logical(
    x, true = true, false = false,
    na_str = na_str, prefix = prefix, suffix = suffix))
  fun_ <- new_function(
    pairlist2(x = , true = true, false = false,
              na_str = na_str, prefix = prefix, suffix = suffix),
    get_expr(quo_fun))

  docall_display(col_keys, fun_, x, i = i)
}


filter_col_keys <- function(x, j, fun){
  j <- get_columns_id(x[["body"]], j )
  col_keys <- x$col_keys[j]
  col_keys[sapply(x[["body"]]$dataset[col_keys], fun)]
}

docall_display <- function(col_keys, fun, x, i = NULL){

  check_formula_i_and_part(i, "body")
  for( varname in col_keys){
    x <- compose(x = x, j = varname, i = i, value = as_paragraph(as_chunk(fun(get(varname)))), part = "body" )
  }
  x
}

