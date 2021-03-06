#' @export
#' @importFrom rlang eval_tidy enquo
#' @title Define flextable displayed values
#' @description Modify flextable displayed values. Function is
#' handling complex formatting as well as image insertion.
#'
#' Function `mk_par` is another name for `compose` as
#' there is an unwanted conflict with package `purrr`.
#' @param x a flextable object
#' @param i rows selection
#' @param j column selection
#' @param value a call to function [as_paragraph()].
#' @param part partname of the table (one of 'all', 'body', 'header', 'footer')
#' @examples
#' library(officer)
#' ft <- flextable(head( mtcars, n = 10))
#' ft <- compose(ft, j = "carb", i = ~ drat > 3.5,
#'   value = as_paragraph("carb is ", as_chunk( sprintf("%.1f", carb)) )
#'   )
#' ft <- autofit(ft)
#' @export
#' @family cells formatters
#' @section Illustrations:
#'
#' \if{html}{\figure{fig_compose_1.png}{options: width=80\%}}
compose <- function(x, i = NULL, j = NULL, value , part = "body"){

  if( !inherits(x, "flextable") ) stop("compose supports only flextable objects.")
  part <- match.arg(part, c("all", "body", "header", "footer"), several.ok = FALSE )

  if( part == "all" ){
    for( p in c("header", "body", "footer") ){
      x <- compose(x = x, i = i, j = j, value = value, part = p)
    }
    return(x)
  }

  if( nrow_part(x, part) < 1 )
    return(x)

  check_formula_i_and_part(i, part)
  i <- get_rows_id(x[[part]], i )
  j <- get_columns_id(x[[part]], j )
  x[[part]]$content[i, j] <- eval_tidy(enquo(value), data = x[[part]]$dataset[i,, drop = FALSE])

  x
}

#' @rdname compose
#' @export
mk_par <- compose

