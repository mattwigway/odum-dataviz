# First, we will load the R "packages" we will use for data manipulation and viewing.
# The tidyverse package includes data manipulation tools as well as the ggplot plotting
# package. The ggthemes library includes "themes" for ggplot that are color-blind friendly.
library(tidyverse)
library(ggthemes)

# Next, we will make a line plot. Line plots are useful for showing trends over time. We are
# going to use data on the unemployment rate and interest rate from the Federal Reserve. The
# data are in a CSV (comma-separated values) format file, a common data format. The here::here
# syntax tells R to look for the file in the same folder as this R script.
unemp = read_csv("unemployment_and_interest.csv")

# We can take a look at what these data look like
head(unemp)

# Making a line plot

# We'll start by making a line plot of unemployment. We will use the ggplot "function". 
# gg stands for "grammar of graphics" which is a formal way to represent plotting and plot
# elements. We give it our data, and then use aesthetics (aes()) to map aspects of that data
# onto aspects of the plot. We then add geoms which are the actual graphical elements.
ggplot(unemp, aes(x=date, y=unemployment)) +
    geom_line()

# Does the plot look how you would expect?

# The "grammar of graphics" makes it easy to change different plot
# elements. For example, we could make this into a scatterplot
# by changing geom_line to geom_point (though a line graph arguably
# makes more sense for this data). We could plot interest rate instead
# of unemployment by just changing unemplotment to interest in the
# code above.
# Exercise: try making both of these changes

# Plotting multiple lines on the same axes

# Often you will want to plot multiple lines on the same axes, to compare them.
# ggplot will map one column only onto the y axis, so in order to make a plot like
# this we need to put all the values we want to plot into one column. Our data are
# currently in "wide" format—there is one row per month, and separate columns for
# unemployment and interest rate. We will convert it to a "long" format, with two rows
# per month: one for unemployment and one for interest rate, and another column to tell
# which is which.
unemp_long = pivot_longer(unemp, all_of(c("unemployment", "interest")))
head(unemp_long)

# Now, we can plot again, mapping the "value" column to the y axis, and adding a new
# aesthetic, color, to differentiate unemployment and interest rate.
ggplot(unemp_long, aes(x=date, y=value, color=name)) +
    geom_line() +
    scale_color_colorblind() # This tells ggplot to use colorblind-safe color schemes

## Scatter plots

# Both economic theory and the graph above suggest that there is a negative correlation
# between unemployment and interest rates. A scatter plot is another way to show this.
# Now, instead of representing time at all, we will put unemployment on the x axis and interest
# rate on the y axis. We need to use our original "wide" data for this, as we need unemployment
# and interest in separate columns so we can map them to different aspects of the chart.
ggplot(unemp, aes(x=unemployment, y=interest)) +
    geom_point()

# There doesn't seem to be much of a relationship here. This is why multiple charts are often
# a good idea. For instance, it might be that we don't see a relationship because unemployment
# and interest rates were both relatively high in the 1980s. Here, I am adding a decade variable
# by rounding the year to three significant digits.
unemp$decade = signif(year(unemp$date), 3)

# and then coloring the points by decade
ggplot(unemp, aes(x=unemployment, y=interest, color=factor(decade))) +
    geom_point() +
    scale_color_colorblind()

# Does this plot tell a different story?

## Bar plots and box plots
# Line plots work best with time series data, and scatter plots work best with continuous data
# (i.e. data that can take on any value, or any value within some range). Bar plots are generally
# used with categorical data, and box plots are often used when comparing categorical and
# continuous data. For this, we will be using data from the COVID Future survey, which was
# a large survey that took place during the COVID-19 pandemic focusing on transportation but
# covering a large variety of topics.
covid = read_csv("covidfuture.csv")

# The main categorical variable we will work with is att_covid_selfsevere, which are 
# Likert-scaled responses to the question "If I catch the coronavirus, I am concerned
# that I will have a severe reaction"
# This is an ordered variable, but R doesn't know the ordering, so here I am telling
# it what the ordering is. This way when plotting our plots will have the right order
# on the axes.
covid = covid |>
    mutate(
        att_covid_selfsevere = factor(att_covid_selfsevere, ordered=T, levels=c(
            "Seen but unanswered",
            "Strongly disagree",
            "Somewhat disagree",
            "Neutral",
            "Somewhat agree",
            "Strongly agree"
        ))
    )


# First, we will make a bar plot of the frequency of responses to this question. A barplot
# uses the geom_bar geom, which does not require a y axis; the y axis will be the count of
# responses in each category. If you instead had data where you had a value you wanted to
# put on the y axis (for instance, if you were working with aggregate data where you had one
# row for each response, and a count of respondents), you could use geom_col with a y aesthetic.

# The only other thing that may look unfamiliar here is the weight aesthetic. Like many
# large surveys, the COVID Future survey is weighted to correct for sampling bias - so one
# respondent might count for more or less than one, depending on whether their demographic
# group is over or underrepresented. Adding the weight aesthetic tells ggplot to account for
# this. Not all geoms support weighting, but the ones we're using here do.
ggplot(covid, aes(x=att_covid_selfsevere, weight=weight_main)) +
    geom_bar()

# A good early step in any continuous data visualization is to make histograms to understand
# what the distributions of your variables are. That is what we are doing here.
ggplot(covid, aes(x=age, weight=weight_main)) +
    geom_histogram()

# Boxplots are useful for looking at continuous data, similar to histograms, but they
# are especially useful to replace scatterplot when looking for correlations between
# a continuous and a categorical variable. This code will create separate boxplots
# for the age of respondents for each different level of response to the COVID concern
# question.
ggplot(covid, aes(x=att_covid_selfsevere, y=age, weight=weight_main)) +
    geom_boxplot()

# Does concern about COVID-19 severity vary by age?

# Changing the labels

# There are a lot of ways you can customize your visualizations to make them publication-
# quality. The most common thing you'll want to do is change the labels. xlab() and ylab()
# change the x and y labels. If you want to change the legend label you would use the labs()
# function with the name of the aesthetic you want to change the label for. Lastly, to change
# the labels for values coming from your data (e.g. the interest/unemployment) I find it's
# easiest to just modify the original data. We'll re-make our double-line plot to demonstrate
# this.

# The |> is the "pipe" operator. Whatever is to the left of it effectively
# becomes the first argument to whatever is to the right of it. Here I 
# am using the mutate function to change the capitalization of the name field
# and then sending the result right into ggplot without saving it anywhere
# else. This will not affect the original data.
unemp_long |>
    # str_to_title wil capitalize the values in the name field
    mutate(name=str_to_title(name)) |>
    ggplot(aes(x=date, y=value, color=name)) +
        geom_line() +
        scale_color_colorblind() +
        xlab("Date (by month)") +
        ylab("Percentage") +
        labs(color="Statistic")

# Saving your plots
# You will often want to export your plots to a file so you can import them into Word,
# etc. The ggsave function does that. Here, I am exporting the most recent plot to a file
# called interest_unemployment.png. I am telling ggplot I want the plot to be formatted to
# be shown 8 inches wide by 6 inches high, with 300 pixels per inch, and on a white background.
# You can of course scale the plot later in Word/Powerpoint/etc, so the numbers you put
# here are not set in stone. I usually just adjust them until I get the plot to look
# readable at the size I want; decreasing the width or height will make the text relatively
# larger.
ggsave("interest_unemployment.png", width=8, height=6, dpi=300, bg="white")
