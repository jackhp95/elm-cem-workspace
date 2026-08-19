# Angular

M3E does not require a dedicated Angular bindings package. Angular provides first-class support for Web Components, allowing all M3E components to be used directly in Angular templates without additional wrappers.

However, Angular requires the `CUSTOM_ELEMENTS_SCHEMA` to recognize custom elements. Add it to your module definition:

```ts
import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from "@angular/core";

@NgModule({
  declarations: [...],
  imports: [...],
  schemas: [CUSTOM_ELEMENTS_SCHEMA],
})
export class AppModule {}
```

---
_Source: [`docs/frameworks/angular.html`](https://github.com/matraic/m3e/blob/v2.7.3/docs/frameworks/angular.html) · `matraic/m3e` @ `v2.7.3`._
