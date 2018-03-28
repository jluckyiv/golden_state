defmodule BallotList.Impl do
  def ballots_won(ballots, team) do
    ballots
    |> Enum.map(&Ballot.ballots_won(&1, team))
    |> Enum.sum()
  end

  def closing_score(ballots, team) do
    ballots
    |> Enum.map(&Ballot.closing_score(&1, team))
    |> Enum.sum()
  end

  def combined_strength(ballots, team) do
    ballots
    |> opponents(team)
    |> Enum.map(&__MODULE__.ballots_won(ballots, &1))
    |> Enum.sum()
  end

  def filter(ballots, opts \\ [])

  def filter(ballots, [{:round_number, round_number} | rest]) do
    ballots
    |> Enum.filter(&(Ballot.round_number(&1) == round_number))
    |> __MODULE__.filter(rest)
  end

  def filter(ballots, [{:team, team} | rest]) do
    ballots
    |> Enum.filter(&Ballot.has_team?(&1, team))
    |> __MODULE__.filter(rest)
  end

  def filter(ballots, [{:prosecution, team} | rest]) do
    ballots
    |> Enum.filter(&(Ballot.prosecution(&1) == team))
    |> __MODULE__.filter(rest)
  end

  def filter(ballots, [{:defense, team} | rest]) do
    ballots
    |> Enum.filter(&(Ballot.defense(&1) == team))
    |> __MODULE__.filter(rest)
  end

  def filter(ballots, [{:up_to_round, round_number} | rest]) do
    ballots
    |> Enum.filter(&(Ballot.round_number(&1) <= round_number))
    |> __MODULE__.filter(rest)
  end

  def filter(ballots, [{:side, side} | []]) do
    ballots
    |> side(side)
  end

  def filter(ballots, [{:side, side} | rest]) do
    ballots
    |> __MODULE__.filter(rest)
    |> __MODULE__.filter(side: side)
  end

  def filter(ballots, []), do: ballots

  def motion_score(ballots, team) do
    ballots
    |> Enum.map(&Ballot.motion_score(&1, team))
    |> Enum.sum()
  end

  def opponents(ballots, team) do
    ballots
    |> Enum.map(&Ballot.opponent(&1, team))
    |> Enum.uniq()
    |> List.delete(nil)
  end

  def point_differential(ballots, team) do
    ballots
    |> Enum.map(&Ballot.point_differential(&1, team))
    |> Enum.sum()
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
end
