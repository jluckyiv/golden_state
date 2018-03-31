defmodule Tournament do
  alias __MODULE__.Impl

  @moduledoc """
  Documentation for Tournament.
  """

  @doc """
  Hello world.

  ## Examples

  """
  defdelegate add_conflict(tournament, conflict), to: Impl
  defdelegate add_pairing(tournament, conflict), to: Impl
  defdelegate ballots(tournament), to: Impl
  defdelegate new(opts), to: Impl
  defdelegate seed_round1(teams), to: Impl
  defdelegate seed_round1(teams, requests), to: Impl
  defdelegate seed_round2(rankings, round1), to: Impl
  defdelegate seed_round3(rankings), to: Impl
  defdelegate seed_round3(rankings, side), to: Impl
  defdelegate seed_round4(rankings, round3), to: Impl
  defdelegate with_rankings(rankings), to: Impl
end
