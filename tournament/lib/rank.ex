defmodule Rank do
  alias __MODULE__.Impl

  defdelegate find(ranks, opts), to: Impl
  defdelegate filter(ranks, opts), to: Impl
  defdelegate format(rank, opts), to: Impl
  defdelegate from_ballot(ballot), to: Impl
  defdelegate from_ballots(ballots), to: Impl
  defdelegate get(rank, property), to: Impl
  defdelegate new(opts), to: Impl
  defdelegate match?(rank1, rank2), to: Impl
  defdelegate rankings(ranks), to: Impl
  defdelegate rankings(ranks, opts), to: Impl
  defdelegate totals(ranks), to: Impl
end
