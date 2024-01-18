import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:super_mario/button.dart';
import 'package:super_mario/jumpingmario.dart';
import 'package:super_mario/mario.dart';
import 'package:super_mario/money.dart';
import 'package:super_mario/shrooms.dart';
import 'package:flame_audio/flame_audio.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
  
}

class _HomePageState extends State<HomePage> {
  static double marioX = 0;
  static double marioY = 1;
  double marioSize = 50;
  double shroomX = 0.5;
  double shroomY = 1;
  double time = 0;
  double height = 0;
  double initialHeight = marioY;
  String direction = "right";
  bool midrun = false;
  bool midjump = false;
  var gameFont = GoogleFonts.pressStart2p(
      textStyle: TextStyle(color: Colors.white, fontSize: 20));
  static double blockX = -0.3;
  static double blockY = 0.3;
  double moneyX = blockX;
  double moneyY = blockY;
  int money = 0;


  void startBgmMusic() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('mario.mp3');
  }

  void checkIfAteShrooms() {
    if ((marioX - shroomX).abs() < 0.05 && (marioY - shroomY).abs() < 0.05) {
      setState(() {
        shroomX = 2;
        marioSize = 100;
      });
    }
  }

  void releaseMoney() {
    money++;
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        moneyY -= 0.1;
      });
      if (moneyY < -1) {
        timer.cancel();
        moneyY = blockY;
      }
    });
  }

  void fall() {
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        marioY += 0.05;
      });
      if (marioY > 1) {
        marioY = 1;
        timer.cancel();
        midjump = false;
      }
    });
  }

  void preJump() {
    time = 0;
    initialHeight = marioY;
  }

  void jump() {
    if (midjump == false) {
      midjump = true;
      preJump();
      Timer.periodic(Duration(milliseconds: 30), (timer) {
        time += 0.01;
        height = -4.9 * time * time + 5 * time;

        if (initialHeight - height > 1) {
          midjump = false;
          setState(() {
            marioY = 1;
          });
          timer.cancel();
        } else {
          setState(() {
            marioY = initialHeight - height;
          });
        }
      });
    }
  }

  void moveRight() {
    direction = "right";
    checkIfAteShrooms();
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      checkIfAteShrooms();
      if (MyButton().userIsHoldingButton() == true && (marioX + 0.2) < 1) {
        setState(() {
          marioX += 0.02;
          midrun = !midrun;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void moveLeft() {
    direction = "left";
    checkIfAteShrooms();
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      checkIfAteShrooms();
      if (MyButton().userIsHoldingButton() == true && (marioY - 0.2) > -1) {
        setState(() {
          marioX -= 0.02;
          midrun = !midrun;
        });
      } else {
        timer.cancel();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Text("MARIO"),
                Container(
                  color: Colors.blue,
                  child: AnimatedContainer(
                    alignment: Alignment(marioX, marioY),
                    duration: Duration(milliseconds: 0),
                    child: midjump
                        ? JumpingMario(
                            direction: direction,
                            size: marioSize,
                          )
                        : MyMario(
                            direction: direction,
                            midrun: midrun,
                            size: marioSize,
                            
                          ),
                  ),
                ),
                Container(
                  alignment: Alignment(moneyX, moneyY),
                  child: MyMoney(),
                ),
                Container(
                  alignment: Alignment(shroomX, shroomY),
                  child: MyShroom(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: 10),
                          Text("MARIO", style: gameFont),
                          SizedBox(height: 10),
                          Text("0000", style: gameFont)
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 10),
                          Text("WORLD", style: gameFont),
                          SizedBox(height: 10),
                          Text("1-1", style: gameFont)
                        ],
                      ),
                      Column(
                        children: [
                          SizedBox(height: 10),
                          Text("TIME", style: gameFont),
                          SizedBox(height: 10),
                          Text("9999", style: gameFont)
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.brown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    function: moveLeft,
                  ),
                  MyButton(
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                    function: jump,
                  ),
                  MyButton(
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    function: moveRight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
