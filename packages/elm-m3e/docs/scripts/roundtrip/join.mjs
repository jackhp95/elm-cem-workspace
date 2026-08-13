// Join the pipeline's per-surface config JSONs into a flat cell matrix.
// rich/surfaces/barrel are keyed by PascalCase module -> parallel arrays.

export const SURFACES = ["top", "record", "build", "barrel"];

/** @returns {Array<{module,index,surface,title,raw,elm,converted}>} */
export function buildMatrix({ rich, surfaces, barrel }) {
  const cells = [];
  for (const module of Object.keys(rich)) {
    const examples = rich[module] || [];
    const surf = (surfaces && surfaces[module]) || [];
    const barr = (barrel && barrel[module]) || [];
    examples.forEach((ex, index) => {
      const surfaceCode = {
        top: ex.top ?? null,
        record: (surf[index] && surf[index].record) ?? null,
        build: (surf[index] && surf[index].build) ?? null,
        barrel: barr[index] ?? null,
      };
      for (const surface of SURFACES) {
        const elm = surfaceCode[surface];
        cells.push({
          module,
          index,
          surface,
          title: ex.title ?? `${module}[${index}]`,
          raw: ex.html ?? null,
          elm,
          converted: typeof elm === "string" && elm.length > 0,
        });
      }
    });
  }
  return cells;
}
