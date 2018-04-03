defmodule Ranking.Individual.Impl do
  def ranking(ballots, opts) do
    ballots
    |> rankings()
    |> rank(opts)
  end

  defp rank(rankings, opts) do
    rankings
    |> Enum.find_index(&Rank.match?(&1, opts))
    |> Kernel.+(1)
  end

  def rankings(ballots, opts \\ []) do
    ballots
    |> Rank.from_ballots()
    |> Rank.filter(List.wrap(opts))
    |> Enum.reject(fn %{team: team} -> team.name == "Bye Buster" end)
    |> Rank.totals()
    |> sort_with_tiebreakers(ballots, :final_ranking)
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

  defp do_filter(ranks, {:match, %Rank.Impl{} = rank}) do
    do_filter(ranks, {:identity, identity(rank)})
  end

  defp do_filter(ranks, {property, value}) do
    Enum.filter(ranks, &(get(&1, property) == value))
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
