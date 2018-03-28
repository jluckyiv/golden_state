defmodule BallotList do
  alias __MODULE__.Impl

  defdelegate ballots_won(ballots, team), to: Impl
  defdelegate closing_score(ballots, team), to: Impl
  defdelegate combined_strength(ballots, team), to: Impl
  defdelegate filter(ballots, opts), to: Impl
  defdelegate motion_score(ballots, team), to: Impl
  defdelegate opponents(ballots, team), to: Impl
  defdelegate point_differential(ballots, team), to: Impl
end
