defmodule Ranking.Impl do
  def rankings(teams, ballots) do
    rank_teams(teams, ballots, [
      :ballots_won,
      :point_differential,
      :distance_traveled
    ])
  end

  def final_rankings(teams, ballots) do
    rank_teams(teams, ballots, [
      :ballots_won,
      {:head_to_head, :ballots_won},
      {:head_to_head, :point_differential},
      {:head_to_head, :closing_score},
      {:head_to_head, :motion_score},
      :combined_strength,
      :point_differentail,
      :distance_traveled
    ])
  end

  defp ballot_totals(_ballots, team1, team2, :distance_traveled) do
    {Team.distance_traveled(team1), Team.distance_traveled(team2)}
  end

  defp ballot_totals(ballots, team1, team2, {:head_to_head, fun}) do
    ballots
    |> filter_ballots(team: team1, team: team2)
    |> ballot_totals(team1, team2, fun)
  end

  defp ballot_totals(ballots, team1, team2, fun) do
    {
      apply(BallotList, :total, [ballots, team1, fun]),
      apply(BallotList, :total, [ballots, team2, fun])
    }
  end

  defp filter_ballots(ballots, filter) do
    BallotList.filter(ballots, filter)
  end

  defp rank_teams(teams, ballots, opts) do
    Enum.sort(teams, &rank_with_tiebreakers(ballots, &1, &2, opts))
  end

  defp rank_with_tiebreakers(_ballots, _team1, _team2, []), do: true

  defp rank_with_tiebreakers(ballots, team1, team2, [head | tail]) do
    {team1_total, team2_total} = ballot_totals(ballots, team1, team2, head)

    cond do
      team1_total > team2_total -> true
      team1_total < team2_total -> false
      true -> rank_with_tiebreakers(ballots, team1, team2, tail)
    end
  end
end
