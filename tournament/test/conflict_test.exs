defmodule ConflictTest do
  use ExUnit.Case

  alias Tournament.Conflict

  test "step 1 conflict resolution: move lower-ranked team down 1" do
    conflicts = [{"Trinity A", "Trinity B"}]

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

    pairings = [
      {"King", "Shasta"},
      {"Trinity A", "Trinity B"},
      {"Tam", "Redlands"},
      {"Carmel", "Menlo"}
    ]

    assert Conflict.conflict?(conflicts, {"Trinity A", "Trinity B"})
    assert Conflict.conflict?(conflicts, {"Trinity B", "Trinity A"})
    assert Conflict.conflicts?(conflicts, pairings) == true

    assert Conflict.resolve_conflicts(conflicts, pairings, rankings) ==
             [
               {"King", "Shasta"},
               {"Trinity A", "Redlands"},
               {"Tam", "Trinity B"},
               {"Carmel", "Menlo"}
             ]
  end

  test "step 3 conflict resolution: move upper-ranked team up 1" do
    conflicts = [{"Trinity A", "Trinity B"}, {"Redlands", "Trinity A"}]

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

    pairings = [
      {"King", "Shasta"},
      {"Trinity A", "Trinity B"},
      {"Tam", "Redlands"},
      {"Carmel", "Menlo"}
    ]

    assert Conflict.resolve_conflicts(conflicts, pairings, rankings) ==
             [
               {"Trinity A", "Shasta"},
               {"King", "Trinity B"},
               {"Tam", "Redlands"},
               {"Carmel", "Menlo"}
             ]
  end

  test "step 5 conflict resolution: move upper-ranked team down 2" do
    conflicts = [{"Trinity A", "Trinity B"}]
    conflicts = [{"King", "Trinity A"} | conflicts]
    conflicts = [{"Menlo", "Trinity B"} | conflicts]

    pairings = [
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

    assert Conflict.resolve_conflicts(conflicts, pairings, rankings) ==
             [
               {"Trinity A", "Shasta"},
               {"Menlo", "King"},
               {"Tam", "Trinity B"},
               {"Redlands", "Carmel"}
             ]
  end

  test "multiple conflicts" do
    conflicts = [
      {"Trinity A", "King"},
      {"Redlands", "Trinity B"},
      {"Trinity A", "Trinity B"},
      {"Carmel", "Menlo"},
      {"Tam", "Shasta"}
    ]

    pairings = [
      {"Trinity A", "King"},
      {"Redlands", "Trinity B"},
      {"Menlo", "Carmel"},
      {"Tam", "Shasta"}
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

    assert Conflict.resolve_conflicts(conflicts, pairings, rankings) == [
             {"Trinity A", "Carmel"},
             {"Menlo", "Trinity B"},
             {"Tam", "King"},
             {"Redlands", "Shasta"}
           ]
  end
end
