defmodule Team do
  alias __MODULE__.Impl
  defdelegate new(opts), to: Impl
  defdelegate name(team), to: Impl
  defdelegate distance_traveled(team), to: Impl
end
