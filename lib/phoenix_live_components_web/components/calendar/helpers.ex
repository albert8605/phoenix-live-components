defmodule PhoenixLiveComponentsWeb.Components.Calendar.Helpers do
  require Logger
  use Timex
  alias Timex.Timezone
  alias PhoenixLiveComponentsWeb.Components.Calendar.Locale


  @january   %{"index" => 1 , "index_str" => "01", "full_name" => "January", "short_name" => "Jan" }
  @february  %{"index" => 2 , "index_str" => "02", "full_name" => "February", "short_name" => "Feb" }
  @march     %{"index" => 3 , "index_str" => "03", "full_name" => "March", "short_name" => "Mar" }
  @april     %{"index" => 4 , "index_str" => "04", "full_name" => "April", "short_name" => "Abr" }
  @may       %{"index" => 5 , "index_str" => "05", "full_name" => "May", "short_name" => "May" }
  @jun       %{"index" => 6 , "index_str" => "06", "full_name" => "Jun", "short_name" => "Jun" }
  @july      %{"index" => 7 , "index_str" => "07", "full_name" => "July", "short_name" => "Jul" }
  @august    %{"index" => 8 , "index_str" => "08", "full_name" => "August", "short_name" => "Ago" }
  @september %{"index" => 9 , "index_str" => "09", "full_name" => "September", "short_name" => "Sep" }
  @october   %{"index" => 10, "index_str" => "10", "full_name" => "October", "short_name" =>  "Oct" }
  @november  %{"index" => 11, "index_str" => "11", "full_name" => "November", "short_name" =>  "Nov" }
  @december  %{"index" => 12, "index_str" => "12", "full_name" => "December", "short_name" =>  "Dec" }

  def week_start_at(), do: :mon

  def get_days_map(locale), do: Enum.map([1,2,3,4,5,6,7],& Locale.days_name(&1,locale))
  def get_month_map(locale), do: Enum.map([1,2,3,4,5,6,7,8,9,10,11,12],& Locale.month_map(&1, locale))

  def week_rows(date) when is_bitstring(date), do: NaiveDateTime.from_iso8601(date) |> week_rows()
  def week_rows({:ok, date}), do: week_rows(date)
  def week_rows(month) do
    (
      first = Timex.beginning_of_week(Timex.beginning_of_month(month), week_start_at())
      last = Timex.end_of_week(Timex.end_of_month(month), week_start_at())
      diff = Timex.diff(last, first, :weeks)
      {new_first, new_last} = complete_interval(month, first, last)
      Enum.chunk_every(Enum.map(Timex.Interval.new(from: new_first, until: new_last), fn x1 -> x1 end), 7)
      )
  end

  defp complete_interval(month, first, last) do
    diff_first = Timex.diff(Timex.beginning_of_month(month), first, :days)
    last_sum = 42 - (Timex.days_in_month(month)) - diff_first
    {Timex.shift(Timex.beginning_of_month(month), days: -(diff_first )), Timex.shift(Timex.end_of_month(month), days: (last_sum )) }
  end

  def month_from_date(nil), do: 0
  def month_from_date(date) when is_bitstring(date), do: NaiveDateTime.from_iso8601!(date) |> month_from_date()
  def month_from_date({:ok, date}), do: year_from_date(date)
  def month_from_date({:error, _}), do: 0
  def month_from_date(date) do
    case Timex.is_valid?(date) do
      true -> Map.take(date, [:month]) |> Map.get(:month)
      _ -> 0
    end
  end

  def year_from_date(nil), do: 0
  def year_from_date(date) when is_bitstring(date), do: NaiveDateTime.from_iso8601!(date) |> year_from_date()
  def year_from_date({:ok, date}), do: year_from_date(date)
  def year_from_date({:error, _}), do: 0
  def year_from_date(date) do
    case Timex.is_valid?(date) do
      true -> Map.take(date, [:year]) |> Map.get(:year)
      _ -> 0
    end
  end

  def set(date, options) when is_bitstring(date), do: NaiveDateTime.from_iso8601(date) |> set(options)
  def set({:ok, date}, options), do: set(date, options)
  def set(date, options), do: Timex.set(date, options)
#                                                                                                                                             2023-11-1T00:00:00Z
#                                                                                                                                             2015-01-23T23:50:07.123Z
  def date_from_str_params(%{:year => year, :month => month, :day => day}, true), do: date_from_str_params(%{"year" => year, "month" => month, "day" => day}, true)
  def date_from_str_params(%{:year => year, :month => month, :day => day}, false), do: date_from_str_params(%{"year" => year, "month" => month, "day" => day}, false)
  def date_from_str_params(%{"year" => year, "month" => month, "day" => day}, true), do: NaiveDateTime.from_iso8601!("#{year}-#{number_parser(month)}-#{number_parser(day)}T00:00:00Z")
  def date_from_str_params(%{"year" => year, "month" => month, "day" => day}, false), do: NaiveDateTime.from_iso8601!("#{year}-#{number_parser(month)}-#{number_parser(day)}T23:59:59Z")
  def date_from_str_params(str_date, start_end), do: NaiveDateTime.from_iso8601!(str_date) |> date_from_str_params(start_end)

  defp number_parser(month) when is_bitstring(month), do: String.to_integer(month) |> number_parser()
  defp number_parser(month) do
    cond do
      month < 10 -> "0#{month}"
      true -> "#{month}"
    end
  end

  def after?(first,last) when is_bitstring(first), do: after?(NaiveDateTime.from_iso8601!(first), last)
  def after?(first,last) when is_bitstring(last), do: after?(first, NaiveDateTime.from_iso8601!(last))
  def after?(first,last), do: Timex.after?(first, last)

end
