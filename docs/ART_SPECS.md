# Art & Asset Generation Specs: "Not a RPG"
## Version 1.0.0
**Visual Style Guide:** Cute 2D chibi fantasy vector art, vibrant gradients, thick clean outlines, isometric perspective, high readability on small portrait mobile screens.

---

## 1. Cohesive AI Art Generation Prompts (DALL-E 3 / Midjourney)

To ensure a completely unified art direction, use these highly structured prompts to generate character sprites and UI elements.

### 🛡️ Heroes (Cute Chibi Style)
> **Base Style Modifier:** `Cute 2D chibi fantasy character sprite, vibrant colors, game asset, isometric view, white background, flat vector art style, thick clean outlines, mobile game icon --no shadow`

*   **Red Warrior:**
    `Cute 2D chibi warrior knight sprite, wearing red armor, holding a small silver sword, determined expression, vibrant colors, flat vector art style, thick clean outlines, white background --no shadow`
*   **Green Archer:**
    `Cute 2D chibi elf archer sprite, green cloak, holding a wooden bow, aiming, cheerful expression, flat vector art style, thick clean outlines, white background --no shadow`
*   **Blue Mage:**
    `Cute 2D chibi wizard mage sprite, blue wizard hat and robes, holding a small glowing wizard staff, magical aura, flat vector art style, thick clean outlines, white background --no shadow`
*   **Yellow Priest:**
    `Cute 2D chibi paladin priest sprite, yellow and gold plate armor, holding a holy shield with a sun emblem, brave expression, flat vector art style, thick clean outlines, white background --no shadow`
*   **Black Ninja:**
    `Cute 2D chibi ninja assassin sprite, black outfit, glowing purple eyes, holding a sharp shuriken or kunai, stealth pose, flat vector art style, thick clean outlines, white background --no shadow`

### 🧌 Enemies (Derpy Cartoon Monsters)
> **Base Style Modifier:** `Cute derpy cartoon monster sprite, chibi style, comic expression, 2D game asset, isometric view, white background, flat vector, clean lines, vibrant colors --no shadow`

*   **Red Troll Archer:**
    `Cute derpy troll sprite, red skin, holding a tiny primitive wooden bow, silly expression, 2D chibi game asset, flat vector art, white background --no shadow`
*   **Green Troll:**
    `Cute chunky troll sprite, green skin, holding a small wooden club, smiling cartoon monster, 2D chibi game asset, flat vector art, white background --no shadow`
*   **Blue Troll Healer:**
    `Cute silly witch doctor troll sprite, blue skin, holding a small glass bottle with a bubbling potion, 2D chibi game asset, flat vector art, white background --no shadow`
*   **Yellow Demon:**
    `Cute derpy red-yellow demon sprite, small horns, tiny wings, holding a tiny pitchfork, silly cartoon monster, 2D chibi game asset, flat vector art, white background --no shadow`
*   **Black Troll Ninja:**
    `Cute derpy troll sprite, black bandana, holding a tiny wooden practice sword, comic expression, 2D chibi game asset, flat vector art, white background --no shadow`

### 👑 Princess & Key Environmental Assets
*   **Princess:**
    `Cute 2D chibi princess sprite, long blonde hair, royal crown, pink dress, waving happily, flat vector art style, thick clean outlines, white background --no shadow`
*   **Princess Cage:**
    `Cute fantasy prison cage made of thick gray metal bars, a giant metallic padlock in the center, 2D game asset, isometric view, vibrant colors, flat vector art style, white background --no shadow`
*   **Gold Coin:**
    `Vibrant yellow shiny cartoon gold coin, thick gold rim, comic book style, 2D game asset, flat vector, white background --no shadow`
*   **Base Portals:**
    `Cute glowing portal vortex, vibrant neon swirls, circular energy gate, 2D game asset, top-down isometric view, white background --no shadow`

---

## 2. Sprite Sheet & Animation Layouts (For Prototyping)

For our interactive HTML5 prototype, we will use lightweight, high-performance CSS sprite sheet animation matrices. Each character action has a dedicated grid:

```
+------------+------------+------------+------------+
|  Frame 0   |  Frame 1   |  Frame 2   |  Frame 3   |  <- Row 1: Idle
+------------+------------+------------+------------+
|  Frame 4   |  Frame 5   |  Frame 6   |  Frame 7   |  <- Row 2: Run / March
+------------+------------+------------+------------+
|  Frame 8   |  Frame 9   |  Frame 10  |  Frame 11  |  <- Row 3: Action / Battle
+------------+------------+------------+------------+
```

### Animation States:
1.  **Idle (4 Frames):** Gentle bobbing or breathing effect. Played when heroes are waiting to spawn or enemies are waiting in camps.
2.  **Run / March (4 Frames):** Energetic running loop. Played when heroes are walking up or down the trails.
3.  **Battle / Action (4 Frames):** Weapon swing, spell casting, or combat clashing. Played during the 1-second battle pause at the enemy camp.

---

## 3. UI Colors & Palette Token Spec

To ensure perfect UI contrast and matches our **Zero-Text** UI requirements, the following palette tokens are established:

*   **Primary Background:** Deep Blue / Dark Violet (`#0C1033` to `#161B46`)
*   **UI Overlay Panels:** Translucent Ice Blue (`rgba(28, 38, 86, 0.85)`)
*   **Active Slot Borders:** Glowing gold-yellow (`#FFD700`)
*   **Error / Blocked Path Border:** Warning orange-red (`#FF4500`)
*   **Confirm/Positive CTA (Green):** `#2ecc71`
*   **Cancel/Negative CTA (Red):** `#e74c3c`
