defmodule Tournament.Conflict.Impl do
  def conflict?(conflicts, pairing) when is_map(pairing) do
    conflict?(conflicts, {pairing.prosecution, pairing.defense})
  end

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
        # IO.puts("Conflict remains.")
        do_resolve_conflicts(conflicts, rankings, pairings, conflict, rest)

      conflicts?(conflicts, new_pairings(pairings, resolved_pairings)) ->
        # IO.puts("Conflict remains.")
        do_resolve_conflicts(conflicts, rankings, pairings, conflict, rest)

      true ->
        # IO.puts("Conflict resolved.")
        resolve_conflicts(conflicts, resolved_pairings, rankings)
    end
  end

  defp do_resolve_conflicts(_conflicts, _rankings, _pairings, _pairing, []) do
    raise "Could not resolve pairings"
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
      # IO.puts("Cannot move #{team.name} up #{distance}.")
      teams
    else
      # IO.puts("Moving #{team.name} up #{distance}.")

      teams
      |> List.delete_at(index)
      |> List.pop_at(sub_index)
      |> (fn {sub, list} -> {sub, List.insert_at(list, sub_index, team)} end).()
      |> (fn {sub, list} -> List.insert_at(list, index, sub) end).()
    end
  end

  defp do_swap(teams, team, {:down, distance}) do
    index = Enum.find_index(teams, &(&1 == team))
    sub_index = index + distance

    if sub_index >= length(teams) do
      # IO.puts("Cannot move #{team.name} down #{distance}.")
      teams
    else
      # IO.puts("Moving #{team.name} down #{distance}.")

      teams
      |> List.pop_at(sub_index)
      |> (fn {sub, list} -> {sub, List.delete_at(list, index)} end).()
      |> (fn {sub, list} -> List.insert_at(list, index, sub) end).()
      |> List.insert_at(sub_index, team)
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
    Enum.zip([prosecution_teams, defense_teams])
  end
end
