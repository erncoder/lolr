defmodule Test.Mocks.RiotApi do
  @moduledoc false

  def summoner() do
    %{
      "name" => Faker.Superhero.name(),
      "puuid" => Faker.UUID.v4()
    }
  end

  def match_list() do
    Enum.map(1..5, fn _n -> "REG-#{Faker.UUID.v4()}" end)
  end

  def match_details() do
    %{"info" => %{"participants" => gen_participants()}}
  end

  def gen_participants() do
    Enum.map(1..5, fn _n ->
      %{
        "summonerName" => Faker.Superhero.name(),
        "puuid" => Faker.UUID.v4()
      }
    end)
  end
end
