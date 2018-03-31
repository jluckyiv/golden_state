defmodule Ballot do
  alias __MODULE__.Impl

  defdelegate defense(ballot), to: Impl
  defdelegate defense?(ballot, team), to: Impl
  defdelegate get(ballot, opts), to: Impl
  defdelegate new(opts), to: Impl
  defdelegate opponent(ballot, team), to: Impl
  defdelegate prosecution(ballot), to: Impl
  defdelegate prosecution?(ballot, team), to: Impl
  defdelegate round_number(ballot), to: Impl
  defdelegate round_number?(ballot, round_number), to: Impl
  defdelegate team?(ballot, team), to: Impl
end
