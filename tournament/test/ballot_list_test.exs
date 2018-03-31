defmodule BallotListTest do
  use ExUnit.Case

  setup_all do
    ballots = [
      Ballot.new(
        bailiff_score: 9,
        clerk_score: 8,
        defense: "Team 1",
        defense_closing_score: 9,
        defense_motion_score: 8,
        defense_total_score: 101,
        prosecution: "Team 2",
        prosecution_motion_score: 7,
        prosecution_total_score: 100,
        attorney_ranks: [
          defense: "Attorney 13",
          prosecution: "Attorney 12",
          defense: "Attorney 11",
          prosecution: "Attorney 14"
        ],
        witness_ranks: [
          defense: "Witness 11",
          prosecution: "Witness 12",
          defense: "Witness 13",
          prosecution: "Witness 14"
        ],
        round_number: 1,
        scorer: "Scorer 1"
      ),
      Ballot.new(
        bailiff_score: 9,
        clerk_score: 8,
        defense: "Team 1",
        defense_closing_score: 9,
        defense_motion_score: 8,
        defense_total_score: 102,
        prosecution: "Team 2",
        prosecution_motion_score: 7,
        prosecution_total_score: 100,
        attorney_ranks: [
          prosecution: "Attorney 12",
          defense: "Attorney 11",
          defense: "Attorney 13",
          prosecution: "Attorney 14"
        ],
        witness_ranks: [
          defense: "Witness 11",
          defense: "Witness 13",
          prosecution: "Witness 14",
          prosecution: "Witness 12"
        ],
        round_number: 1,
        scorer: "Scorer 2"
      ),
      Ballot.new(
        bailiff_score: 9,
        clerk_score: 8,
        defense: "Team 3",
        defense_closing_score: 9,
        defense_motion_score: 8,
        defense_total_score: 100,
        prosecution: "Team 1",
        prosecution_motion_score: 7,
        prosecution_total_score: 100,
        round_number: 2,
        scorer: "Scorer 3"
      ),
      Ballot.new(
        bailiff_score: 9,
        clerk_score: 8,
        defense: "Team 3",
        defense_closing_score: 9,
        defense_motion_score: 8,
        defense_total_score: 101,
        prosecution: "Team 1",
        prosecution_motion_score: 7,
        prosecution_total_score: 100,
        round_number: 2,
        scorer: "Scorer 4"
      ),
      Ballot.new(
        bailiff_score: 9,
        clerk_score: 8,
        defense: "Team 4",
        defense_closing_score: 9,
        defense_motion_score: 8,
        defense_total_score: 101,
        prosecution: "Team 1",
        prosecution_motion_score: 7,
        prosecution_total_score: 100,
        round_number: 3,
        scorer: "Scorer 5"
      ),
      Ballot.new(
        bailiff_score: 9,
        clerk_score: 8,
        defense: "Team 4",
        defense_closing_score: 9,
        defense_motion_score: 8,
        defense_total_score: 100,
        prosecution: "Team 1",
        prosecution_motion_score: 7,
        prosecution_total_score: 101,
        round_number: 3,
        scorer: "Scorer 6"
      ),
      Ballot.new(
        bailiff_score: 9,
        clerk_score: 8,
        defense: "Team 5",
        defense_closing_score: 9,
        defense_motion_score: 8,
        defense_total_score: 107,
        prosecution: "Team 3",
        prosecution_motion_score: 7,
        prosecution_total_score: 100,
        round_number: 4,
        scorer: "Scorer 7"
      ),
      Ballot.new(
        bailiff_score: 8,
        clerk_score: 8,
        defense: "Team 5",
        defense_closing_score: 9,
        defense_motion_score: 8,
        defense_total_score: 105,
        prosecution: "Team 3",
        prosecution_motion_score: 7,
        prosecution_total_score: 100,
        round_number: 4,
        scorer: "Scorer 8"
      ),
      Ballot.new(
        bailiff_score: 9,
        clerk_score: 8,
        defense: "Team 7",
        defense_closing_score: 9,
        defense_motion_score: 8,
        defense_total_score: 105,
        prosecution: "Team 8",
        prosecution_motion_score: 7,
        prosecution_total_score: 100,
        round_number: 5,
        scorer: "Scorer 8"
      ),
      Ballot.new(
        bailiff_score: 9,
        clerk_score: 8,
        defense: "Team 7",
        defense_closing_score: 9,
        defense_motion_score: 8,
        defense_total_score: 105,
        prosecution: "Team 8",
        prosecution_motion_score: 7,
        prosecution_total_score: 100,
        round_number: 5,
        scorer: "Scorer 8"
      ),
      Ballot.new(
        bailiff_score: 9,
        clerk_score: 8,
        defense: "Team 9",
        defense_closing_score: 9,
        defense_motion_score: 8,
        defense_total_score: 105,
        prosecution: "Team 6",
        prosecution_motion_score: 7,
        prosecution_total_score: 100,
        round_number: 5,
        scorer: "Scorer 8"
      ),
      Ballot.new(
        bailiff_score: 9,
        clerk_score: 8,
        defense: "Team 9",
        defense_closing_score: 9,
        defense_motion_score: 8,
        defense_total_score: 105,
        prosecution: "Team 6",
        prosecution_motion_score: 7,
        prosecution_total_score: 100,
        round_number: 5,
        scorer: "Scorer 8"
      )
    ]

    {:ok, ballots: ballots}
  end

  test "teams", context do
    ballots = context[:ballots]

    assert BallotList.teams(ballots) == [
             "Team 1",
             "Team 2",
             "Team 3",
             "Team 4",
             "Team 5",
             "Team 6",
             "Team 7",
             "Team 8",
             "Team 9"
           ]
  end

  test "closing score", context do
    ballots = context[:ballots]
    assert BallotList.total(ballots, closing_score: "Team 5") == 18
  end

  test "bailiff score", context do
    ballots = context[:ballots]
    assert BallotList.total(ballots, bailiff_score: "Team 5") == 17
    assert BallotList.total(ballots, bailiff_score: "Team 8") == 0
  end

  test "clerk score", context do
    ballots = context[:ballots]
    assert BallotList.total(ballots, clerk_score: "Team 5") == 0
    assert BallotList.total(ballots, clerk_score: "Team 8") == 16
  end

  test "motion score", context do
    ballots = context[:ballots]
    assert BallotList.total(ballots, motion_score: "Team 5") == 16
    assert BallotList.total(ballots, motion_score: "Team 6") == 14
    assert BallotList.total(ballots, motion_differential: "Team 5") == 2
    assert BallotList.total(ballots, motion_differential: "Team 6") == -2
  end

  test "total ballots won", context do
    ballots = context[:ballots]
    assert BallotList.total(ballots, ballots_won: "Team 1") == 3.5
    assert BallotList.total(ballots, ballots_won: "Team 2") == 0.0
    assert BallotList.total(ballots, ballots_won: "Team 3") == 1.5
    assert BallotList.total(ballots, ballots_won: "Team 4") == 1.0
    assert BallotList.total(ballots, ballots_won: "Team 5") == 2.0
  end

  test "total point differential", context do
    ballots = context[:ballots]
    assert BallotList.total(ballots, point_differential: "Team 1") == 2
    assert BallotList.total(ballots, point_differential: "Team 2") == -3
    assert BallotList.total(ballots, point_differential: "Team 3") == -11
    assert BallotList.total(ballots, point_differential: "Team 4") == 0
    assert BallotList.total(ballots, point_differential: "Team 5") == 12
  end

  test "opponents", context do
    ballots = context[:ballots]
    assert BallotList.filter(ballots, opponents: "Team 1") == ["Team 2", "Team 3", "Team 4"]
    assert BallotList.filter(ballots, opponents: "Team 2") == ["Team 1"]
    assert BallotList.filter(ballots, opponents: "Team 3") == ["Team 1", "Team 5"]
    assert BallotList.filter(ballots, opponents: "Team 4") == ["Team 1"]
    assert BallotList.filter(ballots, opponents: "Team 5") == ["Team 3"]
  end

  test "combined strength", context do
    ballots = context[:ballots]
    assert BallotList.total(ballots, combined_strength: "Team 1") == 2.5
    assert BallotList.total(ballots, combined_strength: "Team 2") == 3.5
    assert BallotList.total(ballots, combined_strength: "Team 3") == 5.5
    assert BallotList.total(ballots, combined_strength: "Team 4") == 3.5
    assert BallotList.total(ballots, combined_strength: "Team 5") == 1.5
  end

  test "attorney ranks", context do
    ballots = context[:ballots]
    ranks = BallotList.total(ballots, :attorney_ranks)
    assert Enum.count(ranks) == 4
    assert Rank.Individual.find(ranks, name: "Attorney 12").score == 9
    assert Rank.Individual.find(ranks, name: "Attorney 13").score == 8
  end

  test "witness ranks", context do
    ballots = context[:ballots]
    ranks = BallotList.total(ballots, :witness_ranks)
    assert Enum.count(ranks) == 4
    assert Rank.Individual.find(ranks, name: "Witness 11").score == 10
    assert Rank.Individual.find(ranks, name: "Witness 12").score == 6
  end

  test "filter", context do
    ballots = context[:ballots]
    team1_round1 = BallotList.filter(ballots, team: "Team 1", round_number: 1)
    assert Enum.count(team1_round1) == 2

    team1_round4 = BallotList.filter(ballots, team: "Team 1", round_number: 4)
    assert Enum.empty?(team1_round4)

    team1_up_to_round2 = BallotList.filter(ballots, team: "Team 1", up_to_round: 2)
    assert Enum.count(team1_up_to_round2) == 4

    team1_up_to_round3 = BallotList.filter(ballots, team: "Team 1", up_to_round: 3)
    assert Enum.count(team1_up_to_round3) == 6

    team1_up_to_round4 = BallotList.filter(ballots, team: "Team 1", up_to_round: 4)
    assert Enum.count(team1_up_to_round4) == 6

    team2_v_team1_up_to_round4 =
      BallotList.filter(ballots, defense: "Team 1", prosecution: "Team 2", up_to_round: 4)

    assert Enum.count(team2_v_team1_up_to_round4) == 2

    team1_and_team2_up_to_round4 =
      BallotList.filter(ballots, team: "Team 1", team: "Team 2", up_to_round: 4)

    assert Enum.count(team1_and_team2_up_to_round4) == 2
    assert BallotList.filter(ballots, round_number: 5, side: :defense) == ["Team 7", "Team 9"]
    assert BallotList.filter(ballots, side: :defense, round_number: 5) == ["Team 7", "Team 9"]
    assert BallotList.filter(ballots, round_number: 5, side: :prosecution) == ["Team 8", "Team 6"]
    assert BallotList.filter(ballots, side: :prosecution, round_number: 5) == ["Team 8", "Team 6"]
  end
end
