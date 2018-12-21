// Pre-Release
// v0.1
// Creative Commons
// Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)
// https://creativecommons.org/licenses/by-sa/4.0/
// Michael Zoellner, 2018


import geomerative.*;
import processing.net.*;
import java.net.*;
import javax.swing.JOptionPane;

RShape grp;
boolean lines;
boolean rawpoints;
boolean connected;
boolean hide = false;
float resolution = 5;

String lineus_adress = "lineus.local"; //"192.168.4.1";

LineUs myLineUs;

// App Drawing Area
// x: 650 - 1775
// y: 1000 - -1000
// z: 0 - 1000
// 100 units = 5mm

int line_min_x = 650;
int line_max_x = 1775;
int line_min_y = -1000;
int line_max_y = 1000;

int lw = 1775 - 650;
int lh = 2000;

void setup() {
  size(lw/2, lh/2);
  smooth();

  RG.init(this);
  grp = RG.loadShape("venn_.svg");
}

void draw() {
  background(255);

  if (lines == true)
  {
    RG.setPolygonizer(RG.UNIFORMLENGTH);

    if (mousePressed)
      resolution = map(mouseY, 0, height, 3, 200);

    if (rawpoints == false)
      RG.setPolygonizerLength(resolution);
    RPoint[][] points = grp.getPointsInPaths();

    // If there are any points
    if (points != null) {
      for (int j=0; j<points.length; j++)
      {
        noFill();
        stroke(100);
        beginShape();
        for (int i=0; i<points[j].length; i++) {
          vertex(points[j][i].x, points[j][i].y);
        }
        endShape(CLOSE);

        noFill();
        stroke(0);
        for (int i=0; i<points[j].length; i++) {
          ellipse(points[j][i].x, points[j][i].y, 5, 5);
        }
      }
    }
  } else {
    grp.draw();
  }


  // interface
  if (hide == false)
  {
    fill(0, 150);
    text("Line-Us SVG Plotter", 20, 20);
    text("---------------------", 20, 40);
    text("address:\t" + lineus_adress + " (a)", 20, 60);
    text("open SVG:\to", 20, 80);
    text("zoom:\t+/-", 20, 100);
    text("move:\tarrow keys <>", 20, 120);
    text("rotate:\tr", 20, 140);
    text("lines:\tl", 20, 160);
    text("resolution:\tpress mouse / move", 20, 180);
    if (connected == true)
      fill(50, 255, 50);
    text("connect Line-Us:\tc", 20, 200);
    fill(0, 150);
    text("plot:\tp", 20, 220);
    text("hide this:\th", 20, 240);
  }
}

void plot()
{
  println("plotting...");

  myLineUs = new LineUs(this, lineus_adress);

  if (rawpoints == false)
    RG.setPolygonizerLength(resolution);
  RPoint[][] points = grp.getPointsInPaths();

  delay(1000);

  // x: 650 - 1775
  // y: 1000 - -1000
  // If there are any points
  int x = 700;
  int y = 0;
  int last_x = 700;
  int last_y = 0;

  if (points != null) {
    for (int j=0; j<points.length; j++)
    {
      for (int i=0; i<points[j].length; i++) {
        x = int( map(points[j][i].x, 0, width, 650, 1775) );
        y = int( map(points[j][i].y, 0, height, 1000, -1000) );

        // safety check. there could be svg elements outsside the drawing area crashing the robot
        if (x >= line_min_x && x<= line_max_x && y >= line_min_y && y<= line_max_y)
        {
          myLineUs.g01(x, y, 0);
          last_x = x;
          last_y = y;
          delay(100);
        }
      }
      myLineUs.g01(last_x, last_y, 1000);
      delay(100);
    }
  }


  //myLineUs.g01(900, 300, 0);
  //myLineUs.g01(900, -300, 0);
  //myLineUs.g01(900, -300, 1000);
}

void keyPressed()
{
  int t = 2;

  if (key == 'o')
  {
    selectInput("Select an SVG file:", "svgSelected");
  } 
  else if (key == 'a')
  {
      lineus_adress = JOptionPane.showInputDialog("LineUs Address (lineus.local, 192.168.4.1, ...):");
  }
  else if (key == 'h')
  {
    hide = !hide;
  } else if (key == 'p')
  {
    lines = true;
    plot();
  } else if (key == 'r')
  {
    grp.rotate(PI/2.0, grp.getCenter());
  } else if (key == 'w')
  {
    rawpoints = !rawpoints;
  }
  // connect line-us
  else if (key == 'c')
  {
    try {
      myLineUs = new LineUs(this, lineus_adress);
      connected = true;
    }
    catch (Exception e) {
      connected = false;
      println("connection error");
    }
  } else if (keyCode == LEFT)
  {
    grp.translate(-t, 0);
  } else if (keyCode == RIGHT)
  {
    grp.translate(t*2, 0);
  } else if (keyCode == UP)
  {
    grp.translate(0, -t);
  } else if (keyCode == DOWN)
  {
    grp.translate(0, t);
  } else if (key == '-')
  {
    grp.scale(0.95);
  } else if (key == '+')
  {
    grp.scale(1.05);
  } else if (key == 'l')
  {
    if (lines == true)
      lines = false;
    else
      lines = true;
  }

  grp.draw();
}

void svgSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    grp = RG.loadShape(selection.getAbsolutePath());
    println(grp.getWidth());
  }
}

