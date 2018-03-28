defmodule TournamentTest do
  use ExUnit.Case
  doctest Tournament

  # DONE:
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
  # Resolve conflicts by manually swapping teams

  # conflicts: no rematches (except final), same school
  # 1. Step #1: Swap the lower-ranked team down into the next lower-ranked matchup.
  # 2. Step #2: Swap the higher-ranked team down into the next lower-ranked matchup.
  # 3. Step #3: Swap the higher-ranked team up into the next highest-ranked matchup.
  # 4. Step #4: Swap the lower-ranked team up into the next highest-ranked matchup.
  # 5. Step #5: Repeat steps #1-4 moving to the 2nd lowest or highest-ranked matchup.
  # 6. Step #6: Repeat steps #1-4 moving to the 3rd lowest or highest-ranked matchup.

  test "round 1 seeds are random, PDPDPD" do
    :rand.seed(:exsplus, {101, 102, 103})
    teams = ~w[Carmel King Menlo Shasta Tamalpais Trinity]

    assert Tournament.seed_round1(teams) == [
             ~w[Shasta Carmel],
             ~w[Tamalpais Menlo],
             ~w[King Trinity]
           ]
  end

  test "round 1 special requests" do
    :rand.seed(:exsplus, {101, 102, 103})
    teams = ~w[Carmel King Menlo Shasta Tamalpais Trinity]

    assert Tournament.seed_round1(teams, prosecution: "Trinity", defense: "Tamalpais") == [
             ~w[Trinity Tamalpais],
             ~w[Shasta Carmel],
             ~w[Menlo King]
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
      ["Tam", "Redlands"],
      ["Venture", "Shasta"],
      ["King", "University"],
      ["Trinity", "Carmel"]
    ]

    assert Tournament.seed_round2(rankings, round1) == [
             ["Shasta", "Tam"],
             ["Carmel", "King"],
             ["University", "Venture"],
             ["Redlands", "Trinity"]
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
             ["Shasta", "Tam"],
             ["King", "Carmel"],
             ["Trinity", "Venture"],
             ["University", "Redlands"]
           ]

    # PDDP
    assert Tournament.seed_round3(rankings) == [
             ["Tam", "Shasta"],
             ["Carmel", "King"],
             ["Venture", "Trinity"],
             ["Redlands", "University"]
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
      ["Tam", "Trinity"],
      ["King", "Venture"],
      ["Carmel", "Shasta"],
      ["Redlands", "University"]
    ]

    assert Tournament.seed_round4(rankings, round3) == [
             ["Shasta", "Tam"],
             ["Venture", "King"],
             ["Trinity", "Carmel"],
             ["University", "Redlands"]
           ]
  end

  test "conflicts" do
    carmel = "Carmel"
    king = "King"
    menlo = "Menlo"
    tam = "Tam"
    trinity_a = "Trinity A"
    trinity_b = "Trinity B"

    tournament =
      "Golden State 2018"
      |> Tournament.new()
      |> Tournament.add_conflict([trinity_a, trinity_b])
      |> Tournament.add_pairing([carmel, king])
      |> Tournament.add_pairing([tam, menlo])

    assert Tournament.conflict?(tournament, [king, carmel]) == true
    assert Tournament.conflict?(tournament, [tam, menlo]) == true
    assert Tournament.conflict?(tournament, [trinity_b, trinity_a]) == true
    assert Tournament.conflict?(tournament, [trinity_a, king]) == false
    assert Tournament.conflict?(tournament, [trinity_b, menlo]) == false
    assert Tournament.conflict?(tournament, [carmel, tam]) == false
    assert Tournament.head_to_head?(tournament, [king, carmel]) == true
    assert Tournament.head_to_head?(tournament, [tam, menlo]) == true
    assert Tournament.head_to_head?(tournament, [trinity_b, trinity_a]) == false
    assert Tournament.head_to_head?(tournament, [trinity_a, king]) == false
    assert Tournament.head_to_head?(tournament, [trinity_b, menlo]) == false
    assert Tournament.head_to_head?(tournament, [carmel, tam]) == false
  end

  test "lower-ranked team" do
    king = %{name: "King", conflicts: []}
    menlo = %{name: "Menlo", conflicts: []}
    trinity_a = %{name: "Trinity A", conflicts: []}
    trinity_b = %{name: "Trinity B", conflicts: []}

    rankings = [
      trinity_a,
      trinity_b,
      king,
      menlo
    ]

    assert Tournament.lower_ranked_team(rankings, [trinity_a, trinity_b]) == trinity_b
    assert Tournament.lower_ranked_team(rankings, [trinity_a, king]) == king
    assert Tournament.lower_ranked_team(rankings, [trinity_a, menlo]) == menlo
    assert Tournament.lower_ranked_team(rankings, [trinity_b, king]) == king
    assert Tournament.lower_ranked_team(rankings, [trinity_b, menlo]) == menlo
    assert Tournament.lower_ranked_team(rankings, [king, menlo]) == menlo
    assert Tournament.lower_ranked_team(rankings, [menlo, king]) == menlo
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

  test "swap pairings" do
    pairings = [
      ["Tam", "Shasta"],
      ["King", "Carmel"],
      ["Venture", "Trinity"],
      ["Trinity", "Redlands"]
    ]

    assert Tournament.swap_team(pairings, "Tam", :down) == [
             ["King", "Shasta"],
             ["Tam", "Carmel"],
             ["Venture", "Trinity"],
             ["Trinity", "Redlands"]
           ]

    assert Tournament.swap_team(pairings, "Carmel", :down) == [
             ["Tam", "Shasta"],
             ["King", "Trinity"],
             ["Venture", "Carmel"],
             ["Trinity", "Redlands"]
           ]

    assert Tournament.swap_team(pairings, "King", :up) == [
             ["King", "Shasta"],
             ["Tam", "Carmel"],
             ["Venture", "Trinity"],
             ["Trinity", "Redlands"]
           ]

    assert Tournament.swap_team(pairings, "Carmel", :up) == [
             ["Tam", "Carmel"],
             ["King", "Shasta"],
             ["Venture", "Trinity"],
             ["Trinity", "Redlands"]
           ]
  end
end
