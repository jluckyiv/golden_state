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
  defdelegate conflict?(tournament, pairing), to: Impl
  defdelegate conflicts?(tournament, pairings), to: Impl
  defdelegate head_to_head?(tournament, pairing), to: Impl
  defdelegate lower_ranked_team(rankings, pairing), to: Impl
  defdelegate new(opts), to: Impl
  defdelegate resolve_conflicts(tournament, rankings, pairings), to: Impl
  defdelegate seed_round1(teams), to: Impl
  defdelegate seed_round1(teams, requests), to: Impl
  defdelegate seed_round2(rankings, round1), to: Impl
  defdelegate seed_round3(rankings), to: Impl
  defdelegate seed_round3(rankings, side), to: Impl
  defdelegate seed_round4(rankings, round3), to: Impl
  defdelegate swap_team(team, pairings, direction, distance), to: Impl
  defdelegate with_rankings(rankings), to: Impl
end
