# League of Legends Reporter (LoLR)

For a given summoner name and region, the LoLR server fetches and returns the
names of all summoners the given summoner has played with in the last 5 matches.

There is no up-front limit on the number of summoner "flights" (groups of
summoners connected to the given summoner in the request), but the rate limit
for a particular Riot Developer account _will_ constrain the number of flights.

Additionally, the games of the given summoner will be monitored for new matches
every minute for the following hour, with the `match_id` of any said matches
logging to the console.

## Monitoring a Summoner

- Export your riot api key as `RIOT_API_KEY`
- From the root project directory, start the server with `mix deps.get; mix phx.server`
- To start reporting, hit the endpoint: `localhost:4000/api/start/:region/:summoner`

  - `region` is one of

        ["BR1", "EUN1", "EUW1", "JP1", "KR", "LA1", "LA2", "NA1", "OC1", "RU", "TR1"]

  - `summoner` is the summoner name (not your login)

## NOTES

I initialized the project with the following command:

    mix phx.new lolr --no-ecto --no-html --no-mailer --no-assets --no-live --no-dashboard

The scope of the project didn't necessitate a database or serving any html,
live or otherwise, so I started with a pretty scant generated project. I used
Phoenix because I knew I'd use an http endpoint as the human interface, and it
sets the project up for that nicely.

There were a number of approaches I could have taken with the project that would
have been lighter (e.g. a centralized GenServer running a generic timer,
managing an Agent for each summoner flight). I opted to utilize a heavier
architecture, where each flight has a dedicated GenServer with its own timer in
order to deliver, as closely as possible, summoner reports on the minute mark
from the respective original requests.
