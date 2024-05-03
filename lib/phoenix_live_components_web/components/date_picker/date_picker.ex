defmodule PhoenixLiveComponentsWeb.Components.DatePicker do
  use Surface.LiveComponent

  alias PhoenixLiveComponentsWeb.Components.{Calendar, DatePicker.RangeHelper}

  prop name, :string, required: true
  prop calendar_value, :any, default: nil
  prop date_format_string, :string, default: "{0D}-{0M}-{YYYY}"
  prop placeholder, :string, default: "Seleccione"
  prop mode, :string,  values: ["simple", "range"], default: "simple"
  prop left, :boolean, default: false
  prop required, :boolean, default: false
  prop readonly, :boolean, default: false
  prop min_date, :datetime, default: nil
  prop max_date, :datetime, default: nil
  prop text_align, :string, default: "right"
  prop range_options, :list, default: RangeHelper.default_range()
  prop suffix_hover_class, :string, default: "cyan-400"

  prop shown_calendar, :boolean, default: false
  prop show_range_options, :boolean, default: false
  prop locale, :string, values: ["es","en"], default: "en"

  data selected_range, :string, default: "not-selected"



  @impl true
  def handle_event("toggle_calendar", %{"readonly" => _}, socket), do: {:noreply, socket}
  def handle_event("toggle_calendar", %{"shown_calendar" => _}, socket), do: {:noreply, assign(socket, shown_calendar: true) |> assign(show_range_options: false)}
  def handle_event("toggle_calendar", _, socket), do: {:noreply, assign(socket, shown_calendar: false) |> assign(show_range_options: false)}

  def handle_event("show_range_options", %{"readonly" => _}, socket), do: {:noreply, socket}
  def handle_event("show_range_options", %{"show_range_options" => _}, socket), do: {:noreply, assign(socket, show_range_options: true)}
  def handle_event("show_range_options", _, socket), do: {:noreply, assign(socket, show_range_options: false)}

  def handle_event("toggle-close", _, socket), do: {:noreply, assign(socket, show_range_options: false) |> assign(shown_calendar: false)}

  def handle_event("select-range", %{"key" => "custom"}, socket), do: {:noreply, assign(socket, show_range_options: false) |> assign(shown_calendar: true)}
  def handle_event("select-range", %{"key" => key}, socket) do
    {:noreply,
      assign(socket, calendar_value: RangeHelper.date_by_range_mape(key,"es"))
      |> assign(show_range_options: false)
      |> assign(shown_calendar: false)
      |> push_event("change_calendar_value", %{"name" => socket.assigns.name, "value" =>  Jason.encode!(RangeHelper.date_by_range_map(key)) })
    }
  end

  def handle_event("clear", _, socket) do
    {:noreply, assign(socket,calendar_value: nil) |> push_event("change_calendar_value", %{"name" => socket.assigns.name, "value" => "null"})}
  end

  defp is_valid(true,""), do: false
  defp is_valid(true, nil), do: false
  defp is_valid(_,_), do: true

  defp start_date_value(""), do: nil
  defp start_date_value(%{"from" => start_date}), do: start_date
  defp start_date_value(start_date), do: start_date

  defp end_date_value(%{"to" => end_date}), do: end_date
  defp end_date_value(_), do: nil

  defp get_icon_action("simple"), do: "toggle_calendar"
  defp get_icon_action(_), do: "show_range_options"

  defp show_clear_opt(nil, _), do: false
  defp show_clear_opt(_, true), do: false
  defp show_clear_opt(value, _ ) when is_binary(value), do: String.trim(value) != ""
  defp show_clear_opt(value, _) when is_map(value), do: value != Map.new

end