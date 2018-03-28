defmodule Ranking do
  alias __MODULE__.Impl

  defdelegate rankings(teams, ballots), to: Impl
  defdelegate final_rankings(teams, ballots), to: Impl
end
