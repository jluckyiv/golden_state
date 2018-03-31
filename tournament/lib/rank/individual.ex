defmodule Rank.Individual do
  alias __MODULE__.Impl

  defdelegate add(rank1, rank2), to: Impl
  defdelegate find(ranks, opts), to: Impl
  defdelegate filter(ranks, opts), to: Impl
  defdelegate format(rank, opts), to: Impl
  defdelegate from_ballot(ballot), to: Impl
  defdelegate from_ballots(ballots), to: Impl
  defdelegate get(rank, property), to: Impl
  defdelegate new(opts), to: Impl
  defdelegate match?(rank1, rank2), to: Impl
  defdelegate score(rank), to: Impl
  defdelegate totals(ranks), to: Impl
end
