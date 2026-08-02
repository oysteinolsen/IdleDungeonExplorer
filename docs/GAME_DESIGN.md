# Idle Dungeon Explorer — Living Game Brief

> Status: initial discovery interview complete; round 10 incorporated. This document separates confirmed direction from recommendations and deferred details. Move an item into **Decision log** only after it is explicitly agreed.

## Decision log

The following direction is confirmed by the initial project brief:

- The game will be an idle/incremental experience on Roblox, inspired by *Melvor Idle* without copying its setting, content, names, interface, or exact balance.
- The initial release will contain only a small number of professions.
- The underlying systems must make new professions and their content easy to add during development.
- The design will adapt the idea for Roblox players instead of being a menu-only port.
- The game is intended to earn money, using player-respectful and non-aggressive monetization.
- The target is the broad audience reached by popular Roblox games such as *Grow a Garden*: immediately understandable for a new or young player, with enough interconnected progression to hold long-term players.
- Grindy collection goals and genuinely low-chance rewards are an important part of long-term motivation. At launch these rewards are earned through play; later monetization categories are evaluated individually rather than prohibited by a blanket cosmetics-only rule.
- Dungeon exploration is the primary fantasy and the reason to improve the rest of the account.
- Professions are essential to dungeon readiness. Players should not easily progress through dungeons while ignoring professions, because professions upgrade gear, abilities, and supplies.
- Combat, Mining, and Forging are available from the start.
- Smelting is a Forging action rather than a separate profession. Crafting will be added later when its supporting material professions are ready.
- A shop buys ore, bars, and crafted or looted gear for soft in-game currency.
- Soft currency initially buys food and healing potions. Later professions may let players grow or craft these supplies.
- Monsters may drop food, healing items, gear, materials, and rare rewards.
- The item system must support a large and expandable catalog.
- Cooperative gameplay is out of scope for the first iteration.
- Competition is in scope from the first iteration through daily and weekly leaderboards.
- The world structure is a compact shared adventurer town with private/instanced dungeon runs.
- Dungeon combat is one player against one monster at a time. Basic attacks are automatic, while active play allows abilities, supply use, and responses to enemy mechanics.
- Each dungeon has a configured sequence or pool of predetermined monsters and culminates in a boss. It is not an uncontrolled open-world mob fight.
- A player must clear a dungeon manually before unlocking automatic or offline repeat runs for it.
- Automatic/offline dungeon runs use the real combat rules. An underprepared player can die; the game does not provide a definitive “safe to idle” verdict.
- Mining and Forging are separate professions.
- Forging contains both smelting ore into bars and forging bars into weapons, armour, and components used by other recipes.
- Initial equipment uses understandable tier-based Damage and Defence statistics.
- The item architecture must support future prefixes and suffixes even though randomized affixes are not required in the first version.
- Combat uses three attack types: Melee, Ranged, and Magic. Melee is strong against Ranged, Ranged against Magic, and Magic against Melee.
- The first version implements only player Melee equipment and Melee monsters. Ranged and Magic remain in the combat model but are not usable until their supporting professions and content are added.
- Combat progression uses the simplified skill model: Melee, Ranged, Magic, Defence, and Vitality.
- Automatic combat supports basic attacks, automatic food use below a player-configured health threshold, and a configured ability priority. Active players may manually override these actions.
- Dungeon drops enter an unsecured run-loot container. Loot becomes permanent only when the player actively transfers it to secured inventory.
- If the player dies, all accumulated unsecured dungeon loot is lost; loot transferred earlier remains safe.
- Completing a dungeon can automatically restart it when the player enables an explicit repeat toggle. The toggle can be turned off.
- Death also permanently destroys one random eligible equipped weapon or armour item.
- Secured items use one shared, slot-limited bank. Category tabs organize or filter the bank but do not have separate capacities.
- Players buy additional bank slots with Gold at incrementally increasing prices, following the useful Melvor pattern.
- Offline actions run at a reduced rate compared with online actions.
- While online, dungeon loot can be banked manually at any time. Loot accumulated offline remains unsecured until the player returns and manually banks it.
- Automatic looting is added later through the losable, dungeon-earned Auto-Loot Ring and a permanent loot-collecting pet purchased directly for Robux.
- Crafting is not a launch profession. It will arrive when the supporting material-producing professions are ready.
- Pets can be discovered as rare rewards from every activity, not only combat. Each pet grants a minor permanent buff related to the activity or place where it was found.
- Offline actions run at 50% efficiency for up to 24 real hours. Earned Gold or milestone upgrades can eventually raise offline efficiency to a non-paid ceiling of 75%.
- The starting secured bank has 40 shared slots and five fixed category tabs. The unsecured combat-loot container has 16 entries.
- The Auto-Loot Ring and a permanent loot-collecting pet provide the same functional effect: they move dungeon loot directly into the secured bank when space is available.
- The Auto-Loot Ring occupies an eligible equipment slot and can be permanently lost on death.
- The loot-collecting pet is a permanent Robux entitlement, is never randomly purchased, and cannot be lost on death.
- All discovered pet buffs remain active, and every unlocked pet type can be displayed as a visible follower at the same time, including the paid loot pet.
- The approved visual direction is stylized low-poly heroic fantasy using the Roblox-distributed Synty dungeon assets as the primary prototype family.
- The desired atmosphere is original classic tabletop high fantasy with Minecraft-like blocky clarity and approachability.
- The first art pass uses only free, legitimately licensed assets.
- Active first clears take place in a small 3D combat room where the avatar can move and dodge telegraphed attacks. Automatic and offline repeats resolve through the stat simulation without player movement.
- The first public-version content target is level 30, Bronze/Iron/Steel equipment tiers, two complete dungeons, one town, one mine, one shop, daily and weekly leaderboards, and one earned pet for each launch activity and each dungeon.
- Launch equipment slots are Weapon, Shield, Head, Chest, Legs, Feet, Hands, Amulet, and Ring. Equipment slots are data-defined so Ammo and other future slots can be added without redesigning saves or the equipment UI.
- Dungeon loot tables must be highly configurable and balanceable without changing dungeon code. The Auto-Loot Ring is a rare drop from a dungeon; its exact dungeon and odds remain open.
- The first monetized product is a supporter pass. Future monetization is not categorically limited to cosmetics; the architecture must support direct, clearly described purchases such as profession unlocks and other content-appropriate entitlements.
- *Idle Dungeon Explorer* is a working title. The public name will be selected after name and availability research.
- The project is being built by one professional .NET/Java developer, casually during spare time, as an experiment that could grow into meaningful income.
- The first external milestone is a private playable prototype, not a public release.
- The developer will initially test the private prototype alone; outside testers may be added later.
- Some future professions will be free and others will be permanently paid-exclusive.
- Supporter-pass benefits and timing will be explored only after a proper prototype exists.
- All ordinary inventory loot remains repeatable: obtaining an item never removes it from its loot table. Players can own multiple copies, including replacement or spare Auto-Loot Rings.
- The eventual public identity should use the clear descriptive subtitle **Idle RPG** for genre discovery; the invented brand name and tone still require research.
- The public name must represent an expandable account-wide profession RPG rather than Mining, Forging, or anvils specifically. The long-term vision includes broad systems comparable in variety to Melvor's Farming, Herblore, Astrology, Cooking, Fishing, and other skills.
- The private prototype succeeds if it convinces the developer that a solo professional programmer and experienced gamer can learn Roblox development and create a working game whose core loop is genuinely fun, despite having no previous game-development experience.
- The earliest dungeon encounters use traditional low-level enemies, beginning with rats and snakes, in an underground cave/burrow dungeon culminating in the Rat King.
- The first three metal tiers follow Melvor's opening order: Bronze, Iron, and Steel.
- Prototype combat remains deliberately light because this is an idle game first: automatic basic attacks, movement and telegraphed dodging during active first clears, food/potion use, and one reusable active combat ability. Automatic/offline repetition resolves that ability through a simple priority rule.
- Meaningful server-authoritative gameplay events should be recorded through a versioned analytics boundary so statistics and future leaderboard formats can be chosen from observed gameplay rather than guessed in advance. Leaderboard presentation remains undecided.
- The final brand may be an unrelated invented fantasy name as long as it uses the descriptive subtitle **Idle RPG**. It does not need to name a profession or gameplay verb.
- Every first-version dungeon is underground. The launch version can reuse one cohesive underground cave/burrow environment family rather than producing multiple biomes.
- The first dungeon uses rats and snakes and culminates in a Rat King boss.
- Mining follows the familiar Roblox simulator presentation: approach a visible ore node with a pickaxe, start repeated swings, show clear progress and reward feedback, and improve results through tools and progression. One interaction starts continuous mining so the idle game does not require holding or autoclicking.
- Forging is a simple repeating production action: select a recipe and quantity, start, and let items complete automatically. The player may abort before the current item completes. Active forging interaction remains minor.
- The private prototype needs only a small number of representative test items, not complete Bronze, Iron, or Steel catalogs.
- Equipment appearance should change the avatar as much as practical because looking impressive is part of progression. The prototype uses a staged, asset-light solution that prioritizes visible tools, weapons, shields, and a helmet before more complex full-body armour fitting.
- The public brand should evoke classic fantasy. There are no additional naming-style or sound restrictions beyond using the descriptive subtitle **Idle RPG**.
- The shared town is a classic above-ground village. The mine and dungeon are separate, visually distinctive entrances leading to underground spaces.
- Completed Mining rewards go directly into the secured bank when there is room. Mining continues when the bank is full, including profession XP progression, but overflowing item rewards are not granted.
- Aborting an unfinished Forging item returns the ingredients reserved for that item; completed items and their consumed ingredients are unaffected.
- The Rat King's signature active-combat attack is a clearly telegraphed forward lunge that attempts to scratch the player with both claws.
- Gathering professions require an appropriate equipped tool. Mining begins with a pickaxe, and better pickaxes become purchasable with Gold after reaching configured Mining levels. This tool progression must be reusable by later professions.
- The private prototype uses a Rojo filesystem-first workflow with Rokit-pinned tools, Wally-locked dependencies, strict Luau checks, and Roblox Studio CLI tests. Gameplay is split into explicit client/shared/server boundaries, with deterministic domain logic and server-authoritative transactions.

