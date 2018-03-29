defmodule BallotList do
  alias __MODULE__.Impl

  defdelegate filter(ballots, opts), to: Impl
  defdelegate total(ballots, team, fun), to: Impl
end
