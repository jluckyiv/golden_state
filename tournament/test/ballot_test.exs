defmodule BallotTest do
  use ExUnit.Case

  setup_all do
    ballot =
      Ballot.new(
        defense: "defense",
        defense_score: 101,
        defense_closing_score: 9,
        defense_motion_score: 8,
        prosecution: "prosecution",
        prosecution_score: 100,
        prosecution_closing_score: 7,
        prosecution_motion_score: 6,
        round_number: 1,
        scorer: "Scorer"
      )

    {:ok, ballot: ballot}
  end

  test "ballot properties", context do
    ballot = context[:ballot]
    assert Ballot.defense(ballot) == "defense"
    assert Ballot.defense_closing_score(ballot) == 9
    assert Ballot.defense_motion_score(ballot) == 8
    assert Ballot.defense_score(ballot) == 101
    assert Ballot.prosecution(ballot) == "prosecution"
    assert Ballot.prosecution_closing_score(ballot) == 7
    assert Ballot.prosecution_motion_score(ballot) == 6
    assert Ballot.prosecution_score(ballot) == 100
    assert Ballot.round_number(ballot) == 1
    assert Ballot.scorer(ballot) == "Scorer"
  end

  test "ballot total scores", context do
    ballot = context[:ballot]
    assert Ballot.total_score(ballot, "defense") == 101
    assert Ballot.total_score(ballot, "prosecution") == 100
    assert Ballot.total_score(ballot, :defense) == 101
    assert Ballot.total_score(ballot, :prosecution) == 100
  end

  test "ballot closing scores", context do
    ballot = context[:ballot]
    assert Ballot.closing_score(ballot, "defense") == 9
    assert Ballot.closing_score(ballot, "prosecution") == 7
    assert Ballot.closing_score(ballot, :defense) == 9
    assert Ballot.closing_score(ballot, :prosecution) == 7
  end

  test "ballot motion scores", context do
    ballot = context[:ballot]
    assert Ballot.motion_score(ballot, "defense") == 8
    assert Ballot.motion_score(ballot, "prosecution") == 6
    assert Ballot.motion_score(ballot, :defense) == 8
    assert Ballot.motion_score(ballot, :prosecution) == 6
  end

  test "ballot point differential", context do
    ballot = context[:ballot]
    assert Ballot.point_differential(ballot, "defense") == 1
    assert Ballot.point_differential(ballot, "prosecution") == -1
    assert Ballot.point_differential(ballot, :defense) == 1
    assert Ballot.point_differential(ballot, :prosecution) == -1
  end

  test "ballots won", context do
    ballot = context[:ballot]
    assert Ballot.ballots_won(ballot, "defense") == 1
    assert Ballot.ballots_won(ballot, "prosecution") == 0
    assert Ballot.ballots_won(ballot, :defense) == 1
    assert Ballot.ballots_won(ballot, :prosecution) == 0
  end

  test "opponent", context do
    ballot = context[:ballot]
    assert Ballot.opponent(ballot, "defense") == "prosecution"
    assert Ballot.opponent(ballot, "prosecution") == "defense"
    assert Ballot.opponent(ballot, "unknown") == nil
  end

  test "has team", context do
    ballot = context[:ballot]
    assert Ballot.has_team?(ballot, "defense") == true
    assert Ballot.has_team?(ballot, "prosecution") == true
    assert Ballot.has_team?(ballot, "unknown") == false
  end

  test "not on ballot", context do
    ballot = context[:ballot]
    assert Ballot.ballots_won(ballot, "unknown") == 0
    assert Ballot.point_differential(ballot, "unknown") == 0
    assert Ballot.total_score(ballot, "unknown") == 0
  end
end
