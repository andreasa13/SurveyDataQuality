connect_to_LimeRick <- function(user, password) {
  install.packages('LimeRick', repos = NULL, type="source")

  # set link to the LimeSurvey API on the demo remote server
  options(lsAPIurl = 'https://get.epoll.eu/index.php/admin/remotecontrol')

  # set LimeSurvey user login data for survey testing purposes
  options(lsUser = user)
  options(lsPass = password)

  # low-level API call
  #lsAPI(method = "release_session_key")
  # API call using a wrapper function
  lsSessionKey("release")
  sessionKey<-lsSessionKey("set")
  return(sessionKey)

}

get_responses <- function(){
  # install.packages("dplyr")
  lsGetSummary(675392)
  lsGetProperties('survey', 675392)$active
  questionList<-lsList("questions", 675392)
  questions<-questionList %>%
    as_tibble()
  return(questions)

}



#' @title load_dataset
#'
#' @description Load internal dataset for testing
#'
#' @param dataset A data set object
#'
#' @return A data frame object in the form of a list
#' @examples
#' load_dataset()
#' @export
#' @import dplyr readr
#'
load_dataset <- function(){
  issp2020<-read_csv("issp2020.csv")
  return(issp2020)
}

#' @title flag_missing
#'
#' @description ...
#'
#' @param data A data set object
#' @param vars A data set object
#' @param ratio A data set object
#'
#' @return ...
#'
#' @examples
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


#' @title flag_missing
#'
#' @description ...
#'
#' @param data A data set object
#' @param vars2 A data set object
#' @param midpoint A data set object
#' @param ratio2 A data set object
#'
#' @return ...
#'
#' @examples
#'
#' @export
#' @import dplyr
#'
flag_midpoints <-function(data, vars2, midpoint=3, ratio2=0.5){
  data %>%
    select({{vars2}}) %>%
    mutate(across(everything(), ~is_midpoint(.x, midpoint))) %>%
    mutate(midpoints_mean=rowMeans(., na.rm = TRUE))%>%
    mutate(fl_midpoint=if_else(midpoints_mean>ratio2, 1, 0)) %>%
    select(fl_midpoint) %>%
    pull()
}


#' @title flag_straight
#'
#' @description ...
#'
#' @param data ...
#' @param vars3 ...
#'
#' @return ...
#'
#' @examples
#'
#' @export
#' @import dplyr careless
#'
flag_straight <-function(data, vars3){
  data %>%
    select({{vars3}}) %>%
    mutate(straight_lining=longstring(.)== ncol(.)) %>%
    mutate(fl_straight=if_else(straight_lining, 1, 0)) %>%
    select(fl_straight) %>%
    pull()
}


#' @title create_flag_threshold
#'
#' @description ...
#'
#' @param data ...
#' @param vars3 ...
#'
#' @return ...
#'
#' @examples
#'
#' @export
#' @import dplyr
#'
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
#' @description ...
#'
#' @param data ...
#' @param vars3 ...
#'
#' @return ...
#'
#' @examples
#'
#' @export
#' @import dplyr
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
    mutate(across(everything(), ~create_flag_threshold(issp2020, .x, thresholds))) %>%
    mutate(n_speeding=rowSums(., na.rm = TRUE))%>%
    mutate(p_speeding=n_speeding/ ncol(.)) %>%
    mutate(fl_speeding=if_else(p_speeding>ratio, 1, 0)) %>%
    select(fl_speeding) %>%
    pull()
  flag
}
