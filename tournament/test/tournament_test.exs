defmodule TournamentTest do
  use ExUnit.Case
  doctest Tournament

  # DONE
  # r1 pairings
  ## random draw PDPDPD
  ## extraordinary circs pick first side
  # r2 pairings
  ## switch sides from previous round
  ## r1 #1P v. #1D
  # r3 pairings 
  ## #1 v. #2, sides decided by coin flip, PDDP or DPPD
  # r4 pairings
  ## switch sides from previous round
  ## r3 #1P v. #1D
  #
  # conflicts: no rematches (except final), same school
  # 1. Step #1: Swap the lower-ranked team down into the next lower-ranked matchup.
  # 2. Step #2: Swap the higher-ranked team down into the next lower-ranked matchup.
  # 3. Step #3: Swap the higher-ranked team up into the next highest-ranked matchup.
  # 4. Step #4: Swap the lower-ranked team up into the next highest-ranked matchup.
  # 5. Step #5: Repeat steps #1-4 moving to the 2nd lowest or highest-ranked matchup.
  # 6. Step #6: Repeat steps #1-4 moving to the 3rd lowest or highest-ranked matchup.
  #
  # Individual awards
  # Ranks for wits/attys: 5, 4, 3, 2
  # Motions: point differential average per ballot
  # Clerk and bailiff: point average per ballot
  # Ties go to higher-ranked team

  # TODO
  # assign presider?
  # assign scorers?
  # assign department?

  test "simulated tournament" do
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

    tournament =
      [name: "GS18", teams: teams]
      |> Tournament.start()

    round1 = Tournament.random_pairings(tournament)

    assert round1 == [
             {shasta, carmel},
             {venture, tam},
             {university, redlands},
             {king, trinity}
           ]

    tournament =
      tournament
      |> Tournament.add_pairings(round1, round_number: 1)
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Delmare",
          prosecution: shasta,
          defense: carmel,
          round_number: 1,
          prosecution_total_score: 100,
          defense_total_score: 102
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Klein",
          prosecution: shasta,
          defense: carmel,
          round_number: 1,
          prosecution_total_score: 110,
          defense_total_score: 108
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Near",
          prosecution: venture,
          defense: tam,
          round_number: 1,
          prosecution_total_score: 110,
          defense_total_score: 101
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Junker",
          prosecution: venture,
          defense: tam,
          round_number: 1,
          prosecution_total_score: 102,
          defense_total_score: 96
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Barker",
          prosecution: university,
          defense: redlands,
          round_number: 1,
          prosecution_total_score: 99,
          defense_total_score: 104
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Knaack",
          prosecution: university,
          defense: redlands,
          round_number: 1,
          prosecution_total_score: 99,
          defense_total_score: 108
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Talmachoff",
          prosecution: king,
          defense: trinity,
          round_number: 1,
          prosecution_total_score: 112,
          defense_total_score: 112
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Gaughan",
          prosecution: king,
          defense: trinity,
          round_number: 1,
          prosecution_total_score: 93,
          defense_total_score: 96
        )
      )

    assert Tournament.ranked_teams(tournament, round_number: 1) == [
             {%{
                name: "Venture",
                ballots_won: 2.0,
                point_differential: 15,
                distance_traveled: 400
              }, 1},
             {%{
                name: "Redlands",
                ballots_won: 2.0,
                point_differential: 14,
                distance_traveled: 20
              }, 2},
             {%{
                name: "Trinity",
                ballots_won: 1.5,
                point_differential: 3,
                distance_traveled: 100
              }, 3},
             {%{
                name: "Shasta",
                ballots_won: 1.0,
                point_differential: 0,
                distance_traveled: 600
              }, 4},
             {%{
                name: "Carmel",
                ballots_won: 1.0,
                point_differential: 0,
                distance_traveled: 380
              }, 5},
             {%{
                name: "King",
                ballots_won: 0.5,
                point_differential: -3,
                distance_traveled: 0
              }, 6},
             {%{
                name: "University",
                ballots_won: 0.0,
                point_differential: -14,
                distance_traveled: 40
              }, 7},
             {%{
                name: "Tamalpais",
                ballots_won: 0.0,
                point_differential: -15,
                distance_traveled: 450
              }, 8}
           ]

    round2 = Tournament.seed(tournament, round_number: 2)

    assert round2 == [
             {redlands, venture},
             {trinity, shasta},
             {carmel, king},
             {tam, university}
           ]

    tournament =
      tournament
      |> Tournament.add_pairings(round2, round_number: 2)
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Delmare",
          prosecution: redlands,
          defense: venture,
          round_number: 2,
          prosecution_total_score: 104,
          defense_total_score: 92
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Klein",
          prosecution: redlands,
          defense: venture,
          round_number: 2,
          prosecution_total_score: 87,
          defense_total_score: 88
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Near",
          prosecution: trinity,
          defense: shasta,
          round_number: 2,
          prosecution_total_score: 101,
          defense_total_score: 109
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Junker",
          prosecution: trinity,
          defense: shasta,
          round_number: 2,
          prosecution_total_score: 108,
          defense_total_score: 108
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Barker",
          prosecution: carmel,
          defense: king,
          round_number: 2,
          prosecution_total_score: 121,
          defense_total_score: 109
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Knaack",
          prosecution: carmel,
          defense: king,
          round_number: 2,
          prosecution_total_score: 109,
          defense_total_score: 111
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Talmachoff",
          prosecution: tam,
          defense: university,
          round_number: 2,
          prosecution_total_score: 98,
          defense_total_score: 90
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Gaughan",
          prosecution: tam,
          defense: university,
          round_number: 2,
          prosecution_total_score: 83,
          defense_total_score: 72
        )
      )

    assert Tournament.ranked_teams(tournament, round_number: 2) == [
             {%{
                ballots_won: 3.0,
                distance_traveled: 20,
                name: "Redlands",
                point_differential: 25
              }, 1},
             {%{
                ballots_won: 3.0,
                distance_traveled: 400,
                name: "Venture",
                point_differential: 4
              }, 2},
             {%{
                ballots_won: 2.5,
                distance_traveled: 600,
                name: "Shasta",
                point_differential: 8
              }, 3},
             {%{
                ballots_won: 2.0,
                distance_traveled: 380,
                name: "Carmel",
                point_differential: 10
              }, 4},
             {%{
                ballots_won: 2.0,
                distance_traveled: 450,
                name: "Tamalpais",
                point_differential: 4
              }, 5},
             {%{
                ballots_won: 2.0,
                distance_traveled: 100,
                name: "Trinity",
                point_differential: -5
              }, 6},
             {%{
                ballots_won: 1.5,
                distance_traveled: 0,
                name: "King",
                point_differential: -13
              }, 7},
             {%{
                ballots_won: 0.0,
                distance_traveled: 40,
                name: "University",
                point_differential: -33
              }, 8}
           ]

    # TODO fix {venture, redlands} conflict
    round3 = Tournament.seed(tournament, round_number: 3)

    assert round3 == [
             {venture, redlands},
             {shasta, carmel},
             {trinity, tam},
             {king, university}
           ]

    tournament =
      tournament
      |> Tournament.add_pairings(round3, round_number: 3)
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Delmare",
          prosecution: shasta,
          defense: redlands,
          round_number: 3,
          prosecution_total_score: 98,
          defense_total_score: 105
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Klein",
          prosecution: shasta,
          defense: redlands,
          round_number: 3,
          prosecution_total_score: 110,
          defense_total_score: 109
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Near",
          prosecution: venture,
          defense: carmel,
          round_number: 3,
          prosecution_total_score: 68,
          defense_total_score: 65
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Junker",
          prosecution: venture,
          defense: carmel,
          round_number: 3,
          prosecution_total_score: 104,
          defense_total_score: 96
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Barker",
          prosecution: trinity,
          defense: tam,
          round_number: 3,
          prosecution_total_score: 91,
          defense_total_score: 99
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Knaack",
          prosecution: trinity,
          defense: tam,
          round_number: 3,
          prosecution_total_score: 105,
          defense_total_score: 110
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Talmachoff",
          prosecution: king,
          defense: university,
          round_number: 3,
          prosecution_total_score: 96,
          defense_total_score: 107
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Gaughan",
          prosecution: king,
          defense: university,
          round_number: 3,
          prosecution_total_score: 84,
          defense_total_score: 100
        )
      )

    round3_rankings = Tournament.ranked_teams(tournament, round_number: 3)

    assert round3_rankings == [
             {%{
                ballots_won: 5.0,
                distance_traveled: 400,
                name: "Venture",
                point_differential: 15
              }, 1},
             {%{
                ballots_won: 4.0,
                distance_traveled: 20,
                name: "Redlands",
                point_differential: 31
              }, 2},
             {%{
                ballots_won: 4.0,
                distance_traveled: 450,
                name: "Tamalpais",
                point_differential: 17
              }, 3},
             {%{
                ballots_won: 3.5,
                distance_traveled: 600,
                name: "Shasta",
                point_differential: 2
              }, 4},
             {%{
                ballots_won: 2.0,
                distance_traveled: 380,
                name: "Carmel",
                point_differential: -1
              }, 5},
             {%{
                ballots_won: 2.0,
                distance_traveled: 40,
                name: "University",
                point_differential: -6
              }, 6},
             {%{
                ballots_won: 2.0,
                distance_traveled: 100,
                name: "Trinity",
                point_differential: -18
              }, 7},
             {%{
                ballots_won: 1.5,
                distance_traveled: 0,
                name: "King",
                point_differential: -40
              }, 8}
           ]

    round4 = Tournament.seed(tournament, round_number: 4)

    # fix [redlands, venture] with redlands <> carmel
    assert round4 == [
             {redlands, venture},
             {tam, shasta},
             {carmel, trinity},
             {university, king}
           ]

    tournament =
      tournament
      |> Tournament.add_pairings(round4, round_number: 4)
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Delmare",
          prosecution: carmel,
          defense: shasta,
          round_number: 4,
          prosecution_total_score: 111,
          defense_total_score: 110
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Klein",
          prosecution: carmel,
          defense: shasta,
          round_number: 4,
          prosecution_total_score: 112,
          defense_total_score: 113
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Near",
          prosecution: tam,
          defense: venture,
          round_number: 4,
          prosecution_total_score: 115,
          defense_total_score: 109
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Junker",
          prosecution: tam,
          defense: venture,
          round_number: 4,
          prosecution_total_score: 109,
          defense_total_score: 109
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Barker",
          prosecution: redlands,
          defense: trinity,
          round_number: 4,
          prosecution_total_score: 105,
          defense_total_score: 104
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Knaack",
          prosecution: redlands,
          defense: trinity,
          round_number: 4,
          prosecution_total_score: 113,
          defense_total_score: 106
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Talmachoff",
          prosecution: university,
          defense: king,
          round_number: 4,
          prosecution_total_score: 96,
          defense_total_score: 107
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Gaughan",
          prosecution: university,
          defense: king,
          round_number: 4,
          prosecution_total_score: 84,
          defense_total_score: 100
        )
      )

    final_rankings = Tournament.ranked_teams(tournament, round_number: 4)

    # venture beat tam head to head round 1: 2 ballots, 15 points
    # trinity has a higher point differential than university
    assert final_rankings == [
             {%{
                ballots_won: 6.0,
                distance_traveled: 20,
                name: "Redlands",
                point_differential: 39
              }, 1},
             {%{
                ballots_won: 5.5,
                distance_traveled: 400,
                name: "Venture",
                point_differential: 9
              }, 2},
             {%{
                ballots_won: 5.5,
                distance_traveled: 450,
                name: "Tamalpais",
                point_differential: 23
              }, 3},
             {%{
                ballots_won: 4.5,
                distance_traveled: 600,
                name: "Shasta",
                point_differential: 2
              }, 4},
             {%{
                ballots_won: 3.5,
                distance_traveled: 0,
                name: "King",
                point_differential: -13
              }, 5},
             {%{
                ballots_won: 3.0,
                distance_traveled: 380,
                name: "Carmel",
                point_differential: -1
              }, 6},
             {%{
                ballots_won: 2.0,
                distance_traveled: 100,
                name: "Trinity",
                point_differential: -26
              }, 7},
             {%{
                ballots_won: 2.0,
                distance_traveled: 40,
                name: "University",
                point_differential: -33
              }, 8}
           ]

    # Championship pairing
    ## total ballots, head to head, combined_strength, point_differential
    ## head-to-head: ballots, point_differential, closing score, motion score
  end
end
