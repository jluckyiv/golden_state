defmodule RankingTest do
  use ExUnit.Case

  # TODO:
  # r2 matchups: ballots won, point differential, distance traveled
  # r3 matchups ballots won, point differential, distance traveled
  # r4 matchups ballots won, point differential, distance traveled
  #

  test "attorney and witness ties go to higher-ranked team" do
    ballots = [
      Ballot.new(
        defense: "Team 1",
        defense_total_score: 101,
        defense_motion_attorney: "D Motion",
        defense_motion_score: 10,
        prosecution: "Team 2",
        prosecution_total_score: 102,
        prosecution_motion_attorney: "P Motion",
        prosecution_motion_score: 10,
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
        defense: "Team 1",
        defense_total_score: 101,
        defense_motion_attorney: "D Motion",
        defense_motion_score: 10,
        prosecution: "Team 2",
        prosecution_total_score: 102,
        prosecution_motion_attorney: "P Motion",
        prosecution_motion_score: 10,
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

    assert BallotList.total(ballots, total_score: "Team 2") == 204
    assert BallotList.total(ballots, total_score: "Team 1") == 202

    attorney_ranks = Rank.Team.rankings(ballots, :attorney_ranks)

    assert Enum.map(attorney_ranks, &{&1.team, &1.name, &1.score}) == [
             {"Team 2", "Attorney 12", 9},
             {"Team 1", "Attorney 11", 9},
             {"Team 1", "Attorney 13", 6},
             {"Team 2", "Attorney 14", 4}
           ]

    witness_ranks = Rank.Team.rankings(ballots, :witness_ranks)

    assert Enum.map(witness_ranks, &{&1.team, &1.name, &1.score}) == [
             {"Team 1", "Witness 11", 10},
             {"Team 2", "Witness 14", 7},
             {"Team 1", "Witness 13", 7},
             {"Team 2", "Witness 12", 4}
           ]

    # motion_ranks = Rank.Individual.rankings(ballots, :motion_ranks)

    # assert Enum.map(motion_ranks, &{&1.team, &1.name, &1.score}) == []
  end

  test "regular rankings: ballots won, point differential, distance traveled" do
    :rand.seed(:exsplus, {101, 102, 103})

    carmel = Team.new(name: "Carmel", distance_traveled: 380)
    king = Team.new(name: "King", distance_traveled: 0)
    redlands = Team.new(name: "Redlands", distance_traveled: 20)
    shasta = Team.new(name: "Shasta", distance_traveled: 600)
    tam = Team.new(name: "Tamalpais", distance_traveled: 450)
    trinity = Team.new(name: "Trinity", distance_traveled: 100)
    university = Team.new(name: "University", distance_traveled: 40)
    venture = Team.new(name: "Venture", distance_traveled: 400)

    teams = [
      carmel,
      king,
      redlands,
      shasta,
      tam,
      trinity,
      university,
      venture
    ]

    round1 = Tournament.seed_round1(teams)

    assert round1 == [
             {shasta, carmel},
             {venture, tam},
             {university, redlands},
             {king, trinity}
           ]

    r1_ballots = [
      Ballot.new(
        scorer: "Delmare",
        prosecution: shasta,
        defense: carmel,
        round_number: 1,
        prosecution_total_score: 100,
        defense_total_score: 102
      ),
      Ballot.new(
        scorer: "Klein",
        prosecution: shasta,
        defense: carmel,
        round_number: 1,
        prosecution_total_score: 110,
        defense_total_score: 108
      ),
      Ballot.new(
        scorer: "Near",
        prosecution: venture,
        defense: tam,
        round_number: 1,
        prosecution_total_score: 110,
        defense_total_score: 101
      ),
      Ballot.new(
        scorer: "Junker",
        prosecution: venture,
        defense: tam,
        round_number: 1,
        prosecution_total_score: 102,
        defense_total_score: 96
      ),
      Ballot.new(
        scorer: "Barker",
        prosecution: university,
        defense: redlands,
        round_number: 1,
        prosecution_total_score: 99,
        defense_total_score: 104
      ),
      Ballot.new(
        scorer: "Knaack",
        prosecution: university,
        defense: redlands,
        round_number: 1,
        prosecution_total_score: 99,
        defense_total_score: 108
      ),
      Ballot.new(
        scorer: "Talmachoff",
        prosecution: king,
        defense: trinity,
        round_number: 1,
        prosecution_total_score: 112,
        defense_total_score: 112
      ),
      Ballot.new(
        scorer: "Gaughan",
        prosecution: king,
        defense: trinity,
        round_number: 1,
        prosecution_total_score: 93,
        defense_total_score: 96
      )
    ]

    assert BallotList.total(r1_ballots, ballots_won: redlands) == 2.0
    assert BallotList.total(r1_ballots, ballots_won: venture) == 2.0
    assert BallotList.total(r1_ballots, ballots_won: trinity) == 1.5
    assert BallotList.total(r1_ballots, ballots_won: carmel) == 1.0
    assert BallotList.total(r1_ballots, ballots_won: shasta) == 1.0
    assert BallotList.total(r1_ballots, ballots_won: king) == 0.5
    assert BallotList.total(r1_ballots, ballots_won: tam) == 0.0
    assert BallotList.total(r1_ballots, ballots_won: university) == 0.0

    assert BallotList.total(r1_ballots, point_differential: venture) == 15
    assert BallotList.total(r1_ballots, point_differential: redlands) == 14
    assert BallotList.total(r1_ballots, point_differential: trinity) == 3
    assert BallotList.total(r1_ballots, point_differential: carmel) == 0
    assert BallotList.total(r1_ballots, point_differential: shasta) == 0
    assert BallotList.total(r1_ballots, point_differential: king) == -3
    assert BallotList.total(r1_ballots, point_differential: university) == -14
    assert BallotList.total(r1_ballots, point_differential: tam) == -15

    round1_rankings = Rank.Team.rankings(r1_ballots)

    assert round1_rankings == [
             venture,
             redlands,
             trinity,
             shasta,
             carmel,
             king,
             university,
             tam
           ]

    assert Rank.Team.ranking(r1_ballots, venture) == 1
    assert Rank.Team.ranking(r1_ballots, redlands) == 2
    assert Rank.Team.ranking(r1_ballots, trinity) == 3
    assert Rank.Team.ranking(r1_ballots, shasta) == 4
    assert Rank.Team.ranking(r1_ballots, carmel) == 5
    assert Rank.Team.ranking(r1_ballots, king) == 6
    assert Rank.Team.ranking(r1_ballots, university) == 7
    assert Rank.Team.ranking(r1_ballots, tam) == 8

    round2 = Tournament.seed_round2(round1_rankings, round1)

    assert round2 == [
             {redlands, venture},
             {trinity, shasta},
             {carmel, king},
             {tam, university}
           ]

    round2_ballots = [
      Ballot.new(
        scorer: "Delmare",
        prosecution: redlands,
        defense: venture,
        round_number: 2,
        prosecution_total_score: 104,
        defense_total_score: 92
      ),
      Ballot.new(
        scorer: "Klein",
        prosecution: redlands,
        defense: venture,
        round_number: 2,
        prosecution_total_score: 87,
        defense_total_score: 88
      ),
      Ballot.new(
        scorer: "Near",
        prosecution: trinity,
        defense: shasta,
        round_number: 2,
        prosecution_total_score: 101,
        defense_total_score: 109
      ),
      Ballot.new(
        scorer: "Junker",
        prosecution: trinity,
        defense: shasta,
        round_number: 2,
        prosecution_total_score: 108,
        defense_total_score: 108
      ),
      Ballot.new(
        scorer: "Barker",
        prosecution: carmel,
        defense: king,
        round_number: 2,
        prosecution_total_score: 121,
        defense_total_score: 109
      ),
      Ballot.new(
        scorer: "Knaack",
        prosecution: carmel,
        defense: king,
        round_number: 2,
        prosecution_total_score: 109,
        defense_total_score: 111
      ),
      Ballot.new(
        scorer: "Talmachoff",
        prosecution: tam,
        defense: university,
        round_number: 2,
        prosecution_total_score: 98,
        defense_total_score: 90
      ),
      Ballot.new(
        scorer: "Gaughan",
        prosecution: tam,
        defense: university,
        round_number: 2,
        prosecution_total_score: 83,
        defense_total_score: 72
      )
    ]

    r1_r2_ballots = r1_ballots ++ round2_ballots

    round2_rankings = Rank.Team.rankings(r1_r2_ballots)

    assert BallotList.total(r1_r2_ballots, ballots_won: redlands) == 3.0
    assert BallotList.total(r1_r2_ballots, ballots_won: venture) == 3.0
    assert BallotList.total(r1_r2_ballots, ballots_won: shasta) == 2.5
    assert BallotList.total(r1_r2_ballots, ballots_won: trinity) == 2.0
    assert BallotList.total(r1_r2_ballots, ballots_won: carmel) == 2.0
    assert BallotList.total(r1_r2_ballots, ballots_won: tam) == 2.0
    assert BallotList.total(r1_r2_ballots, ballots_won: king) == 1.5
    assert BallotList.total(r1_r2_ballots, ballots_won: university) == 0.0

    # assert BallotList.point_differential(r1_r2_ballots, redlands) == 29
    # assert BallotList.point_differential(r1_r2_ballots, carmel) == 10
    # assert BallotList.point_differential(r1_r2_ballots, shasta) == 8
    # assert BallotList.point_differential(r1_r2_ballots, tam) == 4
    # assert BallotList.point_differential(r1_r2_ballots, venture) == 0
    # assert BallotList.point_differential(r1_r2_ballots, trinity) == -5
    # assert BallotList.point_differential(r1_r2_ballots, king) == -13
    # assert BallotList.point_differential(r1_r2_ballots, university) == -33

    assert round2_rankings == [
             redlands,
             venture,
             shasta,
             carmel,
             tam,
             trinity,
             king,
             university
           ]

    round3 = Tournament.seed_round3(round2_rankings)

    assert round3 == [
             {venture, redlands},
             {shasta, carmel},
             {trinity, tam},
             {king, university}
           ]

    # fix [venture, redlands] conflict
    round3_ballots = [
      Ballot.new(
        scorer: "Delmare",
        prosecution: shasta,
        defense: redlands,
        round_number: 3,
        prosecution_total_score: 98,
        defense_total_score: 105
      ),
      Ballot.new(
        scorer: "Klein",
        prosecution: shasta,
        defense: redlands,
        round_number: 3,
        prosecution_total_score: 110,
        defense_total_score: 109
      ),
      Ballot.new(
        scorer: "Near",
        prosecution: venture,
        defense: carmel,
        round_number: 3,
        prosecution_total_score: 68,
        defense_total_score: 65
      ),
      Ballot.new(
        scorer: "Junker",
        prosecution: venture,
        defense: carmel,
        round_number: 3,
        prosecution_total_score: 104,
        defense_total_score: 96
      ),
      Ballot.new(
        scorer: "Barker",
        prosecution: trinity,
        defense: tam,
        round_number: 3,
        prosecution_total_score: 91,
        defense_total_score: 99
      ),
      Ballot.new(
        scorer: "Knaack",
        prosecution: trinity,
        defense: tam,
        round_number: 3,
        prosecution_total_score: 105,
        defense_total_score: 110
      ),
      Ballot.new(
        scorer: "Talmachoff",
        prosecution: king,
        defense: university,
        round_number: 3,
        prosecution_total_score: 96,
        defense_total_score: 107
      ),
      Ballot.new(
        scorer: "Gaughan",
        prosecution: king,
        defense: university,
        round_number: 3,
        prosecution_total_score: 84,
        defense_total_score: 100
      )
    ]

    r1_r2_r3_ballots = r1_ballots ++ round2_ballots ++ round3_ballots

    assert BallotList.total(r1_r2_r3_ballots, ballots_won: venture) == 5.0
    assert BallotList.total(r1_r2_r3_ballots, ballots_won: redlands) == 4.0
    assert BallotList.total(r1_r2_r3_ballots, ballots_won: tam) == 4.0
    assert BallotList.total(r1_r2_r3_ballots, ballots_won: shasta) == 3.5
    assert BallotList.total(r1_r2_r3_ballots, ballots_won: carmel) == 2.0
    assert BallotList.total(r1_r2_r3_ballots, ballots_won: university) == 2.0
    assert BallotList.total(r1_r2_r3_ballots, ballots_won: trinity) == 2.0
    assert BallotList.total(r1_r2_r3_ballots, ballots_won: king) == 1.5

    # assert BallotList.point_differential(r1_r2_r3_ballots, redlands) == 35
    # assert BallotList.point_differential(r1_r2_r3_ballots, carmel) == 21
    # assert BallotList.point_differential(r1_r2_r3_ballots, venture) == 13
    # assert BallotList.point_differential(r1_r2_r3_ballots, shasta) == 2
    # assert BallotList.point_differential(r1_r2_r3_ballots, university) == -6
    # assert BallotList.point_differential(r1_r2_r3_ballots, tam) == -7
    # assert BallotList.point_differential(r1_r2_r3_ballots, trinity) == -18
    # assert BallotList.point_differential(r1_r2_r3_ballots, king) == -40

    round3_rankings = Rank.Team.rankings(r1_r2_r3_ballots)

    assert round3_rankings == [
             venture,
             redlands,
             tam,
             shasta,
             carmel,
             university,
             trinity,
             king
           ]

    round4 = Tournament.seed_round4(round3_rankings, round3)

    assert round4 == [
             {redlands, venture},
             {tam, shasta},
             {carmel, trinity},
             {university, king}
           ]

    # fix [redlands, venture] with redlands <> carmel
    round4_ballots = [
      Ballot.new(
        scorer: "Delmare",
        prosecution: carmel,
        defense: shasta,
        round_number: 4,
        prosecution_total_score: 111,
        defense_total_score: 110
      ),
      Ballot.new(
        scorer: "Klein",
        prosecution: carmel,
        defense: shasta,
        round_number: 4,
        prosecution_total_score: 112,
        defense_total_score: 113
      ),
      Ballot.new(
        scorer: "Near",
        prosecution: tam,
        defense: venture,
        round_number: 4,
        prosecution_total_score: 115,
        defense_total_score: 109
      ),
      Ballot.new(
        scorer: "Junker",
        prosecution: tam,
        defense: venture,
        round_number: 4,
        prosecution_total_score: 109,
        defense_total_score: 109
      ),
      Ballot.new(
        scorer: "Barker",
        prosecution: redlands,
        defense: trinity,
        round_number: 4,
        prosecution_total_score: 105,
        defense_total_score: 104
      ),
      Ballot.new(
        scorer: "Knaack",
        prosecution: redlands,
        defense: trinity,
        round_number: 4,
        prosecution_total_score: 113,
        defense_total_score: 106
      ),
      Ballot.new(
        scorer: "Talmachoff",
        prosecution: university,
        defense: king,
        round_number: 4,
        prosecution_total_score: 96,
        defense_total_score: 107
      ),
      Ballot.new(
        scorer: "Gaughan",
        prosecution: university,
        defense: king,
        round_number: 4,
        prosecution_total_score: 84,
        defense_total_score: 100
      )
    ]

    r1_r2_r3_r4_ballots = r1_ballots ++ round2_ballots ++ round3_ballots ++ round4_ballots

    # round4_rankings = Rank.Team.final_rankings(r1_r2_r3_r4_ballots)

    final_rankings = Rank.Team.final_rankings(r1_r2_r3_r4_ballots)

    assert final_rankings == [
             redlands,
             venture,
             tam,
             shasta,
             king,
             carmel,
             trinity,
             university
           ]

    assert Rank.Team.final_ranking(r1_r2_r3_r4_ballots, redlands) == 1
    assert Rank.Team.final_ranking(r1_r2_r3_r4_ballots, venture) == 2
    assert Rank.Team.final_ranking(r1_r2_r3_r4_ballots, tam) == 3
    assert Rank.Team.final_ranking(r1_r2_r3_r4_ballots, shasta) == 4
    assert Rank.Team.final_ranking(r1_r2_r3_r4_ballots, king) == 5
    assert Rank.Team.final_ranking(r1_r2_r3_r4_ballots, carmel) == 6
    assert Rank.Team.final_ranking(r1_r2_r3_r4_ballots, trinity) == 7
    assert Rank.Team.final_ranking(r1_r2_r3_r4_ballots, university) == 8

    # Championship pairing
    ## total ballots, head to head, combined_strength, point_differential
    ## head-to-head: ballots, point_differential, closing score, motion score

    # Final rankings
    ## total ballots, head to head, combined_strength, point_differential, distance
    ## head-to-head: ballots, point_differential, closing score, motion score

    assert BallotList.total(r1_r2_r3_r4_ballots, ballots_won: redlands) == 6.0
    assert BallotList.total(r1_r2_r3_r4_ballots, ballots_won: tam) == 5.5
    assert BallotList.total(r1_r2_r3_r4_ballots, ballots_won: shasta) == 4.5
    assert BallotList.total(r1_r2_r3_r4_ballots, ballots_won: venture) == 5.5
    assert BallotList.total(r1_r2_r3_r4_ballots, ballots_won: king) == 3.5
    assert BallotList.total(r1_r2_r3_r4_ballots, ballots_won: carmel) == 3.0
    assert BallotList.total(r1_r2_r3_r4_ballots, ballots_won: trinity) == 2.0
    assert BallotList.total(r1_r2_r3_r4_ballots, ballots_won: university) == 2.0

    # assert BallotList.point_differential(r1_r2_r3_r4_ballots, redlands) == 34
    # assert BallotList.point_differential(r1_r2_r3_r4_ballots, tam) == 1
    # assert BallotList.point_differential(r1_r2_r3_r4_ballots, carmel) == 22
    # assert BallotList.point_differential(r1_r2_r3_r4_ballots, venture) == 19
    # assert BallotList.point_differential(r1_r2_r3_r4_ballots, king) == -13
    # assert BallotList.point_differential(r1_r2_r3_r4_ballots, shasta) == -4
    # assert BallotList.point_differential(r1_r2_r3_r4_ballots, trinity) == -26
    # assert BallotList.point_differential(r1_r2_r3_r4_ballots, university) == -33
  end
end
