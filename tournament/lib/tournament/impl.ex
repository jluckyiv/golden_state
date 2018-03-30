defmodule Tournament.Impl do
  defstruct name: nil, conflicts: [], pairings: [], ballots: []
  def new(opts), do: struct(__MODULE__, opts)

  def add_conflict(tournament, conflict) do
    %{tournament | conflicts: [conflict | tournament.conflicts]}
  end

  def add_pairing(tournament, pairing) do
    %{tournament | pairings: [pairing | tournament.pairings]}
  end

  def ballots(tournament), do: tournament.ballots

  def coin_flip() do
    Enum.random([:prosecution, :defense])
  end

  def seed_round1(teams, requests \\ []) do
    teams
    |> Enum.shuffle()
    |> seed_special_requests(requests)
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  def seed_round2(rankings, round1) do
    seed_even_round(rankings, round1)
  end

  def seed_round3(rankings) do
    seed_round3(rankings, coin_flip())
  end

  def seed_round3(rankings, :prosecution) do
    rankings
    |> seed_round3(:defense)
    |> Enum.map(&reverse_pairing/1)
  end

  def seed_round3(rankings, :defense) do
    rankings
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map_every(2, &reverse_pairing/1)
  end

  def seed_round4(rankings, round3) do
    seed_even_round(rankings, round3)
  end

  def with_rankings(rankings) do
    Enum.with_index(rankings, 1)
  end

  defp reverse_pairing({prosecution, defense}) do
    {defense, prosecution}
  end

  defp seed_even_round(rankings, previous_round) do
    rankings
    |> Enum.split_with(&was_defense?(&1, previous_round))
    |> Tuple.to_list()
    |> Enum.zip()
  end

  defp seed_special_requests(teams, []) do
    teams
  end

  defp seed_special_requests(teams, [{:prosecution, team} | rest]) do
    teams
    |> List.delete(team)
    |> List.insert_at(0, team)
    |> seed_special_requests(rest)
  end

  defp seed_special_requests(teams, [{:defense, team} | rest]) do
    teams
    |> List.delete(team)
    |> List.insert_at(1, team)
    |> seed_special_requests(rest)
  end

  defp was_defense?(team, previous_round) do
    Enum.any?(previous_round, fn {_p, d} -> team == d end)
  end
end
