defmodule Team.Impl do
  defstruct name: nil, distance_traveled: 0

  def distance_traveled(team), do: team.distance_traveled
  def name(team), do: team.name
  def new(opts), do: struct(__MODULE__, opts)
end
