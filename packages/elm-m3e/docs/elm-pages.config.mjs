import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";
import adapter from "elm-pages/adapter/netlify.js";

export default {
  vite: defineConfig({
    plugins: [
      // Tailwind v4 + the m3e token/utility bridge, run by Vite so the
      // stylesheet is bundled + content-hashed (imported from index.ts).
      tailwindcss(),
    ],
    server: {
      // Allow any Host header — safe on a trusted tailnet (tailscale-serve access).
      allowedHosts: true,
    },
  }),
  adapter,
  headTagsTemplate(context) {
    // The stylesheet (style.css) and @m3e/web custom-element registration are
    // imported from `index.ts` and bundled through Vite — hashed assets, with
    // the <link>/<script> injected automatically. No hand-linked static files.
    // Material Symbols Outlined is self-hosted via the @font-face in style.css.
    //
    // T1 — prod theme flash: synchronous inline <head> script reads
    // localStorage["m3e-theme-state"] before Elm/index.ts execute and
    // pre-applies the saved scheme/contrast/color to <m3e-theme> + cssOverrides
    // to <html>. Shape mirrors Theme.Ports.encoder/decoder exactly — do NOT
    // diverge.
    //
    // The <m3e-theme> element is server-rendered as a child of <body>, i.e. it
    // is parsed AFTER this <head> script runs — so a plain querySelector here
    // returns null and cannot pre-apply scheme/contrast/color. We therefore
    // install a MutationObserver on <html> that fires the instant the element
    // is inserted during parsing (a microtask, before first paint) and stamps
    // the attributes onto it, then disconnects. This lands the saved scheme
    // before Lit upgrades the element and before paint, so there is no flash of
    // the default (light/#6750A4) theme. cssOverrides target <html>, which
    // always exists, so they apply synchronously.
    const themeHeadScript = /* js */ `(function(){try{
  var raw=localStorage.getItem("m3e-theme-state");
  if(!raw)return;
  var s=JSON.parse(raw);
  if(typeof s!=="object"||s===null)return;
  function apply(th){
    if(typeof s.scheme==="string")th.setAttribute("scheme",s.scheme);
    if(typeof s.contrast==="string")th.setAttribute("contrast",s.contrast);
    if(typeof s.seed==="string")th.setAttribute("color",s.seed);
  }
  var existing=document.querySelector("m3e-theme");
  if(existing){
    apply(existing);
  } else {
    var obs=new MutationObserver(function(){
      var th=document.querySelector("m3e-theme");
      if(th){obs.disconnect();apply(th);}
    });
    obs.observe(document.documentElement,{childList:true,subtree:true});
    // Safety net: stop observing once the document is fully parsed.
    document.addEventListener("DOMContentLoaded",function(){
      var th=document.querySelector("m3e-theme");
      if(th)apply(th);
      obs.disconnect();
    });
  }
  if(s.cssOverrides&&typeof s.cssOverrides==="object"){
    var ov=Array.isArray(s.cssOverrides)?s.cssOverrides:Object.entries(s.cssOverrides);
    for(var i=0;i<ov.length;i++){
      var k=ov[i][0],v=ov[i][1];
      if(typeof k==="string"&&typeof v==="string"&&v!=="")
        document.documentElement.style.setProperty("--"+k,v);
    }
  }
}catch(e){}})();`;
    return `
<meta name="generator" content="elm-pages v${context.cliVersion}" />
<script>${themeHeadScript}</script>
`;
  },
  preloadTagForFile(file) {
    // add preload directives for JS assets and font assets, etc., skip for CSS files
    // this function will be called with each file that is processed by Vite, including any files in your headTagsTemplate in your config
    return !file.endsWith(".css");
  },
};
