# UK organisation pay gap

UK organisation pay gap Shiny application to show mean and median in terms of date where equal pay stops.

This was inspired by a [2018 Guardian article](https://www.theguardian.com/news/ng-interactive/2018/apr/04/gender-pay-gap-when-does-your-company-stop-paying-women-in-2018) using the formula detailed in the [Equal Pay Wiki page](http://www.equalpay.wiki/Berechnung_des_Equal_Pay_Day) to find the last day of equal pay. Note the original language is German for this page.

Nottinghamshire Healthcare NHS Trust (amongst others) now has a negative percentage for the median so this app now shows how that translates to men's last day of equal pay. 

Where an organisation has greater than -100% difference, this has been changed to -100% (or a full year) for the purposes of showing the difference by calendar day.

### Data

The data is loaded for this app to run and can be updated from the [UK Government site](https://gender-pay-gap.service.gov.uk/viewing/download-data/2020):

```{r}
# load data ---------------------------
url <- "https://gender-pay-gap.service.gov.uk/viewing/download-data/2020"
download.file(url, dest = "pay-gap-202021.csv")
```
```{r}
# load data ---------------------------
url <- "https://gender-pay-gap.service.gov.uk/viewing/download-data/2022"
download.file(url, dest = "pay-gap-202223.csv")
```