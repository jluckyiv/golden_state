defmodule ConflictTest do
  use ExUnit.Case

  alias Tournament.Conflict

  test "conflicts" do
    carmel = "Carmel"
    king = "King"
    menlo = "Menlo"
    redlands = "Redlands"
    shasta = "Shasta"
    tam = "Tam"
    trinity_a = "Trinity A"
    trinity_b = "Trinity B"

    teams = [
      carmel,
      king,
      menlo,
      redlands,
      shasta,
      tam,
      trinity_a,
      trinity_b
    ]

    tournament =
      [name: "Golden State 2018"]
      |> Tournament.new()
      |> Tournament.add_conflict({trinity_a, trinity_b})

    # |> Tournament.add_pairing({carmel, king})
    # |> Tournament.add_pairing({tam, menlo})

    :rand.seed(:exsplus, {106, 102, 103})
    round1 = Tournament.seed_round1(teams)

    rankings = [
      "King",
      "Shasta",
      "Trinity A",
      "Trinity B",
      "Tam",
      "Redlands",
      "Carmel",
      "Menlo"
    ]

    assert round1 == [
             {"King", "Shasta"},
             {"Trinity A", "Trinity B"},
             {"Tam", "Redlands"},
             {"Carmel", "Menlo"}
           ]

    # step 1 conflict resolution
    assert Conflict.conflicts?(tournament, round1) == true

    assert Conflict.resolve_conflicts(tournament, rankings, round1) == [
             {"King", "Shasta"},
             {"Trinity A", "Redlands"},
             {"Tam", "Trinity B"},
             {"Carmel", "Menlo"}
           ]

    # step 2 conflict resolution doesn't resolve conflicts
    # step 3 conflict resolution 
    tournament = Tournament.add_pairing(tournament, {"Redlands", "Trinity A"})
    assert Conflict.conflicts?(tournament, round1) == true

    assert Conflict.resolve_conflicts(tournament, rankings, round1) == [
             {"Trinity A", "Shasta"},
             {"King", "Trinity B"},
             {"Tam", "Redlands"},
             {"Carmel", "Menlo"}
           ]

    # step 4 conflict resolution doesn't resolve conflicts
    # step 5 conflict resolution
    tournament = Tournament.add_pairing(tournament, {"King", "Trinity A"})
    tournament = Tournament.add_pairing(tournament, {"Menlo", "Trinity B"})
    assert Conflict.conflicts?(tournament, round1) == true

    round3 = [
      {"Trinity A", "Trinity B"},
      {"Menlo", "King"},
      {"Tam", "Shasta"},
      {"Redlands", "Carmel"}
    ]

    rankings = [
      "Trinity A",
      "Trinity B",
      "King",
      "Menlo",
      "Tam",
      "Shasta",
      "Carmel",
      "Redlands"
    ]

    assert Conflict.resolve_conflicts(tournament, rankings, round3) == [
             {"Trinity A", "Shasta"},
             {"Menlo", "King"},
             {"Tam", "Trinity B"},
             {"Redlands", "Carmel"}
           ]

    assert Conflict.conflict?(tournament, {trinity_b, trinity_a}) == true
    assert Conflict.conflict?(tournament, {trinity_a, king}) == true
    assert Conflict.conflict?(tournament, {trinity_b, menlo}) == true
    assert Conflict.conflict?(tournament, {carmel, tam}) == false
  end
end
