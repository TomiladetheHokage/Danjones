# Assets Flow Implementation Plan

## Goal
Implement the **Assets** tab in the bottom navigation so it shows:
1. An **Assets list page** (coin list + search + distribution) — matches the left screenshot.
2. An **Asset Details page** (history view) — matches the middle screenshot.
3. An **Asset Info page/tab** — matches the right screenshot.

This document describes the current state, the gaps, and a proposed implementation plan.

---

## Current Project State (Key Files)

### Navigation
- `lib/screens/main_shell.dart` contains the bottom navigation and currently uses placeholders for:
  - **Trade** (center button)
  - **Assets** (tab index 3)
  - **Menu** (tab index 4)

### Existing Asset-related Screens
- `lib/screens/market_screen.dart` is a market view showing “Top Movers”, “New”, and “Top Assets”.
  - Uses `TokenListItem` and navigates to `MarketAssetScreen` on tap.
- `lib/screens/market_asset_screen.dart` is a detailed view for a specific asset.
  - Contains a header with back button.
  - Includes a chart, price/value rows, trade CTA, and an “Info” section (static, inside the same scroll view).

### Shared UI Components
- `lib/widgets/token_list_item.dart` provides the list item used on Market screen.
- `lib/models/crypto_asset.dart` provides the `CryptoAsset` model and mock data (`MockCrypto`).

---

## What the Screens Should Contain (Based on screenshots)

### 1) Assets list page (footer "Assets" tab)
From screenshot (left panel):
- Header: `Assets` title + possibly a top-right settings or search icon?
- Total Equity card (NGN balance + % change), with eye toggle to hide balance (already in Home screen).
- Asset Distribution bar (e.g., NGN 55%, BTC 20%, ETH 10%, Others 15%).
- Search field: `Search Token` (similar to TopMovers screen).
- List of coins: each row includes
  - Coin icon (e.g., BTC, ETH)
  - Symbol + name
  - Sparkline chart
  - Price + USD value + % change (green/red)
- Clicking a coin routes to Asset Details page.

### 2) Asset Details page (history view)
From screenshot (middle panel):
- Back arrow + asset symbol (e.g., BTC) in app bar.
- Big balance (0.1298 BTC) with USD conversion + % change badge.
- Action buttons (Deposit, Buy, Swap) in a row.
- Segment control / tabs: `History` and `Info`.
- Under `History`: list of transactions (Receive / Send) with time, amount, status, and value.
- Footer CTA: "Go to market" button.

### 3) Asset Info page (info tab or separate route)
From screenshot (right panel):
- Same header + balance row as details page.
- Same action buttons row (Deposit, Buy, Swap).
- Tab selected: `Info`.
- Info section includes:
  - Market Cap
  - Circulating Supply
  - Max Supply
  - Total Supply
  - All Time High / Low
  - "View More" action
  - About section (text description)
- Footer CTA: "Go to market" button.

---

## Implementation Plan (High Level)

### A) Add dedicated Assets flow
1. **Create new screen:** `lib/screens/assets_screen.dart`
   - A full-screen version of the left screenshot (Assets list).
   - Use existing `TokenListItem` (or adapt) for list rows.
   - Use `MockCrypto.tokens` or `MockCrypto.marketList` as the data source for the list.
   - Add search bar + distribution visualization.

2. **Create new screen:** `lib/screens/asset_details_screen.dart`
   - Similar to `MarketAssetScreen` but restructured to match the “History / Info” tabbed layout.
   - Use `DefaultTabController` with two tabs (`History`, `Info`).
   - `History` tab: scrollable list of fake transactions (static/mock data). 
   - `Info` tab: show info rows + “About” section.

3. **Update navigation in `MainShell`:**
   - Replace placeholder for tab index 3 (Assets) with `AssetsScreen()`.
   - Keep existing `MarketScreen` usage for tab index 1.

4. **Wire tap to navigation:**
   - In `AssetsScreen`, tapping an asset should `Navigator.push` to `AssetDetailsScreen(asset: selected)`.
   - Ensure `AssetDetailsScreen` includes a back button that pops.

5. **Sync UI patterns / theme**
   - Use the existing `AppTheme` helpers and dark background styling.
   - Reuse `SparklineChart` and `TokenListItem` where possible.
   - Consistent spacing and typography (see `AppTheme.inter` and `AppTheme.heading2`).

---

## Notes / Gotchas (what needs a designer decision)
- The screenshot’s “Assets” page shows a segmented distribution bar (NGN/BTC/ETH/others); current app has no such component. We can implement a simple `Row` of colored bars + legend.
- The “Assets” page’s bottom navigation highlights “Assets” icon; keep this consistent with `MainShell` logic.
- The `Asset Details` screen in the screenshot includes three action buttons (Deposit / Buy / Swap). Current `MarketAssetScreen` only has a “Trade” button. We will add those buttons.
- The `History` view needs mock transaction data; decide if it should be static or derived from the asset price.
- The “Go to market” button shown in screenshot likely routes to `MarketScreen` or opens a full market view.

---

## Next Step (What I’ll do next)
1. Create `lib/screens/assets_screen.dart` and `lib/screens/asset_details_screen.dart`.
2. Update `lib/screens/main_shell.dart` to wire the bottom nav “Assets” tab to `AssetsScreen`.
3. Ensure tapping a coin in `AssetsScreen` navigates to `AssetDetailsScreen`.

---

## Questions / Clarifications Needed
- Should the `Info` view be a separate route (push) or a tab inside the details flow?
- Do the action buttons (Deposit/Buy/Swap) need real logic, or only visual layout for now?
- Is there an expected data source (API) for real coin balances / transactions, or should we keep using `MockCrypto`?
