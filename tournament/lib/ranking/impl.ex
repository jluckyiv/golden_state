defmodule Ranking.Impl do
  def ranking(ballots, team) do
    ballots
    |> rankings()
    |> team_rank(team)
  end

  def rankings(ballots, opts) do
    ballots
    |> total(opts)
    |> sort_with_tiebreakers(ballots, :final_ranking)
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
    |> team_rank(team)
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

  defp pairing_totals(_ballots, {team1, team2}, :distance_traveled) do
    {distance_traveled(team1), distance_traveled(team2)}
  end

  defp pairing_totals(ballots, {team1, team2}, {:head_to_head, fun}) do
    ballots
    |> filter_ballots(team: team1, team: team2)
    |> pairing_totals({team1, team2}, fun)
  end

  defp pairing_totals(ballots, {team1, team2}, fun) do
    {total(ballots, [{fun, team1}]), total(ballots, [{fun, team2}])}
  end

  defp total(ballots, opts), do: BallotList.total(ballots, opts)

  defp filter_ballots(ballots, filter) do
    BallotList.filter(ballots, filter)
  end

  defp sort_with_tiebreakers(elements, tiebreaker_data, tiebreakers) do
    Enum.sort(
      elements,
      &do_sort_with_tiebreakers({&1, &2}, tiebreaker_data, tiebreakers)
    )
  end

  # only for individual ranks
  defp do_sort_with_tiebreakers({rank1, rank2}, ballots, :final_ranking) do
    cond do
      rank1.score > rank2.score ->
        true

      rank1.score < rank2.score ->
        false

      true ->
        final_ranking(ballots, rank1.team) <= final_ranking(ballots, rank2.team)
    end
  end

  defp do_sort_with_tiebreakers(pairing, ballots, [head | tail]) do
    {total1, total2} = pairing_totals(ballots, pairing, head)

    cond do
      total1 > total2 -> true
      total1 < total2 -> false
      true -> do_sort_with_tiebreakers(pairing, ballots, tail)
    end
  end

  defp do_sort_with_tiebreakers(_elements, _tiebreaker_data, []), do: true

  defp team_rank(rankings, team) do
    rankings
    |> Enum.find_index(&(&1 == team))
    |> Kernel.+(1)
  end

  defp teams(ballots), do: BallotList.teams(ballots)
end
