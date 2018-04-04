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
             {:ok,
              [
                {%{name: "King"}, %{name: "Shasta"}},
                {%{name: "Trinity A"}, %{name: "Redlands"}},
                {%{name: "Tam"}, %{name: "Trinity B"}},
                {%{name: "Carmel"}, %{name: "Menlo"}}
              ], [{{%{name: "Trinity A"}, %{name: "Trinity B"}}, :down, 1}]}
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
             {:ok,
              [
                {%{name: "Trinity A"}, %{name: "Shasta"}},
                {%{name: "King"}, %{name: "Trinity B"}},
                {%{name: "Tam"}, %{name: "Redlands"}},
                {%{name: "Carmel"}, %{name: "Menlo"}}
              ],
              [
                {{%{name: "Trinity A"}, %{name: "Trinity B"}}, :down, 1},
                {{%{name: "Trinity A"}, %{name: "Trinity B"}}, :up, 1}
              ]}
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
             {:ok,
              [
                {%{name: "Trinity A"}, %{name: "Shasta"}},
                {%{name: "Menlo"}, %{name: "King"}},
                {%{name: "Tam"}, %{name: "Trinity B"}},
                {%{name: "Redlands"}, %{name: "Carmel"}}
              ],
              [
                {{%{name: "Trinity A"}, %{name: "Trinity B"}}, :down, 1},
                {{%{name: "Trinity A"}, %{name: "Trinity B"}}, :up, 1},
                {{%{name: "Trinity A"}, %{name: "Trinity B"}}, :down, 2}
              ]}
  end

  test "unresolved conflict returns error and moves" do
    king = %{name: "King"}
    menlo = %{name: "Menlo"}
    trinity_a = %{name: "Trinity A"}
    trinity_b = %{name: "Trinity B"}

    conflicts = [{trinity_a, trinity_b}]
    conflicts = [{king, trinity_a} | conflicts]
    conflicts = [{menlo, trinity_b} | conflicts]

    pairings = [
      {trinity_a, trinity_b},
      {menlo, king}
    ]

    rankings = [
      trinity_a,
      trinity_b,
      king,
      menlo
    ]

    assert Conflict.resolve_conflicts(conflicts, pairings, rankings) ==
             {:error, "Could not resolve conflict", {trinity_a, trinity_b},
              pairings}
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

    assert Conflict.resolve_conflicts(conflicts, pairings, rankings) ==
             {:ok,
              [
                {%{name: "Trinity A"}, %{name: "Carmel"}},
                {%{name: "Menlo"}, %{name: "Trinity B"}},
                {%{name: "Tam"}, %{name: "King"}},
                {%{name: "Redlands"}, %{name: "Shasta"}}
              ],
              [
                {{%{name: "Trinity A"}, %{name: "King"}}, :down, 1},
                {{%{name: "Trinity A"}, %{name: "King"}}, :up, 1},
                {{%{name: "Trinity A"}, %{name: "King"}}, :down, 2},
                {{%{name: "Redlands"}, %{name: "Trinity B"}}, :down, 1},
                {{%{name: "Tam"}, %{name: "Shasta"}}, :down, 1},
                {{%{name: "Tam"}, %{name: "Shasta"}}, :up, 1}
              ]}
  end

  # Three schools with two teams; create late round pressure scenario where those teams are 3/8 teams at the top of the bracket, at the middle, and at the bottom; in the bottom scenario, I’d include the bye_buster Team due to special circumstances. Those instances are entirely plausible, though much worse and we’re unlikely to see it.

  test "worst case scenario" do
    bye_buster = %{name: "Bye Buster"}
    carmel = %{name: "Carmel"}
    centennial = %{name: "Centennial"}
    king_a = %{name: "King A"}
    king_b = %{name: "King B"}
    menlo = %{name: "Menlo"}
    moreau = %{name: "Moreau"}
    redlands_a = %{name: "Redlands A"}
    redlands_b = %{name: "Redlands B"}
    shasta = %{name: "Shasta"}
    tam = %{name: "Tam"}
    trinity_a = %{name: "Trinity A"}
    trinity_b = %{name: "Trinity B"}
    venture = %{name: "Venture"}

    rankings = [
      king_a,
      king_b,
      redlands_a,
      carmel,
      centennial,
      menlo,
      trinity_a,
      trinity_b,
      redlands_b,
      moreau,
      shasta,
      tam,
      venture,
      bye_buster
    ]

    conflicts = [
      {king_a, king_b},
      {redlands_a, redlands_b},
      {trinity_a, trinity_b},
      {centennial, bye_buster},
      {centennial, king_b},
      {centennial, moreau},
      {king_a, bye_buster},
      {king_a, carmel},
      {king_a, menlo},
      {redlands_a, menlo},
      {redlands_a, moreau},
      {redlands_a, tam},
      {shasta, king_b},
      {shasta, moreau},
      {shasta, tam},
      {trinity_a, bye_buster},
      {trinity_a, king_b},
      {trinity_a, carmel},
      {venture, carmel},
      {venture, menlo},
      {venture, tam}
    ]

    pairings = [
      {king_a, king_b},
      {redlands_a, carmel},
      {centennial, menlo},
      {trinity_a, trinity_b},
      {redlands_b, moreau},
      {shasta, tam},
      {venture, bye_buster}
    ]

    assert Conflict.resolve_conflicts(conflicts, pairings, rankings) ==
             {:ok,
              [
                {%{name: "King A"}, %{name: "Moreau"}},
                {%{name: "Redlands A"}, %{name: "Carmel"}},
                {%{name: "Trinity A"}, %{name: "Menlo"}},
                {%{name: "Shasta"}, %{name: "Trinity B"}},
                {%{name: "Redlands B"}, %{name: "King B"}},
                {%{name: "Centennial"}, %{name: "Tam"}},
                {%{name: "Venture"}, %{name: "Bye Buster"}}
              ],
              [
                {{%{name: "King A"}, %{name: "King B"}}, :down, 1},
                {{%{name: "King A"}, %{name: "King B"}}, :up, 1},
                {{%{name: "King A"}, %{name: "King B"}}, :down, 2},
                {{%{name: "King A"}, %{name: "King B"}}, :up, 2},
                {{%{name: "King A"}, %{name: "King B"}}, :down, 3},
                {{%{name: "King A"}, %{name: "King B"}}, :up, 3},
                {{%{name: "King A"}, %{name: "King B"}}, :down, 4},
                {{%{name: "Trinity A"}, %{name: "Trinity B"}}, :down, 1},
                {{%{name: "Trinity A"}, %{name: "Trinity B"}}, :up, 1},
                {{%{name: "Shasta"}, %{name: "Tam"}}, :down, 1},
                {{%{name: "Shasta"}, %{name: "Tam"}}, :up, 1},
                {{%{name: "Shasta"}, %{name: "Tam"}}, :down, 2},
                {{%{name: "Shasta"}, %{name: "Tam"}}, :up, 2}
              ]}
  end
end
