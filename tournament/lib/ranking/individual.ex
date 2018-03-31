defmodule Ranking.Individual do
  alias __MODULE__.Impl

  defdelegate ranking(ballots, opts), to: Impl
  defdelegate rankings(ballots, opts), to: Impl
end
