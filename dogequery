# set https://coinmarketcap.com/api/ API key
$ApiKey = "API KEY HERE"

# heavy lifting
$headers = @{"X-CMC_PRO_API_KEY"=$ApiKey;"Content-Type"="application/json"}
$uri = "https://pro-api.coinmarketcap.com/v2/cryptocurrency/quotes/latest?id=74"
$result = Invoke-RestMethod -Uri $uri -Method GET -headers $headers


# run an infinite loop for retrieving dogecoin price every 10 minutes 
    while(1)
{
   (($result.data.74).quote).usd.price
   start-sleep -seconds 600
}
