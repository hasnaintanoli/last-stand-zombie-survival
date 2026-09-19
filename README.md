# 🧟 Last Stand: Zombie Survival

A fast-paced, action-packed **2D Top-Down Zombie Survival Game** built with **Flutter**, **Flame Engine**, and **Material 3 UI**. 

Designed for **Android Mobile & Tablet** with full support for **Windows Desktop**.

---

## 🌟 Key Features

* **Infinite Open World**: Dynamic procedural chunk loading that renders seamless infinite terrain with realistic grid obstacles and boundaries.
* **Diverse Zombie Archetypes**:
  * 🧟 **Normal Zombie**: Balanced speed and dynamic tracking.
  * ⚡ **Fast Runner**: High speed, low health flankers.
  * 🛡️ **Tank Zombie**: Giant size, massive health, devastating damage.
  * ☣️ **Spitter Zombie**: Ranged combatant shooting toxic acid projectiles.
* **Arsenal of Weapons**:
  * 🔫 **Pistol**: High precision starter weapon with infinite reserve ammo.
  * 💥 **Shotgun**: Wide multi-pellet spread for close-range crowd control.
  * 🔫 **Assault Rifle**: High rate-of-fire automatic rifle.
* **RPG XP & Progression System**:
  * Earn XP points by taking down undead hordes.
  * Level up to pick powerful instant upgrades: **Max Health Boost**, **Damage Boost**, **Movement Speed**, **Fire Rate**, and **Health Restore**.
* **Audio & Visual Immersion**:
  * Custom synthesized sound effects (unique gunshots, reloads, zombie growls, player damage).
  * Dark synth ambient background music track.
  * Particle effects for muzzle flashes, blood splatters, toxic spit, and health/ammo pickups.
* **Modern UI & Controls**:
  * Smooth dual touch joysticks (Move & Aim/Shoot) for mobile devices.
  * Full Keyboard + Mouse support for Desktop (WASD to move, Mouse Cursor to aim/shoot).
  * Material 3 Pause Menu, Settings, Audio Toggles, and High Score persistence.

---

## 🎮 Controls

### Mobile (Touch)
* **Left Virtual Joystick**: Move character.
* **Right Virtual Joystick**: Aim & Fire actively in target direction.
* **HUD Buttons**: Quick weapon switching (Pistol / Shotgun / Rifle), Manual Reload, and Pause.

### Desktop (Windows / Web / Linux / macOS)
* **W A S D**: Move Up, Left, Down, Right.
* **Mouse Cursor**: Aim target location.
* **Left Mouse Button / Spacebar**: Fire active weapon.
* **1 / 2 / 3**: Switch active weapon (1: Pistol, 2: Shotgun, 3: Rifle).
* **R**: Reload active weapon.
* **P / ESC**: Pause game.

---

## 🛠️ Built With

* **[Flutter](https://flutter.dev/)** - Cross-platform UI toolkit.
* **[Flame Engine (v1.27.0)](https://flame-engine.org/)** - Modular 2D game engine for Flutter.
* **[Flutter Sound / Audioplayers](https://pub.dev/packages/audioplayers)** - High-performance audio playback system.
* **[Shared Preferences](https://pub.dev/packages/shared_preferences)** - Local high score and settings storage.

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK `^3.5.0` or higher
* Dart SDK `^3.5.0` or higher

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/hasnaintanoli/last-stand-zombie-survival.git
   cd last-stand-zombie-survival
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the game**:
   * For **Windows Desktop**:
     ```bash
     flutter run -d windows
     ```
   * For **Android Mobile**:
     ```bash
     flutter run -d android
     ```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
