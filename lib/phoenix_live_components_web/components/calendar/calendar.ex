defmodule PhoenixLiveComponentsWeb.Components.Calendar do
  use Surface.LiveComponent

  alias Timex
  alias PhoenixLiveComponentsWeb.Components.{Calendar.Helpers, Calendar.Locale}

  prop start_date, :datetime, default: nil
  prop end_date, :datetime, default: nil

  prop start_month, :integer, default: 0
  prop start_year, :integer, default: 0
  prop min_date, :datetime, default: nil
  prop max_date, :datetime, default: nil
  prop mode, :string,  values: ["simple", "range"], default: "simple"
  prop text_size, :string, default: "sm"
  prop date_format_string, :string, default: "{0D}-{0M}-{YYYY}"
  prop calendar_value, :any, default: nil
  prop locale, :string, values: ["es","en"], default: "en"


  prop parent_id, :string, default: ""
  prop parent_socket, :any, default: "not_defined"
  prop name, :string, required: true

  data today, :datetime, default: NaiveDateTime.utc_now()
  data days_name, :list, default: []
  data week_rows, :list, default: []
  data years_rows, :list, default: []
  data date_shown, :datetime, default: NaiveDateTime.utc_now()
  data month_shown, :integer, default: 0
  data year_shown, :integer, default: 0
  data view_mode, :string,  values: ["default", "monthly","years"], default: "default"

  @selected_bg "bg-blue-300 text-white"
  @between_days_range_bg "bg-blue-100 text-white"

  @impl true
  def mount(socket) do
    today = Date.utc_today()
    week_rows = Enum.flat_map(Helpers.week_rows(today), & &1)
    years_rows = create_10_years_range(today,0,11)
    month_shown = Helpers.month_from_date(today)
    year_shown = Helpers.year_from_date(today)
    {:ok,
      socket
      |> assign(:days_name, Helpers.get_days_map("en"))
      |> assign(week_rows: week_rows)
      |> assign(years_rows: years_rows)
      |> assign(month_shown: month_shown)
      |> assign(year_shown: year_shown)
    }
  end

  @impl true
  def handle_event("change_view_mode", %{"view_mode" => "default", "start_date" => start_date}, socket), do:
    {:noreply, assign(socket, view_mode: "monthly") |> assign(year_shown: Helpers.year_from_date(start_date))}

  def handle_event("change_view_mode", %{"view_mode" => "monthly", "start_date" => start_date}, socket), do:
    {:noreply, assign(socket, view_mode: "years") |> assign(year_shown: Helpers.year_from_date(start_date)) |> assign(years_rows: create_10_years_range(Helpers.year_from_date(start_date),0,11)) }


  def handle_event("change_view_mode",  %{"start_date" => start_date} , socket) do
    {:noreply,
    assign(socket, view_mode: "default")
    |> assign(month_shown: Helpers.month_from_date(start_date) )
    |> assign(year_shown: Helpers.year_from_date(start_date))
    |> assign(week_rows: Enum.flat_map(Helpers.week_rows(start_date), & &1))
  }
  end

  def handle_event("change_view_mode", %{"view_mode" => "default"}, socket), do: {:noreply, assign(socket, view_mode: "monthly") }
  def handle_event("change_view_mode", %{"view_mode" => "monthly"}, socket), do: {:noreply, assign(socket, view_mode: "years") }
  def handle_event("change_view_mode", _, socket), do: {:noreply, assign(socket, view_mode: "default") }

  def handle_event("select_day", %{"disabled" => _ }, socket), do: {:noreply, socket}
  def handle_event("select_day", %{"mode" => "simple","date" => start_date }, socket), do: assign(socket, start_date: start_date) |> update_parent_data()
  def handle_event("select_day", %{"mode" => "range","date" => date ,"start_date" => start_date ,"end_date" => end_date }, socket) do
    (case {start_date, end_date} do
      {"empty",_} -> assign(socket, start_date: date) |> assign(end_date: nil)

      _ ->
        cond do
          Helpers.after?(date, start_date) -> assign(socket, end_date: Helpers.date_from_str_params(date, false))

          true -> assign(socket, start_date: date) |> assign(end_date: nil)
        end
    end)
    |> update_parent_data()
  end

  def handle_event("select_month", %{"disabled" => _}, socket), do: {:noreply, socket}
  def handle_event("select_month", %{"month" => start_month, "start_date" => start_date, "date_shown" => date_shown }, socket), do: assign(socket, view_mode: "default") |> set_data(start_date, "monthly", start_month, date_shown) |> update_parent_data()
  def handle_event("select_month", %{"month" => start_month, "date_shown" => date_shown }, socket), do: assign(socket, view_mode: "default") |> set_data(date_shown, "monthly", start_month, date_shown) |> update_parent_data()

  def handle_event("select_year", %{"disabled" => _}, socket), do: {:noreply, socket}
  def handle_event("select_year", %{"year" => start_year, "start_date" => start_date, "date_shown" => date_shown}, socket), do: assign(socket, view_mode: "default") |> set_data(start_date, "years",start_year, date_shown) |> update_parent_data()
  def handle_event("select_year", %{"year" => start_year, "date_shown" => date_shown}, socket), do: assign(socket, view_mode: "default") |> set_data(date_shown, "years",start_year, date_shown) |> update_parent_data()

  def handle_event("back-selection", %{"view_mode" => "monthly", "year_shown" => year_shown, "date_shown" => date_shown}, socket), do:
       {:noreply, assign(socket, year_shown: downgrade_year(year_shown, 12)) |> assign(date_shown: Helpers.set(date_shown, year: downgrade_year(year_shown, 12)))}

  def handle_event("back-selection", %{"view_mode" => "years", "years_rows" => years_rows}, socket), do:
       {:noreply, assign(socket, years_rows: create_10_years_range(years_rows,11,0) )}

  def handle_event("back-selection", %{"view_mode" => "default", "year_shown" => year_shown, "month_shown" => month_shown}, socket) do
    month_shown = downgrade_month(month_shown)
    year_shown = downgrade_year(year_shown, month_shown)
    locale = socket.assigns.locale
    month_from_data = Locale.month_map(month_shown,locale)["index_str"]
    week_rows = Enum.flat_map(Helpers.week_rows("#{year_shown}-#{month_from_data}-01T00:00:00Z"), & &1)
    {:noreply, assign(socket, month_shown: month_shown ) |> assign(year_shown: year_shown) |> assign(week_rows: week_rows) }
  end

  def handle_event("back-selection",_, socket), do: {:noreply, socket}

  def handle_event("forward-selection", %{"view_mode" => "monthly", "year_shown" => year_shown, "date_shown" => date_shown }, socket), do:
       {:noreply, assign(socket, year_shown: upgrade_year(year_shown, 1)) |> assign(date_shown: Helpers.set(date_shown, year: upgrade_year(year_shown, 1))) }

  def handle_event("forward-selection", %{"view_mode" => "years", "years_rows" => years_rows}, socket), do:
    {:noreply, assign(socket, years_rows: create_10_years_range(years_rows, 0, 11) )}

  def handle_event("forward-selection", %{"view_mode" => "default", "year_shown" => year_shown, "month_shown" => month_shown}, socket) do
    month_shown = upgrade_month(month_shown)
    year_shown = upgrade_year(year_shown, month_shown)
    locale = socket.assigns.locale
    month_from_data = Locale.month_map(month_shown,locale)["index_str"]
    week_rows = Enum.flat_map(Helpers.week_rows("#{year_shown}-#{month_from_data}-01T00:00:00Z"), & &1)
    {:noreply, assign(socket, month_shown: month_shown ) |> assign(year_shown: year_shown) |> assign(week_rows: week_rows) }
  end

  def handle_event("forward-selection",_, socket), do: {:noreply, socket}

  defp set_data(socket, selected_date , view_mode, value, date_shown) do
    locale = socket.assigns.locale
    case view_mode do
      "monthly" ->
          new_year = Helpers.year_from_date(date_shown)
          new_date = Helpers.set(selected_date, month: Locale.month_map(value,locale)["index"]) |> Helpers.set(year: new_year)
          assign(socket, start_date: new_date)
          |> assign(end_date: nil)
          |> assign(date_shown: new_date)
          |> assign(month_shown: Locale.month_map(value, locale)["index"])
          |> assign(week_rows: Enum.flat_map(Helpers.week_rows(new_date), & &1))

      "years" ->
          new_date = Helpers.set(selected_date, year: String.to_integer(value))
          assign(socket, start_date: new_date)
          |> assign(end_date: nil)
          |> assign(date_shown: new_date)
          |> assign(year_shown: Helpers.year_from_date(new_date))
          |> assign(week_rows: Enum.flat_map(Helpers.week_rows(new_date), & &1))

      _ -> socket
    end
  end


  defp get_header_text(view_mode, month_shown, year_shown, years_rows, locale) do
    case view_mode do
      "default" -> get_default_header(month_shown, year_shown,locale)

      "monthly" -> "#{year_shown}"

      "years" -> "#{years_rows.first} - #{years_rows.last}"

      _-> view_mode
    end
  end

  defp get_default_header(month_shown, year_shown,locale), do: "#{Locale.month_map(month_shown, locale)["full_name"]} #{year_shown}"

  defp day_row_class(day_row, start_date, end_date, today, min_date, max_date) do
    enabled_rule = "#{add_day_row_cursor_class(day_row,min_date,max_date)}"
    border =
      case Date.diff(today,day_row) do
        0 -> "border border-2 border-dashed border-gray-300"
        _ -> ""
      end
    "flex flex-col justify-center h-5 sm:h-8 hover:bg-gray-100 hover:text-black items-center lg:text-center rounded rounded-md w-full  lg:px-1.5 border-0 text-gray-500 sm:p-0 #{border} #{enabled_rule} #{selected_day_bg(day_row,start_date, end_date)} "
  end

  defp month_row_class(month_row, today, selected_date, date_shown, min_date, max_date) do
    actual_month = { Helpers.month_from_date(today), Helpers.year_from_date(today)}
    shown_month = { month_row["index"], Helpers.year_from_date(date_shown) }
    enabled_rule = add_month_row_cursor_class(month_row, date_shown,min_date,max_date)
    border =
      cond do
        actual_month == shown_month -> "border border-2 border-dashed border-gray-300"
        true -> ""
      end
    "flex flex-row hover:bg-gray-100 items-center justify-center rounded rounded-md #{border}  #{enabled_rule} #{selected_month_bg(month_row, selected_date, date_shown)} "
  end

  defp year_row_class(year, today, start_date, date_shown, min_date, max_date) do
    actual_year = Helpers.year_from_date(today)
    enabled_rule = add_year_row_cursor_class(year, date_shown,min_date, max_date)

    border =
      cond do
        year == actual_year -> "border border-2 border-dashed border-gray-300"
        true -> ""
      end
    "flex flex-row hover:bg-gray-100 items-center justify-center rounded rounded-md #{border} #{enabled_rule} #{selected_year_bg(year,start_date)}"
  end

  defp add_day_row_cursor_class(pivot,min,max), do: is_enable_day(pivot,min,max) |> enabled_or_disabled_cursor()

  defp add_month_row_cursor_class(pivot,start_date,min,max), do: !is_enabled_month(pivot,start_date, min, max) |> enabled_or_disabled_cursor()

  defp add_year_row_cursor_class(pivot,start_date,min,max), do: !is_enabled_year(pivot,start_date, min, max) |> enabled_or_disabled_cursor()

  defp selected_day_bg(_,nil,_), do: ""
  defp selected_day_bg(day_row, start_date,nil), do: selected_day_bg(day_row,start_date,start_date)
  defp selected_day_bg(day_row,start_date, end_date) when is_bitstring(start_date), do: selected_day_bg(day_row,NaiveDateTime.from_iso8601!(start_date), end_date)
  defp selected_day_bg(day_row,start_date, end_date) when is_bitstring(end_date), do: selected_day_bg(day_row,start_date, NaiveDateTime.from_iso8601!(end_date))
  defp selected_day_bg(day_row,start_date, end_date) do
    start_date_rule = Date.diff(start_date,day_row) == 0
    between_days_rule = is_between_days(day_row,start_date,end_date)
    end_date_rule = Date.diff(end_date,day_row) == 0
    cond do
      start_date_rule || end_date_rule -> @selected_bg

      between_days_rule -> @between_days_range_bg

      true -> ""
    end
  end

  defp is_enabled_month(_, nil, _, _), do: true
  defp is_enabled_month(month_row,date_shown, nil, max_date) do
    shown_year = Helpers.year_from_date(date_shown)
    min_date = Helpers.date_from_str_params(%{"year" => shown_year, "month" => month_row["index_str"], "day" => "01"}, true)
    is_enabled_month(month_row,date_shown, min_date, max_date)
  end
  defp is_enabled_month(month_row,date_shown, min_date, nil) do
    shown_year = Helpers.year_from_date(date_shown)
    max_date = Helpers.date_from_str_params(%{"year" => shown_year, "month" => month_row["index_str"], "day" => "01"}, false)
    is_enabled_month(month_row,date_shown, min_date, max_date)
  end

  defp is_enabled_month(month_row,date_shown, min_date, max_date) do
    shown_year = Helpers.year_from_date(date_shown)
    min_date = Timex.beginning_of_month(min_date)
    max_date = Timex.end_of_month(max_date)
    pivot_date = Helpers.date_from_str_params(%{"year" => shown_year, "month" => month_row["index_str"], "day" => "01"}, true)
    is_between_days(pivot_date,min_date, max_date)
  end

  defp is_enabled_year(year, date_shown, min_date, max_date) when is_bitstring(year), do: String.to_integer(year) |> is_enabled_year( date_shown, min_date, max_date)
  defp is_enabled_year(_, nil, _, _), do: true
  defp is_enabled_year(year,date_shown, nil, max_date) do
    shown_month = Helpers.month_from_date(date_shown)
    min_date = Helpers.date_from_str_params(%{"year" => year, "month" => shown_month, "day" => "01"}, true)
    is_enabled_year(year,date_shown, min_date, max_date)
  end
  defp is_enabled_year(year,date_shown, min_date, nil) do
    shown_month = Helpers.month_from_date(date_shown)
    max_date = Helpers.date_from_str_params(%{"year" => year, "month" => shown_month, "day" => "01"}, false)
    is_enabled_year(year,date_shown, min_date, max_date)
  end

  defp is_enabled_year(year,date_shown, min_date, max_date) do
    shown_month = Helpers.month_from_date(date_shown)
    min_date = Timex.beginning_of_month(min_date)
    max_date = Timex.end_of_month(max_date)
    pivot_date = Helpers.date_from_str_params(%{"year" => year, "month" => shown_month, "day" => "01"}, true)
    is_between_days(pivot_date,min_date, max_date)
  end

  defp selected_month_bg(_,nil,_), do: ""
  defp selected_month_bg(_,_,nil), do: ""
  defp selected_month_bg(month_row,start_date, date_shown) do
    month_row = { month_row["index"], Helpers.year_from_date(start_date) }
    date_shown = { Helpers.month_from_date(date_shown), Helpers.year_from_date(date_shown) }
    start_date = { Helpers.month_from_date(start_date), Helpers.year_from_date(start_date) }
    cond do
      ((date_shown == start_date) && (month_row == start_date)) -> @selected_bg
      true -> ""
    end
  end

  defp selected_year_bg(_,nil), do: ""
  defp selected_year_bg(year_row,start_date) when is_bitstring(year_row), do: String.to_integer(year_row) |> selected_year_bg(start_date)
  defp selected_year_bg(year_row,start_date) do
    start_date = Helpers.year_from_date(start_date)
    cond do
      (year_row == start_date) -> @selected_bg
      true -> ""
    end
  end

  defp enabled_or_disabled_cursor(true), do: "unavailable-day cursor-not-allowed text-gray-200"
  defp enabled_or_disabled_cursor(false), do: "available-day cursor-pointer"

  defp is_enable_day(pivot,min,max), do: !is_between_days(pivot,min,max)

  defp is_between_days(pivot,nil,max), do:  is_between_days(pivot,pivot,max)
  defp is_between_days(pivot,min,nil), do: is_between_days(pivot,min,pivot)
  defp is_between_days(pivot,min,max) do
    pivot_ = NaiveDateTime.to_date(pivot)
    min = NaiveDateTime.to_date(min)
    max = NaiveDateTime.to_date(max)
    Timex.between?(pivot_,min,max, inclusive: true)
  end

  defp create_10_years_range(date, minus_offset, plus_offset) do
    current_year = get_year_from_map(date)
    temporal_rem = current_year |> rem(10)
    (current_year - temporal_rem - minus_offset)..(current_year + plus_offset - temporal_rem)
  end

  defp get_year_from_map(year_map) when is_bitstring(year_map), do: String.to_integer(year_map)
  defp get_year_from_map(%{:year => year}), do: year
  defp get_year_from_map(year_map), do: year_map

  defp downgrade_month(month_index) when is_bitstring(month_index), do: String.to_integer(month_index) |> downgrade_month()
  defp downgrade_month(month_index) when (month_index < 1), do: 12
  defp downgrade_month(month_index) when ((month_index - 1) == 0 ), do: 12
  defp downgrade_month(month_index), do: month_index - 1

  defp upgrade_month(month_index) when is_bitstring(month_index), do: String.to_integer(month_index) |> upgrade_month()
  defp upgrade_month(month_index) when (month_index > 12), do: 1
  defp upgrade_month(month_index) when ((month_index + 1) > 12), do: 1
  defp upgrade_month(month_index), do: month_index + 1

  defp downgrade_year(year_index,month_index) when is_bitstring(year_index), do: String.to_integer(year_index) |> downgrade_year(month_index)
  defp downgrade_year(year_index,month_index) when is_bitstring(month_index), do: downgrade_year(year_index,String.to_integer(month_index))
  defp downgrade_year(year_index,month_index) when (month_index == 12), do: year_index - 1
  defp downgrade_year(year_index,_), do: year_index

  defp upgrade_year(year_index,month_index) when is_bitstring(year_index), do: String.to_integer(year_index) |> upgrade_year(month_index)
  defp upgrade_year(year_index,month_index) when is_bitstring(month_index), do: upgrade_year(year_index, String.to_integer(month_index))
  defp upgrade_year(year_index,month_index) when (month_index == 1), do: year_index + 1
  defp upgrade_year(year_index,_), do: year_index

  defp update_parent_data(%{:assigns => %{:parent_socket => "not_defined" }} = socket), do: {:noreply, socket}
  defp update_parent_data(%{:assigns => %{:parent_id => "" }} = socket), do: {:noreply, socket}
  defp update_parent_data(%{:assigns => %{:mode => "range", :end_date => nil }} = socket), do: {:noreply, socket}

  defp update_parent_data(%{:assigns => %{:mode => "simple",:parent_socket => parent_socket, :parent_id => parent_id, :start_date => start_date }} = socket) do
    send_update(parent_socket, id: parent_id, calendar_value: start_date)
    send_update(parent_socket, id: parent_id, shown_calendar: false)
    {:noreply, push_event(socket,"change_calendar_value", %{"name" => socket.assigns.name, "value" => calendar_value_to_search_query(start_date) |> Jason.encode!() })}
  end

  defp update_parent_data(%{:assigns => %{:mode => "range",:parent_socket => parent_socket, :parent_id => parent_id, :start_date => start_date, :end_date => end_date }} = socket) do
    send_update(parent_socket, id: parent_id, calendar_value: %{"from" => start_date, "to" => end_date})
    send_update(parent_socket, id: parent_id, shown_calendar: false)

    {:noreply, push_event(socket,"change_calendar_value", %{"name" => socket.assigns.name, "value" => encode_selected_date( start_date, end_date) }) }
  end
  defp update_parent_data(socket), do: {:noreply, socket}

  defp encode_selected_date(start_date, ""), do: encode_selected_date(start_date, start_date)
  defp encode_selected_date(start_date, nil), do: encode_selected_date(start_date, start_date)
  defp encode_selected_date(start_date, end_date), do: Jason.encode!(%{"from" => start_date, "to" => end_date})

  def format_calendar_value(calendar_value, format_string, mode \\ "simple")
  def format_calendar_value("", _,_), do: ""
  def format_calendar_value(nil, _, _), do: ""
  def format_calendar_value(%{"from" => start_date} = calendar_value, format_string, mode) when is_bitstring(start_date), do: update_calendar_value_map(start_date,"from", calendar_value, format_string, mode)
  def format_calendar_value(%{"to" => end_date} = calendar_value, format_string, mode) when is_bitstring(end_date), do: update_calendar_value_map(end_date,"to", calendar_value, format_string, mode)
  def format_calendar_value(%{"from" => start_date}, format_string, "simple"), do: Timex.format!(start_date, format_string)
  def format_calendar_value(%{"from" => start_date, "to" => end_date}, format_string, "range") do
    start_date = Timex.format!(start_date, format_string)
    end_date = Timex.format!(end_date, format_string)
    "#{start_date} - #{end_date}"
  end

  def format_calendar_value(calendar_value, format_string, mode) when is_bitstring(calendar_value), do: Helpers.date_from_str_params(calendar_value,true) |> format_calendar_value(format_string, mode)
  def format_calendar_value(calendar_value, format_string, _), do: Timex.format!(calendar_value, format_string)


  def calendar_value_to_search_query(nil), do: ""
  def calendar_value_to_search_query(""), do: ""
  def calendar_value_to_search_query(%{"from" => start_date, "to" => end_date}), do: %{"from" =>  Helpers.date_from_str_params(start_date,true), "to" =>  Helpers.date_from_str_params(end_date,false) }
  def calendar_value_to_search_query(map), do: calendar_value_to_search_query(%{"from" =>  map, "to" =>  map})

  defp update_calendar_value_map(value,key, map, format_string, mode) do
    new_value = Helpers.date_from_str_params(value,true)
    Map.put(map, key,new_value)
    |> format_calendar_value(format_string, mode)
  end

  defp month_rows(locale), do: Helpers.get_month_map(locale)

end