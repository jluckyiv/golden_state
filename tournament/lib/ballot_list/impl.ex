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

  def total(ballots, team, :combined_strength) do
    ballots
    |> filter(opponents: team)
    |> Enum.map(&total(ballots, &1, :ballots_won))
    |> Enum.sum()
  end

  def total(ballots, team, fun) do
    ballots
    |> filter(team: team)
    |> Enum.map(&apply(Ballot, fun, [&1, team]))
    |> Enum.sum()
  end
end
