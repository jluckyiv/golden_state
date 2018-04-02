defmodule Tournament.Conflict.Impl do
  def conflict?(conflicts, {prosecution, defense}) do
    Enum.any?(conflicts, &(&1 == {prosecution, defense})) or
      Enum.any?(conflicts, &(&1 == {defense, prosecution}))
  end

  def conflicts?(conflicts, pairings) do
    Enum.any?(pairings, &conflict?(conflicts, &1))
  end

  def find_conflict(conflicts, pairings) do
    Enum.find(pairings, &conflict?(conflicts, &1))
  end

  def resolve_conflicts(conflicts, pairings, rankings) do
    if conflict = find_conflict(conflicts, pairings) do
      do_resolve_conflicts(
        conflicts,
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
    else
      IO.puts("Conflicts resolved.")
      pairings
    end
  end

  defp do_resolve_conflicts(conflicts, rankings, pairings, conflict, [
         {direction, distance} | rest
       ]) do
    resolved_pairings =
      conflict
      |> team_to_swap(rankings, direction)
      |> swap_team(pairings, {direction, distance})

    cond do
      resolved_pairings == pairings ->
        do_resolve_conflicts(conflicts, rankings, pairings, conflict, rest)

      conflicts?(conflicts, new_pairings(pairings, resolved_pairings)) ->
        do_resolve_conflicts(conflicts, rankings, pairings, conflict, rest)

      true ->
        resolve_conflicts(conflicts, resolved_pairings, rankings)
    end
  end

  defp do_resolve_conflicts(_conflicts, _rankings, pairings, _pairing, []) do
    pairings
  end

  defp new_pairings(pairings, resolved_pairings) do
    resolved_pairings
    |> Enum.reject(&(&1 in pairings))
  end

  defp swap_team(team, pairings, {direction, distance}) do
    pairings
    |> split_sides()
    |> do_swap_team(team, {direction, distance})
    |> zip_sides()
  end

  defp do_swap(teams, team, {:up, distance}) do
    index = Enum.find_index(teams, &(&1 == team))
    sub_index = index - distance

    if sub_index < 0 do
      IO.puts("Cannot move #{team} up #{distance}.")
      teams
    else
      IO.puts("Moving #{team} up #{distance}.")
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
      IO.puts("Cannot move #{team} down #{distance}.")
      teams
    else
      IO.puts("Moving #{team} down #{distance}.")
      {sub, list} = List.pop_at(teams, index + distance)
      list = List.delete_at(list, index)
      list = List.insert_at(list, index, sub)
      List.insert_at(list, index + distance, team)
    end
  end

  defp do_swap_team(
         [prosecution_teams, defense_teams],
         team,
         {direction, distance}
       ) do
    cond do
      team in prosecution_teams ->
        [do_swap(prosecution_teams, team, {direction, distance}), defense_teams]

      team in defense_teams ->
        [prosecution_teams, do_swap(defense_teams, team, {direction, distance})]

      true ->
        [prosecution_teams, defense_teams]
    end
  end

  defp higher_ranked_team({prosecution, defense}, rankings) do
    {prosecution_index, defense_index} =
      find_indexes(rankings, {prosecution, defense})

    if prosecution_index < defense_index do
      prosecution
    else
      defense
    end
  end

  defp lower_ranked_team({prosecution, defense}, rankings) do
    {prosecution_index, defense_index} =
      find_indexes(rankings, {prosecution, defense})

    if prosecution_index > defense_index do
      prosecution
    else
      defense
    end
  end

  defp find_indexes(rankings, {prosecution, defense}) do
    {Enum.find_index(rankings, &(&1 == prosecution)),
     Enum.find_index(rankings, &(&1 == defense))}
  end

  defp defense_teams(pairings) do
    Enum.map(pairings, fn {_p, defense} -> defense end)
  end

  defp prosecution_teams(pairings) do
    Enum.map(pairings, fn {prosecution, _d} -> prosecution end)
  end

  defp split_sides(pairings) do
    [prosecution_teams(pairings), defense_teams(pairings)]
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
