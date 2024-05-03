defmodule PhoenixLiveComponentsWeb.Components.ComponentsDetails do
  use Surface.LiveComponent

  alias PhoenixLiveComponentsWeb.Components.{Calendar, DatePicker}

  prop locale, :string, values: ["es","en"], default: "en"
  prop component_shown, :string, default: ""


  defp resume("calendar", "es") do
    """
      Componente que reenderiza un calendario simple, con la opción de navegar entre las distintas fechas
      desde el año 1009 en adelante.
      <br>
      <ul class="list-disc pl-10" >
        <li> Permite ser embebido en otros componentes </li>
        <li> Permite dos tipos de selección ["simple", "rango"] </li>
      </ul>
    """
    end

  defp resume("calendar", "en") do
   """
      Component that renders a simple calendar, with the option to navigate between dates from 1009 onwards.
      from the year 1009 onwards.
      <br>
      <ul class="list-disc pl-10" >
        <li> Allows to be embedded in other components</li>
        <li> Allows two types of selection ["simple", "range"] </li>
      </ul>
    """
    end
  defp resume(_, _), do: "undefined"

  end
