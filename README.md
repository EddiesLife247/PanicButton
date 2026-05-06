# README.md

## Panic Button Resource for QBCore Framework

This resource implements a panic button item for use in a QBCore-based FiveM server. The panic button can be used by certain gangs, jobs, or law enforcement officers (LEOs) as defined in the configuration. This README outlines the integration with Ox Inventory and other functionality.

---

### Features
- Sends alerts to:
  - Members of the same gang (if the player belongs to a permitted gang).
  - Members of the same job and LEOs (if the player is in a permitted job).
  - Only LEOs (if the player does not belong to a gang or permitted job).
- Configurable via `config.lua`.
- Integration with Ox Inventory for item usage.
- Alerts include map blips, notifications, and optional sound effects.

---

### Requirements
- **QBCore Framework**
- **Ox Inventory**
- **ps-dispatch** (Optional for dispatch alerts)
- **InteractSound** (Optional for sound alerts)

---

### Configuration

Edit the `config.lua` file:

```lua
Config.PanicButtonItem = "panic_button" -- Name of the item for the panic button
Config.LeoJobs = {"police", "sheriff", "statepolice", "fib"} -- Predefined LEO jobs
Config.PermittedGangs = {"ballas", "vagos", "families"} -- List of gangs permitted to use the panic button
Config.PermittedJobs = {"mechanic", "ems", "taxi"} -- List of jobs allowed to use the panic button
Config.AlertDuration = 60000 -- Duration for map blip (in milliseconds)
```

---

### Ox Inventory Integration

To add the panic button item to Ox Inventory, modify your Ox Inventory shared items configuration:

```lua
['panic_button'] = {
    label = "Panic Button",
    weight = 200, -- Weight of the item
    stack = false, -- Whether the item can stack
    description = "A button to alert your team in emergencies."
}
```

Add the item to your inventory database or distribute it using in-game commands.

---

### Installation

1. Place the `config.lua`, `server.lua`, and `client.lua` files in a new resource folder (e.g., `panic_button`).
2. Add the resource to your `server.cfg`:

```bash
ensure panic_button
```

3. Ensure all dependencies are installed and configured properly.

---

### Usage

- Players can use the panic button item (e.g., `/use panic_button` or via inventory UI).
- Notifications and alerts are sent based on the player’s gang or job.
- Map blips and sounds guide other players to the location of the alert.

---

### Event Details

**Server Events:**
- `panicButton:playSound`:
  - Plays a sound for players within a certain distance of the alert.

**Client Events:**
- `panicButton:alert`:
  - Displays a map blip and sends notifications to the relevant players.
- `panicButton:playClientSound`:
  - Triggers sound playback for nearby players.

---

### Support
If you encounter any issues or need assistance, feel free to reach out via the project repository or community forums.

---

Happy roleplaying!
