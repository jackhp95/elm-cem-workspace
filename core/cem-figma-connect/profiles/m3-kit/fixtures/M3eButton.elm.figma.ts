// url=https://www.figma.com/design/UtwpUdPiOZEuxp8Nq1d5yQ/Material-3-Design-Kit--Community-?node-id=57994-2227
import figma from "figma"

const instance = figma.selectedInstance

const size = instance.getEnum("Size", {
  XSmall: "M3e.Token.xs",
  Small: "M3e.Token.sm",
  Medium: "M3e.Token.md",
  Large: "M3e.Token.lg",
  XLarge: "M3e.Token.xl",
})

const shape = instance.getEnum("Type", {
  Round: "M3e.Token.rounded",
  Square: "M3e.Token.square",
})

const label = instance.getString("Label text")

export default {
  example: figma.code`M3e.Button.view
    [ M3e.Button.variant M3e.Token.filled
    , M3e.Button.size ${size}
    , M3e.Button.shape ${shape}
    ]
    [ M3e.text "${label}" ]`,
  imports: ["import M3e.Button", "import M3e.Token"],
  id: "m3e-button-filled-elm-spike",
  metadata: { nestable: true },
}
