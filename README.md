![picture2](https://github.com/user-attachments/assets/3a92e7a0-ba96-44b0-9299-e12b1611bf58)


# ✨ Overview

anox-drugsell is a zone-based drug system with dynamic prices and a reputation system.  
Sell more to build reputation (rep) for each drug, increasing your chances of successful NPC deals.  
Set your own prices — but if your rep is low and your price is too high, NPCs might reject you or even alert the police.

- [Preview](https://www.youtube.com/watch?v=iX4n9J9sfHQ)
- [Docs](https://anoxstudios.gitbook.io/anoxstudios/free-scripts/anox-blackmarket)
- [Discord](https://discord.gg/gbJ5SyBJBv)
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
![SOLD DRUG](https://github.com/user-attachments/assets/c9e3c64e-c2b0-499c-8932-0dee396b9d35)
![SETTING_CUSTOM_PRICE](https://github.com/user-attachments/assets/136e1edf-300a-453e-b476-9d281f4795c3)
![SELLING_DRUG](https://github.com/user-attachments/assets/d2adc756-8711-4d4e-ad30-985b3fd04480)
![POLICE_DISPATCH](https://github.com/user-attachments/assets/cb7b7b86-1f14-4ec3-bc7a-426b9aa377af)
![INFO_BOX_FOR_DRUGS](https://github.com/user-attachments/assets/902ca4ac-6a54-499c-98bc-3e35c439d5e3)
![DRUG_SELLING_MENU](https://github.com/user-attachments/assets/549c9ecb-8abd-44bb-afb7-054335b5c4cc)
![BUYER_REFUSED_DEAL](https://github.com/user-attachments/assets/a0b13639-225a-40b3-850c-6adf7224ce36)
![AFTER_USING_CMD_DRUGSELL](https://github.com/user-attachments/assets/5684be98-8f97-4eca-899d-a8036188c899)

