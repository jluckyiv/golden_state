defmodule BallotList.Impl do
  def filter(ballots, opts \\ [])

  def filter(ballots, [{:defense, team} | rest]) do
    ballots
    |> Enum.filter(&Ballot.defense?(&1, team))
    |> filter(rest)
  end

  def filter(ballots, [{:opponents, team} | rest]) do
    ballots
    |> filter(team: team)
    |> Enum.map(&Ballot.opponent(&1, team))
    |> Enum.uniq()
    |> filter(rest)
  end

  def filter(ballots, [{:prosecution, team} | rest]) do
    ballots
    |> Enum.filter(&Ballot.prosecution?(&1, team))
    |> filter(rest)
  end

  def filter(ballots, [{:round_number, round_number} | rest]) do
    ballots
    |> Enum.filter(&Ballot.round_number?(&1, round_number))
    |> filter(rest)
  end

  def filter(ballots, [{:side, side} | []]) do
    ballots
    |> side(side)
  end

  def filter(ballots, [{:side, side} | rest]) do
    ballots
    |> filter(rest)
    |> filter(side: side)
  end

  def filter(ballots, [{:team, team} | rest]) do
    ballots
    |> Enum.filter(&Ballot.team?(&1, team))
    |> filter(rest)
  end

  def filter(ballots, [{:up_to_round, round_number} | rest]) do
    ballots
    |> Enum.filter(&(Ballot.round_number(&1) <= round_number))
    |> filter(rest)
  end

  def filter(ballots, []), do: ballots

  def teams(ballots) do
    ballots
    |> Enum.map(&Ballot.get(&1, :teams))
    |> List.flatten()
    |> Enum.map(&Tuple.to_list/1)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
  end

  def total(ballots, :attorney_ranks) do
    ballots
    |> Rank.from_ballots()
    |> Rank.totals()
    |> Rank.filter(position: :attorney)
  end

  def total(ballots, :witness_ranks) do
    ballots
    |> Rank.from_ballots()
    |> Rank.totals()
    |> Rank.filter(position: :witness)
  end

  def total(ballots, combined_strength: team) do
    ballots
    |> filter(opponents: team)
    |> Enum.map(&total(ballots, ballots_won: &1))
    |> Enum.sum()
  end

  def total(ballots, [{fun, team}]) do
    ballots
    |> filter(team: team)
    |> Enum.map(&Ballot.get(&1, [{fun, team}]))
    |> Enum.sum()
  end

  defp flatten_ranks(ranks) do
    ranks
    |> Enum.reject(&Enum.empty?/1)
    |> List.flatten()
  end

  defp format_ranks(ranks) do
    Enum.map(ranks, fn {{team, name}, rank} -> {team, name, rank} end)
  end

  defp rank_value({{_team, _name}, rank}) do
    rank
  end

  defp side(ballots, :prosecution) do
    ballots
    |> Enum.map(&Ballot.prosecution(&1))
    |> Enum.uniq()
  end

  defp side(ballots, :defense) do
    ballots
    |> Enum.map(&Ballot.defense(&1))
    |> Enum.uniq()
  end

  defp sort_ranks(ranks) do
    ranks
    |> Enum.sort(&(rank_value(&1) >= rank_value(&2)))
  end

  defp sum_ranks(ranks) do
    ranks
    |> Enum.reduce(%{}, fn {team, name, rank}, acc ->
      Map.update(acc, {team, name}, rank, &(&1 + rank))
    end)
    |> Enum.to_list()
  end

  defp total_ranks(ranks) do
    ranks
    |> flatten_ranks()
    |> sum_ranks()
    |> sort_ranks()
    |> format_ranks()
  end
end
