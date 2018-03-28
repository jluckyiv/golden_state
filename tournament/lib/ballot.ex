defmodule Ballot do
  alias __MODULE__.Impl

  defdelegate ballots_won(ballot, side_or_team), to: Impl
  defdelegate closing_score(ballot, side_or_team), to: Impl
  defdelegate defense(ballot), to: Impl
  defdelegate defense_closing_score(ballot), to: Impl
  defdelegate defense_motion_score(ballot), to: Impl
  defdelegate defense_total_score(ballot), to: Impl
  defdelegate has_team?(ballot, team), to: Impl
  defdelegate motion_score(ballot, side_or_team), to: Impl
  defdelegate new(opts), to: Impl
  defdelegate opponent(ballot, team), to: Impl
  defdelegate point_differential(ballot, side_or_team), to: Impl
  defdelegate prosecution(ballot), to: Impl
  defdelegate prosecution_closing_score(ballot), to: Impl
  defdelegate prosecution_motion_score(ballot), to: Impl
  defdelegate prosecution_total_score(ballot), to: Impl
  defdelegate round_number(ballot), to: Impl
  defdelegate scorer(ballot), to: Impl
  defdelegate total_score(ballot, side_or_team), to: Impl
end
