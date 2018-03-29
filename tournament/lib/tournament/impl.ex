defmodule Tournament.Impl do
  defstruct name: nil, conflicts: [], pairings: [], ballots: []
  def new(opts), do: struct(__MODULE__, opts)

  def add_conflict(tournament, conflict) do
    %{tournament | conflicts: [conflict | tournament.conflicts]}
  end

  def resolve_conflicts(tournament, rankings, pairings) do
    conflict = Enum.find(pairings, &conflict?(tournament, &1))

    do_resolve_conflicts(
      tournament,
      rankings,
      pairings,
      conflict,
      down: 1,
      up: 1,
      down: 2,
      up: 2,
      down: 3,
      up: 3,
      down: 4,
      up: 4
    )
  end

  def do_resolve_conflicts(_tournament, _rankings, pairings, _pairing, []) do
    pairings
  end

  def do_resolve_conflicts(tournament, rankings, pairings, pairing, [{direction, distance} | rest]) do
    if conflicts?(tournament, pairings) do
      team = team_to_swap(pairing, rankings, direction)
      new_pairings = swap_team(team, pairings, {direction, distance})

      if conflicts?(tournament, new_pairings) do
        do_resolve_conflicts(tournament, rankings, pairings, pairing, rest)
      else
        new_pairings
      end
    else
      pairings
    end
  end

  def add_pairing(tournament, pairing) do
    %{tournament | pairings: [pairing | tournament.pairings]}
  end

  def swap_team(_pairing, pairings, _rankings, []), do: pairings

  def swap_team(team, pairings, {direction, distance}) do
    pairings
    |> split_sides()
    |> do_swap_team(team, {direction, distance})
    |> zip_sides()
  end

  defp split_sides(pairings) do
    [prosecution_teams(pairings), defense_teams(pairings)]
  end

  defp do_swap_team([prosecution_teams, defense_teams], team, {direction, distance}) do
    cond do
      team in prosecution_teams ->
        [do_swap(prosecution_teams, team, {direction, distance}), defense_teams]

      team in defense_teams ->
        [prosecution_teams, do_swap(defense_teams, team, {direction, distance})]

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

  defp do_swap(teams, team, {:up, distance}) do
    index = Enum.find_index(teams, &(&1 == team))
    sub_index = index - distance

    if sub_index < 0 do
      teams
    else
      list = List.delete_at(teams, index)
      {sub, list} = List.pop_at(list, index - distance)
      list = List.insert_at(list, index - distance, team)
      List.insert_at(list, index, sub)
    end
  end

  defp do_swap(teams, team, {:down, distance}) do
    index = Enum.find_index(teams, &(&1 == team))
    sub_index = index + distance

    if sub_index >= length(teams) do
      teams
    else
      {sub, list} = List.pop_at(teams, index + distance)
      list = List.delete_at(list, index)
      list = List.insert_at(list, index, sub)
      List.insert_at(list, index + distance, team)
    end
  end

  def conflicts?(tournament, pairings) do
    pairings
    |> Enum.any?(&conflict?(tournament, &1))
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

  defp team_to_swap(pairing, rankings, :up) do
    higher_ranked_team(pairing, rankings)
  end

  defp team_to_swap(pairing, rankings, :down) do
    lower_ranked_team(pairing, rankings)
  end

  def higher_ranked_team({prosecution, defense}, rankings) do
    prosecution_index = Enum.find_index(rankings, &(&1 == prosecution))
    defense_index = Enum.find_index(rankings, &(&1 == defense))

    if prosecution_index < defense_index do
      prosecution
    else
      defense
    end
  end

  def lower_ranked_team({prosecution, defense}, rankings) do
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
