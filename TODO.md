# TODO

## Bugs
- [ ] Loot always placed in lower right 90degrees (multiply loot angle by 2pi)
- [x] Round doesnt end if monster hits town and rest dead

## UI
- [ ] Tower purchase menu has pictures + stats of towers
- [ ] Main Menu

## Internals
- [ ] Sound Manager - upper limit on per-sound polyphony
- [x] Sound Manager - default + dynamic volume


## Advanced Gameplay
- [ ] Ramping/diverse spawn rate with custom monster compositions
- [ ] Tower fire tactics: (Front, Back, Lowest Health, Highest Health)
- [ ] Different Towers
  - [ ] Projectile Tower (arrow, magic ball, single target)
  - [ ] Flame Tower (Short range area)
  - [ ] Melee Tower (v. short range, high damage)
  - [x] Fireball Tower (medium range, area of attack)
- [ ] Basic tower level up system (more damage..)
- [ ] Spells
  - [ ] Chain Lightning
  - [ ] Slow
  - [ ] Wall
- [ ] Different Maps
- [x] Different Monsters
    - [x] Ninja
- [x] Monsters Drop Gold Piles which need to be collected with mouse

## Backend
- [x] Repo: Basic Directory Structure

## Graphics, Sauce, QoL
- [ ] Monster "Bobbing" animation
- [ ] Monster loot drop animation (arc from monster to loot landing point)
- [ ] Monster Death Animation + Gibs/Blood
- [ ] XP Particles
- [ ] Fix layers/z index for towers/monters/labels/etc
- [ ] Trail Art
- [ ] Grass Art
- [ ] Tower Level Up Visual Effect
- [ ] Tower DPS Meters (think WoW raid to see all tower DPS)
- [x] Basic Sound Effects
    - [x] Monster Death
        - [x] LollyGagger
        - [x] Ninja
    - [x] Refunded Tower
    - [x] Purchased Tower
    - [x] Placed Tower
    - [x] Town Celebration
    - [x] Fireball Shoot
    - [x] Fireball Explosion
    - [x] Beam Fire
    - [x] Tower Level Up
    - [x] Round Start
    - [x] Collect Coins
- [x] Basic Music
- [x] Towers only show range on mouse over and placement

## Basic Gameplay
- [x] Monsters that attack town shouldn't "die"
- [x] Ability to trigger next wave when victorious
- [x] Cancel tower placement
- [x] Restrict tower placement
  - [x] Not on path
  - [x] Not on other towers
  - [x] Not outside map
- [x] Monsters give money
- [x] Win State
- [x] Ability to place towers with mouse
- [x] Fail state
