# 🚆 CreativeTrain

CreativeTrain is a real-life social deduction game where players interact in person while a backend system tracks the game in real time. It uses QR codes and a Spring Boot backend to handle player actions, eliminations, and game state.

The idea is inspired by games like *Mafia* and *Among Us*, but played in the real world instead of on a screen.

---
<img width="1887" height="1018" alt="grafik" src="https://github.com/user-attachments/assets/cabb59bd-0b72-444b-b1d7-b8215ba87809" />

# 🎮 How it works

Each player gets a unique QR code linked to their player ID. This code is printed and attached to the player (for example on clothing).

During the game:

- Players move around and interact in real life  
- Certain roles can eliminate other players  
- Eliminations happen by scanning another player’s QR code  
- The backend checks if the action is valid  
- Player status updates immediately in the system  


<img width="959" height="500" alt="grafik" src="https://github.com/user-attachments/assets/076f5e0b-9af6-4be2-bf3e-582d553e9c54" />

---

# ✨ Features

## 🕵️ Gameplay
- Real-life social deduction mechanics  
- Player elimination system  
- Live updates during the game  

## 🔍 QR System
- Each player gets a unique QR code  
- Codes are linked to player IDs  
- Scanning a QR code triggers game actions  

## ⚙️ Backend
- Spring Boot REST API  
- Player and session management  
- Validation of actions  
- Tracks player state during the game  

---

# 🛠 Tech Stack

## Backend
- Java 21  
- Spring Boot 3.3.5  
- Maven  

## Frontend
- HTML  
- CSS  
- JavaScript  

## Other
- ZXing for QR code generation and scanning  
- JUnit for testing  

---

# 🚀 Getting started

## Requirements
- Java 21 or newer  
- Maven  

## Run locally

```bash
git clone https://github.com/CreativeN025/CreativeTrain.git
cd CreativeTrain
mvn spring-boot:run
````

## 📱 Gameplay flow


1. Generate QR codes for players
2. Print and assign them
3. Players join the game in real life
4. Players scan each other’s QR codes during gameplay
5. Backend validates actions
6. Player status updates automatically

## 📈 Possible improvements


- Mobile app instead of browser scanning
- Long term Login/auth system instead of session based
- Admin dashboard
- Match history and stats
- Better API documentation

## 👨‍💻 Author


CreativeN025
https://github.com/CreativeN025
