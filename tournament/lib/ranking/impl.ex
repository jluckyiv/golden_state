defmodule Ranking.Impl do
  def ranking(ballots, team) do
    ballots
    |> rankings()
    |> Enum.find_index(&(&1 == team))
    |> Kernel.+(1)
  end

  def rankings(ballots, :attorney_ranks) do
    ballots
    |> BallotList.total(:attorney_ranks)
    |> rank_competitors(ballots, :final_ranking)
  end

  def rankings(ballots) do
    ballots
    |> BallotList.teams()
    |> rank_teams(ballots, [
      :ballots_won,
      :point_differential,
      :distance_traveled
    ])
  end

  def final_ranking(ballots, team) do
    ballots
    |> final_rankings()
    |> Enum.find_index(&(&1 == team))
    |> Kernel.+(1)
  end

  def final_rankings(ballots) do
    ballots
    |> BallotList.teams()
    |> rank_teams(ballots, [
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

  defp ballot_totals(_ballots, {team1, team2}, :distance_traveled) do
    {Team.distance_traveled(team1), Team.distance_traveled(team2)}
  end

  defp ballot_totals(ballots, {team1, team2}, {:head_to_head, fun}) do
    ballots
    |> filter_ballots(team: team1, team: team2)
    |> ballot_totals({team1, team2}, fun)
  end

  defp ballot_totals(ballots, {team1, team2}, fun) do
    {
      BallotList.total(ballots, [{fun, team1}]),
      BallotList.total(ballots, [{fun, team2}])
    }
  end

  defp filter_ballots(ballots, filter) do
    BallotList.filter(ballots, filter)
  end

  defp rank_elems({{_, _, rank1}, {_, _, rank2}}), do: {rank1, rank2}

  defp rank_competitors(competitors, ballots, opts) do
    Enum.sort(competitors, &rank_with_tiebreakers(ballots, {&1, &2}, opts))
  end

  defp rank_teams(teams, ballots, opts) do
    Enum.sort(teams, &rank_with_tiebreakers(ballots, {&1, &2}, opts))
  end

  defp rank_with_tiebreakers(_ballots, _pairing, []), do: true

  defp rank_with_tiebreakers(ballots, competitors, :final_ranking) do
    {team1, team2} = team_elems(competitors)
    {rank1, rank2} = rank_elems(competitors)

    cond do
      rank1 > rank2 -> true
      rank1 < rank2 -> false
      true -> ranking(ballots, team1) <= final_ranking(ballots, team2)
    end
  end

  defp rank_with_tiebreakers(ballots, pairing, [head | tail]) do
    {team1_total, team2_total} = ballot_totals(ballots, pairing, head)

    cond do
      team1_total > team2_total -> true
      team1_total < team2_total -> false
      true -> rank_with_tiebreakers(ballots, pairing, tail)
    end
  end

  defp team_elems({{team1, _, _}, {team2, _, _}}), do: {team1, team2}
end
