defmodule Rank.Impl do
  defstruct name: nil,
            position: nil,
            score: 0,
            side: nil,
            team: nil,
            round_number: 0

  def find(ranks, opts), do: List.first(filter(ranks, opts))

  def filter(ranks, [head | tail]) do
    ranks
    |> do_filter(head)
    |> filter(tail)
  end

  def filter(ranks, []), do: ranks

  def from_ballot(ballot) do
    Enum.concat([
      attorney_ranks(ballot),
      witness_ranks(ballot),
      motion_ranks(ballot),
      [bailiff_rank(ballot)],
      [clerk_rank(ballot)]
    ])
  end

  def from_ballots([]), do: []

  def from_ballots(ballots) do
    ballots
    |> Enum.map(&from_ballot/1)
    |> List.flatten()
  end

  def get(rank, property), do: apply(__MODULE__, property, [rank])

  def identity(rank) do
    rank
    |> Map.from_struct()
    |> Map.delete(:score)
    |> Map.delete(:round_number)
  end

  def match?(rank1, rank2), do: identity(rank1) == identity(rank2)
  def name(rank), do: rank.name
  def new(opts), do: struct(__MODULE__, opts)
  def position(rank), do: rank.position
  def round_number(rank), do: rank.round_number
  def score(rank), do: rank.score
  def side(rank), do: rank.side

  def rankings(ballots, opts \\ []) do
    ballots
    |> from_ballots()
    |> filter(List.wrap(opts))
    |> totals()
    |> sort_with_tiebreakers(ballots, :final_ranking)
  end

  def team(rank), do: rank.team

  def totals(ranks) do
    ranks
    |> reduce_ranks_to_map()
    |> Enum.to_list()
    |> Enum.map(&map_score/1)
    |> Enum.map(&new/1)
    |> sort_by_score()
  end

  defp attorney_ranks(ballot) do
    ballot
    |> Ballot.get(:attorney_ranks)
    |> do_attorney_ranks(ballot)
  end

  defp do_attorney_ranks([], _ballot), do: []

  defp do_attorney_ranks(attorney_ranks, ballot) do
    attorney_ranks
    |> Enum.with_index()
    |> Enum.map(&append_score_to_rank/1)
    |> Enum.map(fn {side, name, score} ->
      new(
        name: name,
        position: :attorney,
        score: score,
        side: side,
        team: Ballot.get(ballot, side),
        round_number: ballot.round_number
      )
    end)
  end

  defp witness_ranks(ballot) do
    ballot
    |> Ballot.get(:witness_ranks)
    |> Enum.with_index()
    |> Enum.map(&append_score_to_rank/1)
    |> Enum.map(fn {side, name, score} ->
      new(
        name: name,
        position: :witness,
        score: score,
        side: side,
        team: Ballot.get(ballot, side),
        round_number: ballot.round_number
      )
    end)
  end

  defp motion_ranks(ballot) do
    [
      motion_rank(ballot, :prosecution),
      motion_rank(ballot, :defense)
    ]
  end

  defp motion_rank(ballot, side) do
    name = Ballot.get(ballot, motion_attorney: side)

    new(
      name: name,
      position: :motion,
      score: Ballot.get(ballot, motion_differential: side),
      side: side,
      team: Ballot.get(ballot, side),
      round_number: ballot.round_number
    )
  end

  defp bailiff_rank(ballot) do
    name = Ballot.get(ballot, :bailiff)
    score = Ballot.get(ballot, :bailiff_score)

    new(
      name: name,
      position: :bailiff,
      score: score,
      side: :defense,
      team: Ballot.get(ballot, :defense),
      round_number: ballot.round_number
    )
  end

  defp clerk_rank(ballot) do
    name = Ballot.get(ballot, :clerk)
    score = Ballot.get(ballot, :clerk_score)

    new(
      name: name,
      position: :clerk,
      score: score,
      side: :prosecution,
      team: Ballot.get(ballot, :prosecution),
      round_number: ballot.round_number
    )
  end

  defp append_score_to_rank({rank, index}) do
    Tuple.append(rank, 5 - index)
  end

  defp do_filter(ranks, {:ranks, value}) do
    do_filter(ranks, {:position, value})
  end

  defp do_filter(ranks, :attorney_ranks) do
    do_filter(ranks, {:position, :attorney})
  end

  defp do_filter(ranks, :bailiff_ranks) do
    do_filter(ranks, {:position, :bailiff})
  end

  defp do_filter(ranks, :clerk_ranks) do
    do_filter(ranks, {:position, :clerk})
  end

  defp do_filter(ranks, :motion_ranks) do
    do_filter(ranks, {:position, :motion})
  end

  defp do_filter(ranks, :witness_ranks) do
    do_filter(ranks, {:position, :witness})
  end

  defp do_filter(ranks, {:match, %__MODULE__{} = rank}) do
    do_filter(ranks, {:identity, identity(rank)})
  end

  defp do_filter(ranks, {property, value}) do
    Enum.filter(ranks, &(get(&1, property) == value))
  end

  defp map_score({identity, {score, ballots}}) do
    Map.put(identity, :score, score / ballots)
  end

  defp map_score(
         {identity = %{position: position},
          {_round_numbers, total_score, _ballot_count}}
       )
       when position in [:attorney, :witness] do
    Map.put(identity, :score, total_score / 4)
  end

  defp map_score({identity, {round_numbers, total_score, ballot_count}}) do
    if MapSet.size(round_numbers) < 2 do
      Map.put(identity, :score, :ineligible)
    else
      Map.put(identity, :score, total_score / ballot_count)
    end
  end

  defp reduce_ranks_to_map(ranks) do
    Enum.reduce(ranks, %{}, fn rank, acc ->
      Map.update(
        acc,
        identity(rank),
        {MapSet.new([rank.round_number]), rank.score, 1},
        fn {round_numbers, score, ballots} ->
          {MapSet.put(round_numbers, rank.round_number), score + rank.score,
           ballots + 1}
        end
      )
    end)
  end

  defp sort_by_score(ranks) do
    Enum.sort_by(ranks, &score/1, &>=/2)
  end

  defp sort_with_tiebreakers(elements, tiebreaker_data, tiebreakers) do
    Enum.sort(
      elements,
      &do_sort_with_tiebreakers({&1, &2}, tiebreaker_data, tiebreakers)
    )
  end

  defp do_sort_with_tiebreakers({rank1, rank2}, ballots, :final_ranking) do
    cond do
      rank1.score > rank2.score ->
        true

      rank1.score < rank2.score ->
        false

      true ->
        final_ranking(ballots, rank1.team) <= final_ranking(ballots, rank2.team)
    end
  end

  defp final_ranking(ballots, team),
    do: Ranking.Team.final_ranking(ballots, team)
end
