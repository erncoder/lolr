defmodule Lolr.Models.Summoner do
  @moduledoc """
  Struct for a Summoner
  """

  @req_fields [:name, :puuid, :last_matches]
  defstruct @req_fields
end
