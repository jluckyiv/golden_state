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

  # TODO
  # Individual awards
  # Ranks for wits/attys: 5, 4, 3, 2
  # Motions: point differential average per ballot
  # Clerk and bailiff: point average per ballot
  # Ties go to higher-ranked team

  test "round 1 seeds are random, PDPDPD" do
    :rand.seed(:exsplus, {101, 102, 103})
    teams = ~w[Carmel King Menlo Shasta Tamalpais Trinity]

    assert Tournament.seed_round1(teams) == [
             {"Shasta", "Carmel"},
             {"Tamalpais", "Menlo"},
             {"King", "Trinity"}
           ]
  end

  test "round 1 special requests" do
    :rand.seed(:exsplus, {101, 102, 103})
    teams = ~w[Carmel King Menlo Shasta Tamalpais Trinity]

    assert Tournament.seed_round1(teams, prosecution: "Trinity", defense: "Tamalpais") == [
             {"Trinity", "Tamalpais"},
             {"Shasta", "Carmel"},
             {"Menlo", "King"}
           ]
  end

  test "round 2 seeds reverse sides and pair corresponding ranks from P and D" do
    rankings = [
      "Tam",
      "Shasta",
      "King",
      "Carmel",
      "Venture",
      "Trinity",
      "University",
      "Redlands"
    ]

    round1 = [
      {"Tam", "Redlands"},
      {"Venture", "Shasta"},
      {"King", "University"},
      {"Trinity", "Carmel"}
    ]

    assert Tournament.seed_round2(rankings, round1) == [
             {"Shasta", "Tam"},
             {"Carmel", "King"},
             {"University", "Venture"},
             {"Redlands", "Trinity"}
           ]
  end

  test "round 3 seeds in rank order, PDDP or DPPD, depending on coin flip" do
    :rand.seed(:exsplus, {101, 102, 103})

    rankings = [
      "Tam",
      "Shasta",
      "King",
      "Carmel",
      "Venture",
      "Trinity",
      "University",
      "Redlands"
    ]

    # DPPD
    assert Tournament.seed_round3(rankings) == [
             {"Shasta", "Tam"},
             {"King", "Carmel"},
             {"Trinity", "Venture"},
             {"University", "Redlands"}
           ]

    # PDDP
    assert Tournament.seed_round3(rankings) == [
             {"Tam", "Shasta"},
             {"Carmel", "King"},
             {"Venture", "Trinity"},
             {"Redlands", "University"}
           ]
  end

  test "round 4 seeds reverse sides and pair corresponding ranks from P and D" do
    rankings = [
      "Tam",
      "Shasta",
      "King",
      "Carmel",
      "Venture",
      "Trinity",
      "University",
      "Redlands"
    ]

    round3 = [
      {"Tam", "Trinity"},
      {"King", "Venture"},
      {"Carmel", "Shasta"},
      {"Redlands", "University"}
    ]

    assert Tournament.seed_round4(rankings, round3) == [
             {"Shasta", "Tam"},
             {"Venture", "King"},
             {"Trinity", "Carmel"},
             {"University", "Redlands"}
           ]
  end

  test "with rankings" do
    rankings = [
      "Tam",
      "Shasta",
      "King",
      "Carmel",
      "Venture",
      "Trinity",
      "University",
      "Redlands"
    ]

    assert Tournament.with_rankings(rankings) == [
             {"Tam", 1},
             {"Shasta", 2},
             {"King", 3},
             {"Carmel", 4},
             {"Venture", 5},
             {"Trinity", 6},
             {"University", 7},
             {"Redlands", 8}
           ]
  end
end
