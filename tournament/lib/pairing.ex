defmodule Pairing do
  defstruct prosecution: nil, defense: nil, round_number: 0

  def new({prosecution, defense}, round_number: round_number) do
    new(prosecution: prosecution, defense: defense, round_number: round_number)
  end

  def new(%__MODULE__{} = pairing), do: pairing
  def new(opts), do: struct(__MODULE__, opts)

  def display(pairings) when is_list(pairings) do
    Enum.map(pairings, &display/1)
  end

  def display(pairing), do: "{#{pairing.defense.name}}"
end
