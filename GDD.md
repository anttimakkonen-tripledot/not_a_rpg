# Game Design Document: "Not a RPG"
## Version 1.4.0 (Dynamic BFS Peeling Grid & Interactive Level Layouts Update)
**Author:** Desi (Expert Casual Mobile Game Designer)  
**Platform:** Mobile (Portrait 9:16)  
**Genre:** Color-Sorting Puzzle / Casual Hero Battler  
**Theme:** Cute Fantasy RPG  

---

## 1. Executive Summary & Concept
"Not a RPG" is a tactical puzzle game where players manage a cute squad of fantasy heroes divided into color-coded **Troop Boxes**. Players must strategically tap these boxes to send heroes marching along predefined, intersecting trails on a grid-based board to defeat matching enemy pixels (where each enemy occupies exactly one grid cell), collect gold coins, and rescue a captured Princess locked in the center of the level.

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
*   **Enemy Pixels:** Fixed tiles on the board where individual enemies reside (one enemy per grid cell). Cleared cells display a soft magical sparkle effect (✨) or ruins, and remaining active enemies pulse gently with their respective base color glows.
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
2.  **Continuous Spawning & Target Reservation:** If the path is unblocked and there are heroes left in the box to spawn, the box releases a new hero onto the level every **0.5 seconds** (500ms). When a hero is spawned, it dynamically locks onto its target enemy camp, reserving/blocking that cell from other heroes. Only one hero can target/attack a specific enemy cell at any given time. If other heroes of that color want to spawn, they must find a path to a different (untargeted) matching enemy camp, or wait until the current target is defeated and the fighting hero begins returning. Multiple heroes can march, fight, and return simultaneously on different targets.
3.  **March Up:** Each hero walks **up** the predefined (hidden) trail cell-by-cell.
4.  **Step-by-Step Enemy Search ("Pac-Man" Clearing):** At each cell along the path, the marching hero checks if there is a living enemy of their matching color on that specific grid cell.
5.  **Battle Pause:** Upon stepping onto a cell with a matching enemy, the hero stops marching, engages in a **1-second battle animation** to defeat it, turning the enemy into a **Yellow Gold Coin**.
6.  **March Down:** The hero grabs the coin and immediately walks **down** (backwards along the path from their current position) to the active slot.
7.  **Sinking:** Once a hero enters the active slot with the coin, the coin is deposited, the box counter decrements, and the active hero count decreases.
8.  **Sequence Clearing:** Subsequent heroes will march up, pass through already-cleared cells (now showing ✨), and walk further up the path until they encounter the next active enemy.
8.  **Clearing:** When the box counter reaches 0 (all heroes have returned and deposited their coins), the empty box vanishes from the Active Slot, freeing up that slot for another box from the columns below.

### The Princess Objective & Win State
*   **The Lock Counter:** The cage padlock displays a count equal to the **total number of living enemies** remaining on the level.
*   **Rescue:** Once the counter hits **0**, the cage bars slide open, the Princess is freed, and the level is successfully completed.

---

## 4. Puzzle Pathing & Blocking Logic (The Fail State)

To keep the game highly strategic, "Not a RPG" uses **Dynamic BFS Pathfinding & Peeling Obstacles**:

1.  **Enemies as Obstacles:** Living enemies of any color act as solid obstacles (walls). They block lines-of-sight and physical pathways.
2.  **Dynamic BFS Shortest Path:** Whenever a troop box of color X is placed in slot `i`, the game dynamically calculates the shortest path from portal `i` (at coordinates `(1 + i * 2, 15)`) to any reachable living enemy of color X.
3.  **The Peeling Puzzle Rule:** Heroes can only attack "exposed" enemies. An enemy is exposed if there is a clear, contiguous pathway of empty grid cells leading from the portal to that enemy. 
    *   *Surrounded Core:* If a green enemy core is completely surrounded by red enemies, the green path is **BLOCKED**. Players must first spawn red heroes to clear the outer red shell. As outer cells are cleared and become empty spaces (✨), pathways are created, exposing and unlocking the inner green core!
4.  **The Stalemate Fail State:**
    *   If all **5 Active Slots** are filled with boxes, and all 5 colors have no reachable active path to any of their matching living enemies (e.g. they are completely trapped behind other colors), the game reaches a stalemate.
    *   Since the active slots are full and no heroes are active, the player cannot tap any more boxes from the supply columns below.
    *   A **"No Path to Enemies" Fail Screen** is triggered (blue card backdrop, split 3D heart, red "1x Claim" or green "Continue" CTA).

---

## 5. Level Design and Editor Principles

The puzzle's difficulty and strategy are entirely determined by the level layout. The level designer has precise control over the following parameters:

*   **Balance Rule:** Each level has **exactly the same amount of heroes and enemies of the same color**.
*   **Troop Division & Column Layering:** The level designer chooses how many Troop Boxes are created, their colors, their counts, and how they are stacked vertically inside **2 to 5 columns** at the bottom.
    *   *Strategic Layering:* Stacking boxes vertically allows the designer to create complex dependencies. For example, placing a Green Box underneath/behind a Red Box forces the player to tap and clear the Red Box before they can even access the Green Box!
*   **Supply Columns Configuration:** The level designer can choose how many **columns** (2 to 5) are displayed.

### 5.1 Handcrafted Levels Database

