# BizTrackBI
I will to this repo when I find an interesting SQL query I enjoyed building.

These were targeted for our systems so watch out for the branch_id
If the branch_id doesn't work set branch_id = 0 

## CreditCard
We used this to find out what types of cards our customers were using and more importantly how they were using it. Depending on how it was ran we can find out what they transaction fees are this way. The CASE statements are so that when moved into Excel it was easier for our Excel pivot chart.

## LastTransactionDate
This is built to help find stock that has not been moving. 
You will need to add a filter in the Biztrack system called "LastTransactionDate" and that will allow you to filter down your results

## YTDvsLY
Is a simple current year data vs last year data of the same time frame. This is meant to see how things are currently going this year as compared to last year. 
Make sure to add a filter for "FromDate" and "ToDate".
This one is a bit dated since we added more to it. We did edit it to work as a Dashboard table. One for YTD and one for LY.
