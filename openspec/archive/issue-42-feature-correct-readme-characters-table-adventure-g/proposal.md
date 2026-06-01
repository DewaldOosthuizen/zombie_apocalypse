## Overview

README.md contains two contradictory statements about Adventure Girl: the controls section (lines 46-49) carries a "Work in progress — no playable scene exists yet" warning block, while the Characters table (line 66) lists her status as "Playable". In reality adventure_girl.gd does exist and the character is launchable, but she borrows the Ninja's bullet scene and lacks a dedicated bullet scene, jump-shoot, and jump-melee animations. The fix adopts Option B from the issue: update the Characters table status to "Playable (partial)", remove or rephrase the misleading warning block so it accurately describes what is still missing, and add a `## Known Gaps / Roadmap` section that explicitly documents the remaining work items and links them to open GitHub Issues.

## Issues

### Issue 1

**File:** `README.md`
**Problem:** Line 66 lists Adventure Girl status as "Playable" in the Characters table, while lines 46-49 state "no playable scene exists yet". The two statements are mutually contradictory and both inaccurate: the scene exists but is incomplete (no dedicated bullet scene, no jump-shoot/jump-melee animations).
**Fix:** Change the Characters table status cell for Adventure Girl from `Playable` to `Playable (partial)` to signal capability without overstating completeness.

### Issue 2

**File:** `README.md`
**Problem:** The Adventure Girl controls warning block (lines 46-49) says "no playable scene exists yet", which is factually wrong — `adventure_girl.gd` is present and launchable. The inaccurate prose misleads contributors about the character's actual state.
**Fix:** Replace the warning block with a concise note that accurately describes the current gaps: the character is playable but borrows the Ninja bullet scene and is missing a dedicated bullet scene and jump-shoot/jump-melee animation variants.

### Issue 3

**File:** `README.md` (new section)
**Problem:** There is no consolidated place in the README documenting future work, so contributors have no roadmap visibility without reading individual GitHub Issues.
**Fix:** Add a `## Known Gaps / Roadmap` section after the Characters table listing the three remaining Adventure Girl items (dedicated bullet scene, jump-shoot animation, jump-melee animation) with references to the corresponding open GitHub Issues where applicable.
