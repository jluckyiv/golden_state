defmodule RankingTest do
  use ExUnit.Case

  # TODO:
  # r2 matchups: ballots won, point differential, distance traveled
  # r3 matchups ballots won, point differential, distance traveled
  # r4 matchups ballots won, point differential, distance traveled
  #

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
             [shasta, carmel],
             [venture, tam],
             [university, redlands],
             [king, trinity]
           ]

    r1_ballots = [
      Ballot.new(
        scorer: "Delmare",
        prosecution: shasta,
        defense: carmel,
        round_number: 1,
        prosecution_score: 100,
        defense_score: 102
      ),
      Ballot.new(
        scorer: "Klein",
        prosecution: shasta,
        defense: carmel,
        round_number: 1,
        prosecution_score: 110,
        defense_score: 108
      ),
      Ballot.new(
        scorer: "Near",
        prosecution: venture,
        defense: tam,
        round_number: 1,
        prosecution_score: 110,
        defense_score: 101
      ),
      Ballot.new(
        scorer: "Junker",
        prosecution: venture,
        defense: tam,
        round_number: 1,
        prosecution_score: 102,
        defense_score: 96
      ),
      Ballot.new(
        scorer: "Barker",
        prosecution: university,
        defense: redlands,
        round_number: 1,
        prosecution_score: 99,
        defense_score: 104
      ),
      Ballot.new(
        scorer: "Knaack",
        prosecution: university,
        defense: redlands,
        round_number: 1,
        prosecution_score: 99,
        defense_score: 108
      ),
      Ballot.new(
        scorer: "Talmachoff",
        prosecution: king,
        defense: trinity,
        round_number: 1,
        prosecution_score: 112,
        defense_score: 112
      ),
      Ballot.new(
        scorer: "Gaughan",
        prosecution: king,
        defense: trinity,
        round_number: 1,
        prosecution_score: 93,
        defense_score: 96
      )
    ]

    round1_rankings = Ranking.rankings(teams, r1_ballots)

    assert BallotList.ballots_won(r1_ballots, redlands) == 2.0
    assert BallotList.ballots_won(r1_ballots, venture) == 2.0
    assert BallotList.ballots_won(r1_ballots, trinity) == 1.5
    assert BallotList.ballots_won(r1_ballots, carmel) == 1.0
    assert BallotList.ballots_won(r1_ballots, shasta) == 1.0
    assert BallotList.ballots_won(r1_ballots, king) == 0.5
    assert BallotList.ballots_won(r1_ballots, tam) == 0.0
    assert BallotList.ballots_won(r1_ballots, university) == 0.0

    assert BallotList.point_differential(r1_ballots, venture) == 15
    assert BallotList.point_differential(r1_ballots, redlands) == 14
    assert BallotList.point_differential(r1_ballots, trinity) == 3
    assert BallotList.point_differential(r1_ballots, carmel) == 0
    assert BallotList.point_differential(r1_ballots, shasta) == 0
    assert BallotList.point_differential(r1_ballots, king) == -3
    assert BallotList.point_differential(r1_ballots, university) == -14
    assert BallotList.point_differential(r1_ballots, tam) == -15

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

    round2 = Tournament.seed_round2(round1_rankings, round1)

    assert round2 == [
             [redlands, venture],
             [trinity, shasta],
             [carmel, king],
             [tam, university]
           ]

    round2_ballots = [
      Ballot.new(
        scorer: "Delmare",
        prosecution: redlands,
        defense: venture,
        round_number: 2,
        prosecution_score: 104,
        defense_score: 92
      ),
      Ballot.new(
        scorer: "Klein",
        prosecution: redlands,
        defense: venture,
        round_number: 2,
        prosecution_score: 87,
        defense_score: 88
      ),
      Ballot.new(
        scorer: "Near",
        prosecution: trinity,
        defense: shasta,
        round_number: 2,
        prosecution_score: 101,
        defense_score: 109
      ),
      Ballot.new(
        scorer: "Junker",
        prosecution: trinity,
        defense: shasta,
        round_number: 2,
        prosecution_score: 108,
        defense_score: 108
      ),
      Ballot.new(
        scorer: "Barker",
        prosecution: carmel,
        defense: king,
        round_number: 2,
        prosecution_score: 121,
        defense_score: 109
      ),
      Ballot.new(
        scorer: "Knaack",
        prosecution: carmel,
        defense: king,
        round_number: 2,
        prosecution_score: 109,
        defense_score: 111
      ),
      Ballot.new(
        scorer: "Talmachoff",
        prosecution: tam,
        defense: university,
        round_number: 2,
        prosecution_score: 98,
        defense_score: 90
      ),
      Ballot.new(
        scorer: "Gaughan",
        prosecution: tam,
        defense: university,
        round_number: 2,
        prosecution_score: 83,
        defense_score: 72
      )
    ]

    r1_r2_ballots = r1_ballots ++ round2_ballots

    round2_rankings = Ranking.rankings(teams, r1_r2_ballots)

    assert BallotList.ballots_won(r1_r2_ballots, redlands) == 3.0
    assert BallotList.ballots_won(r1_r2_ballots, venture) == 3.0
    assert BallotList.ballots_won(r1_r2_ballots, shasta) == 2.5
    assert BallotList.ballots_won(r1_r2_ballots, trinity) == 2.0
    assert BallotList.ballots_won(r1_r2_ballots, carmel) == 2.0
    assert BallotList.ballots_won(r1_r2_ballots, tam) == 2.0
    assert BallotList.ballots_won(r1_r2_ballots, king) == 1.5
    assert BallotList.ballots_won(r1_r2_ballots, university) == 0.0

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
             [venture, redlands],
             [shasta, carmel],
             [trinity, tam],
             [king, university]
           ]

    # fix [venture, redlands] conflict
    round3_ballots = [
      Ballot.new(
        scorer: "Delmare",
        prosecution: shasta,
        defense: redlands,
        round_number: 3,
        prosecution_score: 98,
        defense_score: 105
      ),
      Ballot.new(
        scorer: "Klein",
        prosecution: shasta,
        defense: redlands,
        round_number: 3,
        prosecution_score: 110,
        defense_score: 109
      ),
      Ballot.new(
        scorer: "Near",
        prosecution: venture,
        defense: carmel,
        round_number: 3,
        prosecution_score: 68,
        defense_score: 65
      ),
      Ballot.new(
        scorer: "Junker",
        prosecution: venture,
        defense: carmel,
        round_number: 3,
        prosecution_score: 104,
        defense_score: 96
      ),
      Ballot.new(
        scorer: "Barker",
        prosecution: trinity,
        defense: tam,
        round_number: 3,
        prosecution_score: 91,
        defense_score: 99
      ),
      Ballot.new(
        scorer: "Knaack",
        prosecution: trinity,
        defense: tam,
        round_number: 3,
        prosecution_score: 105,
        defense_score: 110
      ),
      Ballot.new(
        scorer: "Talmachoff",
        prosecution: king,
        defense: university,
        round_number: 3,
        prosecution_score: 96,
        defense_score: 107
      ),
      Ballot.new(
        scorer: "Gaughan",
        prosecution: king,
        defense: university,
        round_number: 3,
        prosecution_score: 84,
        defense_score: 100
      )
    ]

    r1_r2_r3_ballots = r1_ballots ++ round2_ballots ++ round3_ballots

    assert BallotList.ballots_won(r1_r2_r3_ballots, venture) == 5.0
    assert BallotList.ballots_won(r1_r2_r3_ballots, redlands) == 4.0
    assert BallotList.ballots_won(r1_r2_r3_ballots, tam) == 4.0
    assert BallotList.ballots_won(r1_r2_r3_ballots, shasta) == 3.5
    assert BallotList.ballots_won(r1_r2_r3_ballots, carmel) == 2.0
    assert BallotList.ballots_won(r1_r2_r3_ballots, university) == 2.0
    assert BallotList.ballots_won(r1_r2_r3_ballots, trinity) == 2.0
    assert BallotList.ballots_won(r1_r2_r3_ballots, king) == 1.5

    # assert BallotList.point_differential(r1_r2_r3_ballots, redlands) == 35
    # assert BallotList.point_differential(r1_r2_r3_ballots, carmel) == 21
    # assert BallotList.point_differential(r1_r2_r3_ballots, venture) == 13
    # assert BallotList.point_differential(r1_r2_r3_ballots, shasta) == 2
    # assert BallotList.point_differential(r1_r2_r3_ballots, university) == -6
    # assert BallotList.point_differential(r1_r2_r3_ballots, tam) == -7
    # assert BallotList.point_differential(r1_r2_r3_ballots, trinity) == -18
    # assert BallotList.point_differential(r1_r2_r3_ballots, king) == -40

    round3_rankings = Ranking.rankings(teams, r1_r2_r3_ballots)

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
             [redlands, venture],
             [tam, shasta],
             [carmel, trinity],
             [university, king]
           ]

    # fix [redlands, venture] with redlands <> carmel
    round4_ballots = [
      Ballot.new(
        scorer: "Delmare",
        prosecution: carmel,
        defense: shasta,
        round_number: 4,
        prosecution_score: 111,
        defense_score: 110
      ),
      Ballot.new(
        scorer: "Klein",
        prosecution: carmel,
        defense: shasta,
        round_number: 4,
        prosecution_score: 112,
        defense_score: 113
      ),
      Ballot.new(
        scorer: "Near",
        prosecution: tam,
        defense: venture,
        round_number: 4,
        prosecution_score: 115,
        defense_score: 109
      ),
      Ballot.new(
        scorer: "Junker",
        prosecution: tam,
        defense: venture,
        round_number: 4,
        prosecution_score: 109,
        defense_score: 109
      ),
      Ballot.new(
        scorer: "Barker",
        prosecution: redlands,
        defense: trinity,
        round_number: 4,
        prosecution_score: 105,
        defense_score: 104
      ),
      Ballot.new(
        scorer: "Knaack",
        prosecution: redlands,
        defense: trinity,
        round_number: 4,
        prosecution_score: 113,
        defense_score: 106
      ),
      Ballot.new(
        scorer: "Talmachoff",
        prosecution: university,
        defense: king,
        round_number: 4,
        prosecution_score: 96,
        defense_score: 107
      ),
      Ballot.new(
        scorer: "Gaughan",
        prosecution: university,
        defense: king,
        round_number: 4,
        prosecution_score: 84,
        defense_score: 100
      )
    ]

    r1_r2_r3_r4_ballots = r1_ballots ++ round2_ballots ++ round3_ballots ++ round4_ballots

    # round4_rankings = Ranking.final_rankings(teams, r1_r2_r3_r4_ballots)

    final_rankings = Ranking.final_rankings(teams, r1_r2_r3_r4_ballots)

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

    # Championship pairing
    ## total ballots, head to head, combined_strength, point_differential
    ## head-to-head: ballots, point_differential, closing score, motion score

    # Final rankings
    ## total ballots, head to head, combined_strength, point_differential, distance
    ## head-to-head: ballots, point_differential, closing score, motion score

    assert BallotList.ballots_won(r1_r2_r3_r4_ballots, redlands) == 6.0
    assert BallotList.ballots_won(r1_r2_r3_r4_ballots, tam) == 5.5
    assert BallotList.ballots_won(r1_r2_r3_r4_ballots, shasta) == 4.5
    assert BallotList.ballots_won(r1_r2_r3_r4_ballots, venture) == 5.5
    assert BallotList.ballots_won(r1_r2_r3_r4_ballots, king) == 3.5
    assert BallotList.ballots_won(r1_r2_r3_r4_ballots, carmel) == 3.0
    assert BallotList.ballots_won(r1_r2_r3_r4_ballots, trinity) == 2.0
    assert BallotList.ballots_won(r1_r2_r3_r4_ballots, university) == 2.0

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
