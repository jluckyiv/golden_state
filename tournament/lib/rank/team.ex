defmodule Rank.Team do
  alias __MODULE__.Impl

  defdelegate ranking(ballots, team), to: Impl
  defdelegate rankings(ballots), to: Impl
  defdelegate rankings(ballots, opts), to: Impl
  defdelegate final_ranking(ballots, team), to: Impl
  defdelegate final_rankings(ballots), to: Impl
end
