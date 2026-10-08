> [!WARNING]
> This release fixes a bug where the iOS SDK collected device identifiers (`$idfa`, `$idfv`, `$ip`, `$deviceVersion`) when setting an attribution ID, even with `automaticDeviceIdentifierCollectionEnabled` set to `false`. Identifiers already collected are not cleared automatically; the app must clear them.

## RevenueCat SDK
### 🐞 Bugfixes
* Fix iOS ignoring `automaticDeviceIdentifierCollectionEnabled` in `configure` (#1956) via Álvaro Brey (@AlvaroBrey)
