# Item Icons

These 512×512 transparent PNGs are the first repository-owned item-art set:

| Content ID | File | Intended use |
| --- | --- | --- |
| `item.copper_ore` | `copper-ore.png` | Bank rows, Mining rewards, and Copper-node prompts |
| `tool.starter_pickaxe` | `starter-pickaxe.png` | Tool shop and owned-tool presentation |
| `tool.copper_pickaxe` | `copper-pickaxe.png` | Tool shop and owned-tool presentation |

The images were generated specifically for Idle Dungeon Explorer with the built-in image-generation tool. The prompt set requested vibrant, polished, low-poly fantasy-RPG inventory art, strong silhouettes, no text, no border, no drop shadow, and a flat chroma-key background. The chroma background was converted to a soft transparent matte, and the final images were downsampled with alpha preserved for efficient UI use.

## Roblox import handoff

Roblox UI cannot address repository PNG paths directly. Import all three files through Studio's Asset Manager (or the Creator Dashboard), wait for moderation, and copy their image asset IDs. Runtime code should reference those values as `rbxassetid://<id>`; do not commit account cookies or Open Cloud keys.

After IDs exist, add them to the content presentation metadata and render them in `ImageLabel` controls. Keep the item name, quantity, price, and tool requirements as accessible text beside the artwork; icons supplement rather than replace essential information.

## Art direction

- Preserve the warm copper-orange, charcoal stone, dark iron, and rich wood palette.
- Favor readable silhouettes and exaggerated material highlights over tiny surface noise.
- Give each tier a visibly stronger construction and richer material treatment.
- Avoid bare geometric placeholders as final-facing art.
- Keep transparent breathing room around the silhouette so icons remain legible on small phones.
