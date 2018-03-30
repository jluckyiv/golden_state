defmodule Tournament.Conflict.Impl do
  def conflict?(tournament, pairing) do
    has_conflict?(tournament.conflicts, pairing) or has_pairing?(tournament.pairings, pairing)
  end

  def conflicts?(tournament, pairings) do
    pairings
    |> Enum.any?(&conflict?(tournament, &1))
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

  defp defense_teams(pairings) do
    Enum.map(pairings, fn {_p, defense} -> defense end)
  end

  defp do_resolve_conflicts(_tournament, _rankings, pairings, _pairing, []) do
    pairings
  end

  defp do_resolve_conflicts(tournament, rankings, pairings, pairing, [
         {direction, distance} | rest
       ]) do
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

  defp has_conflict?(conflicts, {prosecution, defense}) do
    Enum.any?(conflicts, &(&1 == {prosecution, defense})) or
      Enum.any?(conflicts, &(&1 == {defense, prosecution}))
  end

  defp has_pairing?(pairings, {prosecution, defense}) do
    Enum.any?(pairings, &(&1 == {prosecution, defense})) or
      Enum.any?(pairings, &(&1 == {defense, prosecution}))
  end

  defp higher_ranked_team({prosecution, defense}, rankings) do
    prosecution_index = Enum.find_index(rankings, &(&1 == prosecution))
    defense_index = Enum.find_index(rankings, &(&1 == defense))

    if prosecution_index < defense_index do
      prosecution
    else
      defense
    end
  end

  defp lower_ranked_team({prosecution, defense}, rankings) do
    prosecution_index = Enum.find_index(rankings, &(&1 == prosecution))
    defense_index = Enum.find_index(rankings, &(&1 == defense))

    if prosecution_index > defense_index do
      prosecution
    else
      defense
    end
  end

  defp prosecution_teams(pairings) do
    Enum.map(pairings, fn {prosecution, _d} -> prosecution end)
  end

  defp split_sides(pairings) do
    [prosecution_teams(pairings), defense_teams(pairings)]
  end

  defp swap_team(team, pairings, {direction, distance}) do
    pairings
    |> split_sides()
    |> do_swap_team(team, {direction, distance})
    |> zip_sides()
  end

  defp team_to_swap(pairing, rankings, :up) do
    higher_ranked_team(pairing, rankings)
  end

  defp team_to_swap(pairing, rankings, :down) do
    lower_ranked_team(pairing, rankings)
  end

  defp zip_sides([prosecution_teams, defense_teams]) do
    [prosecution_teams, defense_teams]
    |> Enum.zip()
  end
end
