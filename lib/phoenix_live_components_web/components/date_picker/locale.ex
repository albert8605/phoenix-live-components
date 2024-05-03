defmodule PhoenixLiveComponentsWeb.Components.DatePicker.Locale do
  @moduledoc false

  @not_found_map %{"key" => "not_found", "label" =>  "not_found", "amount" => -1}

  @today %{"key" => "today", "label" =>  "Today", "amount" => 0, "in" => :days}
  @yesterday %{"key" => "yesterday", "label" =>  "Yesterday", "amount" => -1, "in" => :days}
  @last_7days %{"key" => "last_7days", "label" =>  "Last 7 days", "amount" => -6, "in" => :days}
  @last_30days %{"key" => "last_30days", "label" =>  "Last 30 days", "amount" => -30, "in" => :days}
  @this_month %{"key" => "this_month", "label" =>  "This Month", "amount" => 0, "in" => :months}
  @last_month %{"key" => "last_month", "label" =>  "Last Month", "amount" => -1, "in" => :months}
  @this_year %{"key" => "this_year", "label" =>  "This Year", "amount" => 0, "in" => :years}
  @custom %{"key" => "custom", "label" =>  "Custom"}

  defp es_locale(), do: %{
    "ranges" => [
      %{"key" => "today", "label" =>  "Hoy", "amount" => 0, "in" => :days},
      %{"key" => "yesterday", "label" =>  "Ayer", "amount" => -1, "in" => :days},
      %{"key" => "last_7days", "label" =>  "Últimos 7 días", "amount" => -6, "in" => :days},
      %{"key" => "last_30days", "label" =>  "Últimos 30 días", "amount" => -30, "in" => :days},
      %{"key" => "this_month", "label" =>  "This Mes", "amount" => 0, "in" => :months},
      %{"key" => "last_month", "label" =>  "Último Mes", "amount" => -1, "in" => :months},
      %{"key" => "this_year", "label" =>  "Este Año", "amount" => 0, "in" => :years},
  ],
  }

  defp en_locale(), do: %{
    "ranges" => [
      %{"key" => "today", "label" =>  "Today", "amount" => 0, "in" => :days},
      %{"key" => "yesterday", "label" =>  "Yesterday", "amount" => -1, "in" => :days},
      %{"key" => "last_7days", "label" =>  "Last 7 days", "amount" => -6, "in" => :days},
      %{"key" => "last_30days", "label" =>  "Last 30 days", "amount" => -30, "in" => :days},
      %{"key" => "this_month", "label" =>  "This Month", "amount" => 0, "in" => :months},
      %{"key" => "last_month", "label" =>  "Last Month", "amount" => -1, "in" => :months},
      %{"key" => "this_year", "label" =>  "This Year", "amount" => 0, "in" => :years},
  ],
  }

  def map_by_lang("es"), do: es_locale()["range"]
  def map_by_lang("en"), do: es_locale()["range"]
  def map_by_lang(_), do: []

  def map_by_key(key, lang) do
    IO.inspect(key)
    IO.inspect(lang)
    Enum.find(map_by_lang(lang), & (&1["key"] == key))
    |> IO.inspect(structs: false)
    %{"key" => "today", "label" =>  "Today", "amount" => 0, "in" => :days}
  end


end
