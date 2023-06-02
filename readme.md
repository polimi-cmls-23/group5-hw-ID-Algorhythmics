# YASC
The goal of the project is to to develop an interactive recorder performance tool, incorporating
Joy-Con controllers via a web interface for gesture-based inputs and SuperCollider for sound
synthesis.
<div>
<img style="width: 500px" src="./readme-image/YASC.jpg">
<div>

## Requirements
+ node.js>=v16
+ SuperCollider software

## Dependency Installation

```bash
cd /server
npm install
```
## Connect Joy-Con controllers
Connect your Joy-Con controllers to PC via Bluetooth, click the button below until your PC find and connect it.
<div>
<img width="250px" src="./readme-image/bluetooth.png">
<div>

## Introduction of Joy-Con controllers
The Joy-Con controllers consist of two individual units, each containing an analog stick and an array of buttons. In the project, the left controller are used to control the parameters in super collider and the right one is responsible to play notes.
<div>
<img width="400px" src="./readme-image/joy-con-map.png">
<div>

## Run the website and SuperCollider
1. Run server first.
```bash
node /server/index.js
```
2. Open the address shown in console. http://127.0.0.1:8081/
3. Open the files in /supercollider in SuperCollider and run relative codes.
4. Follow the instructions on website and enjoy.

## Overall Structure
The system tracks interaction with Joy-Con controllers and use them as
input. The web system acts as the center interface, providing users with an intuitive and interactive
to set up and customize their performance experience. SuperCollider serves as the sound synthesis
engine, generating the sounds according to the commands from web system via the Open Sound
Control (OSC) protocol. Finally, the sound can be captured by web system to show the visual effect.
<div>
<img width="600px" src="./readme-image/overall.png">
<div>

## Website Introduction
+ Welcome to our home page! On this page, you'll find three links to different functions.
+ Additionally, a special feature linked to the logo, <b>clicking on the logo</b> allows you to connect your controllers to the web system.
+ Or you can connect via <b>game-pad icon</b> on the top-left in different function pages.
<div>
<img width="500px" src="./readme-image/home.png">
<div>

+ The hotkey page: it serves as an interface for users to personalize their recorder experience. Through this page, users can customize their Joy-Con controller buttons to map to different recorder sounds and operations.
+ In particular, the left controller is responsible for adjusting params of recorder in SuperCollider. And the right controller is working for playing notes. 
+ Additionally, every motion of the Joy-Con controller can be captured and be shown in the middle of page. In this way, you can test the working condition of your controllers. 
<div>
<img width="500px" src="./readme-image/hotkey2.png">
<div>

+ The game page: it serves as an interactive training tool designed to <b>help users
   familiarize themselves with their custom hotkeys.</b> The key point in our implementation is that
   the jumping action is triggered only through the correct Joy-Con button that the user has
   previously mapped in the Hotkey Page. Please note that as the game progresses, the speed increases, making it more challenging.
<div>
<img width="500px" src="./readme-image/dino-instruction.png">
<div>

<div>
<img width="500px" src="./readme-image/dino-2.png">
<div>

+ The Spectrum Page: it provides an immersive audio-visual experience by representing sounds as visual spectra.
+ Following the instructions, click the button and share the entire screen and system audio.
+ Additionally, we prepare a short mario audio for beginners to follow.
<div>
<img width="500px" src="./readme-image/stft-instruction.png">
<div>
<div>
<img width="500px" src="./readme-image/stft.png">
<div>

## SuperCollider introduction
+ The recorder sound is handled by SuperCollider, offering a couple of params parameters for customization.
<div>
<img width="500px" src="./readme-image/sc.png">
<div>

## Group: Algorhythmics
+ Alice Sironi
+ Cecilia Raho
+ Stefano Ravasi
+ Yan Zhuang
