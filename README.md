# Node-RED-Project

A Data Logging / Plotting System based on Node-RED

INTERNET OF THINGS - PROJECT (GRADE: 30 CUM LAUDE) - POLITECNICO DI MILANO

I was required to develop an ad-hoc system for managing data coming from a Wireless Sensor Network, exploiting the Node-RED tool.

Technologies used: nesC,TinyOS, Cooja Simulator (on Ubuntu 12.04), JavaScript, NODE-RED, Google Chart API

Technologies studied (but not specifically used in the project): Python, TOSSIM, Node.js, WebSockets, Plotly

# PROJECT SETUP:

1- Open a terminal and run:

sudo /home/user/node-v0.10.36-linux-x86/bin/npm install -g node-red-contrib-googlechart

2- Open another terminal and run: node-red; then open Cooja.

3- Go to http://localhost:1880/# , and Import the content of "node-red-source" in the clipboard to set up the flows in the workspace.

4- Double-click on BOTH email nodes and fill the fields:

    To: noderedproject@gmail.com 
    Username: noderedproject@gmail.com 
    Password: project3

Then click Deploy.

4- In Cooja go to Open Simulation --> "node-red-project.csc". Everything is already set up, all you need to do is to press Start.

5- Go to www.gmail.com and login with: 

    Username: noderedproject@gmail.com 
    Password: project3

6- WAIT for a message to arrive on the Node-RED debug output console, then open two new tabs and go to:

    http://localhost:1880/temperature 
    http://localhost:1880/humidity
 
Additional notes: Files will be written to the directory $HOME  
              If you want to start over the simulation, delete all the created files and close the terminal in which you started node-red and restart it 
              (refreshing the webpages is not enough).



