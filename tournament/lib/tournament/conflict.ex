defmodule Tournament.Conflict do
  alias Tournament.Conflict.Impl

  defdelegate conflict?(tournament, pairing), to: Impl
  defdelegate conflicts?(tournament, pairings), to: Impl
  defdelegate resolve_conflicts(tournament, pairings, rankings), to: Impl
end
