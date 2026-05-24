# 🚆 CreativeTrain

CreativeTrain is a real-life social deduction game where players interact in person while a backend system tracks the game in real time. It uses QR codes and a Spring Boot backend to handle player actions, eliminations, and game state.

The idea is inspired by games like *Mafia* and *Among Us*, but played in the real world instead of on a screen.

---

# 🎮 How it works

Each player gets a unique QR code linked to their player ID. This code is printed and attached to the player (for example on clothing).

During the game:

- Players move around and interact in real life  
- Certain roles can eliminate other players  
- Eliminations happen by scanning another player’s QR code  
- The backend checks if the action is valid  
- Player status updates immediately in the system  

Admins can monitor who is still in the game and track what’s happening in real time.

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