## Working game description

*Idle Dungeon Explorer* is a mobile-first Roblox incremental dungeon RPG in which players train interconnected professions, prepare supplies and equipment, and take their avatar into increasingly dangerous dungeon expeditions. Players begin with Combat, Mining, and Forging. Ore becomes bars; bars and monster materials become equipment or future crafting components; and equipment and consumables enable deeper dungeon progress. Unneeded resources and gear can be sold for soft currency used to buy food and healing potions.

Every action creates understandable progress: active players can explore and make combat decisions, while idle players can return to a concise report of resources, experience, discoveries, and upgrades earned while away. Long-term appeal comes from pushing dungeon depth, optimizing production, completing a large item catalog, chasing very rare drops, and competing on rotating daily and weekly leaderboards. New professions plug into the same action, recipe, reward, mastery, inventory, shop, and offline-progression systems so content can expand without rebuilding the game each time.

This description is a **proposal**, not yet an agreed final pitch.

## Preliminary public-name research

Roblox recommends accurate, unique metadata and warns against repetitive titles, irrelevant keywords, and closely imitating an existing experience's title or imagery. Search understands more than exact title words, so the name should be memorable first and use only genre terms the game genuinely fulfills. The description and thumbnails can carry additional search context.

Sources:

- [Roblox discovery and metadata guidance](https://create.roblox.com/docs/production/promotion/discovery)
- [Roblox publishing and game-name guidance](https://create.roblox.com/docs/production/publishing/publish-games-and-places)

### Updated naming requirement

The first shortlist overemphasized the launch professions. **Forge & Delve**, **Loot & Anvils**, and **Delve & Forge** are no longer recommended because the finished game is intended to grow far beyond Mining and Forging. Melvor's breadth includes Farming, Herblore, Astrology, Fishing, Cooking, Crafting, Cartography, Archaeology, and many other systems; this project needs the same freedom to expand without its name becoming misleading. [Melvor skill categories](https://wiki.melvoridle.com/w/Category%3ASkills)

The next naming pass should favor a short original fantasy-world or brand name followed by **Idle RPG**, similar in structure rather than wording to *Melvor Idle*. The invented word does not need to describe gameplay; the subtitle carries the genre explanation. This leaves the brand free to contain combat, professions, collection, exploration, and future regions without becoming misleading.

**Idle Dungeon Explorer** remains the working title because dungeons are still the main progression aspiration, but it is not selected as the final title. A new broad shortlist requires separate collision research.

### Names screened out

- **Idle Delver** is already a released game with sequels, including *Idle Delver III*. [Existing Idle Delver series](https://1buttonwonder.itch.io/idle-delver)
- **Dungeon Smith** has already been used by multiple released or prototype games. [2015 Dungeon Smith](https://an0malystudios.itch.io/dungeon-smith), [2023 Dungeon Smith](https://vuqo.itch.io/dungeon-smith)
- **Deepforge** is already used by an upcoming Steam game, a game studio, and software projects. [Deepforge Brawl](https://store.steampowered.com/app/4921440/Deepforge_Brawl/)
- **Everdelve** and **Delvebound** are active game names. [Everdelve](https://everdelve.com/en/), [Delvebound](https://www.delvebound.com/)

This is collision screening, not trademark clearance. Roblox titles are not exclusive identifiers, indexed search misses some experiences, and the live Roblox search could not be accessed from the current research environment. Before selecting a public name, search it manually in Roblox, check major app stores and game storefronts, review social/domain availability, and perform an appropriate trademark search for intended markets.

## Research findings

### What is worth carrying over from Melvor Idle

Melvor's durable foundation is a network of simple timed actions rather than one complicated mechanic:

- A player selects an action in one skill and it repeats until stopped or blocked.
- Skill XP unlocks higher-tier actions and materials.
- Individual actions also have mastery, creating depth inside a profession instead of making level the only goal.
- Gathering and production skills feed each other and eventually feed combat.
- Offline progress uses the same underlying rules and reports the result when the player returns.
- Equipment, consumables, modifiers, completion goals, pets, rare drops, and dungeons create overlapping long-term objectives.

Melvor currently grants up to 24 hours of offline progress, and its mastery model gives both skill experience and action-specific mastery. These are useful patterns, but Roblox needs a faster first session and a more visual, social presentation.

Sources:

- [Melvor Idle beginner's guide](https://wiki.melvoridle.com/index.php?title=Beginners_Guide)
- [Melvor Idle mastery system history](https://wiki.melvoridle.com/w/V0.17)
- [Melvor Idle skill and boost examples](https://wiki.melvoridle.com/index.php?title=Summoning)

### What Roblox changes

- Roblox recommends mobile-first design because most users play on mobile.
- Familiar Roblox genre conventions reduce how much must be explained in the first session.
- Social play can improve retention because players create ongoing content for one another.
- Contextual, interaction-led onboarding is preferable to a large opening tutorial.
- Discovery evaluates signals including qualified plays, playtime, retention, monetization, friend plays, and intentional co-play. A satisfying game should produce these honestly, not keep players online through artificial delays.
- The 2025 Roblox breakout *Grow a Garden* demonstrated the broad appeal of a simple, legible, multiplayer idle loop; Roblox reported a peak of 21.6 million concurrent users in July 2025.

Sources:

- [Roblox: Design for Roblox](https://create.roblox.com/docs/production/game-design/design-for-roblox)
- [Roblox: Onboarding techniques](https://create.roblox.com/docs/production/game-design/onboarding-techniques)
- [Roblox: Discovery](https://create.roblox.com/docs/production/promotion/discovery)
- [Roblox 2025 Replay](https://about.roblox.com/en-nz/newsroom/2025/12/roblox-replay-decoded-search-style)
- [Roblox genre insights](https://corp.roblox.com/en/newsroom/2024/07/roblox-genre-insights-what-will-you-create-next)

### What the recent Roblox hits have in common

The top of Roblox is diverse rather than one fixed genre. A July 2026 live-chart snapshot includes roleplay, survival, RPG, shooter, simulation, and pet-collection games. The repeatable lessons are more valuable than copying the theme of the current number-one game:

- **A one-sentence premise:** plant and sell a garden, survive nights in a forest, collect and protect absurd creatures, or explore dungeons and forge better gear.
- **Almost no delay before the first meaningful action:** a player can understand and touch the core loop immediately.
- **A simple outer loop with deeper inner optimization:** the basic verb is easy, while items, upgrades, builds, rarity, and collections provide depth.
- **Visible ownership and status:** gardens, bases, pets, equipment, titles, and leaderboard positions let other players see progress.
- **Randomness that creates stories:** unusually rare or visually distinctive outcomes are exciting to obtain and share.
- **Persistent or repeatable progress:** leaving and returning does not make the previous session feel wasted.
- **A reason to return together:** synchronized shop stock, weather, update launches, events, or rotating goals create conversation and spikes of activity.
- **Frequent content built on existing systems:** new items, enemies, variants, regions, and events refresh a proven loop more cheaply than adding an unrelated system every week.
- **Strong video moments:** rare drops, close escapes, discoveries, impressive collections, and update events translate into short-form content.

*Grow a Garden* is an especially relevant case. Its creator emphasized the persistent garden and offline growth, while reporting and player accounts highlight the simple buy → plant → harvest → sell loop, visible neighboring gardens, gifting, shared shop stock, rare items, mutations, and scheduled updates. Roblox's 2025 review also shows how important off-platform conversation became: Roblox-related content reached one trillion all-time YouTube views, and one in five game-related TikTok videos in July and August mentioned Roblox.

Useful sources:

- [Roblox interview with Grow a Garden creator Jandel](https://about.roblox.com/en-nz/newsroom/2025/09/roblox-tech-talks-episode-29-creator)
- [GamesBeat interview with Jandel](https://gamesbeat.com/janzen-madsen-interview/)
- [Associated Press reporting on Grow a Garden](https://apnews.com/article/2f5e4368448d57002d08b1b3d4a289ca)
- [Roblox 2025 Replay](https://about.roblox.com/en-nz/newsroom/2025/12/roblox-replay-decoded-search-style)
- [July 2026 live Roblox player-count snapshot](https://robipedia.com/topic/popular)

For this game, adapt those patterns as rare ore veins, exceptional crafted quality, named monster drops, relic variants, server-wide dungeon conditions, rotating vendor inventory, and scheduled dungeon events. Do not copy artificial frustration such as making basic progression depend on being present for a five-minute shop restock.

### Direct market comparison: The Forge

Roblox already has a close thematic competitor, *The Forge*, whose official description is “Mining, Forging, and Fighting.” It promotes more than 1,000 item variations, ore combinations with distinct traits, action combat, islands, runes, and a forging minigame. Its Gold economy pays for pickaxes, potions, storage, and enhancement; premium products include double storage and convenience features.

Sources:

- [The Forge on Roblox](https://www.roblox.com/games/76558904092080/The-Forge)
- [The Forge economy guide](https://the-forge.wiki/the-forge-wiki/guides/economy-guide/)
- [PC Gamer overview of The Forge](https://www.pcgamer.com/roblox/the-forge-tips/)

This project must not market itself as another active mining-and-forging RPG. Its differentiators are:

- a Melvor-like idle profession engine where actions progress online or offline;
- authored single-enemy dungeon sequences rather than open-world groups of enemies;
- active first clears followed by risk-bearing automatic/offline repetition;
- unsecured expedition loot that creates a bank-or-risk decision;
- professions as a long-term interconnected network rather than only a way to roll weapon variants;
- daily and weekly normalized competition;
- calm, clearly described monetization and earned rare drops without paid random rolls.

## Recommended adaptation for Roblox

### Product identity

Use a hybrid of three familiar forms:

1. **Idle/incremental depth:** profession levels, mastery, production chains, offline progress, and long-term optimization.
2. **Simulator clarity:** interact with a visible node or target, fill a progress bar, get a satisfying reward burst, unlock the next zone, and display upgrades on the avatar and camp.
3. **Dungeon RPG aspiration:** equipment builds, enemy families, bosses, collections, and optional co-op expeditions give the economy a purpose beyond making larger numbers.

The game should feel easy to begin but reveal meaningful planning over time. Active play should be more engaging and somewhat more efficient, while idle progress remains legitimate rather than a deliberately weak teaser.

### Proposed core loop

1. Choose a profession task or dungeon expedition.
2. Watch the avatar perform it and receive the first reward within roughly 20–30 seconds.
3. Gain resources, profession XP, and action mastery.
4. Convert resources into equipment, camp upgrades, consumables, or unlock requirements.
5. Push into a harder dungeon or a higher resource tier.
6. Return after time away to a clear earnings report and choose the next goal.

### Roblox-native active play

Active play should add choices rather than repetitive clicking:

- Move through a compact shared world to discover resource nodes, vendors, and dungeon entrances.
- Trigger short skill checks, elite encounters, treasure rooms, or route choices.
- Join a friend's expedition or contribute to a short public event.
- Return to a personal camp that visibly displays trophies, profession stations, and upgrades.
- Use strong audiovisual feedback for level-ups, rare drops, mastery milestones, and boss victories.

Avoid building the main loop around autoclicking, mandatory constant movement, or leaving a device running overnight.

### Confirmed world layout

Use a **compact shared adventurer town plus instanced dungeons**, rather than a passive waiting lobby or one enormous seamless world.

The town is a small, classic, above-ground fantasy village and should be functional from the first second:

- Players spawn facing an obvious first objective and clear signs toward the mine and dungeon.
- The shop, forge, mine entrance, dungeon entrance, and daily/weekly leaderboard displays are visible or only a few seconds apart.
- The mine and dungeon use separate, visually distinctive entrances. Both lead underground, but a new player should never confuse the productive mine route with the dangerous dungeon route.
- Higher-level players remain visible in impressive equipment, giving new players aspirational goals.
- Profession stations can visually expand as new professions arrive.
- Locked regions or mine tiers are previewed through gates, elevators, or portals without making navigation overwhelming.

The dungeon entrance starts a private run so other players cannot interfere and cooperation is not required. The first implementation can keep the village, mine, and isolated dungeon arenas inside one Roblox place to avoid loading friction and simplify testing. Shared services should remain place-independent, allowing later dungeon themes or large regions to move into separate places through `TeleportService` when scale or performance justifies it.

Sources:

- [Roblox places and game organization](https://create.roblox.com/docs/production/publishing/publish-games-and-places)
- [Roblox teleportation between places](https://create.roblox.com/docs/projects/teleport)

## Profession foundation

Each profession should be content configured against shared systems rather than implemented as a unique monolith.

### Shared profession contract

Every profession definition should declare:

- identity, icon, category, and display order;
- unlock requirements;
- actions and their base duration;
- input costs and output rewards;
- profession XP and action-mastery XP;
- level and mastery requirements;
- drop tables and deterministic bonus rewards;
- modifiers that may affect duration, quantity, quality, preservation, or XP;
- station, animation, sound, and world-location references;
- required tool category and the tool modifiers used by its actions;
- offline eligibility and any safe stopping conditions.

Shared services should own the action scheduler, reward calculation, modifier pipeline, inventory transactions, progression, offline simulation, save schema, analytics events, and return report. A profession supplies data and only uses custom code for genuinely unique mechanics.

### Expansion rule

A normal new profession should require mostly new configuration, assets, recipes, and balance data. It should not require a new save format, offline engine, inventory implementation, or UI screen framework. Save data should use stable string IDs and versioned migrations so content can be renamed or extended safely.

### Confirmed profession-tool progression

- A profession may declare a required tool category. Mining requires a pickaxe; later professions can reuse the same system for axes, fishing rods, farming tools, and other appropriate tools.
- Each tool is a data-defined item with a profession-level requirement, Gold price, visual reference, and modifiers such as Power, Speed, or Luck.
- The shop reveals or unlocks better pickaxes at configured Mining levels. Buying an upgrade permanently removes Gold from the economy and makes the profession visibly and mechanically more effective.
- The selected tool affects both online and offline actions through the same modifier pipeline. Tool behavior must not be hard-coded specifically for Mining.
- Prototype progression needs only a starter pickaxe and one purchasable upgrade to validate requirements, purchasing, equipping, visible appearance, and changed action speed.

### Confirmed initial systems

The launch foundation contains:

- **Combat/Dungeon Exploration** as the demand engine: expeditions produce coins, monster materials, equipment, supplies, and rare relics.
- **Mining** as the gathering profession: ores come from increasingly dangerous tiers.
- **Forging** as the metal-production profession: ore becomes bars; bars become melee equipment or components used by other recipes and future professions.
- **Future crafting framework** in the architecture only: later recipes will combine forged components, monster materials, and future-profession resources. Crafting is not exposed as a launch profession.
- **Shop/Economy** as the sink and safety valve: ore, bars, and gear can be sold for soft currency; food and healing potions can initially be purchased.

This creates the loop mine → smelt/forge → prepare → explore → loot/sell → upgrade → push deeper. Future ranged, magic, farming, cooking, and alchemy professions can consume forged parts or replace shop-bought supplies without invalidating the initial economy.

### Confirmed first public-version content target

- Level 30 for each launch profession.
- Bronze, Iron, and Steel equipment tiers, matching Melvor's opening metal order without copying its exact recipes or balance.
- Two complete dungeons.
- One compact shared town, one mine, and one shop.
- Daily and weekly leaderboards.
- One earned pet for each launch activity and one for each launch dungeon.

The earlier **private playable prototype** is a validation milestone and does not need all of this content. It should prove one complete vertical slice—save/load, one Mining-to-Forging equipment path, active dungeon combat, secured versus unsecured loot, death, and offline simulation—before the full public-version content table is produced. This smaller prototype is a recommendation intended to keep a solo spare-time project achievable.

The prototype's success test is primarily confidence and fun: the developer can understand and safely change the whole vertical slice, complete its loop without manual data repair, and still wants to play another run after repeated development testing. It is acceptable for presentation and content quantity to remain rough. Monetization, public leaderboards, and outside testing are not required to answer this first question.

The prototype uses only enough test content to feel the complete loop. A suitable initial set is two mineable ores, one bar, one weapon, one armour item, one food item, one potion, and two representative monster drops. These may use temporary names, icons, and balance values. Full Bronze recipe and equipment tables begin only after the loop is enjoyable and reliable.

Source for opening metal order: [Melvor Bronze Smithing table](https://wiki.melvoridle.com/w/Template%3ASmithingTable), [Melvor Iron Bar](https://wiki.melvoridle.com/w/Iron_Bar), [Melvor Steel Bar](https://wiki.melvoridle.com/w/Steel_Bar)

This follows the useful dependency pattern from Melvor's Smithing skill: Mining produces ore; the metal profession smelts bars, forges melee armour and weapons, and creates metal components used elsewhere. It does not copy Melvor's item names, quantities, progression table, or content.

Source: [Melvor beginner's guide: Mining and Smithing](https://wiki.melvoridle.com/index.php?title=Beginners_Guide)

### Roblox-style Mining interaction

The established Roblox mining/simulator loop is:

1. Equip a visible pickaxe and target a rock, ore block, or vein in a 3D mine.
2. Hold or repeatedly activate the mining input while the avatar swings.
3. Reduce node health or fill a mining-cycle progress bar based on tool power and speed.
4. Grant ore when the cycle or node completes, with a chance for rarer materials.
5. Stop when the backpack is full, then sell resources and upgrade the pickaxe or storage.
6. Unlock deeper zones containing slower, more valuable nodes.

*The Forge* uses hold-to-mine, Mine Power, Mining Speed, Luck, node health, and optional weak-spot critical hits. *Mining Simulator* uses a visible mining-cycle bar, mining power against block density, a backpack limit, and a surface selling point. *Mining Simulator 2* publicly describes the same explore → find rare ore → sell → upgrade tools/backpack loop.

Sources:

- [The Forge mining mechanics](https://forge-roblox.fandom.com/wiki/Mining)
- [The Forge ore weak spots](https://bloxinformer.com/wikis/the-forge/ores/)
- [Mining Simulator gameplay](https://roblox.fandom.com/wiki/Rumble_Studios/Mining_Simulator)
- [Mining Simulator 2 on Roblox](https://www.roblox.com/games/9551640993/Mining-Simulator-2)

### Confirmed idle adaptation

- The player walks to a visible ore node and taps/clicks it or its contextual **Mine** prompt once.
- The avatar equips the current pickaxe, faces the node, and repeatedly swings without further input.
- A world-space node bar and compact HUD progress bar show the current cycle. Each swing provides animation, sound, particles, and small damage feedback; useful rewards occur on completed cycles rather than every frame.
- Pickaxe Power reduces required cycles, Mining Speed reduces swing interval, and Mining Luck affects configured secondary or rare drops. These modifiers use the shared profession modifier pipeline.
- The selected action repeats until the player stops it, leaves the allowed area, changes activity, or lacks a required tool or other action requirement.
- Each completed ore reward is deposited directly into the secured bank if its stack already exists or a free slot is available. If it cannot fit, the reward is discarded while Mining and profession XP continue.
- A persistent full-bank warning, changed reward feedback, and the return report must make discarded rewards unmistakable. The system records overflow counts for balancing and support diagnostics.
- Online Mining uses visible nodes as activity targets, but rewards and progress are personal and server-authoritative. Another player cannot steal a partially completed cycle or exhaust the player's long-running action.
- A depleted node briefly cracks or collapses for feedback, then resets and continues automatically. It is not a long shared respawn timer.
- The same selected ore continues offline at the confirmed reduced efficiency, without simulating the avatar or physical node.
- A second press on **Stop Mining**, movement beyond the node's interaction area, or selecting another activity stops the action.

This keeps the Roblox fantasy of physically mining rocks while preserving Melvor's choose-once-and-repeat behavior. The prototype does not need weak-spot clicking; that can be tested later as a small active bonus if ordinary mining feels too passive.

### Confirmed Forging interaction

- Select a smelting or forging recipe and a desired quantity, including a repeat-until-stopped option.
- Press **Start Forging** once; the avatar/station animation and progress bar repeat automatically.
- Completed items and XP are awarded one action at a time. The action stops when the quantity completes, ingredients run out, output cannot fit, or the player aborts.
- The player can abort during the current item. Completed items remain earned; the unfinished item's progress is discarded.
- Reserve the current item's ingredients atomically and include the reservation in the saved action snapshot so disconnects cannot duplicate or destroy materials. Successful completion consumes the reservation and grants the output; a deliberate abort returns the unfinished reservation.
- No rhythm game or mandatory hammer-timing sequence is included. Minor audiovisual interaction can be added later, but unattended forging remains the normal behavior.

## Dungeon and offline-combat model

### Encounter structure

- Every first-version dungeon is underground. The same modular cave-and-burrow environment kit, palette, and lighting foundation can support both launch dungeons; layouts, props, encounters, and bosses provide variation without requiring another biome.
- Only one monster fights the player at a time.
- Each dungeon definition lists its ordered encounters or controlled monster pools, encounter counts, boss, unlock requirements, first-clear reward, repeat reward table, and offline eligibility.
- First clears take place in a compact 3D combat room. The player moves the Roblox avatar, dodges clearly telegraphed special attacks, uses supplies, and makes ability decisions.
- Automatic and offline repeats do not simulate avatar movement. They resolve the same underlying attacks, stats, supplies, and enemy mechanics through the server-authoritative combat simulator.
- The first dungeon's encounter families are rats and snakes. Variants may change size, color, statistics, and one readable special attack while reusing the same small asset families. Its final encounter is the **Rat King**.
- The Rat King visibly crouches and draws both claws back before lunging forward in a straight line for a two-claw scratch. An active player can sidestep the telegraphed lane; automatic and offline combat resolve the same move through the combat simulator's configured hit and damage rules.
- A run advances automatically from a defeated monster to the next encounter.
- Basic attacks repeat according to attack interval. Active abilities, food, potions, and later automation rules operate on top of the same combat simulation.
- A first clear requires active play. Clearing it unlocks automatic online repetition and offline repetition.

Melvor dungeons use authored monster sequences and counts, followed by a boss, which gives the player a learnable preparation problem instead of an arbitrary stream of enemies. For example, Cursed Forest defines multiple encounters from three enemy families followed by its boss.

Source: [Melvor Cursed Forest dungeon](https://wiki.melvoridle.com/w/Cursed_Forest)

### Confirmed prototype combat complexity

The prototype has only one combat ability in addition to automatic basic attacks: **Power Strike**, a readable cooldown attack that deals increased weapon damage. Active players can trigger it manually; automatic and offline combat use it when ready through the same ability-priority system.

The full active decision set is intentionally small:

- move away from a clearly telegraphed enemy area;
- trigger Power Strike when useful;
- manually use food or a potion when needed;
- decide when to bank unsecured loot or leave the dungeon.

There are no combos, stamina meter, manual basic-attack timing, animation cancelling, target switching, complex hotbars, or action-game parry system in the prototype. Future equipment and combat styles may add abilities through configuration, but the idle simulator must remain capable of resolving every ability without avatar movement or player reflexes.

### Configurable dungeon loot

Dungeon code must not contain item-specific reward branches. A dungeon instead references versioned, server-side loot-table definitions whose entries can declare:

- stable item or nested-table IDs;
- eligible encounter, monster, boss, first-clear, and repeat contexts;
- weight or probability, minimum and maximum quantity, and roll count;
- conditions such as dungeon tier, difficulty, first clear, or an account unlock;
- unique-drop handling and an optional progression-token fallback;
- analytics labels so observed drop rates and economy impact can be compared with intended balance.

Changing a weight, quantity, item, or table reference should be a data change rather than a dungeon-code change. Published balance versions should be retained long enough to explain rewards already simulated offline. Exact odds remain visible to players wherever practical. The Auto-Loot Ring will be a rare entry in one dungeon's configured loot table; its source and rate will be selected during content balancing.

Ordinary loot is never globally marked “already obtained.” Every eligible item can drop repeatedly, and players may keep multiple copies subject to normal stacking and bank rules. Collection-log completion records discovery without disabling future rolls. Account unlocks—such as activity-pet discoveries, achievements, and Robux entitlements—are not inventory loot and do not create stackable duplicate entitlements.

### Hidden idle risk

Offline combat must not use a simplified “free rewards” calculation. It replays the same attack timing, accuracy, damage rolls, resistance, healing thresholds, supply consumption, monster sequence, and special attacks as automatic online combat.

- The game displays understandable player stats, enemy attack type, known special attacks, and previous maximum damage observations.
- The game does **not** display a definitive “100% safe to idle” badge or expose the final survival calculation.
- Unknown drops can remain unknown, but encountered monster mechanics should be inspectable so loss does not feel arbitrary.
- Enabling offline combat requires an explicit warning that defeat and item loss are possible.
- On death, simulation stops at the calculated death time; rewards are never generated after death.
- The return report explains where the run ended, supplies consumed, unsecured loot lost, and any other death consequence.

### Unsecured dungeon loot

- Monster drops enter a separate run-loot container rather than secured inventory.
- Stackable items merge within the container; equipment occupies individual entries.
- While online and active, the player can transfer accumulated loot to secured inventory through an explicit action.
- Only transferred loot survives a future defeat.
- During offline combat, loot accumulates but cannot be transferred because the player is absent.
- When the player returns, the offline report shows the unsecured loot and requires a manual bank action.
- If the player dies, the entire unsecured container is discarded.
- If the container becomes full, combat stops safely rather than silently deleting or replacing rewards.
- After a successful dungeon completion, the `Automatically repeat dungeon` toggle determines whether the next run begins.
- Successful completion does not automatically secure the loot; the risk continues across repeated runs until the player returns and banks it.
- While online, the player may bank the loot at any time, including during an encounter.
- A future progression reward may automatically move loot into the bank when space is available.

### Confirmed automatic-loot paths

Two unlocks provide the same automatic-looting behavior:

- **Auto-Loot Ring:** a rare equippable ring that automatically transfers drops into the secured bank when space is available. Because it is equipped, it participates in the random item-loss pool on death and may be permanently destroyed. It always remains eligible to drop again, allowing replacement rings and multiple spare copies.
- **Loot-collecting pet:** a later, direct Robux purchase that provides the same automatic transfer without occupying equipment and cannot be lost on death. It is a permanent entitlement, not a paid random pet roll.

If the secured bank is full, neither effect deletes or replaces an item. The new drop remains in the unsecured loot container if it has space; if both are full, combat stops safely. The return report states why progress stopped.

This makes repeat duration a meaningful risk decision: a stronger build, larger loot container, and adequate supplies allow longer unattended runs, but the player can always choose a shorter active session and bank frequently.

This creates a community knowledge problem similar to Melvor: ordinary players make a judgment from visible information, while highly invested players may eventually derive calculators. The server remains authoritative, and the client never receives future random rolls.

### Confirmed death consequences

- The player keeps experience already earned.
- Supplies already consumed remain consumed.
- The run stops immediately.
- All unsecured dungeon loot is lost.
- Previously secured inventory remains safe.
- One randomly selected eligible equipped weapon or armour item is permanently destroyed.
- Food, potions, cosmetics, pets, and non-equipped bank items are not eligible for equipped-item loss.

An earned protection mechanic may later protect one item, but item protection will not be sold as a death-screen Robux purchase.

Melvor's standard death rule permanently removes a random item from the active equipment set, and its offline combat applies the same consequence before stopping progress.

Sources:

- [Melvor death rules](https://wiki.melvoridle.com/index.php/FAQ)
- [Melvor offline combat](https://wiki.melvoridle.com/w/V0.21)

## Combat triangle

The three attack types form a readable preparation triangle:

- Melee is strong against Ranged and weak against Magic.
- Ranged is strong against Magic and weak against Melee.
- Magic is strong against Melee and weak against Ranged.
- Matching the enemy's style is neutral.

Use Melvor's standard-mode values as the first balancing baseline:

| Player style | Enemy style | Damage modifier | Resistance modifier |
|---|---|---:|---:|
| Melee | Melee | 1.00× | 1.00× |
| Melee | Ranged | 1.10× | 1.25× |
| Melee | Magic | 0.85× | 0.75× |
| Ranged | Melee | 0.85× | 0.95× |
| Ranged | Ranged | 1.00× | 1.00× |
| Ranged | Magic | 1.10× | 1.25× |
| Magic | Melee | 1.10× | 1.25× |
| Magic | Ranged | 0.85× | 0.85× |
| Magic | Magic | 1.00× | 1.00× |

These values are configuration, not hard-coded branches. Testing may tune them to make switching style worthwhile without making a disadvantaged matchup useless. The triangle modifies the player rather than applying a second independent monster triangle, avoiding double multiplication.

The first version intentionally contains only Melee player equipment and Melee enemies, so every launch matchup is neutral. The complete triangle remains in the shared combat model and content schema, but Ranged and Magic monsters are withheld until players can reasonably obtain the countering styles. This prevents impossible or unfair launch matchups while avoiding a combat-system rewrite later.

Source: [Melvor standard combat triangle](https://wiki.melvoridle.com/index.php?title=Combat_Triangle)

## Equipment model

### First version

- Equipment follows clear material tiers.
- Weapons primarily expose Damage, attack type, and attack interval.
- Armour primarily exposes Defence/Resistance and equip-slot identity.
- Items have stable template IDs; individual item instances have unique IDs so future affixes, upgrades, and loss can be represented safely.
- Forged items use deterministic base stats in the first version.
- The launch slots are Weapon, Shield, Head, Chest, Legs, Feet, Hands, Amulet, and Ring.

### Staged visible-equipment plan

Looking more impressive as equipment improves is part of the reward loop, but fitting complete armour to arbitrary Roblox avatar proportions is substantially more asset work than displaying held tools and rigid accessories. Roblox `Tool` objects attach to the character's hand, while rigid accessories attach to named points on the avatar without needing deformation. These are suitable for an asset-light prototype.

**Private prototype:**

- Display the active pickaxe and equipped weapon in the right hand using reusable Tool/attachment code.
- Display the shield on the left arm during combat and optionally on the back outside combat.
- Display the helmet as a rigid head accessory.
- Use one cohesive free low-poly model family and material/color variants for early tiers.
- Keep Chest, Legs, Feet, Hands, Amulet, and Ring fully functional in stats and UI even if their first test items do not yet have a fitted 3D model.

**First public version, after the loop is proven:**

- Normalize player characters to compatible R15 body proportions while retaining recognizable avatar identity such as face, skin tone, and compatible hair/accessories.
- Add modular rigid or welded armour pieces for torso, arms/hands, legs, and feet, referenced by data-defined visual IDs on item templates.
- Provide cosmetic visibility toggles so players may hide individual armour slots without removing their statistics.
- Hide or adjust incompatible hair/accessories while a helmet is shown, then restore them safely when it is removed.
- Use LOD and visibility controls for distant players so detailed equipment and pet collections do not overload mobile clients.
- Do not require visible models for tiny Ring and Amulet slots; important rare accessories can later use a bounded aura, trail, or chest ornament.

The code and data configuration for this approach can be built in the repository. The developer will still need guided Roblox Studio steps to select/import free models, verify attachment placement, and visually test them on representative R15 avatars. Custom Blender modelling and layered clothing are not required for the private prototype.

Sources:

- [Roblox in-experience Tool objects](https://create.roblox.com/docs/players/tools)
- [Roblox rigid accessories](https://create.roblox.com/docs/art/accessories)
- [Roblox Accessory Fitting Tool](https://create.roblox.com/docs/art/accessories/accessory-fitting-tool)

### Extensible equipment-slot contract

Slots must be definitions in a registry, not positions in a hard-coded nine-element array. Each slot definition declares a stable ID, display order and UI group, accepted item tags, equipped quantity rules, incompatible slots, combat-style restrictions, and whether its contents can participate in death loss. A loadout stores equipment by stable slot ID, and the UI renders from the registry, allowing a new definition to appear without rewriting the save schema or equipment screen.

The registry initially enables the nine launch slots and reserves support for future slots such as **Ammo**. When Ranged arrives, Ammo can hold a quantity-bearing stack of compatible arrows, bolts, or other ammunition; ranged attacks can consume that stack through the shared combat-cost system. Exact ammunition types, preservation rules, empty-ammo behavior, bank refill behavior, and death-loss consequences are deferred until Ranged is designed. Two-handed weapons and future off-hand items use configured incompatibility rules rather than special-case UI code.

New slot definitions default to empty for existing players. Removed or renamed slots require an explicit save migration that safely returns equipped items to the bank; equipment must never disappear because a definition changed.

### Future-ready affixes

The data model supports optional prefixes and suffixes without enabling them at launch:

- a prefix and suffix each reference a stable affix definition;
- affixes declare allowed item categories, tiers, attack types, stat modifiers, and display text;
- generated stats are stored or reproducible from an immutable roll seed;
- balance calculations operate through the shared modifier pipeline;
- save migrations preserve items when affix definitions change.

This produces names such as “Tempered Iron Sword of Swiftness” later without requiring a save-data redesign.

## Inventory and Gold economy research

### What comparable Roblox games do

- *Dungeon Quest* currently limits storage to 300 individual items. Its community documentation notes that the limit was introduced after very large unlimited inventories exceeded save-data limits and caused item loss.
- *Grow a Garden* separates inventory into categories such as seeds, gear, pets, and crops. Its inventory can be expanded through earned Sheckles as well as Robux.
- *The Forge*, the closest direct competitor, uses Gold for storage upgrades, pickaxes, potions, and rune/item enhancement, while also selling a double-storage product.
- *Dungeon Quest* uses Gold for equipment upgrades and skill resets in addition to ordinary purchases, providing scalable sinks after basic consumables stop mattering.

Sources:

- [Dungeon Quest inventory](https://dungeonquestroblox.fandom.com/wiki/Inventory)
- [Dungeon Quest Gold](https://dungeonquestroblox.fandom.com/wiki/Gold)
- [Grow a Garden inventory mechanics](https://growagarden.fandom.com/wiki/Mechanics)
- [The Forge economy](https://the-forge.wiki/the-forge-wiki/guides/economy-guide/)

### Confirmed shared-bank model

Use one secured bank with a single shared slot limit, modeled on Melvor's useful inventory pressure:

- Every distinct stack occupies one bank slot regardless of category.
- Identical ores, bars, materials, food, and potions stack by item definition.
- Identical deterministic equipment may stack. Future affixed equipment stacks only when its complete generated identity is identical; otherwise it occupies its own slot.
- Tabs filter or organize categories such as All, Materials, Equipment, Consumables, and Special. Tabs do not create extra storage pools.
- The first version provides a fixed tab set and fixed starting capacity.
- Players buy permanent `+1 Bank Slot` upgrades with Gold.
- Each purchased slot increases the price of the next slot according to a data-configured curve.
- The bank UI supports search, sorting, favorites, multi-sell, and clear new-item highlighting.
- An item that is favorited cannot be accidentally sold or selected for destructive actions.
- If the bank lacks room, a manual loot transfer fails safely and explains what must be sold or consolidated.

The unsecured dungeon-loot container remains separate because its contents have not entered the bank yet. Its precise capacity is still an open balance decision.

Melvor likewise uses one slot-limited bank with organizational tabs, incrementally more expensive bank-slot purchases, and a separate combat loot container. Its bank-slot cost eventually reaches a cap, preventing late-game storage from becoming completely unaffordable.

Sources:

- [Melvor shop and bank-slot pricing](https://wiki.melvoridle.com/w/Shop)
- [Melvor bank FAQ](https://wiki.melvoridle.com/index.php/FAQ)
- [Melvor bank tabs](https://wiki.melvoridle.com/w/V0.17)

Do not sell bank slots for Robux in the first version. Storage is a deliberate Gold sink and progression system, not a frustration funnel.

### Gold sources

- selling ore, bars, equipment, and selected monster materials;
- dungeon completion rewards;
- leaderboard milestone rewards, kept modest;
- first-time collection and quest rewards.

### Launch Gold sinks

- food and healing potions;
- incrementally priced shared-bank slots;
- level-gated pickaxes and future profession-tool upgrades;
- later profession-station and town-facility upgrades;
- equipment tempering/upgrades with increasing costs;
- unlocking deeper mining access and town facilities;
- skill respecs after an initial free period;
- convenience unlocked through play, such as additional saved loadouts or more detailed automatic-healing rules.

Avoid permanent equipment durability and routine repair bills in the first version. They remove Gold but commonly feel like taxation rather than progress. Avoid dungeon entry fees on ordinary runs because they discourage experimentation with the hidden idle-risk system.

### Confirmed reduced-rate offline progression

Roblox implementations vary widely. *Grow a Garden* allows planted crops to continue maturing for very long absences, but offline time primarily changes plant growth rather than simulating a risky combat chain. Other Roblox idle/tycoon experiences commonly use short caps that can be upgraded, sometimes alongside reduced offline efficiency or monetized extensions.

The confirmed direction is that offline actions produce less progress than online actions. Implement this through `effectiveElapsedTime = elapsedTime × offlineEfficiency`, then run the normal deterministic profession or combat simulator for that effective duration. This preserves the same combat outcomes per simulated run rather than inventing a separate offline reward table.

Offline efficiency starts at **50% for up to 24 real hours**. Earned Gold or milestone upgrades may eventually raise efficiency to a non-paid ceiling of **75%**. Actual dungeon progress can stop earlier because the player dies, runs out of food, fills the loot container, or disables automatic repeat. Production professions stop if required inputs run out or output cannot fit in the bank. Mining continues when the bank is full, awards its normal profession XP, and discards item outputs that cannot fit, matching online Mining behavior.

This approach:

- preserves a normal once-per-day return rhythm;
- avoids rewarding devices left running overnight;
- lets storage and preparation create strategic limits;
- avoids using a short cap as pressure to log in repeatedly;
- bounds server computation and exploit exposure.

Offline efficiency or duration will not be sold for Robux in the first version.

## Reward rarity and grind recommendations

Low-chance rewards should sit on top of dependable progress, not replace it:

- Every successful action gives a useful baseline reward and progress toward a known goal.
- Uncommon rewards create regular excitement within an ordinary session.
- Rare named gear, recipes, relics, ore variants, or cosmetic trophies become multi-session pursuits.
- Ultra-rare rewards should be visually distinctive and recorded in the collection log, profile, and relevant leaderboards.
- Duplicate rare items retain value through selling, salvaging, upgrading, or collection milestones.
- Drop sources and exact odds should be visible. Transparency does not remove excitement and makes the grind feel trustworthy.
- A non-random long path, such as boss tokens or blueprint fragments, should eventually let an extremely unlucky player obtain progression-critical items. Pure chase cosmetics can remain fully random.
- Robux will not buy random loot rolls or paid luck in the initial direction. Future direct gameplay entitlements will be evaluated individually; active challenges can improve reward quantity or grant extra rolls earned through play.

Recommended rarity hooks adapted from popular Roblox games:

- **Ore quality variants:** normal, rich, crystalline, ancient, and region-specific mutations.
- **Craft quality:** exceptional results with visual variants and small bounded stat improvements.
- **Monster uniques:** named equipment and materials tied to recognizable enemies.
- **Relic discoveries:** rare collection pieces that alter a build or display in town/profile.
- **Server conditions:** scheduled events such as a volcanic surge or cursed moon that temporarily changes available enemies and resource variants for everyone.
- **Visible announcements:** celebrate genuinely rare finds in the server without interrupting other players.

## Pet system

Ordinary activity pets are rare permanent discoveries tied to activities and locations rather than purchased eggs. The loot-collecting pet is a separate premium convenience entitlement and is not part of the random activity-pet drop system.

### Confirmed direction

- Every profession, dungeon, boss family, and future activity may have one or more discoverable pets.
- A pet can drop while the related activity is performed online or offline.
- Its buff is minor and thematically related to its source, such as Mining yield, Forging preservation, Melee accuracy, Defence, healing efficiency, or Gold from item sales.
- Pets are collection goals and visible status rewards, not required gates for normal progression.
- There are no Robux-paid eggs, paid pet rolls, paid luck boosts, or duplicate-pet fusion at launch.
- The loot-collecting pet is the exception to earned acquisition: it is bought directly for Robux, permanently secures dungeon drops when bank space exists, and cannot be lost on death. Its exact price and release timing remain open.

### Recommended behavior

- The first discovery permanently unlocks the pet; duplicate pet drops are unnecessary.
- All discovered pet buffs remain active, following Melvor's collection model.
- Every unlocked pet type may follow the player visibly at the same time. This includes earned activity pets and the paid loot-collecting pet; visible presentation does not change which buffs or utilities are active.
- Followers should use a data-driven formation with stable pet IDs and attachment positions so new pet types do not require bespoke follower code.
- To protect mobile performance and town readability as the collection grows, clients may simplify or hide other players' distant pets, and players should have visibility controls. The owner must still be able to display their complete unlocked collection when desired.
- Pet bonuses remain small, usually around 1–2% or a similarly bounded utility effect, so finding one is exciting without making unlucky players noncompetitive.
- Drop chance is normalized by action duration so a fast one-second action does not receive dramatically more pet rolls than a slow action.
- The collection log reveals the source category while keeping the pet silhouette hidden until discovered.

Source: [Melvor pet behavior](https://wiki.melvoridle.com/index.php/FAQ#Pets)

## Progression recommendations

- Use a modest launch cap, such as level 30–40 per profession, instead of creating a mostly empty level-99 grind.
- Give each action its own mastery track, but keep the first version lighter than Melvor: a few visible breakpoints with understandable rewards.
- Make upgrades change appearance or behavior, not only percentages.
- Prefer unlocks, new choices, collection completion, and automation improvements over endless rebirth resets.
- If a prestige system is added, frame it as opening a new region, camp tier, or expedition era. Preserve meaningful collections and paid cosmetics.
- Start with an offline cap that supports a normal day away. The precise cap is an interview decision.
- Simulate elapsed time from timestamps on the server; do not run an action every second while the player is absent.

## Competitive social design

The first iteration is solo in play but socially competitive. Players share a town and see each other's appearance and achievements, but do not need to party, trade, or cooperate.

- **Daily dungeon board:** best score or deepest floor in a normalized daily challenge.
- **Daily profession board:** one rotating metric such as ore value mined, bars smelted, or quality items crafted.
- **Weekly explorer board:** cumulative dungeon score, bosses defeated, or deepest verified tier.
- **Weekly rotating profession board:** keeps Mining, Smelting, and Crafting relevant instead of letting Combat dominate every competition.
- **Personal comparison:** always show the player's own rank and the next reachable milestone, not only an intimidating global top ten.
- **Rewards:** titles, profile frames, town statues, cosmetic effects, and modest soft currency. Avoid exclusive power that causes winners to keep winning.

Direct player trading is not recommended for the first release because it adds exploitation, duplication, moderation, economy-balancing, and regional-pricing complications.

Leaderboard scores must be computed and validated by the server. Daily and weekly boards should use time-period-specific ordered data stores rather than deleting and rebuilding one board at reset. Roblox supports sortable global leaderboards through ordered data stores.

Sources:

- [Roblox custom leaderboard guidance](https://create.roblox.com/docs/tutorials/use-case-tutorials/data-storage/create-leaderboard)
- [Roblox retention and competitive systems](https://create.roblox.com/docs/production/analytics/retention)

## Player-respectful monetization direction

### Confirmed product direction

- The first planned product is a supporter pass, but its benefits, price, and release timing will not be designed until a proper playable prototype exists.
- There is no permanent cosmetics-only boundary for later releases. The commerce and entitlement architecture should support direct purchases for natural expansions such as profession unlocks, as well as convenience, cosmetics, and other future products approved individually.
- Profession definitions support an unlock policy rather than assuming every profession is free. The long-term catalog will contain additional free professions as well as some permanently paid-exclusive professions.
- The permanent loot-collecting pet is a later direct Robux entitlement. It is guaranteed, never rolled randomly, and the dungeon-earned Auto-Loot Ring provides an earnable version of its core automatic-looting function with greater risk and an equipment-slot cost.
- Most monetization is postponed until there is enough tested content and economy data to judge its effect.
- The original non-aggressive goal remains: monetization should help the project earn revenue without relying on nagging, deception, or deliberately making the free experience unpleasant.

### Recommended guardrails

- Purchases appear in a calm shop and relevant previews, not repeated pop-ups.
- Do not use fake discounts, fake scarcity, restarting countdowns, purchase nagging after failure, or confusing multi-currency chains.
- Keep rare random chase drops earned through play; do not sell paid random loot, pet rolls, or luck rolls.
- A child should be able to understand exactly what a purchase provides, whether it is permanent, and whether an earnable alternative exists before accepting it.
- Directly purchased permanent entitlements must restore from purchase records and can never participate in equipment-loss or unsecured-loot deletion.
- If later products affect progression, disclose the effect numerically and assess their effect on leaderboard fairness. Normalized competitive boards should ignore paid advantages where practical.
- Profession products should use a generic entitlement/unlock-policy system rather than checks for one named profession. Each definition declares whether it is free or permanently tied to a purchase entitlement.

Roblox itself warns creators not to mislead or pressure users, especially minors. Paid random items also require odds disclosure and per-user policy handling, which strengthens the case for guaranteed purchases only.

Sources:

- [Roblox monetization documentation](https://create.roblox.com/docs/production/monetization)
- [Roblox paid random item policy](https://create.roblox.com/docs/production/monetization/paid-random-items)
- [Roblox regional pricing](https://create.roblox.com/docs/production/monetization/regional-pricing)

### Product sequencing

The private prototype does not need a sellable supporter pass. It should establish a generic, testable entitlement and purchase-restoration boundary without committing to pass benefits. Supporter-pass design begins only after the prototype proves the core loop. A later low-production-cost benefit set could include a supporter title, badge, profile frame, and cosmetic effect, but this remains a recommendation rather than an agreed benefit list.

Later candidates include the direct loot pet, cosmetic packs, private servers, profession unlocks, storage or loadout convenience, currency, and subscriptions. Add them only when the related system exists and can be balanced from real player data. Paid random pets, loot boxes, and paid luck are not launch products; introducing any of them would require a separate explicit decision, policy review, odds disclosure, and consideration of the non-aggressive monetization goal.

Roblox's Creator Rewards can also provide revenue from genuine engagement, including qualifying ten-minute sessions, so a fair game with a satisfying medium-length session can monetize without pushing a purchase on every player.

Source: [Roblox Creator Rewards](https://create.roblox.com/docs/creator-rewards)

## Graphics and asset strategy

### Confirmed requirements

- The project should rely heavily on premade assets because the developer does not have visual-design skills.
- Graphics should feel native and familiar to Roblox players.
- Icons must be attractive, consistent, readable at mobile sizes, and easy to understand without relying on text.
- The first art pass uses only free assets with clear commercial-use permission.

### Confirmed art direction

Use a **stylized low-poly heroic fantasy** style with classic tabletop-fantasy atmosphere and Minecraft-like blocky readability:

- chunky readable silhouettes and slightly exaggerated tools, weapons, monsters, and props;
- simple materials, restrained texture detail, and strong color separation;
- warm, inviting town lighting contrasted with cooler or more dramatic dungeon lighting;
- adventurous rather than grim, graphic, or realistically violent;
- Roblox player avatars remain recognizable instead of replacing them with realistic custom characters;
- limited particles and PBR materials so the game remains responsive on lower-end phones.

“Classic tabletop fantasy” means familiar original adventurers, mines, ruins, slimes, skeletons, goblin-like raiders, treasure, armour, and magical architecture. “Minecraft-like” means readable blocky proportions, simple materials, welcoming colors, and approachable silhouettes. The project must not use protected *Dungeons & Dragons* or *Minecraft* names, logos, characters, creature designs, textures, sounds, rules text, or copied assets.

This style is affordable, modular, easy to extend with asset packs, and well suited to Roblox's mobile-heavy audience. Roblox recommends mobile-first UI, consistent icons, visual tutorials, and careful performance management.

Sources:

- [Roblox design guidance](https://create.roblox.com/docs/production/game-design/design-for-roblox)
- [Roblox 3D art overview](https://create.roblox.com/docs/art/overview-studio)
- [Roblox performance guidance](https://create.roblox.com/docs/performance-optimization/design)

### Premade 3D asset options

#### Option A — Roblox Creator Store

This is the easiest path because assets can be inserted directly through Studio's Toolbox. The Creator Store includes models, materials, UI elements, visual effects, audio, and plugins. Asset pages expose creator identity, ratings, triangle/vertex counts, mesh counts, and script counts.

Strong starting candidate:

- [Synty Dungeon Pack: Cave & Castle Interiors](https://create.roblox.com/store/asset/6934021345/Synty-Dungeon-Pack-Cave-Castle-Interiors) — free, distributed by Roblox, officially licensed for Roblox games, cohesive, modular, and script-free.

Use verified creators or assets distributed by Roblox where possible. Never insert a large “ultimate asset collection” merely because it is free; some uploads openly contain work the uploader did not create.

#### Option B — external CC0 packs

CC0 packs can be used and modified commercially without required attribution. Roblox Studio imports `.fbx`, `.gltf`, and `.obj` meshes.

- [Quaternius Modular Dungeon Pack](https://quaternius.com/packs/medievaldungeon.html) — 41 modular dungeon and prop models, CC0.
- [Quaternius Modular Dungeons Pack](https://quaternius.com/packs/modulardungeon.html) — another 48-piece CC0 set.
- [Kenney assets](https://kenney.nl/assets) — CC0 fantasy-town, dungeon, UI, input-prompt, audio, and general game packs.

Sources:

- [Quaternius licensing FAQ](https://quaternius.com/faq.html)
- [Kenney licensing FAQ](https://kenney.nl/support)
- [Roblox asset importer](https://create.roblox.com/docs/studio/importer)

#### Option C — selective custom work later

Premade assets can build the prototype and most environment content. Spend custom-art budget only where it gives the game identity:

- game logo and store thumbnails;
- dungeon portal and town centerpiece;
- major bosses and pet silhouettes;
- signature weapons and rare relics;
- UI frame, rarity treatment, and particles.

A small number of recognizable custom “hero assets” provides more differentiation than commissioning an entire environment before the core loop is proven.

### Confirmed prototype asset mix

Use one primary 3D family, not a mixture of unrelated packs:

1. Prototype the town and first dungeon with the free Roblox-distributed Synty pack and Studio primitives.
2. Use Roblox avatars and a small, audited set of compatible monster rigs.
3. Establish a custom palette, lighting setup, signage system, portal effect, and UI skin.
4. Add one custom boss and two or three custom pet models once gameplay is validated.
5. Replace conspicuously common assets only when analytics show the game is worth further investment.

No paid asset packs or commissions are planned for the first art pass. Free Creator Store assets still require ownership and script inspection; external assets must have clear commercial-use licensing such as CC0.

### Asset safety and licensing workflow

- Prefer script-free art assets. Disable or remove every included script before evaluating a model.
- Inspect models for scripts, unexpected remote asset loads, excessive geometry, hidden objects, sounds, and particles.
- Never use ripped assets from another Roblox experience, game, film, or franchise.
- Keep an asset ledger containing source URL, creator, license, acquisition date, receipt if paid, local source file, Roblox asset ID, and modifications.
- Preserve the license file distributed with every external pack.
- Test every imported asset on a real low-end mobile device or representative client.

Roblox specifically lets creators disable scripts in inserted models and prohibits obfuscated code and hidden remote asset loading in Creator Store submissions. Assets are also subject to copyright and moderation rules.

Source: [Roblox Creator Store documentation](https://create.roblox.com/docs/production/creator-store)

### Icon system

Icons should be built as a reusable system rather than found individually:

- Start from a single CC0 family such as [Kenney Game Icons](https://kenney.nl/assets/game-icons), or generate one cohesive custom set and manually review it.
- Author at a consistent high resolution with transparent backgrounds; export Roblox-ready PNG files.
- Use one centered object, a bold silhouette, generous padding, and a consistent three-quarter view and light direction.
- Avoid words inside icons. Pair the icon with localized text where a precise meaning is required.
- Do not communicate category or rarity through color alone; combine color with border shape, corner marks, or symbols.
- Keep item art separate from the rarity frame so one sword image can appear in multiple UI states.
- Test icons at their smallest real phone size, not only enlarged in an editor.

For hundreds of future item tiers, render icons from the actual 3D item models with a fixed camera and lighting rig. Reserve hand-made or generated illustrations for professions, currencies, pets, bosses, and other high-value concepts. This keeps item art consistent with what the avatar equips.

AI-generated raster icons are an option for the small high-value set, and can be produced during development, but they still need consistency checks, transparent-background cleanup, moderation review, and a clear record of their source.

## Analytics and statistics foundation

### Confirmed intent

Record most **meaningful state transitions** on the authoritative server so balance questions, player histories, achievements, and future leaderboard formats can be answered with evidence. This does not mean recording every rendered frame, progress-bar tick, or individual automatic attack. High-frequency activity is summarized at encounter, action batch, dungeon run, or offline-session boundaries.

The initial event catalog covers:

- sessions, onboarding steps, return reports, and feature/UI adoption;
- profession actions started, stopped, and completed, including inputs, outputs, XP, duration, and stop reason;
- item production, loot rolls, banking, selling, equipping, upgrading, and death loss;
- combat encounters and dungeon runs, including enemy, equipment tier, damage totals, supplies used, dodges, ability uses, duration, outcome, and death reason;
- currency sources, sinks, resulting balances, and shop transactions;
- levels, mastery milestones, dungeon first clears, unlocks, rare drops, and pet discoveries;
- entitlement checks and successful or failed purchase processing.

### Event contract

All systems publish through one server-side `EventRecorder` boundary. A logical event contains a stable event name, schema version, unique event ID, server timestamp, Roblox user ID and session ID, content version, relevant stable content IDs, numeric value where useful, and a small validated property set. Item or monster IDs are fields, not separate event names. Any later export outside Roblox should pseudonymize the user identifier unless a concrete operational need requires otherwise.

The boundary supports multiple sinks through composition:

1. **Statistics projections** update durable, purpose-built counters such as kills by monster, dungeon outcomes, items produced, Gold sources/sinks, and personal records.
2. **Roblox AnalyticsService** receives a curated and batched mapping to economy, funnel, and custom events for aggregate dashboards.
3. **Development diagnostics** capture events during Studio play and automated tests, because Roblox custom events can only be sent from the server in published experiences.
4. A later external analytics warehouse can be added behind another sink without changing gameplay services.

Do not use player DataStores as an unlimited raw event log. Save durable aggregates and important audit records; batch high-volume metrics and retain only bounded diagnostic traces around errors or disputed transactions. Future leaderboards should use separate validated score projections and OrderedDataStore entries rather than trying to read scores back from analytics charts.

Analytics is emitted only after the corresponding server transaction succeeds. Analytics failure never rolls back a valid gameplay transaction, but it is reported explicitly and counted through bounded error telemetry. Events contain no chat text, personal information, or unnecessary free-form strings.

Roblox currently provides economy, funnel, and custom dashboards. Custom events are server-only, limited to 100 event names, and benefit from batching values instead of sending one event for every repeated kill; the overall service also has a per-minute request limit. These constraints are why the internal domain-event catalog can be rich while the Roblox sink remains compact.

Sources:

- [Roblox analytics event types](https://create.roblox.com/docs/production/analytics/event-types)
- [Roblox custom events](https://create.roblox.com/docs/production/analytics/custom-events)
- [Roblox funnel events](https://create.roblox.com/docs/production/analytics/funnel-events)

## Technical and product guardrails

- The server is authoritative for inventory, currencies, rewards, progression, purchases, and elapsed-time validation.
- Persistent updates use explicit error handling, retries with limits, and versioned data; failures are surfaced and never silently discarded.
- Offline rewards are calculated from the last saved action snapshot and server time, with hard caps and sanity checks.
- The first experience is designed and tested on a small phone screen before desktop embellishment.
- Content and economy events are instrumented from the first playable build through the shared EventRecorder: onboarding steps, task starts/stops, first forge, first expedition, session summaries, return reports, and shop views/transactions.
- Build a representative end-to-end slice before producing large item tables.

Roblox DataStore calls are network operations that can fail and should be handled explicitly. Data stores are shared across places in an experience, which leaves room to split large future regions into separate places while retaining progression.

Source: [Roblox data stores](https://create.roblox.com/docs/cloud-services/data-stores)

## Interview status

The initial discovery interview is complete. No unanswered question blocks the private prototype. Remaining details should be decided through implementation and playtesting, using data-driven definitions wherever content or balance is expected to expand.

## Deferred decisions

- Final invented public name, precise tone, and lore.
- Whether weak-spot Mining interaction is worth adding after the base idle loop is tested.
- Final Rat King timings, hit rules, and numerical tuning.
- Post-prototype ability list and advanced automation conditions; the prototype uses Power Strike only.
- Bank-slot price curve and costs for offline-efficiency upgrades.
- Exact Auto-Loot Ring dungeon and drop rate.
- Loot-pet price, release timing, and detailed purchase messaging.
- Ammo types, consumption and preservation rules, automatic bank refill, and death-loss behavior.
- Final private-prototype item list and numerical success criteria; outside testing is postponed.
- Full-body visible armour scope, avatar compatibility rules, and the final free asset set.
- Supporter-pass benefits, price, and release timing.
- Paid-profession catalog and competitive-leaderboard treatment.
- Leaderboard formats and presentation, to be chosen after representative gameplay statistics exist.
- Analytics retention needs and whether a later external event warehouse is justified.
- Pet-following formation, visibility controls, and mobile performance limits for large collections.
- Later monetization catalog, price points, and product-by-product fairness rules.
- Trading, guilds, PvP, cooperative play, and competitive seasons beyond daily/weekly leaderboards.
- Content cadence and live-operations scope.
