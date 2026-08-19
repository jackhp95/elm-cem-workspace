import { ActionElementBase } from "@m3e/web/core";
/** A base implementation for a button used to move to a step in a stepper. This class must be inherited. */
export declare abstract class StepperButtonElementBase extends ActionElementBase {
    #private;
    constructor(action: "next" | "previous" | "reset");
    /** @inheritdoc */
    _onClick(): void;
}
//# sourceMappingURL=StepperButtonElementBase.d.ts.map