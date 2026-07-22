# Game Design Document: "Not a RPG"
## Version 1.1.0 (Refined Mechanics & Level Design Rules)
**Author:** Desi (Expert Casual Mobile Game Designer)  
**Platform:** Mobile (Portrait 9:16)  
**Genre:** Color-Sorting Puzzle / Casual Hero Battler  
**Theme:** Cute Fantasy RPG  

---

## 1. Executive Summary & Concept
"Not a RPG" is a tactical puzzle game where players manage a cute squad of fantasy heroes divided into color-coded **Troop Boxes**. Players must strategically tap these boxes to send heroes marching along predefined, intersecting trails on a grid-based board to defeat matching enemy camps, collect gold coins, and rescue a captured Princess locked in the center of the level.

The puzzle core is a **topological path-blocking challenge**. Active trails act as walls, meaning intersecting paths cannot both be active. Tapping a troop box places it in an active slot; from there, heroes emerge *if and only if* they have a clear path to their corresponding enemy camp. If a player fills all active slots with blocked troop boxes, they run out of moves, triggering a fail state.

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
|   - Predefined intersecting trails       |
|                                          |
|                                          |
+------------------------------------------+
| Active Slots Bar / Tray | 100px          |
+------------------------------------------+
| Box Lanes (Troop Supply Queue)           |
| - Custom row count per level design      |
+------------------------------------------+
```

### HUD Header (80px)
*   **Visual Style:** Dark blue translucent bar floating at the top.
*   **Left Side:** Standard gold coins and lives pill display.
*   **Right Side:** Settings Gear button. Tapping opens a full-screen settings overlay.

### Gameplay Canvas (390px x 663px)
*   Centered, floating layout.
*   Background is a rich deep blue fantasy horizon.
*   **Princess Cage:** Prominent center graphic, locked with an animated padlock displaying a countdown lock.
*   **Enemy Camps:** Fixed tiles on the board where stacks of enemies reside. Each camp displays the number of active enemies remaining (e.g., Red Troll Archer x3).
*   **Portals / Trails:** Sockets at the bottom of the board where trails start. Each socket directly aligns with an Active Slot underneath. Trails are represented by faintly pulsing colored dash lines that connect the sockets to their matching color Enemy Camps.

### Active Slots Tray (100px)
*   Sits at the bottom of the board, directly underneath the starting sockets of the trails.
*   Contains **5 empty symmetrical slot pods** (active slots).
*   When a player taps a Troop Box from the Box Lanes below, it flies smoothly up into the leftmost available Active Slot.

### Box Lanes (Troop Supply Queue)
*   Situated at the very bottom of the screen.
*   Displays the sequence of **Troop Boxes** available for the level.
*   The level designer can choose the number of lanes (rows) of boxes, their exact colors, and their layout sequence.

---

## 3. Core Gameplay Loop & Mechanics

### Troop Boxes (The Tapping Mechanic)
1.  **Supply:** At the bottom of the screen, players have a pool of **Troop Boxes** arranged in lanes.
2.  **Color-Coding:** Each troop box is single-colored, matching the hero class inside:
    *   🔴 **Red Box:** Warrior ⚔️
    *   🟢 **Green Box:** Archer 🏹
    *   🔵 **Blue Box:** Mage 🧙‍♂️
    *   🟡 **Yellow Box:** Priest/Paladin 🛡️
    *   ⚫ **Black Box:** Ninja 🥷
3.  **Hero Counter:** Every box displays a counter showing exactly how many heroes it contains (e.g., a Red Box with a `3` counter contains 3 Warriors).
4.  **Tapping & Flying:** Tapping a troop box sends it flying up from the supply lanes into an empty **Active Slot** in the active tray.

### Two-Way Combat & Loot Dragging
Once a Troop Box is settled in an Active Slot:
1.  **Spawning Check:** The game checks if the trail starting from this slot to the corresponding Enemy Camp on the board is **clear and unblocked**.
2.  **Hero Spawning:** If the path is unblocked, a hero of that box's color emerges from the box in the Active Slot.
3.  **March Up:** The hero walks **up** the predefined trail to the matching Enemy Camp on the board.
4.  **Battle Pause:** Upon reaching the camp, the hero engages in a **1-second battle animation** (clashing swords, sparkles, sound effects) with one enemy.
5.  **Loot Spawning:** The enemy is defeated, turning into a **Yellow Gold Coin**.
6.  **March Down:** The hero grabs the coin and walks **down** the trail, dragging it back to the active slot.
7.  **Sinking:** Once the hero enters the box in the active slot with the coin, the coin is deposited, the box counter decrements by 1, and the next hero in that box is spawned (if any remain).
8.  **Clearing:** When the box counter reaches 0, the empty box vanishes from the Active Slot, freeing up that slot for another box from the lanes below.

### The Princess Objective & Win State
*   **The Princess Cage:** Located in the middle of the board.
*   **The Lock Counter:** The padlock displays a count equal to the **total number of living enemies** remaining on the level.
*   **Countdown:** As enemies are defeated and turned into coins, this lock counter counts down.
*   **Rescue:** Once the counter hits **0**, the cage bars slide open, the Princess is freed and cheers, and the level is successfully completed.

---

## 4. Puzzle Pathing & Blocking Logic (The Fail State)

To keep the game highly strategic, "Not a RPG" uses **Topological Path Blocking** rather than timing-based physics:

1.  **Active Paths:** A trail is active if its corresponding Active Slot holds a troop box.
2.  **Intersection Rule:** If Trail A and Trail B intersect on the grid, they are **mutual blockers**. 
3.  **Blocking Behavior:**
    *   If a box of color X is placed in an Active Slot, and its path intersects with an *already active* trail, the path is blocked.
    *   Heroes **will not emerge** from the blocked box. It sits in the Active Slot idle, displaying a warning indicator.
4.  **The Stalemate Fail State:**
    *   If all **5 Active Slots** are filled with boxes, and some of those boxes are blocked by other active trails (or circular pathing dependencies exist), the game reaches a stalemate where no heroes can walk.
    *   Since the slots are full, the player cannot tap any more boxes from the lanes below.
    *   A **"No Path to Enemies" Fail Screen** is triggered (blue card backdrop, split 3D heart, red "1x Claim" or green "Continue" CTA).

---

## 5. Level Design and Editor Principles

The puzzle's difficulty and strategy are entirely determined by the level layout. The level designer has precise control over the following parameters:

*   **Balance Rule:** Each level has **exactly the same amount of heroes and enemies of the same color**. (e.g., if a level has 6 Red Trolls, there must be exactly 6 Red Warriors across all Red Troop Boxes).
*   **Troop Division:** The level designer chooses how many Troop Boxes are created and how the heroes are distributed.
    *   *Example:* 6 Red Heroes can be divided into three boxes of 2, two boxes of 3, or one box of 6.
*   **Supply Lanes Configuration:** The level designer can choose how many **lanes of boxes** (rows) are displayed in the bottom supply queue.
*   **Supply Order:** The level designer defines the exact horizontal and vertical order of hero boxes in the lanes. This forces players to think about the sequence in which boxes must be tapped and cleared to avoid blocking active slots.

---

## 6. Developer & QA Cheat Overlay

A toggleable dev panel facilitates testing:
*   **Trigger:** Floating small "DEV" pill in the top-right corner.
*   **Toggle Features:**
    *   **Show Hitboxes:** Renders visual bounds around elements.
    *   **Set Player Level Cheat:** Completion cheats for levels below the set number.
    *   **Resource Depletion:** Force fail state testing by depleting moves/lives to zero.
    *   **Autoplay Bot:** A simple rule-based AI solver to test level playability.
