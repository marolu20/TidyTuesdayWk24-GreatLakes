# TidyTuesdayWk24-GreatLakes

This is a group project presented by Siqi Li, Mariam Olupitan, Caroline Valade and Joshua Allard from DSBA5122 Class taught by Prof. Jinwen Qiu in Summer 2021 at UNCC.

Our main objective was to build an application that could identify which species and what type of fish needed to be restocked in which areas of the Great Lakes.

Below is the link to R-Shiny-Dashboard (Some data was not available for display.)

https://marolu21.shinyapps.io/GreatLakes_Stocked/

# Problem
We sought to solve the problem of identifying which species need to be stocked in which areas, based on data of stocked fish from previous years. With the target user being a member of the US Fish and Wildlife services, or an aquaculture farmer that grows the fish that are used to restock the Great Lakes. 

# Solution 
By providing data visualizations for information on the weight, age, and condition of fish previously stocked, this could help the farmers know which type of fish have been needed in the past and which may be needed to be stocked in the future, in addition to the number of fish needed for each species in eachlocation.

# Data Preprocessing

Once we had downloaded the stocked.csv from the #tidytuesday github repository, we
uploaded the file into an Rstudio project and loaded the data into a dataframe in our project. Our
next step was to view the data and explore the distribution of the variables to gain a better
understanding of what cleansing needed to be done and what variables would be most beneficial
to use in our R Shiny application. From this analysis, we decided to keep only 'YEAR',
'MONTH', 'DAY', 'LAKE', 'STATE_PROV', 'SPECIES', 'NO_STOCKED', 'AGEMONTH',
'WEIGHT', 'CONDITION', and 'STAGE' from the stocked.csv, and left out all other columns
from the file when adding to our dataframe. We found that there were a lot of missing values for
the columns month, day, and condition, so we replaced those values by inputting the median
value for each of the columns and substituting any missing values with those medians. There
were also some values for ‘DAY’ that were recorded as 0, which isn’t logical as days of the
month can be values of 1-31, so we replaced any instances where ‘DAY’ = 0 to be ‘DAY’= 1,
instead. Finally we changed the data variable type for condition from numeric to a dummy
variable, and changed species and lake names to abbreviations4.

