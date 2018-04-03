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
  # Bye Buster
  # bye buster begins on prosecution
  # bye buster is always lowest seed
  # bye buster is not eligible for awards
  # bye buster is calculated for CS
  #
  # 3rd round tie ballots won and point differential; distance traveled is tiebreak
  #
  # Individual awards
  # Ranks for wits/attys: 5, 4, 3, 2
  # Ties go to higher-ranked team
  # bye buster competitors are not eligible for awards

  # TODO
  # Motions: point differential average per ballot
  # Clerk and bailiff: point average per ballot
  #
  # assign presider?
  # assign scorers?
  # assign department?

  test "simulated tournament" do
    :rand.seed(:exsplus, {101, 102, 103})

    bye = Team.new(name: "Bye Buster", distance_traveled: 0)
    carmel = Team.new(name: "Carmel", distance_traveled: 380)
    king = Team.new(name: "King", distance_traveled: 0)
    redlands = Team.new(name: "Redlands", distance_traveled: 20)
    shasta = Team.new(name: "Shasta", distance_traveled: 600)
    tam = Team.new(name: "Tamalpais", distance_traveled: 450)
    trinity_a = Team.new(name: "Trinity A", distance_traveled: 100)
    trinity_b = Team.new(name: "Trinity B", distance_traveled: 100)
    university = Team.new(name: "University", distance_traveled: 40)
    venture = Team.new(name: "Venture", distance_traveled: 400)

    teams = [
      bye,
      carmel,
      king,
      redlands,
      shasta,
      tam,
      trinity_a,
      trinity_b,
      university,
      venture
    ]

    tournament =
      [name: "GS18", teams: teams]
      |> Tournament.start()

    round1 = [
      {shasta, carmel},
      {venture, tam},
      {university, redlands},
      {trinity_a, king},
      {bye, trinity_b}
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
          defense_total_score: 102
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Knaack",
          prosecution: university,
          defense: redlands,
          round_number: 1,
          prosecution_total_score: 99,
          defense_total_score: 101
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Talmachoff",
          prosecution: trinity_a,
          defense: king,
          round_number: 1,
          prosecution_total_score: 112,
          defense_total_score: 112
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Gaughan",
          prosecution: trinity_a,
          defense: king,
          round_number: 1,
          prosecution_total_score: 93,
          defense_total_score: 96
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Scarborough",
          prosecution: bye,
          defense: trinity_b,
          round_number: 1,
          prosecution_total_score: 87,
          defense_total_score: 94
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Mendlin",
          prosecution: bye,
          defense: trinity_b,
          round_number: 1,
          prosecution_total_score: 80,
          defense_total_score: 88
        )
      )

    assert Tournament.ranked_teams(tournament, round_number: 1) ==
             [
               {%{
                  ballots_won: 2.0,
                  distance_traveled: 400,
                  name: "Venture",
                  point_differential: 15,
                  combined_strength: 0.0
                }, 1},
               {%{
                  ballots_won: 2.0,
                  distance_traveled: 100,
                  name: "Trinity B",
                  point_differential: 15,
                  combined_strength: 0.0
                }, 2},
               {%{
                  ballots_won: 2.0,
                  distance_traveled: 20,
                  name: "Redlands",
                  point_differential: 5,
                  combined_strength: 0.0
                }, 3},
               {%{
                  ballots_won: 1.5,
                  distance_traveled: 0,
                  name: "King",
                  point_differential: 3,
                  combined_strength: 0.5
                }, 4},
               {%{
                  ballots_won: 1.0,
                  distance_traveled: 600,
                  name: "Shasta",
                  point_differential: 0,
                  combined_strength: 1.0
                }, 5},
               {%{
                  ballots_won: 1.0,
                  distance_traveled: 380,
                  name: "Carmel",
                  point_differential: 0,
                  combined_strength: 1.0
                }, 6},
               {%{
                  ballots_won: 0.5,
                  distance_traveled: 100,
                  name: "Trinity A",
                  point_differential: -3,
                  combined_strength: 1.5
                }, 7},
               {%{
                  ballots_won: 0.0,
                  distance_traveled: 40,
                  name: "University",
                  point_differential: -5,
                  combined_strength: 2.0
                }, 8},
               {%{
                  ballots_won: 0.0,
                  distance_traveled: 450,
                  name: "Tamalpais",
                  point_differential: -15,
                  combined_strength: 2.0
                }, 9},
               {%{
                  ballots_won: 0.0,
                  distance_traveled: 0,
                  name: "Bye Buster",
                  point_differential: -15,
                  combined_strength: 2.0
                }, 10}
             ]

    round2 = Tournament.seed(tournament, round_number: 2)

    assert round2 == [
             {trinity_b, venture},
             {redlands, shasta},
             {king, university},
             {carmel, trinity_a},
             {tam, bye}
           ]

    tournament =
      tournament
      |> Tournament.add_pairings(round2, round_number: 2)
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Delmare",
          prosecution: trinity_b,
          defense: venture,
          round_number: 2,
          prosecution_total_score: 104,
          defense_total_score: 92
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Klein",
          prosecution: trinity_b,
          defense: venture,
          round_number: 2,
          prosecution_total_score: 87,
          defense_total_score: 88
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Near",
          prosecution: redlands,
          defense: shasta,
          round_number: 2,
          prosecution_total_score: 101,
          defense_total_score: 109
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Junker",
          prosecution: redlands,
          defense: shasta,
          round_number: 2,
          prosecution_total_score: 108,
          defense_total_score: 108
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Barker",
          prosecution: king,
          defense: university,
          round_number: 2,
          prosecution_total_score: 115,
          defense_total_score: 109
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Knaack",
          prosecution: king,
          defense: university,
          round_number: 2,
          prosecution_total_score: 109,
          defense_total_score: 111
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Talmachoff",
          prosecution: carmel,
          defense: trinity_a,
          round_number: 2,
          prosecution_total_score: 98,
          defense_total_score: 90
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Gaughan",
          prosecution: carmel,
          defense: trinity_a,
          round_number: 2,
          prosecution_total_score: 83,
          defense_total_score: 72
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "East",
          prosecution: tam,
          defense: bye,
          round_number: 2,
          prosecution_total_score: 109,
          defense_total_score: 118
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Inchon",
          prosecution: tam,
          defense: bye,
          round_number: 2,
          prosecution_total_score: 98,
          defense_total_score: 104
        )
      )

    assert Tournament.ranked_teams(tournament, round_number: 2) == [
             {%{
                ballots_won: 3.0,
                distance_traveled: 100,
                name: "Trinity B",
                point_differential: 26,
                combined_strength: 5.0
              }, 1},
             {%{
                ballots_won: 3.0,
                distance_traveled: 380,
                name: "Carmel",
                point_differential: 19,
                combined_strength: 3.0
              }, 2},
             {%{
                ballots_won: 3.0,
                distance_traveled: 400,
                name: "Venture",
                point_differential: 4,
                combined_strength: 3.0
              }, 3},
             {%{
                ballots_won: 2.5,
                distance_traveled: 600,
                name: "Shasta",
                point_differential: 8,
                combined_strength: 5.5
              }, 4},
             {%{
                ballots_won: 2.5,
                distance_traveled: 0,
                name: "King",
                point_differential: 7,
                combined_strength: 1.5
              }, 5},
             {%{
                ballots_won: 2.5,
                distance_traveled: 20,
                name: "Redlands",
                point_differential: -3,
                combined_strength: 3.5
              }, 6},
             {%{
                ballots_won: 1.0,
                distance_traveled: 40,
                name: "University",
                point_differential: -9,
                combined_strength: 5.0
              }, 7},
             {%{
                ballots_won: 0.5,
                distance_traveled: 100,
                name: "Trinity A",
                point_differential: -22,
                combined_strength: 5.5
              }, 8},
             {%{
                ballots_won: 0.0,
                distance_traveled: 450,
                name: "Tamalpais",
                point_differential: -30,
                combined_strength: 5.0
              }, 9},
             {%{
                ballots_won: 2.0,
                distance_traveled: 0,
                name: "Bye Buster",
                point_differential: 0,
                combined_strength: 3.0
              }, 10}
           ]

    round3 = Tournament.seed(tournament, round_number: 3, coin_flip: :tails)

    assert round3 == [
             {carmel, trinity_b},
             {venture, shasta},
             {redlands, king},
             {university, tam},
             {bye, trinity_a}
           ]

    tournament =
      tournament
      |> Tournament.add_pairings(round3, round_number: 3)
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Delmare",
          prosecution: carmel,
          defense: trinity_b,
          round_number: 3,
          prosecution_total_score: 98,
          defense_total_score: 105
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Klein",
          prosecution: carmel,
          defense: trinity_b,
          round_number: 3,
          prosecution_total_score: 110,
          defense_total_score: 109
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Near",
          prosecution: venture,
          defense: shasta,
          round_number: 3,
          prosecution_total_score: 81,
          defense_total_score: 65
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Junker",
          prosecution: venture,
          defense: shasta,
          round_number: 3,
          prosecution_total_score: 100,
          defense_total_score: 96
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Barker",
          prosecution: redlands,
          defense: king,
          round_number: 3,
          prosecution_total_score: 95,
          defense_total_score: 99
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Knaack",
          prosecution: redlands,
          defense: king,
          round_number: 3,
          prosecution_total_score: 110,
          defense_total_score: 115
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Talmachoff",
          prosecution: university,
          defense: tam,
          round_number: 3,
          prosecution_total_score: 96,
          defense_total_score: 107
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Gaughan",
          prosecution: university,
          defense: tam,
          round_number: 3,
          prosecution_total_score: 84,
          defense_total_score: 100
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Kahlon",
          prosecution: bye,
          defense: trinity_a,
          round_number: 3,
          prosecution_total_score: 108,
          defense_total_score: 110
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Evans",
          prosecution: bye,
          defense: trinity_a,
          round_number: 3,
          prosecution_total_score: 88,
          defense_total_score: 85
        )
      )

    assert Tournament.ranked_teams(tournament, round_number: 3) == [
             {%{
                ballots_won: 5.0,
                combined_strength: 8.5,
                distance_traveled: 400,
                name: "Venture",
                point_differential: 24
              }, 1},
             {%{
                ballots_won: 4.5,
                combined_strength: 5.0,
                distance_traveled: 0,
                name: "King",
                point_differential: 16
              }, 2},
             {%{
                ballots_won: 4.0,
                combined_strength: 12.0,
                distance_traveled: 100,
                name: "Trinity B",
                point_differential: 32
              }, 3},
             {%{
                ballots_won: 4.0,
                combined_strength: 8.0,
                distance_traveled: 380,
                name: "Carmel",
                point_differential: 13
              }, 4},
             {%{
                ballots_won: 2.5,
                combined_strength: 11.5,
                distance_traveled: 600,
                name: "Shasta",
                point_differential: -12
              }, 5},
             {%{
                ballots_won: 2.5,
                combined_strength: 8.0,
                distance_traveled: 20,
                name: "Redlands",
                point_differential: -12
              }, 6},
             {%{
                ballots_won: 2.0,
                combined_strength: 9.0,
                distance_traveled: 450,
                name: "Tamalpais",
                point_differential: -3
              }, 7},
             {%{
                ballots_won: 1.5,
                combined_strength: 11.5,
                distance_traveled: 100,
                name: "Trinity A",
                point_differential: -23
              }, 8},
             {%{
                ballots_won: 1.0,
                combined_strength: 9.0,
                distance_traveled: 40,
                name: "University",
                point_differential: -36
              }, 9},
             {%{
                ballots_won: 3.0,
                combined_strength: 7.5,
                distance_traveled: 0,
                name: "Bye Buster",
                point_differential: 1
              }, 10}
           ]

    round4 = Tournament.seed(tournament, round_number: 4)

    assert round4 == [
             {king, venture},
             {trinity_a, university},
             {trinity_b, redlands},
             {tam, carmel},
             {shasta, bye}
           ]

    tournament =
      tournament
      |> Tournament.add_pairings(round4, round_number: 4)
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Delmare",
          prosecution: tam,
          defense: venture,
          round_number: 4,
          prosecution_total_score: 111,
          defense_total_score: 110
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Klein",
          prosecution: tam,
          defense: venture,
          round_number: 4,
          prosecution_total_score: 112,
          defense_total_score: 113
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Near",
          prosecution: redlands,
          defense: shasta,
          round_number: 4,
          prosecution_total_score: 110,
          defense_total_score: 109
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Junker",
          prosecution: redlands,
          defense: shasta,
          round_number: 4,
          prosecution_total_score: 110,
          defense_total_score: 109
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Barker",
          prosecution: university,
          defense: trinity_a,
          round_number: 4,
          prosecution_total_score: 105,
          defense_total_score: 104
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Knaack",
          prosecution: university,
          defense: trinity_a,
          round_number: 4,
          prosecution_total_score: 113,
          defense_total_score: 106
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Talmachoff",
          prosecution: carmel,
          defense: king,
          round_number: 4,
          prosecution_total_score: 108,
          defense_total_score: 107
        )
      )
      |> Tournament.add_ballot(
        Ballot.new(
          scorer: "Gaughan",
          prosecution: carmel,
          defense: king,
          round_number: 4,
          prosecution_total_score: 101,
          defense_total_score: 100
        )
      )

    assert Tournament.ranked_teams(tournament, round_number: 4) == [
             {%{
                ballots_won: 6.0,
                distance_traveled: 380,
                name: "Carmel",
                point_differential: 15,
                combined_strength: 12.5
              }, 1},
             {%{
                ballots_won: 6.0,
                distance_traveled: 400,
                name: "Venture",
                point_differential: 24,
                combined_strength: 9.5
              }, 2},
             {%{
                ballots_won: 4.5,
                distance_traveled: 0,
                name: "King",
                point_differential: 14,
                combined_strength: 15.0
              }, 3},
             {%{
                ballots_won: 4.5,
                distance_traveled: 20,
                name: "Redlands",
                point_differential: -10,
                combined_strength: 10.0
              }, 4},
             {%{
                ballots_won: 4.0,
                distance_traveled: 100,
                name: "Trinity B",
                point_differential: 32,
                combined_strength: 15.0
              }, 5},
             {%{
                ballots_won: 3.0,
                distance_traveled: 450,
                name: "Tamalpais",
                point_differential: -3,
                combined_strength: 12.0
              }, 6},
             {%{
                ballots_won: 3.0,
                distance_traveled: 40,
                name: "University",
                point_differential: -28,
                combined_strength: 13.5
              }, 7},
             {%{
                ballots_won: 2.5,
                distance_traveled: 600,
                name: "Shasta",
                point_differential: -14,
                combined_strength: 16.5
              }, 8},
             {%{
                ballots_won: 1.5,
                distance_traveled: 100,
                name: "Trinity A",
                point_differential: -31,
                combined_strength: 16.5
              }, 9},
             {%{
                ballots_won: 3.0,
                distance_traveled: 0,
                name: "Bye Buster",
                point_differential: 1,
                combined_strength: 8.5
              }, 10}
           ]

    assert Tournament.championship_pairing(tournament) == [
             %Team.Impl{distance_traveled: 380, name: "Carmel"},
             %Team.Impl{distance_traveled: 400, name: "Venture"}
           ]
  end
end
