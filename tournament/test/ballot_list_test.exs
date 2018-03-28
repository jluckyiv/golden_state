defmodule BallotListTest do
  use ExUnit.Case

  setup_all do
    team1 = Team.new(name: "Team 1")

    ballots = [
      Ballot.new(
        defense_motion_score: 8,
        defense_closing_score: 9,
        defense: team1,
        defense_total_score: 101,
        prosecution: "Team 2",
        prosecution_total_score: 100,
        round_number: 1,
        scorer: "Scorer 1"
      ),
      Ballot.new(
        defense_motion_score: 8,
        defense_closing_score: 9,
        defense: team1,
        defense_total_score: 102,
        prosecution: "Team 2",
        prosecution_total_score: 100,
        round_number: 1,
        scorer: "Scorer 2"
      ),
      Ballot.new(
        defense_motion_score: 8,
        defense_closing_score: 9,
        defense: "Team 3",
        defense_total_score: 100,
        prosecution: team1,
        prosecution_total_score: 100,
        round_number: 2,
        scorer: "Scorer 3"
      ),
      Ballot.new(
        defense_motion_score: 8,
        defense_closing_score: 9,
        defense: "Team 3",
        defense_total_score: 101,
        prosecution: team1,
        prosecution_total_score: 100,
        round_number: 2,
        scorer: "Scorer 4"
      ),
      Ballot.new(
        defense_motion_score: 8,
        defense_closing_score: 9,
        defense: "Team 4",
        defense_total_score: 101,
        prosecution: team1,
        prosecution_total_score: 100,
        round_number: 3,
        scorer: "Scorer 5"
      ),
      Ballot.new(
        defense_motion_score: 8,
        defense_closing_score: 9,
        defense: "Team 4",
        defense_total_score: 100,
        prosecution: team1,
        prosecution_total_score: 101,
        round_number: 3,
        scorer: "Scorer 6"
      ),
      Ballot.new(
        defense_motion_score: 8,
        defense_closing_score: 9,
        defense: "Team 5",
        defense_total_score: 107,
        prosecution: "Team 3",
        prosecution_total_score: 100,
        round_number: 4,
        scorer: "Scorer 7"
      ),
      Ballot.new(
        defense_motion_score: 8,
        defense_closing_score: 9,
        defense: "Team 5",
        defense_total_score: 105,
        prosecution: "Team 3",
        prosecution_total_score: 100,
        round_number: 4,
        scorer: "Scorer 8"
      ),
      Ballot.new(
        defense_motion_score: 8,
        defense_closing_score: 9,
        defense: "Team 7",
        defense_total_score: 105,
        prosecution: "Team 8",
        prosecution_total_score: 100,
        round_number: 5,
        scorer: "Scorer 8"
      ),
      Ballot.new(
        defense_motion_score: 8,
        defense_closing_score: 9,
        defense: "Team 7",
        defense_total_score: 105,
        prosecution: "Team 8",
        prosecution_total_score: 100,
        round_number: 5,
        scorer: "Scorer 8"
      ),
      Ballot.new(
        defense_motion_score: 8,
        defense_closing_score: 9,
        defense: "Team 9",
        defense_total_score: 105,
        prosecution: "Team 6",
        prosecution_total_score: 100,
        round_number: 5,
        scorer: "Scorer 8"
      ),
      Ballot.new(
        defense_motion_score: 8,
        defense_closing_score: 9,
        defense: "Team 9",
        defense_total_score: 105,
        prosecution: "Team 6",
        prosecution_total_score: 100,
        round_number: 5,
        scorer: "Scorer 8"
      )
    ]

    {:ok, ballots: ballots, team1: team1}
  end

  test "closing score", context do
    ballots = context[:ballots]
    assert BallotList.closing_score(ballots, "Team 5") == 18
  end

  test "motion score", context do
    ballots = context[:ballots]
    assert BallotList.motion_score(ballots, "Team 5") == 16
    assert BallotList.motion_score(ballots, "Team 6") == 0
  end

  test "total ballots won", context do
    ballots = context[:ballots]
    team1 = context[:team1]
    assert BallotList.ballots_won(ballots, team1) == 3.5
    assert BallotList.ballots_won(ballots, "Team 2") == 0.0
    assert BallotList.ballots_won(ballots, "Team 3") == 1.5
    assert BallotList.ballots_won(ballots, "Team 4") == 1.0
    assert BallotList.ballots_won(ballots, "Team 5") == 2.0
  end

  test "total point differential", context do
    ballots = context[:ballots]
    team1 = context[:team1]
    assert BallotList.point_differential(ballots, team1) == 2
    assert BallotList.point_differential(ballots, "Team 2") == -3
    assert BallotList.point_differential(ballots, "Team 3") == -11
    assert BallotList.point_differential(ballots, "Team 4") == 0
    assert BallotList.point_differential(ballots, "Team 5") == 12
  end

  test "opponents", context do
    ballots = context[:ballots]
    team1 = context[:team1]
    assert BallotList.opponents(ballots, team1) == ["Team 2", "Team 3", "Team 4"]
    assert BallotList.opponents(ballots, "Team 2") == [team1]
    assert BallotList.opponents(ballots, "Team 3") == [team1, "Team 5"]
    assert BallotList.opponents(ballots, "Team 4") == [team1]
    assert BallotList.opponents(ballots, "Team 5") == ["Team 3"]
  end

  test "combined strength", context do
    ballots = context[:ballots]
    team1 = context[:team1]
    assert BallotList.combined_strength(ballots, team1) == 2.5
    assert BallotList.combined_strength(ballots, "Team 2") == 3.5
    assert BallotList.combined_strength(ballots, "Team 3") == 5.5
    assert BallotList.combined_strength(ballots, "Team 4") == 3.5
    assert BallotList.combined_strength(ballots, "Team 5") == 1.5
  end

  test "filter", context do
    ballots = context[:ballots]
    team1 = context[:team1]
    team1_round1 = BallotList.filter(ballots, team: team1, round_number: 1)
    assert Enum.count(team1_round1) == 2

    team1_round4 = BallotList.filter(ballots, team: team1, round_number: 4)
    assert Enum.empty?(team1_round4)

    team1_up_to_round2 = BallotList.filter(ballots, team: team1, up_to_round: 2)
    assert Enum.count(team1_up_to_round2) == 4

    team1_up_to_round3 = BallotList.filter(ballots, team: team1, up_to_round: 3)
    assert Enum.count(team1_up_to_round3) == 6

    team1_up_to_round4 = BallotList.filter(ballots, team: team1, up_to_round: 4)
    assert Enum.count(team1_up_to_round4) == 6

    team2_v_team1_up_to_round4 =
      BallotList.filter(ballots, defense: team1, prosecution: "Team 2", up_to_round: 4)

    assert Enum.count(team2_v_team1_up_to_round4) == 2

    team1_and_team2_up_to_round4 =
      BallotList.filter(ballots, team: team1, team: "Team 2", up_to_round: 4)

    assert Enum.count(team1_and_team2_up_to_round4) == 2
    assert BallotList.filter(ballots, round_number: 5, side: :defense) == ["Team 7", "Team 9"]
    assert BallotList.filter(ballots, side: :defense, round_number: 5) == ["Team 7", "Team 9"]
    assert BallotList.filter(ballots, round_number: 5, side: :prosecution) == ["Team 8", "Team 6"]
    assert BallotList.filter(ballots, side: :prosecution, round_number: 5) == ["Team 8", "Team 6"]
  end
end
