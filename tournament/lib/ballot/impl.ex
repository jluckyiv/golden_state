defmodule Ballot.Impl do
  defstruct defense: nil,
            defense_closing_score: 0,
            defense_motion_score: 0,
            defense_total_score: 0,
            prosecution: nil,
            prosecution_closing_score: 0,
            prosecution_motion_score: 0,
            prosecution_total_score: 0,
            round_number: nil,
            scorer: nil

  def ballots_won(%{defense: team} = ballot, team) do
    ballots_won(ballot, :defense)
  end

  def ballots_won(%{prosecution: team} = ballot, team) do
    ballots_won(ballot, :prosecution)
  end

  def ballots_won(ballot, side) when side in [:prosecution, :defense] do
    cond do
      win?(ballot, side) -> 1.0
      tie?(ballot) -> 0.5
      true -> 0.0
    end
  end

  def ballots_won(_, _), do: 0.0

  def closing_score(ballot, :defense), do: ballot.defense_closing_score
  def closing_score(ballot, :prosecution), do: ballot.prosecution_closing_score

  def closing_score(%{defense: team} = ballot, team) do
    ballot.defense_closing_score
  end

  def closing_score(%{prosecution: team} = ballot, team) do
    ballot.prosecution_closing_score
  end

  def closing_score(_, _), do: 0

  def defense(ballot), do: ballot.defense
  def defense_closing_score(ballot), do: ballot.defense_closing_score
  def defense_motion_score(ballot), do: ballot.defense_motion_score
  def defense_total_score(ballot), do: ballot.defense_total_score

  def has_team?(%{defense: team}, team), do: true
  def has_team?(%{prosecution: team}, team), do: true
  def has_team?(_, _), do: false

  def motion_score(ballot, :defense), do: ballot.defense_motion_score
  def motion_score(ballot, :prosecution), do: ballot.prosecution_motion_score

  def motion_score(%{defense: team} = ballot, team) do
    ballot.defense_motion_score
  end

  def motion_score(%{prosecution: team} = ballot, team) do
    ballot.prosecution_motion_score
  end

  def motion_score(_, _), do: 0

  def new(opts), do: struct(__MODULE__, opts)

  def opponent(%{defense: team} = ballot, team), do: ballot.prosecution
  def opponent(%{prosecution: team} = ballot, team), do: ballot.defense
  def opponent(_, _), do: nil

  def point_differential(ballot, :defense) do
    ballot.defense_total_score - ballot.prosecution_total_score
  end

  def point_differential(ballot, :prosecution) do
    ballot.prosecution_total_score - ballot.defense_total_score
  end

  def point_differential(%{defense: team} = ballot, team) do
    point_differential(ballot, :defense)
  end

  def point_differential(%{prosecution: team} = ballot, team) do
    point_differential(ballot, :prosecution)
  end

  def point_differential(_, _), do: 0

  def prosecution(ballot), do: ballot.prosecution
  def prosecution_closing_score(ballot), do: ballot.prosecution_closing_score
  def prosecution_motion_score(ballot), do: ballot.prosecution_motion_score
  def prosecution_total_score(ballot), do: ballot.prosecution_total_score

  def round_number(ballot), do: ballot.round_number
  def scorer(ballot), do: ballot.scorer
  def tie?(ballot), do: ballot.prosecution_total_score == ballot.defense_total_score

  def total_score(ballot, :defense), do: ballot.defense_total_score
  def total_score(ballot, :prosecution), do: ballot.prosecution_total_score

  def total_score(%{defense: team} = ballot, team) do
    ballot.defense_total_score
  end

  def total_score(%{prosecution: team} = ballot, team) do
    ballot.prosecution_total_score
  end

  def total_score(_, _), do: 0

  defp win?(ballot, :defense) do
    ballot.defense_total_score > ballot.prosecution_total_score
  end

  defp win?(ballot, :prosecution) do
    ballot.prosecution_total_score > ballot.defense_total_score
  end
end
