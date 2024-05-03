defmodule PhoenixLiveComponentsWeb.Components.Calendar.Locale do
  @moduledoc false

  @not_found_map %{"index" => -1 , "index_str" => "-1", "full_name" => "", "short_name" => "" }

  defp es_locale(), do: %{
    "days" => [
      %{"index" => 1 , "index_str" => "01", "full_name" => "Lunes", "short_name" => "Lun" },
      %{"index" => 2 , "index_str" => "02", "full_name" => "Martes", "short_name" => "Mar" },
      %{"index" => 3 , "index_str" => "03", "full_name" => "Miércoles", "short_name" => "Mie" },
      %{"index" => 4 , "index_str" => "04", "full_name" => "Jueves", "short_name" => "Jue" },
      %{"index" => 5 , "index_str" => "05", "full_name" => "Viernes", "short_name" => "Vie" },
      %{"index" => 6 , "index_str" => "06", "full_name" => "Sábado", "short_name" => "Sab" },
      %{"index" => 7 , "index_str" => "07", "full_name" => "Domingo", "short_name" => "Dom" },
  ],
  "month" => [
      %{"index" => 1 , "index_str" => "01", "full_name" => "Enero", "short_name" => "Ene" },
      %{"index" => 2 , "index_str" => "02", "full_name" => "Febrero", "short_name" => "Feb" },
      %{"index" => 3 , "index_str" => "03", "full_name" => "Marzo", "short_name" => "Mar" },
      %{"index" => 4 , "index_str" => "04", "full_name" => "Abril", "short_name" => "Abr" },
      %{"index" => 5 , "index_str" => "05", "full_name" => "Mayo", "short_name" => "May" },
      %{"index" => 6 , "index_str" => "06", "full_name" => "Junio", "short_name" => "Jun" },
      %{"index" => 7 , "index_str" => "07", "full_name" => "Julio", "short_name" => "Jul" },
      %{"index" => 8 , "index_str" => "08", "full_name" => "Agosto", "short_name" => "Ago" },
      %{"index" => 9 , "index_str" => "09", "full_name" => "Septiembre", "short_name" => "Sep" },
      %{"index" => 10, "index_str" => "10", "full_name" => "Octubre", "short_name" =>  "Oct" },
      %{"index" => 11, "index_str" => "11", "full_name" => "Noviembre", "short_name" =>  "Nov" },
      %{"index" => 12, "index_str" => "12", "full_name" => "Diciembre", "short_name" =>  "Dic" },
    ]
  }

  defp en_locale(), do: %{
    "days" => [
      %{"index" => 1 , "index_str" => "01", "full_name" => "Monday", "short_name" => "Mon" },
      %{"index" => 2 , "index_str" => "02", "full_name" => "Tuesday", "short_name" => "Tue" },
      %{"index" => 3 , "index_str" => "03", "full_name" => "Wednesday", "short_name" => "Wed" },
      %{"index" => 4 , "index_str" => "04", "full_name" => "Thursday", "short_name" => "Thu" },
      %{"index" => 5 , "index_str" => "05", "full_name" => "Friday", "short_name" => "Fri" },
      %{"index" => 6 , "index_str" => "06", "full_name" => "Saturday", "short_name" => "Sat" },
      %{"index" => 7 , "index_str" => "07", "full_name" => "Sunday", "short_name" => "Sun" },
  ],
    "month" => [
      %{"index" => 1 , "index_str" => "01", "full_name" => "January", "short_name" => "Jan" },
      %{"index" => 2 , "index_str" => "02", "full_name" => "February", "short_name" => "Feb" },
      %{"index" => 3 , "index_str" => "03", "full_name" => "March", "short_name" => "Mar" },
      %{"index" => 4 , "index_str" => "04", "full_name" => "April", "short_name" => "Apr" },
      %{"index" => 5 , "index_str" => "05", "full_name" => "May", "short_name" => "May" },
      %{"index" => 6 , "index_str" => "06", "full_name" => "Jun", "short_name" => "Jun" },
      %{"index" => 7 , "index_str" => "07", "full_name" => "July", "short_name" => "Jul" },
      %{"index" => 8 , "index_str" => "08", "full_name" => "August", "short_name" => "Aug" },
      %{"index" => 9 , "index_str" => "09", "full_name" => "September", "short_name" => "Sep" },
      %{"index" => 10, "index_str" => "10", "full_name" => "October", "short_name" =>  "Oct" },
      %{"index" => 11, "index_str" => "11", "full_name" => "November", "short_name" =>  "Nov" },
      %{"index" => 12, "index_str" => "12", "full_name" => "December", "short_name" =>  "Dec" },
    ]
  }

  def days_name(index,locale) when is_bitstring(index), do: days_name_map(locale, index, "index_str")
  def days_name(index,locale), do: days_name_map(locale, index, "index")

  defp days_name_map("es", day_index, map_index), do: find_value_at("es", "days", map_index, day_index)
  defp days_name_map("en", day_index, map_index), do: find_value_at("en", "days", map_index, day_index)

  def month_map(index,locale) when is_bitstring(index), do: month_name_map(locale, index, "index_str")
  def month_map(index,locale), do: month_name_map(locale, index, "index")

  defp month_name_map("es", day_index, map_index), do: find_value_at("es", "month", map_index, day_index)
  defp month_name_map("en", day_index, map_index), do: find_value_at("en", "month", map_index, day_index)

  defp find_value_at("es", dictionary, map_index, value_index), do: find_value_at(es_locale()[dictionary], map_index, value_index, @not_found_map)
  defp find_value_at("en", dictionary, map_index, value_index), do: find_value_at(en_locale()[dictionary], map_index, value_index, @not_found_map)
  defp find_value_at(enum, index, value, default) do
    Enum.find(enum, & &1[index] == value)
    |> case  do
      nil -> default
      value -> value
    end
  end

end
