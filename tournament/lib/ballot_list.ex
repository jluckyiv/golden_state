defmodule BallotList do
  alias __MODULE__.Impl

  defdelegate filter(ballots, opts), to: Impl
  defdelegate teams(ballots), to: Impl
  defdelegate total(ballots, opts), to: Impl
end
