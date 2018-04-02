defmodule Tournament.Conflict do
  alias Tournament.Conflict.Impl

  defdelegate conflict?(conflicts, pairing), to: Impl
  defdelegate conflicts?(conflicts, pairings), to: Impl
  defdelegate resolve_conflicts(conflicts, pairings, rankings), to: Impl
end
