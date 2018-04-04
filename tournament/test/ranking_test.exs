defmodule RankingTest do
  use ExUnit.Case

  # TODO

  test "attorney and witness ties go to higher-ranked team" do
    team1 = %{name: "Team 1"}
    team2 = %{name: "Team 2"}

    ballots = [
      Ballot.new(
        defense: team1,
        defense_total_score: 101,
        defense_motion_attorney: "D Motion",
        defense_motion_score: 10,
        prosecution: team2,
        prosecution_total_score: 102,
        prosecution_motion_attorney: "P Motion",
        prosecution_motion_score: 9,
        attorney_ranks: [
          defense: "Attorney 11",
          prosecution: "Attorney 12",
          defense: "Attorney 13",
          prosecution: "Attorney 14"
        ],
        witness_ranks: [
          defense: "Witness 11",
          prosecution: "Witness 14",
          defense: "Witness 13",
          prosecution: "Witness 12"
        ],
        round_number: 1,
        scorer: "Scorer 1"
      ),
      Ballot.new(
        defense: team1,
        defense_total_score: 101,
        defense_motion_attorney: "D Motion",
        defense_motion_score: 10,
        prosecution: team2,
        prosecution_total_score: 102,
        prosecution_motion_attorney: "P Motion",
        prosecution_motion_score: 9,
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
      )
    ]

    assert BallotList.total(ballots, total_score: team2) == 204
    assert BallotList.total(ballots, total_score: team1) == 202

    attorney_ranks = Ranking.Individual.rankings(ballots, :attorney_ranks)

    assert Enum.map(attorney_ranks, &{&1.team.name, &1.name, &1.score}) == [
             {"Team 2", "Attorney 12", 2.25},
             {"Team 1", "Attorney 11", 2.25},
             {"Team 1", "Attorney 13", 1.5},
             {"Team 2", "Attorney 14", 1.0}
           ]

    witness_ranks = Ranking.Individual.rankings(ballots, position: :witness)

    assert Enum.map(witness_ranks, &{&1.team.name, &1.name, &1.score}) == [
             {"Team 1", "Witness 11", 2.5},
             {"Team 2", "Witness 14", 1.75},
             {"Team 1", "Witness 13", 1.75},
             {"Team 2", "Witness 12", 1.0}
           ]

    motion_ranks = Ranking.Individual.rankings(ballots, ranks: :motion)

    assert Enum.map(motion_ranks, &{&1.team.name, &1.name, &1.score}) == [
             {"Team 2", "P Motion", :ineligible},
             {"Team 1", "D Motion", :ineligible}
           ]
  end

  test "eliminate bye buster ranks" do
    team1 = %{name: "Team 1"}
    bye = %{name: "Bye Buster"}

    ballots = [
      Ballot.new(
        defense: team1,
        defense_total_score: 101,
        defense_motion_attorney: "D Motion",
        defense_motion_score: 10,
        prosecution: bye,
        prosecution_total_score: 102,
        prosecution_motion_attorney: "P Motion",
        prosecution_motion_score: 9,
        attorney_ranks: [
          defense: "Attorney 11",
          prosecution: "Attorney 12",
          defense: "Attorney 13",
          prosecution: "Attorney 14"
        ],
        witness_ranks: [
          defense: "Witness 11",
          prosecution: "Witness 14",
          defense: "Witness 13",
          prosecution: "Witness 12"
        ],
        round_number: 1,
        scorer: "Scorer 1"
      ),
      Ballot.new(
        defense: team1,
        defense_total_score: 101,
        defense_motion_attorney: "D Motion",
        defense_motion_score: 10,
        prosecution: bye,
        prosecution_total_score: 102,
        prosecution_motion_attorney: "P Motion",
        prosecution_motion_score: 9,
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
      )
    ]

    assert BallotList.total(ballots, total_score: bye) == 204
    assert BallotList.total(ballots, total_score: team1) == 202

    attorney_ranks = Ranking.Individual.rankings(ballots, :attorney_ranks)

    assert Enum.map(attorney_ranks, &{&1.team.name, &1.name, &1.score}) == [
             {"Team 1", "Attorney 11", 2.25},
             {"Team 1", "Attorney 13", 1.5}
           ]

    witness_ranks = Ranking.Individual.rankings(ballots, position: :witness)

    assert Enum.map(witness_ranks, &{&1.team.name, &1.name, &1.score}) == [
             {"Team 1", "Witness 11", 2.5},
             {"Team 1", "Witness 13", 1.75}
           ]

    motion_ranks = Ranking.Individual.rankings(ballots, ranks: :motion)

    assert Enum.map(motion_ranks, &{&1.team.name, &1.name, &1.score}) == [
             {"Team 1", "D Motion", :ineligible}
           ]
  end
end
