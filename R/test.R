issp2020<-read_csv("issp2020.csv")

issp2020 %>%
  mutate(flag=flag_missing(., Q4:Q8, ratio=0.1)) %>%
  select(flag) %>%
  count(flag)


vars<-issp2020 %>% select(Q1a_1, Q1a_2, Q3a_1, Q3a_2, Q4:Q8,  Q10_a:Q10_e,
                          Q10_f:Q12_e, Q12_f:Q22_c) %>% names()

issp2020 %>%
  mutate(flag=flag_missing(., vars, ratio=0.1)) %>%
  select(flag) %>%
  count(flag)


issp2020 %>%
  mutate(flag=flag_midpoints(., Q10_a:Q12_g, midpoint=3, ratio2=0.33)) %>%
  select(flag) %>%
  count(flag)
