defmodule Formatter do
  alias __MODULE__.Impl
  defdelegate display_as_map(module, struct, args), to: Impl
  defdelegate display_as_tuple(module, struct, args), to: Impl
end
