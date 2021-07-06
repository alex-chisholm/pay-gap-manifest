# UK organisation pay gap

UK organisation pay gap Shiny application to show mean and median in terms of date where equal pay stops.

This was inspired by a [2018 Guardian article](https://www.theguardian.com/news/ng-interactive/2018/apr/04/gender-pay-gap-when-does-your-company-stop-paying-women-in-2018) using the formula detailed in this [page](http://www.equalpay.wiki/Berechnung_des_Equal_Pay_Day) to find the last day of equal pay. Note the original language is German for this page.

### Shiny app

The shiny app was created for the Gender Identity, Gender and Sexual Orientation group at [Nottinghamshire Healthcare NHS Foundation Trust](https://www.nottinghamshirehealthcare.nhs.uk/) and is hosted on the RStudio server [here](https://involve.nottshc.nhs.uk:8443/pay-gap/).

### Data 2020/21

The data is loaded for this app to run and can be updated from the [UK Government site](https://gender-pay-gap.service.gov.uk/viewing/download-data/2020):

```{r}
# load data ---------------------------
url <- "https://gender-pay-gap.service.gov.uk/viewing/download-data/2020"
download.file(url, dest = "pay-gap-202021.csv")
```
