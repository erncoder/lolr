ExUnit.start()
MockMe.start()

shared_resps = [
  %MockMe.Response{
    flag: :empty,
    body: [],
    status_code: 200
  },
  %MockMe.Response{
    flag: :not_found,
    body: "resource not found",
    status_code: 404
  },
  %MockMe.Response{
    flag: :rate_limited,
    body: "rate limited",
    status_code: 429
  },
  %MockMe.Response{
    flag: :unauthorized,
    body: "unauthorized",
    status_code: 403
  }
]

routes = [
  %MockMe.Route{
    name: :fetch_summoner,
    path: ":region/summoner/v4/summoners/by-name/:name",
    responses:
      shared_resps ++
        [
          %MockMe.Response{
            flag: :success,
            body: Test.Mocks.RiotApi.summoner(),
            status_code: 200
          }
        ]
  },
  %MockMe.Route{
    name: :match_list,
    path: ":region/match/v5/matches/by-puuid/:puuid/ids",
    responses:
      shared_resps ++
        [
          %MockMe.Response{
            flag: :success,
            body: Test.Mocks.RiotApi.match_list(),
            status_code: 200
          }
        ]
  },
  %MockMe.Route{
    name: :match_details,
    path: ":region/match/v5/matches/by-puuid/:puuid/ids",
    responses:
      shared_resps ++
        [
          %MockMe.Response{
            flag: :success,
            body: Test.Mocks.RiotApi.match_details(),
            status_code: 200
          }
        ]
  }
]

MockMe.add_routes(routes)
MockMe.start_server()
