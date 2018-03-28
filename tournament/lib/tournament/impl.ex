defmodule Tournament.Impl do
  defstruct name: nil, conflicts: [], pairings: [], ballots: []
  def new(name), do: %__MODULE__{name: name}

  def add_conflict(tournament, conflict) do
    %{tournament | conflicts: [conflict | tournament.conflicts]}
  end

  def add_pairing(tournament, pairing) do
    %{tournament | pairings: [pairing | tournament.pairings]}
  end

  def swap_team(pairings, team, direction) do
    pairings
    |> split_sides()
    |> do_swap_team(team, direction)
    |> zip_sides()
  end

  defp split_sides(pairings) do
    [prosecution_teams(pairings), defense_teams(pairings)]
  end

  defp do_swap_team([prosecution_teams, defense_teams], team, direction) do
    cond do
      team in prosecution_teams ->
        [do_swap(prosecution_teams, team, direction), defense_teams]

      team in defense_teams ->
        [prosecution_teams, do_swap(defense_teams, team, direction)]

      true ->
        [prosecution_teams, defense_teams]
    end
  end

  defp prosecution_teams(pairings) do
    Enum.map(pairings, fn {prosecution, _d} -> prosecution end)
  end

  defp defense_teams(pairings) do
    Enum.map(pairings, fn {_p, defense} -> defense end)
  end

  defp zip_sides([prosecution_teams, defense_teams]) do
    [prosecution_teams, defense_teams]
    |> Enum.zip()
  end

  defp do_swap([], _team, _direction), do: []

  defp do_swap([team, next_team | tail], team, :down) do
    [next_team, team | tail]
  end

  defp do_swap([previous_team, team | tail], team, :up) do
    [team, previous_team | tail]
  end

  defp do_swap([another_team | tail], team, direction) do
    [another_team | do_swap(tail, team, direction)]
  end

  def conflict?(tournament, pairing) do
    has_conflict?(tournament.conflicts, pairing) or has_pairing?(tournament.pairings, pairing)
  end

  def head_to_head?(tournament, pairing) do
    has_pairing?(tournament.pairings, pairing)
  end

  defp has_conflict?(conflicts, {prosecution, defense}) do
    Enum.any?(conflicts, &(&1 == {prosecution, defense})) or
      Enum.any?(conflicts, &(&1 == {defense, prosecution}))
  end

  defp has_pairing?(pairings, {prosecution, defense}) do
    Enum.any?(pairings, &(&1 == {prosecution, defense})) or
      Enum.any?(pairings, &(&1 == {defense, prosecution}))
  end

  def lower_ranked_team(rankings, {prosecution, defense}) do
    prosecution_index = Enum.find_index(rankings, &(&1 == prosecution))
    defense_index = Enum.find_index(rankings, &(&1 == defense))

    if prosecution_index > defense_index do
      prosecution
    else
      defense
    end
  end

  def seed_round1(teams, requests \\ []) do
    teams
    |> Enum.shuffle()
    |> seed_special_requests(requests)
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
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

  defp reverse_pairing({prosecution, defense}) do
    {defense, prosecution}
  end

  def seed_round4(rankings, round3) do
    seed_even_round(rankings, round3)
  end

  defp seed_even_round(rankings, previous_round) do
    rankings
    |> Enum.split_with(&was_defense?(&1, previous_round))
    |> Tuple.to_list()
    |> Enum.zip()
  end

  def with_rankings(rankings) do
    Enum.with_index(rankings, 1)
  end

  def coin_flip() do
    Enum.random([:prosecution, :defense])
  end

  defp was_defense?(team, previous_round) do
    Enum.any?(previous_round, fn {_p, d} -> team == d end)
  end
end
