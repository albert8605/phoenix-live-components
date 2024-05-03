defmodule PhoenixLiveComponentsWeb.Components.DatePicker.RangeHelper do
  use Timex
  alias PhoenixLiveComponentsWeb.Components.Calendar.Helpers
  alias PhoenixLiveComponentsWeb.Components.DatePicker.Locale

   @today %{"key" => "today", "label" =>  "Today", "amount" => 0, "in" => :days}
   @yesterday %{"key" => "yesterday", "label" =>  "Yesterday", "amount" => -1, "in" => :days}
   @last_7days %{"key" => "last_7days", "label" =>  "Last 7 days", "amount" => -6, "in" => :days}
   @last_30days %{"key" => "last_30days", "label" =>  "Last 30 days", "amount" => -30, "in" => :days}
   @this_month %{"key" => "this_month", "label" =>  "This Month", "amount" => 0, "in" => :months}
   @last_month %{"key" => "last_month", "label" =>  "Last Month", "amount" => -1, "in" => :months}
   @this_year %{"key" => "this_year", "label" =>  "This Year", "amount" => 0, "in" => :years}
   @custom %{"key" => "custom", "label" =>  "Custom"}

  def default_range(locale), do: Locale.map_by_lang(locale)


  def locale_date_by_range_map(range_map, locale) do
    Locale.map_by_key(range_map,locale)
    |> date_by_range_map(Date.utc_today())
  end

  def date_by_range_map(range_map, to_date \\ Date.utc_today())

  def date_by_range_map(%{"key" => "yesterday"} = date_map, _), do: Map.put(date_map, "key","") |> date_by_range_map(Timex.shift(Date.utc_today(), days: -1 )) |> IO.inspect()
  def date_by_range_map(%{"key" => "this_month"}, to_date), do: Timex.beginning_of_month(Date.utc_today()) |> range_by_today(Timex.end_of_month(Date.utc_today()) )
  def date_by_range_map(%{"key" => "last_month"}, to_date), do: range_by_today(Timex.shift(Timex.beginning_of_month(Date.utc_today()), months: -1), Timex.shift(Timex.beginning_of_month(Date.utc_today()), days: -1))
  def date_by_range_map(%{"key" => "this_year"}, to_date), do: Timex.beginning_of_year(Date.utc_today()) |> range_by_today(Timex.end_of_year(Date.utc_today()))

  def date_by_range_map("custom", _), do: nil
  def date_by_range_map(%{"key" => "custom"}, _), do: nil

  def date_by_range_map(%{"in" => :days} = range_map, to_date), do: Timex.shift(Date.utc_today(), days: range_map["amount"] ) |> range_by_today(to_date)
  def date_by_range_map(%{"in" => :months} = range_map, to_date), do: Timex.shift(Date.utc_today(), months: range_map["amount"] ) |> range_by_today(to_date)
  def date_by_range_map(%{"in" => :years} = range_map, to_date), do: Timex.shift(Date.utc_today(), years: range_map["amount"] ) |> range_by_today(to_date)

  defp range_by_today(from_date,to_date), do: Timex.before?(to_date, from_date) |> is_before_result?(from_date,to_date)

  defp is_before_result?(true, from_date,to_date), do: %{"from" => date_format(to_date, true), "to" => date_format(from_date, false)}
  defp is_before_result?(false, from_date,to_date), do: %{"from" => date_format(from_date, true), "to" => date_format(to_date, false)}

  defp date_format(date, is_start_date), do: Helpers.date_from_str_params(%{"year" => date.year, "month" => date.month, "day" => day_formatted(date.day)}, is_start_date)

  defp day_formatted(day) when day < 10, do: "0#{day}"
  defp day_formatted(day), do: "#{day}"

end