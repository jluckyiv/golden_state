defmodule Team do
  alias __MODULE__.Impl
  defdelegate distance_traveled(team), to: Impl
  defdelegate name(team), to: Impl
  defdelegate new(opts), to: Impl
end
