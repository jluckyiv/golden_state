defmodule RankTest do
  use ExUnit.Case

  test "attorney properties" do
    rank =
      Rank.new(
        name: "Name",
        position: :attorney,
        score: 5,
        side: :prosecution,
        team: "Team"
      )

    assert Rank.get(rank, :name) == "Name"
    assert Rank.get(rank, :position) == :attorney
    assert Rank.get(rank, :score) == 5
    assert Rank.get(rank, :side) == :prosecution
    assert Rank.get(rank, :team) == "Team"
  end

  test "format rank" do
    rank =
      Rank.new(
        name: "Name",
        position: :attorney,
        score: 5,
        side: :prosecution,
        team: "Team"
      )

    assert Rank.format(rank, [:name, :position, :score]) == {
             "Name",
             :attorney,
             5
           }
  end

  test "motion attorney properties" do
    rank =
      Rank.new(
        name: "Name",
        position: :motion,
        score: 5,
        side: :defense,
        team: "Team"
      )

    assert Rank.get(rank, :position) == :motion
  end

  test "witness properties" do
    rank =
      Rank.new(
        name: "Competitor Name",
        position: :witness,
        score: 5,
        side: :defense,
        team: "Team"
      )

    assert Rank.get(rank, :name) == "Competitor Name"
    assert Rank.get(rank, :position) == :witness
  end

  test "compare ranks" do
    rank1a =
      Rank.new(
        name: "Competitor 1",
        position: :witness,
        score: 5,
        side: :prosecution,
        team: "Team"
      )

    rank1b =
      Rank.new(
        name: "Competitor 1",
        position: :witness,
        score: 4,
        side: :prosecution,
        team: "Team"
      )

    rank2 =
      Rank.new(
        name: "Competitor 1",
        position: :witness,
        score: 5,
        side: :defense,
        team: "Team"
      )

    assert Rank.match?(rank1a, rank1b) == true
    assert Rank.match?(rank1a, rank2) == false
  end

  test "query ranks" do
    rank1a =
      Rank.new(
        name: "Competitor 1",
        position: :witness,
        score: 5,
        side: :prosecution,
        team: "Team"
      )

    rank1b =
      Rank.new(
        name: "Competitor 1",
        position: :witness,
        score: 4,
        side: :prosecution,
        team: "Team"
      )

    rank2 =
      Rank.new(
        name: "Competitor 1",
        position: :witness,
        score: 5,
        side: :defense,
        team: "Team"
      )

    ranks = [rank1a, rank1b, rank2]

    competitor1_filter = Rank.filter(ranks, name: "Competitor 1")
    assert Enum.count(competitor1_filter) == 3
    multiple_filter = Rank.filter(ranks, name: "Competitor 1", side: :defense)
    assert Enum.count(multiple_filter) == 1
    match_filter = Rank.filter(ranks, match: rank1a)
    assert Enum.count(match_filter) == 2
  end

  test "total ranks" do
    rank2a =
      Rank.new(
        name: "Competitor 2",
        position: :witness,
        score: 5,
        side: :prosecution,
        team: "Team"
      )

    rank2b =
      Rank.new(
        name: "Competitor 2",
        position: :witness,
        score: 4,
        side: :prosecution,
        team: "Team"
      )

    rank1 =
      Rank.new(
        name: "Competitor 1",
        position: :witness,
        score: 5,
        side: :defense,
        team: "Team"
      )

    ranks = [rank2a, rank2b, rank1]

    totals = Rank.totals(ranks)
    assert Enum.count(totals) == 2

    assert Enum.map(totals, &Rank.format(&1, [:name, :score])) == [
             {"Competitor 2", 9},
             {"Competitor 1", 5}
           ]
  end

  test "ranks from ballot" do
    ballot =
      Ballot.new(
        prosecution: "Prosecution",
        defense: "Defense",
        attorney_ranks: [
          prosecution: "Prosecution Attorney 1",
          defense: "Defense Attorney 2",
          prosecution: "Prosecution Attorney 3",
          defense: "Defense Attorney 4"
        ],
        bailiff: "Student Bailiff",
        bailiff_score: 9,
        clerk: "Student Clerk",
        clerk_score: 8,
        defense_motion_attorney: "Defense Motion Attorney",
        defense_motion_score: 9,
        prosecution_motion_attorney: "Prosecution Motion Attorney",
        prosecution_motion_score: 8,
        witness_ranks: [
          prosecution: "Student Witness 1",
          defense: "Student Witness 2",
          prosecution: "Student Witness 3",
          defense: "Student Witness 4"
        ]
      )

    ranks = Rank.from_ballot(ballot)

    assert Enum.map(ranks, &Rank.format(&1, [:name, :score])) == [
             {"Prosecution Attorney 1", 5},
             {"Defense Attorney 2", 4},
             {"Prosecution Attorney 3", 3},
             {"Defense Attorney 4", 2},
             {"Student Witness 1", 5},
             {"Student Witness 2", 4},
             {"Student Witness 3", 3},
             {"Student Witness 4", 2},
             {"Prosecution Motion Attorney", -1},
             {"Defense Motion Attorney", 1},
             {"Student Bailiff", 9},
             {"Student Clerk", 8}
           ]
  end

  test "ranks from mulitple ballots" do
    ballot1 =
      Ballot.new(
        prosecution: "Prosecution",
        defense: "Defense",
        attorney_ranks: [
          prosecution: "Prosecution Attorney 1",
          defense: "Defense Attorney 2",
          prosecution: "Prosecution Attorney 3",
          defense: "Defense Attorney 4"
        ],
        bailiff: "Student Bailiff",
        bailiff_score: 10,
        clerk: "Student Clerk",
        clerk_score: 8,
        defense_motion_attorney: "Defense Motion Attorney",
        defense_motion_score: 9,
        prosecution_motion_attorney: "Prosecution Motion Attorney",
        prosecution_motion_score: 8,
        witness_ranks: [
          prosecution: "Student Witness 1",
          defense: "Student Witness 2",
          prosecution: "Student Witness 3",
          defense: "Student Witness 4"
        ]
      )

    ballot2 =
      Ballot.new(
        prosecution: "Prosecution",
        defense: "Defense",
        attorney_ranks: [
          prosecution: "Prosecution Attorney 3",
          defense: "Defense Attorney 4",
          prosecution: "Prosecution Attorney 5",
          defense: "Defense Attorney 6"
        ],
        bailiff: "Student Bailiff",
        bailiff_score: 9,
        clerk: "Student Clerk",
        clerk_score: 9,
        defense_motion_attorney: "Defense Motion Attorney",
        defense_motion_score: 9,
        prosecution_motion_attorney: "Prosecution Motion Attorney",
        prosecution_motion_score: 8,
        witness_ranks: [
          prosecution: "Student Witness 3",
          defense: "Student Witness 4",
          prosecution: "Student Witness 5",
          defense: "Student Witness 6"
        ]
      )

    ranks = Rank.from_ballots([ballot1, ballot2])
    assert Enum.count(ranks) == 24
    totals = Rank.totals(ranks)
    assert Enum.count(totals) == 16
    assert Rank.find(totals, name: "Student Bailiff").score == 19
    assert Rank.find(totals, name: "Student Clerk").score == 17
    assert Rank.find(totals, name: "Prosecution Attorney 3").score == 8
    assert Rank.find(totals, name: "Prosecution Motion Attorney").score == -2
    assert Rank.find(totals, name: "Student Witness 4").score == 6
  end
end
