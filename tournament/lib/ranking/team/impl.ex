defmodule Ranking.Team.Impl do
  def ranking(ballots, team) do
    ballots
    |> rankings()
    |> rank(team)
  end

  def rankings(ballots) do
    ballots
    |> teams()
    |> sort_with_tiebreakers(ballots, [
      :ballots_won,
      :point_differential,
      :distance_traveled
    ])
  end

  def final_ranking(ballots, team) do
    ballots
    |> final_rankings()
    |> rank(team)
  end

  def final_rankings(ballots) do
    ballots
    |> teams()
    |> sort_with_tiebreakers(ballots, [
      :ballots_won,
      {:head_to_head, :ballots_won},
      {:head_to_head, :point_differential},
      {:head_to_head, :closing_score},
      {:head_to_head, :motion_score},
      :combined_strength,
      :point_differential,
      :distance_traveled
    ])
  end

  defp distance_traveled(team), do: Team.distance_traveled(team)

  defp filter_ballots(ballots, filter), do: BallotList.filter(ballots, filter)

  defp pairing_totals(_ballots, {team1, team2}, :distance_traveled) do
    {distance_traveled(team1), distance_traveled(team2)}
  end

  defp pairing_totals(ballots, {team1, team2}, {:head_to_head, fun}) do
    ballots
    |> filter_ballots(team: team1, team: team2)
    |> pairing_totals({team1, team2}, fun)
  end

  defp pairing_totals(ballots, {team1, team2}, fun) do
    {ballot_total(ballots, [{fun, team1}]),
     ballot_total(ballots, [{fun, team2}])}
  end

  defp ballot_total(ballots, opts), do: BallotList.total(ballots, opts)

  defp sort_with_tiebreakers(elements, tiebreaker_data, tiebreakers) do
    Enum.sort(
      elements,
      &do_sort_with_tiebreakers({&1, &2}, tiebreaker_data, tiebreakers)
    )
  end

  defp do_sort_with_tiebreakers({team1, _} = pairing, ballots, [head | tail]) do
    {total1, total2} = pairing_totals(ballots, pairing, head)

    cond do
      team1.name == "Bye Buster" -> false
      total1 > total2 -> true
      total1 < total2 -> false
      true -> do_sort_with_tiebreakers(pairing, ballots, tail)
    end
  end

  defp do_sort_with_tiebreakers(_elements, _tiebreaker_data, []), do: true

  defp rank(rankings, team) do
    rankings
    |> Enum.find_index(&(&1 == team))
    |> Kernel.+(1)
  end

  defp teams(ballots), do: BallotList.teams(ballots)
end
