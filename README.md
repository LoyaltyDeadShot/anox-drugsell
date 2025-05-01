![picture2](https://github.com/user-attachments/assets/3a92e7a0-ba96-44b0-9299-e12b1611bf58)


# ✨ Overview

anox-drugsell is a zone-based drug system with dynamic prices and a reputation system.  
Sell more to build reputation (rep) for each drug, increasing your chances of successful NPC deals.  
Set your own prices — but if your rep is low and your price is too high, NPCs might reject you or even alert the police.

---

## ✨ Features

### 📡 Built-in Dispatch Alert System
- Uses `ox_lib` for dispatch.
- Police can be alerted based on player’s price and rep.
- Base alert chance is 10% (fully configurable).

### 🌍 Zone-Based Selling System
- Prices vary by zone — some give higher payouts.
- Uses a multiplier system (easily configurable).
- Option to enable/disable zone-based pricing.

### 📊 Detailed Sell Feedback (Optional)
- Players can view dispatch chance, success chance, and zone info.
- Can be disabled for a cleaner experience or more serious RP.

### 🚫 Blacklisted Jobs Restriction
- Certain jobs (e.g., police) can be blocked from selling drugs.

### 💰 Custom Drug Pricing System
- Players set their own selling price.
- Each drug has a configurable min/max price.
- Option to receive either dirty money or clean cash.

### 📈 Drug Reputation System
- Gain rep for each specific drug you sell.
- More rep = better chances of NPCs buying.
- Max rep per drug is 100 (configurable).
- Failed deals reduce rep — price smart!
- Rep is saved in the database for a smooth experience.

### ➕ Add Unlimited Drugs
- Easily add any number of drugs in the config file.

### 🧠 NPC Behavior
- NPCs walk up and wait a set amount of time (configurable) during `/drugsell`.
- Difficulty and patience levels can be adjusted.
- You can choose which drug to sell in the Drug Selling Menu.

### 🔧 Framework Compatibility
- Fully tested with **ESX**, **QBCore**, and **Qbox**.
- Localization support through `ox_lib`.

---

## ✨ Requirements

- **One of the following frameworks:**
  - ESX  
  - QBCore  
  - Qbox

- **One of the following target systems:**
  - ox_target  
  - qb-target

- **Must-have dependencies:**
  - ox_lib  
  - oxmysql

---

### 💬 Support & Preview
- Full preview and support available.
- Tested and optimized for smooth server performance.

---

