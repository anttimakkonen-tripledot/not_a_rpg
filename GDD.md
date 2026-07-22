# Game Design Document: "Not a RPG"
## Version 1.2.0 (Solitaire Columns & Hidden Paths Update)
**Author:** Desi (Expert Casual Mobile Game Designer)  
**Platform:** Mobile (Portrait 9:16)  
**Genre:** Color-Sorting Puzzle / Casual Hero Battler  
**Theme:** Cute Fantasy RPG  

---

## 1. Executive Summary & Concept
"Not a RPG" is a tactical puzzle game where players manage a cute squad of fantasy heroes divided into color-coded **Troop Boxes**. Players must strategically tap these boxes to send heroes marching along predefined, intersecting trails on a grid-based board to defeat matching enemy camps, collect gold coins, and rescue a captured Princess locked in the center of the level.

The puzzle has two core layers of strategy:
1.  **Vertical Solitaire Columns (The Sorting Puzzle):** Troop boxes sit in vertical stacks at the bottom. Only the first (exposed) box of each column is active and tapable. Tapping it exposes the box behind it, creating a deep chronological planning layer reminiscent of Solitaire or Mahjong.
2.  **Topological Path-Blocking & Hidden Trails (The Surprise Element):** Active trails act as physical walls; intersecting paths cannot both be active. To increase surprise and memorization fun, the predefined paths on the board are **completely hidden from the player** during normal play. Players must learn and discover where the trails go as they spawn heroes.

---

## 2. Core Screen Layout & UI/UX Standards

The game screen is optimized for a **390px x 844px portrait viewport** with a floating playfield style (no rigid dividers, clean transitions).

```
+------------------------------------------+
| HUD: Coins/Lives Pills | 80px            |
+------------------------------------------+
|                                          |
|                                          |
|   Gameplay Canvas (10x17 Grid)           |
|   - 39px Square Cells                    |
|   - Floating Playfield (390px x 663px)   |
|   - Princess Cage in the center          |
|   - Enemy Camps on the grid              |
|   - Predefined trails (HIDDEN by default) |
|                                          |
|                                          |
+------------------------------------------+
| Active Slots Bar / Tray | 90px           |
+------------------------------------------+
| Box Columns (Solitaire-Style Queue)      |
| - 2 to 5 columns of vertically stacked   |
|   troop boxes (Height: 154px)            |
+------------------------------------------+
```

### HUD Header (80px)
*   **Visual Style:** Dark blue translucent bar floating at the top.
*   **Left Side:** Standard gold coins and lives pill display.
*   **Right Side:** Settings Gear button and DEV toggle button.

### Gameplay Canvas (390px x 663px)
*   Centered, floating layout. Background is a rich deep blue fantasy horizon.
*   **Princess Cage:** Prominent center graphic, locked with an animated padlock displaying a countdown lock.
*   **Enemy Camps:** Fixed tiles on the board where stacks of enemies reside. Each camp displays the number of active enemies remaining (e.g., Red Troll Archer x3).
*   **Portals / Trails:** Sockets at the bottom of the board where trails start. Trails are **hidden from view**, creating a surprise pathing dynamic as heroes begin marching.

### Active Slots Tray (90px)
*   Sits at the bottom of the board, directly underneath the starting sockets of the trails.
*   Contains **5 empty symmetrical slot pods** (active slots).
*   When a player taps an exposed Troop Box from the Box Columns below, it flies smoothly up into the leftmost available Active Slot.

### Box Columns (The Solitaire-Style Queue)
*   Situated at the very bottom of the screen (height: 154px).
*   Arranged in **2 to 5 vertical columns** of troop boxes.
*   Within each column, boxes are layered from front to back (rendered vertically with overlapping card-style layouts).
*   **Exposed Box Rule:** Only the bottom-most (closest to the active tray, last element of the stack) box in each column is active, colorful, and tapable.
*   **Locked Boxes:** Boxes behind the exposed box are visually dimmed, desaturated (grayscale overlay), and locked with a small padlock emblem. They cannot be tapped.
*   **Exposure sequence:** Tapping the exposed box moves it to the Active Slots, instantly sliding the box behind it down, unlocking it, and making it tapable!

---

## 3. Core Gameplay Loop & Mechanics

