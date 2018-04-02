defmodule ConflictTest do
  use ExUnit.Case

  alias Tournament.Conflict

  test "step 1 conflict resolution: move lower-ranked team down 1" do
    carmel = %{name: "Carmel"}
    king = %{name: "King"}
    menlo = %{name: "Menlo"}
    redlands = %{name: "Redlands"}
    shasta = %{name: "Shasta"}
    tam = %{name: "Tam"}
    trinity_a = %{name: "Trinity A"}
    trinity_b = %{name: "Trinity B"}

    conflicts = [{trinity_a, trinity_b}]

    rankings = [
      king,
      shasta,
      trinity_a,
      trinity_b,
      tam,
      redlands,
      carmel,
      menlo
    ]

    pairings = [
      {king, shasta},
      {trinity_a, trinity_b},
      {tam, redlands},
      {carmel, menlo}
    ]

    assert Conflict.conflict?(conflicts, {trinity_a, trinity_b})
    assert Conflict.conflict?(conflicts, {trinity_b, trinity_a})
    assert Conflict.conflicts?(conflicts, pairings) == true

    assert Conflict.resolve_conflicts(conflicts, pairings, rankings) ==
             [
               {king, shasta},
               {trinity_a, redlands},
               {tam, trinity_b},
               {carmel, menlo}
             ]
  end

  test "step 3 conflict resolution: move upper-ranked team up 1" do
    carmel = %{name: "Carmel"}
    king = %{name: "King"}
    menlo = %{name: "Menlo"}
    redlands = %{name: "Redlands"}
    shasta = %{name: "Shasta"}
    tam = %{name: "Tam"}
    trinity_a = %{name: "Trinity A"}
    trinity_b = %{name: "Trinity B"}
    conflicts = [{trinity_a, trinity_b}, {redlands, trinity_a}]

    rankings = [
      king,
      shasta,
      trinity_a,
      trinity_b,
      tam,
      redlands,
      carmel,
      menlo
    ]

    pairings = [
      {king, shasta},
      {trinity_a, trinity_b},
      {tam, redlands},
      {carmel, menlo}
    ]

    assert Conflict.resolve_conflicts(conflicts, pairings, rankings) ==
             [
               {trinity_a, shasta},
               {king, trinity_b},
               {tam, redlands},
               {carmel, menlo}
             ]
  end

  test "step 5 conflict resolution: move upper-ranked team down 2" do
    carmel = %{name: "Carmel"}
    king = %{name: "King"}
    menlo = %{name: "Menlo"}
    redlands = %{name: "Redlands"}
    shasta = %{name: "Shasta"}
    tam = %{name: "Tam"}
    trinity_a = %{name: "Trinity A"}
    trinity_b = %{name: "Trinity B"}
    conflicts = [{trinity_a, trinity_b}]
    conflicts = [{king, trinity_a} | conflicts]
    conflicts = [{menlo, trinity_b} | conflicts]

    pairings = [
      {trinity_a, trinity_b},
      {menlo, king},
      {tam, shasta},
      {redlands, carmel}
    ]

    rankings = [
      trinity_a,
      trinity_b,
      king,
      menlo,
      tam,
      shasta,
      carmel,
      redlands
    ]

    assert Conflict.resolve_conflicts(conflicts, pairings, rankings) ==
             [
               {trinity_a, shasta},
               {menlo, king},
               {tam, trinity_b},
               {redlands, carmel}
             ]
  end

  test "multiple conflicts" do
    carmel = %{name: "Carmel"}
    king = %{name: "King"}
    menlo = %{name: "Menlo"}
    redlands = %{name: "Redlands"}
    shasta = %{name: "Shasta"}
    tam = %{name: "Tam"}
    trinity_a = %{name: "Trinity A"}
    trinity_b = %{name: "Trinity B"}

    conflicts = [
      {trinity_a, king},
      {redlands, trinity_b},
      {trinity_a, trinity_b},
      {carmel, menlo},
      {tam, shasta}
    ]

    pairings = [
      {trinity_a, king},
      {redlands, trinity_b},
      {menlo, carmel},
      {tam, shasta}
    ]

    rankings = [
      trinity_a,
      trinity_b,
      king,
      menlo,
      tam,
      shasta,
      carmel,
      redlands
    ]

    assert Conflict.resolve_conflicts(conflicts, pairings, rankings) == [
             {trinity_a, carmel},
             {menlo, trinity_b},
             {tam, king},
             {redlands, shasta}
           ]
  end
end
