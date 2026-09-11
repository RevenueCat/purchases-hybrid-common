/**
 * A paywall control interaction, as delivered to the paywall listener's `onInteraction`.
 * Keys use the snake_case names documented for the `paywall_component_interacted` event; keys that do
 * not apply are omitted.
 * @public
 */
export interface PaywallInteractionEvent {
  readonly timestamp: number;
  readonly session_id: string;
  readonly offering_id: string;
  readonly paywall_id?: string;
  readonly paywall_revision: number;
  readonly display_mode?: string;
  readonly dark_mode?: boolean;
  readonly locale?: string;
  readonly component_type: string;
  readonly component_value: string;
  readonly component_name?: string;
  readonly component_url?: string;
  readonly origin_index?: number;
  readonly destination_index?: number;
  readonly origin_context_name?: string;
  readonly destination_context_name?: string;
  readonly default_index?: number;
  readonly origin_package_id?: string;
  readonly destination_package_id?: string;
  readonly default_package_id?: string;
  readonly current_package_id?: string;
  readonly resulting_package_id?: string;
  readonly origin_product_id?: string;
  readonly destination_product_id?: string;
  readonly default_product_id?: string;
  readonly current_product_id?: string;
  readonly resulting_product_id?: string;
}

/**
 * Known values of `component_type` in {@link PaywallInteractionEvent}.
 * @public
 */
export const PAYWALL_COMPONENT_TYPES = {
  TAB: "tab",
  SWITCH: "switch",
  CAROUSEL: "carousel",
  BUTTON: "button",
  TEXT: "text",
  PACKAGE: "package",
  PACKAGE_SELECTION_SHEET: "package_selection_sheet",
  PURCHASE_BUTTON: "purchase_button",
} as const;
