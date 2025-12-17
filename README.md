# 🎮 Roku GameDev Boilerplate – 2D Platformer

A **Prince of Persia–inspired 2D platformer prototype** built using **classic BrightScript (`roScreen`)** for Roku devices.

This project demonstrates real **game-engine fundamentals** on constrained hardware:
- Time-based input handling (no key-up events)
- State-driven animation (idle / walk / jump)
- Physics with acceleration, friction, gravity
- Jump mechanics with ground detection
- Screen boundary enforcement
- Sprite flipping via transform scaling

---

## 🕹️ Controls

| Button | Action |
|------|-------|
| ⬅ Left | Move left |
| ➡ Right | Move right |
| ⬆ Up | Jump |
| Hold ⬅ / ➡ | Continuous movement |
| Release ⬅ / ➡ | Return to idle |
| Back | Exit app |

---

## ⚙️ Core Systems

### Input System (Prince of Persia Style)
- Uses **time-based intent** instead of key-up events
- Compatible with `roUniversalControlEvent`
- Smooth transitions between movement states

### Physics Engine
- Horizontal acceleration & friction
- Vertical gravity & jump impulse
- Ground collision with clean landing

### Animation Engine
- Frame-based sprite animation
- State machine: `idle`, `walk`, `jump`
- Animation resets on state change
- One draw call per frame

### Rendering
- Uses `DrawTransformedObject`
- Horizontal sprite flipping via `scaleX`
- Double-buffered rendering for smooth animation

---

## 🧠 Design Philosophy

This project intentionally avoids SceneGraph to:
- Demonstrate **low-level engine control**
- Mirror classic console-era game architecture
- Highlight fundamentals over UI abstractions

The architecture closely follows how **Prince of Persia (1989)** handled:
- Input polling
- Movement physics
- Animation timing
- State transitions

---

## 🚀 Future Enhancements

- Turn-around delay & skid animation
- Coyote-time jumping
- Ledge detection
- Collision boxes
- Modular PlayerController
- Enemy AI & patrol logic

---

## 📺 Target Platform

- Roku TV / Roku OS
- Classic BrightScript (`roScreen`)
- 1280×720 resolution

---

## 🧑‍💻 Author

Built as part of a **Roku game development learning series**, focusing on:
- Engine design
- Animation systems
- Console-style input handling

---

## 📜 License

Educational / Prototype use.
