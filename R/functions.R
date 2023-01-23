#' @title flag_missing
#'
#' @description flag_missing uses three arguments: data, vars and ratio (if not provided, its default value is 0.33) and it creates a binary vector.
#'
#' @param data A tibble
#' @param vars Any expression that can be used with dplyr::select
#' @param ratio Any number between 0 and 1 (if not provided, its default value is 0.33).
#'
#' @return A binary vector
#'
#' @export
#' @import dplyr magrittr
#'
flag_missing <-function(data, vars, ratio=0.33){
  data %>%
    select({{vars}}) %>%
    mutate(missing_mean = rowMeans(is.na(.))) %>%
    mutate(fl_missing=if_else(missing_mean>ratio, 1, 0)) %>%
    select(fl_missing) %>%
    pull()
}

is_midpoint<-function(x, midpoint=3) {
  if_else(x==midpoint, 1, 0)
}


#' @title flag_midpoints
#'
#' @description flag_ midpoint uses four arguments: data, vars, midpoint (if not provided, its default value is 3) and ratio (if not provided, its default value is 0.5)  and it creates a binary vector.
#'
#' @param data A tibble (or a compatible data structure)
#' @param vars Any expression that can be used with dplyr::select
#' @param midpoint An integer (if not provided, its default value is 3)
#' @param ratio Any number between 0 and 1 (if not provided, its default value is 0.5)
#'
#' @return A binary vector
#'
#' @export
#' @import dplyr
#'
flag_midpoints <-function(data, vars, midpoint=3, ratio=0.5){
  data %>%
    select({{vars}}) %>%
    mutate(across(everything(), ~is_midpoint(.x, midpoint))) %>%
    mutate(midpoints_mean=rowMeans(., na.rm = TRUE))%>%
    mutate(fl_midpoint=if_else(midpoints_mean>ratio, 1, 0)) %>%
    select(fl_midpoint) %>%
    pull()
}


#' @title flag_straight
#'
#' @description flag_ straight uses two arguments: data, and vars and it creates a binary vector.
#'
#' @param data A tibble (or a compatible data structure)
#' @param vars Any expression that can be used with dplyr::select
#' and it should correspond to the items that have been displayed
#' to respondents as a grid question
#'
#' @return A binary vector
#'
#' @export
#' @import dplyr careless
#'
flag_straight <-function(data, vars){
  data %>%
    select({{vars}}) %>%
    mutate(straight_lining=longstring(.)== ncol(.)) %>%
    mutate(fl_straight=if_else(straight_lining, 1, 0)) %>%
    select(fl_straight) %>%
    pull()
}


create_flag_threshold<-function(data, var, threshold_data) {
  th<-threshold_data %>%
    select({{var}}) %>%
    pull()
  data %>%
    transmute("fl_{{var}}" := if_else({{var}}>th, 0,1)) %>%
    pull()
}

#' @title flag_times
#'
#' @description flag_time uses three arguments: data, threshold_file and ratio (if not provided, its default value is 0.1) and it creates a binary vector.
#'
#' @param data A tibble
#' @param threshold_file The name of the file with variable names, number of characters and number of subquestions
#' @param ratio can by any number between 0 and 1
#'
#' @return A binary vector
#'
#' @export
#' @import dplyr tidyr stringr
#'
flag_times<-function(data, threshold_file, ratio=0.1) {
  question_chars<-read_csv(threshold_file)
  thresholds<-
    question_chars %>%
    mutate(threshold=1.4*n_sub+n_chars/40) %>%
    mutate(name=str_c(name, "Time")) %>%
    select(name, threshold) %>%
    pivot_wider(names_from = name, values_from=threshold)
  vars<-names(thresholds)
  flag<-data %>%
    select(vars) %>%
    mutate(across(everything(), ~create_flag_threshold(data, .x, thresholds))) %>%
    mutate(n_speeding=rowSums(., na.rm = TRUE))%>%
    mutate(p_speeding=n_speeding/ ncol(.)) %>%
    mutate(fl_speeding=if_else(p_speeding>ratio, 1, 0)) %>%
    select(fl_speeding) %>%
    pull()
  flag
}