Below is the list of levels built into the game's prototype database, designed to showcase different aspects of color-sorting, stack-clearing, and path-blocking strategies:

### 5.1 Handcrafted Levels Database

Below is the list of levels built into the game's prototype database, designed to showcase different aspects of color-sorting, peeling puzzles, and dynamic path-blocking strategies:

#### Level 1: Smiley Face Siege (The Epic Sorting Battle)
*   **Concept:** A massive level where enemies are visually arranged into a classic smiley face layout (Eyes + Smile) using Red and Green monster groups, represented as single pixel units.
*   **Enemies & Pixels (18 Total):**
    *   **Left Eye (`red_1`):** A 2x2 square cluster of 4 Red Troll Archers at coordinates: `(2,2)`, `(3,2)`, `(2,3)`, `(3,3)`.
    *   **Right Eye (`red_2`):** A 2x2 square cluster of 4 Red Troll Archers at coordinates: `(6,2)`, `(7,2)`, `(6,3)`, `(7,3)`.
    *   **The Smile (`green_1` to `green_6`):** Six green pixels of 1 Green Troll each forming a symmetrical curve spanning `y: 7` to `y: 9` (from `x: 2` to `x: 7`).
*   **The Hero Deck (18 Total):**
    *   Stacked inside **2 Columns** of **4 Boxes each**:
        *   **Column 1:** `green_1` (1), `green_2` (1), `green_3` (1), locked behind `red_1` (4).
        *   **Column 2:** `green_4` (1), `green_5` (1), `green_6` (1), locked behind `red_2` (4).

#### Level 2: Crossings Core (The Peeling Heart Shape)
*   **Concept:** A gorgeous Red Heart with a hidden Green Core. The Green core is completely surrounded by Red pixel-art, making Green pathfinding initially BLOCKED. Players must peel the outer Red Heart to expose the inner Green core!
*   **Enemies & Pixels (32 Total):**
    *   **Outer Red Heart (16 Red Pixels):** Arranged in a beautiful outline centered around columns 4 and 5, spanning row 3 to 8.
    *   **Inner Green Core (16 Green Pixels):** Arranged as the solid inner heart core.
*   **The Hero Deck (32 Total):**
    *   **Column 1:** 16 Green Archers locked behind 16 Red Warriors. Players must deploy the warriors to strip away the outer shield before the archers can reach the exposed heart core!

#### Level 3: Triple Danger (The Majestic Royal Shield)
*   **Concept:** A magnificent multi-layered shield composed of an outer Red Steel border, an inner Yellow Gold frame, and a central Blue Gem. 
*   **Enemies & Pixels (36 Total):**
    *   **Outer Red Border (20 Red Pixels):** Forming the grand outer contour of the shield.
    *   **Gold Frame (12 Yellow Pixels):** Symmetrical golden frame lining the interior of the red border.
    *   **Blue Gem (4 Blue Pixels):** Centered blue gem at the heart of the shield `(4,5)`, `(5,5)`, `(4,6)`, `(5,6)`.
*   **The Hero Deck (36 Total):**
    *   **Column 1:** Blue Box (4) stacked under Yellow Box (12) stacked under Red Box (20). A clean, sequential 3-tiered peeling challenge!

#### Level 4: Shadow Matrix (The Balance of Yin-Yang)
*   **Concept:** A beautiful circular Yin-Yang symbol divided into a Yellow light side and a Black dark side.
*   **Enemies & Pixels (30 Total):**
    *   **Yellow Light Side (15 Yellow Pixels):** Symmetrical right-aligned split circle.
    *   **Black Dark Side (15 Black Pixels):** Symmetrical left-aligned split circle.
*   **The Hero Deck (30 Total):**
    *   **Column 1:** Yellow (15) locked behind Black (15).
    *   **Column 2:** Black (15) locked behind Yellow (15).
    *   Creates a circular dependency where players must strategically clear sections of both sides to avoid hitting a stalemate.

#### Level 5: Ultimate Raid (The Royal Crown)
*   **Concept:** A grand final level drawing a majestic pixel-art Crown using Red velvet, Yellow gold, Blue sapphires, and a Black velvet base.
*   **Enemies & Pixels (32 Total):**
    *   **Velvet (12 Red Pixels):** Core interior velvet.
    *   **Gold Frame (11 Yellow Pixels):** Elegant spiked contour.
    *   **Sapphire Gems (3 Blue Pixels):** Spire gems.
    *   **Shadow Base (6 Black Pixels):** The base cushion.
*   **The Hero Deck (32 Total):**
    *   **Column 1:** Blue (3) locked behind Red (12).
    *   **Column 2:** Black (6) locked behind Yellow (11).

## 6. Developer & QA Cheat Overlay

A toggleable dev panel facilitates testing:
*   **Trigger:** Floating small "DEV" pill in the top-right corner.
*   **Toggle Features:**
    *   **Show Hitboxes:** Renders visual bounds around elements.
    *   **Show Surprising Path Overlays:** **Draws the hidden trails as glowing neon paths** on the board so level designers and QA can see where paths cross and verify layouts instantly.
    *   **Set Player Level Cheat:** Completion cheats for levels below the set number.
    *   **Resource Depletion:** Force fail state testing by depleting moves/lives to zero.
    *   **Instant Victory/Fail Cheats:** Skip straight to win/loss screens to verify CTAs.
