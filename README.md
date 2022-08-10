Survey Data Quality
================

<!-- README.md is generated from README.Rmd. Please edit that file -->

The R Package “Survey Data Quality” has been created as one of the
outputs of the Research Project “Innovative methods and high-quality
data for populism and euroscepticism research”
[DATAPOPEU](https://www.datapopeu.gr/).

The package homepage: <https://github.com/andreasa13/SurveyDataQuality>

## Survey Data Quality: motivation

-   Even the best respondents may get tired or lose their interest and
    motivation and they may respond less carefully to the questions of a
    self-administered survey (i.e., with minimal cognitive effort).
-   Other respondents may not be interested in providing their best
    response. Instead, their motivation may be to complete the survey as
    quickly as possible (e.g., when they are after rewards/ incentives)

## Based on the survey methodology literature

Survey methodology scholars have used many methods to measure response
quality. Based on the theory of satisficing we use a series of
indicators of lower quality responses to estimate the level of
engagement of survey participants in answering the questionnaires:

-   item-nonresponse (skipping): e.g., calculate the ratio of missing
    answers for each respondent.

-   mid-point responses in Likert-type scale items: (e.g.,
    “neither/nor”): calculate the ratio of mid-point responses, because
    respondents may choose mid-point responses when they do not process
    a question with the required effort.

-   non-differentiation in grid questions (straight-lining)

-   the time spent on questionnaire items (speeding): e.g., using the
    minimum time needed to read and answer an attitudinal question given
    the length of the question text

## Survey Data Quality Tutorial

### Installing developer version from GitHub

``` r
# install.packages('devtools')
devtools::install_github("andreasa13/SurveyDataQuality")
```

### Loading the installed package

We load the new package. We also load tidyverse because we will need it
to run the examples below

``` r
library(SurveyDataQuality)
library(tidyverse)
```

### ISSP 2020

We will apply our functions and methods on issp2020, a dataset that
comes with the package. It was collected from a sample of students at
Aristotle University of Thessaloniki using the 2020 questionnaire of the
[International Social Survey Programme](https://issp.org/)

``` r
# preview of issp2020
issp2020 
#> # A tibble: 179 × 118
#>       id Q1a_1 Q1a_2 Q3a_1 Q3a_2    Q4  Q5_a  Q5_b  Q5_c  Q5_d    Q6    Q7    Q8
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1    21     1     6     3     4     5     9     3     3     2     5     6     4
#>  2    22     1     2     2     4     2     7     3     4     5     3     7     4
#>  3    25     6     2     4     2     3     7     3     5     5     3     6     4
#>  4    26     1     6     2     4     3     8     3     5     5     4     2     3
#>  5    30     2     6     2     4     3     9     2     4     3     4     6     4
#>  6    31     1     6     1     2     2     7     5     7     5     4     9     4
#>  7    32     1     2     2     4     2    10     3     7     6     5     7     3
#>  8    33     1     5     2     4     3     9     6     7     7     4     7     3
#>  9    34     6     2     3     1     4     7     4     8     5     3     6     4
#> 10    35     1     2     1     2     3     7     5     5     8     3     2     4
#> # … with 169 more rows, and 105 more variables: Q9a <dbl>, Q9b <dbl>,
#> #   Q10_a <dbl>, Q10_b <dbl>, Q10_c <dbl>, Q10_c2 <dbl>, Q10_d <dbl>,
#> #   Q10_e <dbl>, Q10_e2 <dbl>, Q10_e3 <dbl>, Q10_f <dbl>, Q11a <dbl>,
#> #   Q11b <dbl>, Q11c <dbl>, Q11d <dbl>, Q12_a <dbl>, Q12_b <dbl>, Q12_c <dbl>,
#> #   Q12_d <dbl>, Q12_e <dbl>, Q12_e2 <dbl>, Q12_e3 <dbl>, Q12_f <dbl>,
#> #   Q12_g <dbl>, Q13_g <dbl>, Q13_f <dbl>, Q13_c <dbl>, Q13_a <dbl>,
#> #   Q13_a1 <dbl>, Q13_b <dbl>, Q13_b1 <dbl>, Q13_d <dbl>, Q13_e <dbl>, …
```

### Item non-response

Some web survey packages offer the option to include a non-substantive
response (such as “I do not know”) and set it as the default response
option (i.e., it is recorded when the respondent has not selected any of
the response options. In this case a “don’t know” is equivalent to item
nonresponse.

If “don’t know” has been used as the default response option, we might
need to merge them with item nonresponse (e.g. transform “don’t know” to
missing)

Counting the number of missing values for each respondent, we should
check for items where a missing value would not indicate a low quality
response. Sometimes there is a good reason for a missing value
e.g. conditional questions. We need to exclude them

For the item-nonresponse indicator, calculate the ratio of missing
answers for each respondent and flag if the ratio is greater than (say)
0.33.

flag_missing uses three arguments: data, vars and ratio (if not
provided, its default value is 0.33) and it creates a binary vector.

Cases with a ratio of missing values greater than the provided (or the
default) ratio, are flagged with ones, while cases with a smaller ratio
of missing values have zeros

``` r
# flag cases with many missing values
issp2020 %>%
  mutate(flag=flag_missing(., Q4:Q8, ratio=0.5)) %>%
  filter(flag==1) %>%
  select(id, Q4:Q8)
#> # A tibble: 1 × 9
#>      id    Q4  Q5_a  Q5_b  Q5_c  Q5_d    Q6    Q7    Q8
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1   165    NA    NA    NA    NA    NA    NA    NA    NA
```

### Midpoint responses

Respondents may choose mid-point responses when they do not process a
question with the required effort.

While counting the number of midpoints for each respondent, we should
use items where a midpoint would indeed indicate a low quality response
e.g. excessive use of the “Neither/nor” option.

For the midpoint indicator:

1.  Select a list of survey items/variables
2.  Count how many times each respondent has selected the midpoint
3.  Calculate the ratio of midpoints for each respondent
4.  Flag if the ratio is greater than (say) 0.5.

flag\_ midpoint uses four arguments: data, vars, midpoint (if not
provided, its default value is 3) and ratio (if not provided, its
default value is 0.5)

Cases with a ratio of midpoint greater than the provided (or the
default) ratio, are flagged with ones, while cases with a smaller ratio
of missing values have zeros

``` r
# flag cases with many midpoints
issp2020 %>%
 mutate(flag=flag_midpoints(., Q10_a:Q12_g, midpoint=3, ratio2=0.5))%>%
  filter(flag==1) %>%
  select(id, Q10_a:Q12_g)
#> # A tibble: 1 × 23
#>      id Q10_a Q10_b Q10_c Q10_c2 Q10_d Q10_e Q10_e2 Q10_e3 Q10_f  Q11a  Q11b
#>   <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl>  <dbl>  <dbl> <dbl> <dbl> <dbl>
#> 1   132     3     4     2      4     4     3     NA      3     3     2     3
#> # … with 11 more variables: Q11c <dbl>, Q11d <dbl>, Q12_a <dbl>, Q12_b <dbl>,
#> #   Q12_c <dbl>, Q12_d <dbl>, Q12_e <dbl>, Q12_e2 <dbl>, Q12_e3 <dbl>,
#> #   Q12_f <dbl>, Q12_g <dbl>
```

### Straight-lining

To check straight-lining for each respondent, we need to choose items in
grid question.

It is much better if at least one of the items is **not** in the same
direction with the other items of the grid.

Repeat for each grid question:

1.  Count how many times each respondent has selected the same response
2.  If all responses are the same, we flag the corresponding case

``` r
# flag straight-lining
issp2020 %>%
  mutate(flag=flag_straight(., Q13_g:Q13_e)) %>%
  filter(flag==1) %>%
  select(id, Q13_g:Q13_e)
#> # A tibble: 1 × 10
#>      id Q13_g Q13_f Q13_c Q13_a Q13_a1 Q13_b Q13_b1 Q13_d Q13_e
#>   <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl>  <dbl> <dbl> <dbl>
#> 1   121     2     2     2     2      2     2      2     2     2
```

### Item response times

Before answering a survey question, a respondent needs to spend some:

-   Time to Read and Comprehend the question and the available response
    options (TRC), and
-   Time to Select and Report an answer (TSR).

The time spent on reading and comprehension depends on respondent
characteristics (e.g., age, education level) and the length and
complexity of the question.

The time spent on selecting and reporting an answer is affected by
question type and the number of response options offered.

Details about the method has been presented in the 2021 Joint
Statistical Meetings (Andreadis, 2021) and the main ideas have been
puplished circa 10 years ago (Andreadis, 2012, 2014) and have been
tested in various datasets (Andreadis, 2015a, 2015b).

A short version is presented below:

reading speeds \>40 cps (i.e., faster than skimming and closer to
scanning) indicate that at least one or more words of the question text
have been skipped. Thus the minimum TRC is: **MTRC=NC/40**

The Minimum Time to Select and Report an answer (MTSR) is: 1.4 seconds

Consequently, the minimum response time (MRT) for a simple attitude
question is:

**MRT=MTSR+MTRC=1.4+NC/40**

A question of 120 characters would take 1.4+120/40=4.4

Matrix/Grid/Array questions include a few subquestions (or items) that
share the same response options. In this case, the respondent needs to
spend time to select and report an answer for each subquestion.
Consequently, the formula should be adapted as follows:

**MRT=MTSR*NS+MTRC=1.4*NS+NC/40**

where, NS is the number of the subquestions in the matrix question

To start with, we need a web survey platform that enables us to capture
the time spent on each question by each participant.

In addition, we need to have the text of each question including the
text of sub-questions (if any) and the text of the response options.
Finally, if we have grid (matrix) questions, we usually have the time
spent to respond to all sub-questions (i.e. we do not have the time
spent to respond each sub-question separately). In this case, we need to
keep in our records the number of sub-questions.

Then, we can bring in the data of the time spent on each question by
each respondent and compare these times with the calculated thresholds.
If a respondent has spent less time on a questions that the minimum time
required to understand and respond to the question, we can flag the
corresponding case.

function flag_time uses three arguments: data, threshold_file and ratio
(if not provided, its default value is 0.1) and it creates a binary
vector. \* The argument data can be a tibble,

-   threshold_file is the name of the file with variable names, number
    of characters and number of subquestions

-   ratio can by any number between 0 and 1

Cases with a ratio of extremely fast responses greater than the provided
(or the default) ratio, are flagged with ones, while cases with a
smaller ratio have zeros

``` r
# flag speeders
issp2020 %>%
 mutate(flag=flag_times(., "http://www.datapopeu.gr/question-chars.csv", 0.2)) %>%
  filter(flag==1) 
#> # A tibble: 15 × 119
#>       id Q1a_1 Q1a_2 Q3a_1 Q3a_2    Q4  Q5_a  Q5_b  Q5_c  Q5_d    Q6    Q7    Q8
#>    <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1    71     6     1     4     2     4     9     5     8     7     4     7     3
#>  2    95     2     1     3     4     3     9     1     7     3     5     1     4
#>  3   102     1     6     4     2     3     9     4     5     8     4     4     4
#>  4   115     5     6     1     3     2     4     1     3     1     2     9     4
#>  5   132     2     3     4    NA     2     6     3     4     3     3     9     3
#>  6   134     2     3     4     3     2     6     3     4     3     3     9     3
#>  7   165     1    NA   100    NA    NA    NA    NA    NA    NA    NA    NA    NA
#>  8   189     6     5     1     2     2     8     3     8     6     3     7     4
#>  9   260     1     6     2     4   100     8     4     7    10    NA     7     3
#> 10   293     1     6     2     4     5     9     4     7     9     4     1     3
#> 11   298     1     6     1     2     3     8     5     6     6     3     4     3
#> 12   325     6     1     3     2     2     8     2   100     2     4     6     3
#> 13   355     1     2     4     2     3     4     2     1     1     5     9     4
#> 14   356     6     1     2     4     3     6     6     6     4     3     5     2
#> 15   363     6     2     4     1     3     6     3     3     5     5     1     4
#> # … with 106 more variables: Q9a <dbl>, Q9b <dbl>, Q10_a <dbl>, Q10_b <dbl>,
#> #   Q10_c <dbl>, Q10_c2 <dbl>, Q10_d <dbl>, Q10_e <dbl>, Q10_e2 <dbl>,
#> #   Q10_e3 <dbl>, Q10_f <dbl>, Q11a <dbl>, Q11b <dbl>, Q11c <dbl>, Q11d <dbl>,
#> #   Q12_a <dbl>, Q12_b <dbl>, Q12_c <dbl>, Q12_d <dbl>, Q12_e <dbl>,
#> #   Q12_e2 <dbl>, Q12_e3 <dbl>, Q12_f <dbl>, Q12_g <dbl>, Q13_g <dbl>,
#> #   Q13_f <dbl>, Q13_c <dbl>, Q13_a <dbl>, Q13_a1 <dbl>, Q13_b <dbl>,
#> #   Q13_b1 <dbl>, Q13_d <dbl>, Q13_e <dbl>, Q14a <dbl>, Q14b <dbl>, …
```

Let’s see how long it took one of these respodents to answer one of the
ISSP 2020 questions. For instance, we can look closer at Q7. Here it the
question wording:

Which environmental problem, if any, do you think is the most important
for Greece as a whole?

and the respondent has to choose one of the following options:

\[1\] “Air pollution”  
\[2\] “Chemicals and pesticides”  
\[3\] “Water shortage”  
\[4\] “Water pollution”  
\[5\] “Nuclear waste”  
\[6\] “Domestic waste disposal”  
\[7\] “Climate change”  
\[8\] “Genetically modified foods”  
\[9\] “Using up our natural resources”

\[10\] “None of these”  
\[11\] “Can’t choose”

How much time has one of these respondents spent on Q7?

``` r
issp2020 %>%
  filter(id==356) %>%
  select(Q7Time)
#> # A tibble: 1 × 1
#>   Q7Time
#>    <dbl>
#> 1   2.88
```

This is a very short time, not enough to read the question and all
answer options.

### Combining all methods

Now we can reveal the respondents who have failed to pass at least two
of the four quality checks we have applied:

``` r
issp2020 %>%
  mutate(flag_missing=flag_missing(., Q4:Q8, ratio=0.1)) %>%  
  mutate(flag_midpoints=flag_midpoints(., Q10_a:Q12_g, midpoint=3, ratio2=0.33)) %>%
  mutate(flag_straight=flag_straight(., Q13_g:Q13_e)) %>%
  mutate(flag_times=flag_times(., "http://www.datapopeu.gr/question-chars.csv", 0.2))%>%
  mutate(sum_flags = flag_missing+ flag_midpoints+ flag_straight+flag_times) %>%
  filter(sum_flags>1) %>%
  count()
#> # A tibble: 1 × 1
#>       n
#>   <int>
#> 1     6
```

## Acknowledgements

The research work was supported by the Hellenic Foundation for Research
and Innovation (H.F.R.I.) under the “First Call for H.F.R.I. Research
Projects to support Faculty members and Researchers and the procurement
of high-cost research equipment grant” (Project Number: 3572).

# References

<div id="refs" class="references csl-bib-body hanging-indent"
line-spacing="2">

<div id="ref-Andreadis2015h" class="csl-entry">

Andreadis, I. (2015a). Comparison of Response Times between Desktop and
Smartphone Users. In D. Toninelli, R. Pinter, & P. de Pedraza (Eds.),
*Mobile Research Methods: Opportunities and challenges of mobile
research methodologies* (pp. 63–79). Ubiquity Press.
<https://doi.org/10.5334/bar.e>

</div>

<div id="ref-Andreadis2015c" class="csl-entry">

Andreadis, I. (2015b). Web surveys optimized for smartphones: Are there
differences between computer and smartphone users? *Methods, Data,
Analysis*, *9*(2), 213–228. <https://doi.org/10.12758/mda.2015.012>

</div>

<div id="ref-Andreadis2012c" class="csl-entry">

Andreadis, I. (2012). To clean or not to clean? Improving the quality of
VAA data. *XXII World Congress of Political Science (IPSA)*.
<http://ikee.lib.auth.gr/record/132697/files/IPSA-2012.pdf>

</div>

<div id="ref-Andreadis2014" class="csl-entry">

Andreadis, I. (2014). Data Quality and Data Cleaning. In D. Garzia & S.
Marschall (Eds.), *Matching Voters with Parties and Candidates. Voting
Advice Applications in Comparative Perspective* (pp. 79–91). ECPR Press.
<http://www.polres.gr/en/sites/default/files/VAA-Book-Ch6.pdf>

</div>

<div id="ref-Andreadis2021" class="csl-entry">

Andreadis, I. (2021). Web Survey Response Times What to Do and What Not
to Do. *Proceedings of the 2021 Joint Statistical Meetings*.

</div>

</div>
