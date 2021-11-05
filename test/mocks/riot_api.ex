defmodule Test.Mocks.RiotApi do
  @moduledoc false

  def summoner() do
    %{
      "name" => Faker.Superhero.name(),
      "puuid" => Faker.UUID.v4()
    }
    |> Jason.encode!()
  end

  def match_list() do
    1..5
    |> Enum.map(fn _n -> "REG-#{Faker.UUID.v4()}" end)
    |> Jason.encode!()
  end

  def match_details() do
    %{"info" => %{"participants" => gen_participants()}} |> Jason.encode!()
  end

  def gen_participants() do
    Enum.map(1..10, fn _n ->
      %{
        "summonerName" => Faker.Superhero.name(),
        "puuid" => Faker.UUID.v4()
      }
    end)
  end
end