### Troop Boxes (The Tapping Mechanic)
1.  **Color-Coding:** Each troop box is single-colored, matching the hero class inside:
    *   🔴 **Red Box:** Warrior ⚔️
    *   🟢 **Green Box:** Archer 🏹
    *   🔵 **Blue Box:** Mage 🧙‍♂️
    *   🟡 **Yellow Box:** Priest/Paladin 🛡️
    *   ⚫ **Black Box:** Ninja 🥷
2.  **Hero Counter:** Every box displays a counter showing exactly how many heroes it contains (e.g., a Red Box with a `3` counter contains 3 Warriors).
3.  **Tapping:** Tapping an exposed troop box sends it flying up into an empty **Active Slot** in the active tray.

### Two-Way Combat & Loot Dragging
Once a Troop Box is settled in an Active Slot:
1.  **Spawning Check:** The game checks if the trail starting from this slot to the corresponding Enemy Camp on the board is **clear and unblocked**.
2.  **Hero Spawning:** If the path is unblocked, a hero of that box's color emerges from the box in the Active Slot.
3.  **March Up:** The hero walks **up** the predefined (hidden) trail to the matching Enemy Camp on the board.
4.  **Battle Pause:** Upon reaching the camp, the hero engages in a **1-second battle animation** with one enemy.
5.  **Loot Spawning:** The enemy is defeated, turning into a **Yellow Gold Coin**.
6.  **March Down:** The hero grabs the coin and walks **down** the trail, dragging it back to the active slot.
7.  **Sinking:** Once the hero enters the active slot with the coin, the coin is deposited, the box counter decrements, and the next hero is spawned (if any remain).
8.  **Clearing:** When the box counter reaches 0, the empty box vanishes from the Active Slot, freeing up that slot for another box from the columns below.

### The Princess Objective & Win State
*   **The Lock Counter:** The cage padlock displays a count equal to the **total number of living enemies** remaining on the level.
*   **Rescue:** Once the counter hits **0**, the cage bars slide open, the Princess is freed, and the level is successfully completed.

---

## 4. Puzzle Pathing & Blocking Logic (The Fail State)

To keep the game highly strategic, "Not a RPG" uses **Topological Path Blocking** rather than timing-based physics:

1.  **Active Paths:** A trail is active if its corresponding Active Slot holds a troop box.
2.  **Intersection Rule:** If Trail A and Trail B intersect on the grid, they are **mutual blockers**. 
3.  **Blocking Behavior:**
    *   If a box of color X is placed in an Active Slot, and its path intersects with an *already active* trail, the path is blocked.
    *   Heroes **will not emerge** from the blocked box. It sits in the Active Slot idle, displaying a red "BLOCKED" indicator.
4.  **The Stalemate Fail State:**
    *   If all **5 Active Slots** are filled with boxes, and some of those boxes are blocked by other active trails (or circular pathing dependencies exist), the game reaches a stalemate where no heroes can walk.
    *   Since the slots are full, the player cannot tap any more boxes from the columns below.
    *   A **"No Path to Enemies" Fail Screen** is triggered (blue card backdrop, split 3D heart, red "1x Claim" or green "Continue" CTA).

---

## 5. Level Design and Editor Principles

The puzzle's difficulty and strategy are entirely determined by the level layout. The level designer has precise control over the following parameters:

*   **Balance Rule:** Each level has **exactly the same amount of heroes and enemies of the same color**.
*   **Troop Division & Column Layering:** The level designer chooses how many Troop Boxes are created, their colors, their counts, and how they are stacked vertically inside **2 to 5 columns** at the bottom.
    *   *Strategic Layering:* Stacking boxes vertically allows the designer to create complex dependencies. For example, placing a Green Box underneath/behind a Red Box forces the player to tap and clear the Red Box before they can even access the Green Box!
*   **Supply Columns Configuration:** The level designer can choose how many **columns** (2 to 5) are displayed.

---

## 6. Developer & QA Cheat Overlay

A toggleable dev panel facilitates testing:
*   **Trigger:** Floating small "DEV" pill in the top-right corner.
*   **Toggle Features:**
    *   **Show Hitboxes:** Renders visual bounds around elements.
    *   **Show Surprising Path Overlays:** **Draws the hidden trails as glowing neon paths** on the board so level designers and QA can see where paths cross and verify layouts instantly.
    *   **Set Player Level Cheat:** Completion cheats for levels below the set number.
    *   **Resource Depletion:** Force fail state testing by depleting moves/lives to zero.
    *   **Instant Victory/Fail Cheats:** Skip straight to win/loss screens to verify CTAs.
