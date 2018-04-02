defmodule Tournament do
  alias __MODULE__.Impl

  @moduledoc """
  Documentation for Tournament.
  """

  @doc """
  Hello world.

  ## Examples

  """
  defdelegate add_ballot(tournament, ballot), to: Impl
  defdelegate add_ballots(tournament, ballots), to: Impl
  defdelegate add_conflict(tournament, conflict), to: Impl
  defdelegate add_pairings(tournament, pairings, opts), to: Impl
  defdelegate add_team(tournament, team), to: Impl
  defdelegate add_teams(tournament, teams), to: Impl
  defdelegate ballots(tournament), to: Impl
  defdelegate ballots(tournament, opts), to: Impl
  defdelegate start(opts), to: Impl
  defdelegate pairings(tournament, opts), to: Impl
  defdelegate random_pairings(tournament), to: Impl
  defdelegate ranked_teams(tournament, opts), to: Impl
  defdelegate seed(tournament, opts), to: Impl
  defdelegate team_rankings(tournament, opts), to: Impl
  defdelegate with_rankings(rankings), to: Impl
end
