defmodule TeamTest do
  use ExUnit.Case

  test "properties" do
    team = Team.new(name: "Team", distance_traveled: 100)

    assert Team.name(team) == "Team"
    assert Team.distance_traveled(team) == 100
  end
end
