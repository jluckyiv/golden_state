defmodule Ballot.Impl do
  defstruct attorney_ranks: [],
            bailiff: nil,
            bailiff_score: 0,
            clerk: nil,
            clerk_score: 0,
            defense: nil,
            defense_closing_score: 0,
            defense_motion_attorney: nil,
            defense_motion_score: 0,
            defense_total_score: 0,
            prosecution: nil,
            prosecution_closing_score: 0,
            prosecution_motion_attorney: nil,
            prosecution_motion_score: 0,
            prosecution_total_score: 0,
            round_number: nil,
            scorer: nil,
            witness_ranks: []

  def bailiff(ballot), do: ballot.bailiff

  def bailiff_score(%{defense: team} = ballot, team) do
    bailiff_score(ballot)
  end

  def bailiff_score(ballot, :defense), do: bailiff_score(ballot)
  def bailiff_score(_ballot, _team), do: 0
  def bailiff_score(ballot), do: ballot.bailiff_score

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

  def clerk(ballot), do: ballot.clerk

  def clerk_score(%{prosecution: team} = ballot, team) do
    clerk_score(ballot)
  end

  def clerk_score(ballot, :prosecution), do: clerk_score(ballot)
  def clerk_score(_ballot, _team), do: 0
  def clerk_score(ballot), do: ballot.clerk_score

  def closing_score(ballot, :defense), do: ballot.defense_closing_score
  def closing_score(ballot, :prosecution), do: ballot.prosecution_closing_score

  def closing_score(%{defense: team} = ballot, team) do
    closing_score(ballot, :defense)
  end

  def closing_score(%{prosecution: team} = ballot, team) do
    closing_score(ballot, :prosecution)
  end

  def closing_score(_, _), do: 0

  def defense(ballot), do: ballot.defense

  def defense?(%{defense: team}, team), do: true
  def defense?(_, _), do: false

  def get(ballot, [{fun, :defense}]), do: get(ballot, defense: fun)
  def get(ballot, [{fun, :prosecution}]), do: get(ballot, prosecution: fun)

  def get(%{defense: team} = ballot, [{fun, team}]) do
    get(ballot, defense: fun)
  end

  def get(%{prosecution: team} = ballot, [{fun, team}]) do
    get(ballot, prosecution: fun)
  end

  def get(ballot, defense: fun) do
    apply(__MODULE__, fun, [ballot, :defense])
  end

  def get(ballot, prosecution: fun) do
    apply(__MODULE__, fun, [ballot, :prosecution])
  end

  def get(ballot, fun) do
    apply(__MODULE__, fun, [ballot])
  end

  def motion_differential(ballot, :defense) do
    motion_score(ballot, :defense) - motion_score(ballot, :prosecution)
  end

  def motion_differential(ballot, :prosecution) do
    motion_score(ballot, :prosecution) - motion_score(ballot, :defense)
  end

  def motion_differential(%{defense: team} = ballot, team) do
    motion_differential(ballot, :defense)
  end

  def motion_differential(%{prosecution: team} = ballot, team) do
    motion_differential(ballot, :prosecution)
  end

  def motion_differential(_, _), do: 0

  def motion_attorney(ballot, :defense), do: ballot.defense_motion_attorney
  def motion_attorney(ballot, :prosecution), do: ballot.prosecution_motion_attorney

  def motion_attorney(%{defense: team} = ballot, team) do
    motion_attorney(ballot, :defense)
  end

  def motion_attorney(%{prosecution: team} = ballot, team) do
    motion_attorney(ballot, :prosecution)
  end

  def motion_score(ballot, :defense), do: ballot.defense_motion_score
  def motion_score(ballot, :prosecution), do: ballot.prosecution_motion_score

  def motion_score(%{defense: team} = ballot, team) do
    motion_score(ballot, :defense)
  end

  def motion_score(%{prosecution: team} = ballot, team) do
    motion_score(ballot, :prosecution)
  end

  def motion_score(_, _), do: 0

  def new(opts), do: struct(__MODULE__, opts)

  def opponent(%{defense: team} = ballot, team), do: ballot.prosecution
  def opponent(%{prosecution: team} = ballot, team), do: ballot.defense
  def opponent(ballot, :defense), do: ballot.prosecution
  def opponent(ballot, :prosecution), do: ballot.defense
  def opponent(_, _), do: nil

  def pairing(ballot) do
    {prosecution(ballot), defense(ballot)}
  end

  def point_differential(ballot, :defense) do
    total_score(ballot, :defense) - total_score(ballot, :prosecution)
  end

  def point_differential(ballot, :prosecution) do
    total_score(ballot, :prosecution) - total_score(ballot, :defense)
  end

  def point_differential(%{defense: team} = ballot, team) do
    point_differential(ballot, :defense)
  end

  def point_differential(%{prosecution: team} = ballot, team) do
    point_differential(ballot, :prosecution)
  end

  def point_differential(_, _), do: 0

  def prosecution(ballot), do: ballot.prosecution

  def prosecution?(%{prosecution: team}, team), do: true
  def prosecution?(_, _), do: false

  def round_number(ballot), do: ballot.round_number

  def round_number?(ballot, round_number) do
    round_number(ballot) == round_number
  end

  def scorer(ballot), do: ballot.scorer

  def teams(ballot), do: pairing(ballot)

  def team?(ballot, team) do
    prosecution?(ballot, team) or defense?(ballot, team)
  end

  def tie?(ballot) do
    total_score(ballot, :prosecution) == total_score(ballot, :defense)
  end

  def total_score(ballot, :defense), do: ballot.defense_total_score
  def total_score(ballot, :prosecution), do: ballot.prosecution_total_score

  def total_score(%{defense: team} = ballot, team) do
    total_score(ballot, :defense)
  end

  def total_score(%{prosecution: team} = ballot, team) do
    total_score(ballot, :prosecution)
  end

  def total_score(_, _), do: 0

  def attorney_ranks(ballot), do: ballot.attorney_ranks

  def witness_ranks(ballot), do: ballot.witness_ranks

  defp win?(ballot, :defense) do
    total_score(ballot, :defense) > total_score(ballot, :prosecution)
  end

  defp win?(ballot, :prosecution) do
    total_score(ballot, :prosecution) > total_score(ballot, :defense)
  end

  defp win?(_, _), do: false
end
