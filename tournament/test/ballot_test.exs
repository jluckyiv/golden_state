defmodule BallotTest do
  use ExUnit.Case

  setup_all do
    ballot =
      Ballot.new(
        attorney_ranks: [
          prosecution: "Attorney 1",
          defense: "Attorney 2",
          prosecution: "Attorney 3",
          defense: "Attorney 4"
        ],
        defense: "Defense",
        defense_total_score: 101,
        defense_closing_score: 9,
        defense_motion_attorney: "Defense Motion Attorney",
        defense_motion_score: 8,
        bailiff: "Bailiff",
        bailiff_score: 9,
        prosecution: "Prosecution",
        prosecution_total_score: 100,
        prosecution_closing_score: 7,
        prosecution_motion_attorney: "Prosecution Motion Attorney",
        prosecution_motion_score: 6,
        clerk: "Clerk",
        clerk_score: 6,
        round_number: 1,
        scorer: "Scorer",
        witness_ranks: [
          defense: "Witness 1",
          prosecution: "Witness 2",
          defense: "Witness 3",
          prosecution: "Witness 4"
        ]
      )

    {:ok, ballot: ballot}
  end

  test "ballot properties", context do
    ballot = context[:ballot]
    assert Ballot.defense(ballot) == "Defense"
    assert Ballot.prosecution(ballot) == "Prosecution"
    assert Ballot.round_number(ballot) == 1
    assert Ballot.scorer(ballot) == "Scorer"

    assert Ballot.get(ballot, :bailiff) == "Bailiff"
    assert Ballot.get(ballot, :bailiff_score) == 9
    assert Ballot.get(ballot, :clerk) == "Clerk"
    assert Ballot.get(ballot, :clerk_score) == 6
    assert Ballot.get(ballot, :defense) == "Defense"
    assert Ballot.get(ballot, :prosecution) == "Prosecution"
    assert Ballot.get(ballot, :round_number) == 1
    assert Ballot.get(ballot, :scorer) == "Scorer"
    assert Ballot.get(ballot, closing_score: :defense) == 9
    assert Ballot.get(ballot, closing_score: :prosecution) == 7
    assert Ballot.get(ballot, motion_attorney: :defense) == "Defense Motion Attorney"
    assert Ballot.get(ballot, motion_attorney: :prosecution) == "Prosecution Motion Attorney"
    assert Ballot.get(ballot, motion_score: :defense) == 8
    assert Ballot.get(ballot, motion_score: :prosecution) == 6

    assert Ballot.get(ballot, :witness_ranks) == [
             {:defense, "Witness 1"},
             {:prosecution, "Witness 2"},
             {:defense, "Witness 3"},
             {:prosecution, "Witness 4"}
           ]

    assert Ballot.get(ballot, :attorney_ranks) == [
             {:prosecution, "Attorney 1"},
             {:defense, "Attorney 2"},
             {:prosecution, "Attorney 3"},
             {:defense, "Attorney 4"}
           ]
  end

  test "ballot total scores", context do
    ballot = context[:ballot]
    assert Ballot.get(ballot, total_score: "Defense") == 101
    assert Ballot.get(ballot, total_score: "Prosecution") == 100
    assert Ballot.get(ballot, total_score: :defense) == 101
    assert Ballot.get(ballot, total_score: :prosecution) == 100

    assert Ballot.get(ballot, defense: :total_score) == 101
    assert Ballot.get(ballot, prosecution: :total_score) == 100
  end

  test "ballot closing scores", context do
    ballot = context[:ballot]

    assert Ballot.get(ballot, closing_score: "Defense") == 9
    assert Ballot.get(ballot, closing_score: "Prosecution") == 7
    assert Ballot.get(ballot, closing_score: :defense) == 9
    assert Ballot.get(ballot, closing_score: :prosecution) == 7

    assert Ballot.get(ballot, defense: :closing_score) == 9
    assert Ballot.get(ballot, prosecution: :closing_score) == 7
  end

  test "ballot motion scores", context do
    ballot = context[:ballot]

    assert Ballot.get(ballot, motion_score: "Defense") == 8
    assert Ballot.get(ballot, motion_score: "Prosecution") == 6
    assert Ballot.get(ballot, motion_score: :defense) == 8
    assert Ballot.get(ballot, motion_score: :prosecution) == 6

    assert Ballot.get(ballot, defense: :motion_score) == 8
    assert Ballot.get(ballot, prosecution: :motion_score) == 6

    assert Ballot.get(ballot, motion_differential: :defense) == 2
    assert Ballot.get(ballot, motion_differential: :prosecution) == -2

    assert Ballot.get(ballot, defense: :motion_differential) == 2
    assert Ballot.get(ballot, prosecution: :motion_differential) == -2

    assert Ballot.get(ballot, motion_differential: "Defense") == 2
    assert Ballot.get(ballot, motion_differential: "Prosecution") == -2
  end

  test "ballot bailiff and clerk scores", context do
    ballot = context[:ballot]
    assert Ballot.get(ballot, bailiff_score: "Defense") == 9
    assert Ballot.get(ballot, bailiff_score: "Prosecution") == 0
    assert Ballot.get(ballot, clerk_score: "Defense") == 0
    assert Ballot.get(ballot, clerk_score: "Prosecution") == 6
  end

  test "ballot point differential", context do
    ballot = context[:ballot]
    assert Ballot.get(ballot, point_differential: "Defense") == 1
    assert Ballot.get(ballot, point_differential: "Prosecution") == -1
    assert Ballot.get(ballot, point_differential: :defense) == 1
    assert Ballot.get(ballot, point_differential: :prosecution) == -1
  end

  test "ballots won", context do
    ballot = context[:ballot]
    assert Ballot.get(ballot, ballots_won: "Defense") == 1
    assert Ballot.get(ballot, ballots_won: "Prosecution") == 0
    assert Ballot.get(ballot, ballots_won: :defense) == 1
    assert Ballot.get(ballot, ballots_won: :prosecution) == 0
  end

  test "opponent", context do
    ballot = context[:ballot]
    assert Ballot.get(ballot, opponent: "Defense") == "Prosecution"
    assert Ballot.get(ballot, opponent: "Prosecution") == "Defense"
  end

  test "has team", context do
    ballot = context[:ballot]
    assert Ballot.team?(ballot, "Defense") == true
    assert Ballot.team?(ballot, "Prosecution") == true
    assert Ballot.team?(ballot, "Unknown") == false
  end

  test "not on ballot", context do
    ballot = context[:ballot]
    assert Ballot.opponent(ballot, "Unknown") == nil
    # assert Ballot.ballots_won(ballot, "Unknown") == 0
    # assert Ballot.point_differential(ballot, "Unknown") == 0
    # assert Ballot.total_score(ballot, "Unknown") == 0
  end
end
