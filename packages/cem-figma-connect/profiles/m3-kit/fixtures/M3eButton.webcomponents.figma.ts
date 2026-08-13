// url=https://www.figma.com/design/UtwpUdPiOZEuxp8Nq1d5yQ/Material-3-Design-Kit--Community-?node-id=57994-2227
import figma from "figma"

/**
 * VERIFY-NOW SPIKE (publish gate) — m3e-button (filled) bound to the M3 kit "Button" set.
 * Axes: Size (XSmall..XLarge) -> size attr; Type (Round/Square) -> shape attr.
 */

const instance = figma.selectedInstance

const size = instance.getEnum("Size", {
  XSmall: "extra-small",
  Small: "small",
  Medium: "medium",
  Large: "large",
  XLarge: "extra-large",
})

const shape = instance.getEnum("Type", {
  Round: "rounded",
  Square: "square",
})

const label = instance.getString("Label text")

export default {
  example: figma.code`<m3e-button variant="filled" size="${size}" shape="${shape}">${label}</m3e-button>`,
  imports: ['import "@m3e/web/all"'],
  id: "m3e-button-filled-spike",
  metadata: {
    nestable: true,
  },
}
