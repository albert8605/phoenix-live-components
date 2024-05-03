defmodule PhoenixLiveComponentsWeb.Components.DatePicker.Locale do

  @not_found_map %{"key" => "not_found", "label" =>  "not_found", "amount" => -1}

  @today %{"key" => "today", "label" =>  "Today", "amount" => 0, "in" => :days}
  @yesterday %{"key" => "yesterday", "label" =>  "Yesterday", "amount" => -1, "in" => :days}
  @last_7days %{"key" => "last_7days", "label" =>  "Last 7 days", "amount" => -6, "in" => :days}
  @last_30days %{"key" => "last_30days", "label" =>  "Last 30 days", "amount" => -29, "in" => :days}
  @this_month %{"key" => "this_month", "label" =>  "This Month", "amount" => 0, "in" => :months}
  @last_month %{"key" => "last_month", "label" =>  "Last Month", "amount" => -1, "in" => :months}
  @this_year %{"key" => "this_year", "label" =>  "This Year", "amount" => 0, "in" => :years}
  @custom %{"key" => "custom", "label" =>  "Custom"}

  defp es_locale(), do: %{
    "ranges" => [
       Map.put(@today,"label", "Hoy" ),
       Map.put(@yesterday,"label", "Ayer" ),
       Map.put(@last_7days,"label", "Últimos 7 días"),
       Map.put(@last_30days,"label", "Últimos 30 días"),
       Map.put(@this_month,"label", "Este Mes"),
       Map.put(@last_month,"label", "Último Mes"),
       Map.put(@this_year,"label", "Este Año"),
       Map.put(@custom,"label", "Personalizado"),
  ],
  }

  defp en_locale(), do: %{
    "ranges" => [
      @today,
      @yesterday,
      @last_7days,
      @last_30days,
      @this_month,
      @last_month,
      @this_year,
      @custom,
  ],
  }

  def placeholder_locale("es"), do: "Seleccione"
  def placeholder_locale(_), do: "Select"

  def map_by_lang("es"), do: es_locale()["ranges"]
  def map_by_lang("en"), do: en_locale()["ranges"]
  def map_by_lang(_), do: []

  def map_by_key(key, lang), do: Enum.find(map_by_lang(lang), & (&1["key"] == key))

end
