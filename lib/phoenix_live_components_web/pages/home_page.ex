defmodule PhoenixLiveComponentsWeb.Pages.HomePage do
  use Surface.LiveView
  use PhoenixLiveComponentsWeb, :verified_routes

  alias PhoenixLiveComponentsWeb.Components.{ComponentsDetails}

  @component_list [
  %{"name" => "calendar", "title" => "Calendar"},
  %{"name" => "simple_date_picker", "title" => "Date Picker(Simple)"},
  %{"name" => "range_date_picker", "title" => "Date Picker(Range)"},
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
      assign(socket, :component_list, @component_list)
      |> assign(:component_shown, nil)
      |> assign(:searchText, "")
      |> assign(:locale, "en")
    }
  end

  @impl true
  def handle_event("show_component", %{"value" => component_shown}, socket), do: {:noreply, assign(socket, :component_shown, component_shown)}
  def handle_event("search_keyup", %{"value" => value}, socket), do: {:noreply, assign(socket, :component_list, Enum.filter(@component_list, & (string_downcase_contains(value, &1["title"]))))}
  def handle_event("change_locale", %{"lang" => lang}, socket), do: {:noreply, assign(socket, :locale, lang)}

    defp string_downcase_contains(value, found), do: String.contains?(string_normalize(found), string_normalize(value))
  defp string_normalize(str), do: String.downcase(str) |> String.normalize(:nfd) |> String.replace(~r/[^A-z\s]/u, "") |> String.replace(~r/\s/, "")

  defp images_url(img_name), do: ~p"/images/#{img_name}"

end
