# Control Flexible Robot Arm

<p>
    <img src="https://img.shields.io/badge/ubuntu-v20.04-blue"/>
    <img src="https://img.shields.io/badge/matlab-R2020a-orange"/>
    <img src="https://img.shields.io/badge/Simulink-v10.1-orange"/>
    <img src="https://img.shields.io/badge/language-portuguese-red"/>
</p>

Project for the course "Computer Control" at Instituto Superior Técnico.

### Assignment

The work proposed here is in the spirit of Control applied to Cyber-Physical Systems: A computer is attached to a physical plant (a flexible robot arm joint) to modify its physical behavior through the interaction with the computational part (the computer algorithm).

##### 1) Model identification

A plant model that relates the motor that drives the arm with the angular position of its tip is obtained using System Identification methods and data obtained from experiments performed with the plant.

##### 2) Control

A controller is designed using the previously obtained model in order to drive position the tip of the robot joint to a desired angle. The controller is then tested on the actual plant.
