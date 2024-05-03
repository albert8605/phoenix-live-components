// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/phoenix_live_components_web.ex",
    "../lib/phoenix_live_components_web/**/*.*ex",
    "../lib/phoenix_live_components_web/**/*.sface"
  ],
  theme: {
    extend: {
      colors: {
        brand: "#FD4F00",
      },
      fontSize: {
        'xxs': '0.5rem',
      },
      screens: {
        'sm': '640px',
        'md': '768px',
        'lg': '1024px',
        'xl': '1280px',
        '2xl': '1536px',
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, {values})
    }),
    plugin(function ({addUtilities}) {
      addUtilities({
        '.input-group': {
          position: 'relative'
        },
        '.input-group_input': {
          'background-color': 'transparent',
          transition: 'outline-color 500ms'
        },
        '.input-group_input:is(focus,:valid)': {
          'outline-color': '#3c50eb'
        },
        '.input-group_label': {
          position: 'absolute',
          top:'-4px',
          left: '19px',
          translate: '10px 10px',
          color: '#625a5a',
          transition: 'translate 500ms, scale 500ms'
        },
        '.input-group_input:focus + .input-group_label,.input-group_input:valid + .input-group_label': {
          'padding-inline': '1px',
          translate: '10px -8px',
          scale: '0.8',
          background: 'linear-gradient(0deg, #f3f4f6b5 50%, #ffffff00 100%)',
          'border-top-left-radius': '0.5rem',
          'border-top-right-radius': '0.5rem',
        }
      })
    })
  ]
}
