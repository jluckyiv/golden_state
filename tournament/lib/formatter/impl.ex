defmodule Formatter.Impl do
  def display_as_map(_module, struct, args) do
    Map.take(struct, args)
  end

  def display_as_tuple(module, struct, args),
    do: do_display_as_tuple({}, module, struct, args)

  defp do_display_as_tuple(tuple, _module, _struct, []), do: tuple

  defp do_display_as_tuple(tuple, module, struct, [head | tail]) do
    tuple
    |> Tuple.append(module.get(struct, head))
    |> do_display_as_tuple(module, struct, tail)
  end
end
