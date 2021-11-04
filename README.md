# League of Legends Reporter (LoLR)

For a given summoner name and region, fetches and returns the names of all
summoners the given summoner has played with in the last 5 matches.

Additionally, the games of the given summoner will be monitored for new matches
every minute for the following hour, with the `match_id` of any said matches
logging to the console.

## Setup

### Inside IEx Shell

- Start
  Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Using compiled binary

- Start

## Monitoring a Summoner

To being monitoring a summoner, you may either call the `ENDPOINT HERE` endpoint,
or

## NOTES

I initialized the project with the following command:

    mix phx.new lolr --no-ecto --no-html --no-mailer --no-assets --no-live --no-dashboard

The scope of the project didn't necessitate a database or Ecto FINISH THIS

phx has a lot out of the box, even if we don't use all
