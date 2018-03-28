defmodule Team.Impl do
  defstruct name: nil, distance_traveled: 0

  def new(opts), do: struct(__MODULE__, opts)
  def name(team), do: team.name
  def distance_traveled(team), do: team.distance_traveled
end
