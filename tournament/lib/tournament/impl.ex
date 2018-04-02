defmodule Tournament.Impl do
  defstruct name: nil, teams: [], conflicts: [], pairings: [], ballots: []
  def start(opts), do: struct(__MODULE__, opts)

  def add_ballot(tournament, ballot) do
    %{tournament | ballots: [ballot | tournament.ballots]}
  end

  def add_ballots(tournament, ballots) do
    %{tournament | ballots: Enum.concat(ballots, tournament.ballots)}
  end

  def add_conflict(tournament, conflict) do
    %{tournament | conflicts: [conflict | tournament.conflicts]}
  end

  def add_pairing(tournament, data, opts) do
    pairing = Pairing.new(data, opts)
    %{tournament | pairings: [pairing | tournament.pairings]}
  end

  def add_pairings(tournament, data, opts) do
    pairings = Enum.map(data, &Pairing.new(&1, opts))
    %{tournament | pairings: pairings ++ tournament.pairings}
  end

  def add_team(tournament, team) do
    %{tournament | teams: [team | tournament.teams]}
  end

  def add_teams(tournament, teams) do
    %{tournament | teams: tournament.teams ++ teams}
  end

  def ballots(tournament, round_numbers: round_numbers) do
    tournament.ballots
    |> Enum.filter(&(Ballot.round_number(&1) in round_numbers))
  end

  def ballots(tournament, round_number: round_number) do
    tournament.ballots
    |> Enum.filter(&(Ballot.round_number(&1) == round_number))
  end

  def ballots(tournament), do: tournament.ballots

  def championship_pairing(tournament) do
    tournament
    |> final_rankings()
    |> Enum.take(2)
  end

  def pairings(tournament, opts \\ [])

  def pairings(tournament, opts) do
    do_pairings(tournament.pairings, opts)
  end

  def random_pairings(tournament) do
    tournament.teams
    |> Enum.shuffle()
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  def resolve_conflicts(pairings, tournament, round_number) do
    conflicts =
      (tournament.conflicts ++ tournament.pairings)
      |> Enum.map(&{&1.prosecution, &1.defense})

    rankings = team_rankings(tournament, round_number: round_number)

    Tournament.Conflict.resolve_conflicts(conflicts, pairings, rankings)
  end

  def seed(tournament, round_number: 1) do
    tournament
    |> seed_round1()
    |> resolve_conflicts(tournament, 1)
  end

  def seed(tournament, round_number: 2) do
    tournament
    |> seed_round2()
    |> resolve_conflicts(tournament, 2)
  end

  def seed(tournament, round_number: 3) do
    tournament
    |> seed_round3()
    |> resolve_conflicts(tournament, 3)
  end

  def seed(tournament, round_number: 4) do
    tournament
    |> seed_round4()
    |> resolve_conflicts(tournament, 4)
  end

  def ranked_teams(tournament, round_number: 4) do
    tournament
    |> team_rankings(round_number: 4)
    |> Enum.map(&map_ranking(tournament, &1))
    |> Enum.with_index(1)
  end

  def ranked_teams(tournament, round_number: round_number) do
    tournament
    |> team_rankings(round_number: round_number)
    |> Enum.map(&map_ranking(tournament, &1))
    |> Enum.with_index(1)
  end

  def team_rankings(tournament, round_number: 4) do
    tournament
    |> ballots(round_numbers: 1..4)
    |> Ranking.Team.final_rankings()
  end

  def team_rankings(tournament, round_number: round_number) do
    tournament
    |> ballots(round_numbers: 1..round_number)
    |> Ranking.Team.rankings()
  end

  def final_rankings(tournament), do: team_rankings(tournament, round_number: 4)

  defp map_ranking(tournament, team) do
    %{
      name: team.name,
      ballots_won: BallotList.total(tournament.ballots, ballots_won: team),
      point_differential:
        BallotList.total(tournament.ballots, point_differential: team),
      distance_traveled: team.distance_traveled
    }
  end

  def with_rankings(rankings) do
    Enum.with_index(rankings, 1)
  end

  defp coin_flip() do
    Enum.random([:prosecution, :defense])
  end

  defp do_pairings(pairings, []), do: pairings

  defp do_pairings(pairings, [{:round_number, round_number} | tail]) do
    pairings
    |> Enum.filter(&(&1.round_number == round_number))
    |> do_pairings(tail)
  end

  defp seed_round1(tournament, requests \\ []) do
    tournament.teams
    |> Enum.shuffle()
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  defp seed_round2(tournament) do
    seed_even_round(tournament, round_number: 2)
  end

  defp seed_round3(tournament) do
    tournament
    |> team_rankings(round_number: 2)
    |> do_seed_round3(coin_flip())
  end

  defp seed_round4(tournament) do
    seed_even_round(tournament, round_number: 4)
  end

  defp do_seed_round3(rankings, :prosecution) do
    rankings
    |> do_seed_round3(:defense)
    |> Enum.map(&reverse_pairing/1)
  end

  defp do_seed_round3(rankings, :defense) do
    rankings
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.map_every(2, &reverse_pairing/1)
  end

  defp reverse_pairing({prosecution, defense}) do
    {defense, prosecution}
  end

  defp seed_even_round(tournament, round_number: round_number) do
    previous_round = round_number - 1
    previous_pairings = pairings(tournament, round_number: previous_round)

    tournament
    |> team_rankings(round_number: previous_round)
    |> Enum.split_with(&was_defense?(&1, previous_pairings))
    |> Tuple.to_list()
    |> Enum.zip()
  end

  defp was_defense?(team, previous_pairings) do
    Enum.any?(previous_pairings, fn pairing -> pairing.defense == team end)
  end
end
