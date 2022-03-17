int laneLength = 6;
int cars = 100;
int n = 50;
int m = 50;
int framerate = 10;
int emptySpace = 0;
int a = 0;
int o = 0;
int y = 0;
int l = 0;
int real_x = 0;
int y_maker = 2;
int o_maker = 0;

color[][] cells2before = new color[n][m];
color[][] cellsbefore = new color[n][m];
color[][] cells = new color[n][m];
color[][] cellsnext = new color[n][m];
int[] Direction = {-1, 1}; //-1 for left, 1 for right

int width = 500;
int height = 800;
int cellSize = width / n;

color black = color(0);
color purple = color(161, 0, 186);
color orange = color(255, 170, 0);
color green = color(0, 255, 0);

color blue = color(0, 0, 255);
color red = color(255, 0, 0);

color white = color(255);
color grey = color(173);

color[] colors = {blue, red, purple, black };

int REGULAR = 0;
int CRASH = 1;
int FAST = 2;
int STOPPED = 3;

int state = REGULAR;

boolean right_turning_capability = false;
boolean left_turning_capability = false;

int crash_counter = 0;

void setup() {
  size(500, 750);
  frameRate(framerate);
  stroke(255);
  firstgen();
}

void firstgen() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      if (i % laneLength == 0) {
        cells[i][j] = white;
        cellsnext[i][j] = white;
      }
      else {
        cells[i][j] = grey;
        cellsnext[i][j] = grey;
      }
    }
  }
}

void nextgen() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {

      if (frameCount % 5 == round(random(0, 2))) {
        if (i % laneLength == 3 && j == m-1 && cells[i][m-2] == grey) {
          cellsnext[i][j] = colors[round(random(0, 3))];
        }
      }
      
      if (cells[i][j] != grey && cells[i][j] != white) {
        o_maker = 0;
        for (int r = 0; r <= 6; r++) {
          if (r % 2 == 0) {
            o = r/2;
          }
          else {
            o = (r * -1) + o_maker;
            o_maker++;
            }
          
          for (int p = -4; p <= 3; p++) {
            try {
              if (cells[i + o][j + p] != grey && cells[i + o][j + p] != white && (pow(o, 2) + pow(p, 2)) != 0) {
                if ((pow(o, 2) + pow(p, 2) == 1) || (pow(o, 2) + pow(p, 2) == 2)) {
                  cellsnext[i][j] = cells[i][j];
                  state = CRASH;
                } 
                else if (pow(o, 2) < 2 && p >= -4 && p <= -2 && cells[i + o][j + p] == cellsbefore[i + o][j + p]) {
                  cellsnext[i][j] = cells[i][j];
                  state = STOPPED;
                }
                //else if ((p >= 0 && o < 0 && cells[i + o][j + p] == cellsbefore[(i + o) - 1][(j + p) + 1] && state == REGULAR && i % 6 == 3) || (p >= 0 && o > 0 && cells[i + o][j + p] == cellsbefore[(i + o) + 1][(j + p) + 1]) && state == REGULAR && i % 6 == 3) {
                //  cellsnext[i][j - 2] = cells[i][j];
                //  cellsnext[i][j] = grey;
                //  state = FAST;
                //}
              }
            } 
            catch (Exception e) {                  // fix this for stutter stop
              if (i % laneLength == 0) {
                cellsnext[i][j] = white;
                }
             else {
                if (j - 2 != grey && j > 2) {
                  cellsnext[i][j] = cells[i][j];
                }
                else {
                cellsnext[i][j] = grey;
                }
              }
            }
          }
        }
    
    
     
    if (i % laneLength == 3) { //checks if coloured cell is in the middle of lane
      try {
        for (int x = -1; x > -8; x--) { //creates pattern to check if cars are in the way of changing lanes when turning left
          for (int y_m = 0; y_m < 5; y_m++) {
            y = x + y_maker;
            y_maker -= 1;
            
            if (cells[i + x][j + y] != grey && cells[i + x][j + y] != white) { //checks if there is a coloured cell in the pattern created
              if (cells[i + x][j + y] == cellsbefore[i + x][j + y]) { //checks if the coloured cell in the pattern has not moved since last generation, therefore the car is stopped or crashed
              crash_counter += 1;
              }  
            }
          }
          y_maker = 2;  //variable used to create pattern
        }
        println(crash_counter);
        if (crash_counter == 0 && cells[i - 6][j + 1] == grey && cells[i - 6][j] == grey && cells[i - 6][j - 1] == grey) {  //if there are no cars crashes nearby and the lane to the left is clear, left turning is possible
         left_turning_capability = true;
        }
      }
       catch (Exception e) {}
       crash_counter = 0; //resets crashes for right turning detection
       try {
        for (int fake_x = -1; fake_x > -8; fake_x--) { //creates pattern to check if cars are in the way of changing lanes when turning right
          real_x = fake_x * -1;  //since the y coordinates are the same as the left turning detection, same loop is used but the x coordinate will be positive rather than negative
            for (int y_m = 0; y_m < 5; y_m++) {
                y = fake_x + y_maker;
                y_maker -= 1;
                
                if (cells[i + real_x][j + y] != grey && cells[i + real_x][j + y] != white) {  //checks if coloured cell is in the pattern
                  if (cells[i + real_x][j + y] == cellsbefore[i + real_x][j + y]) {  //checks if that coloured cell is crashed or stopped
                  crash_counter += 1;
                  } 
                }
              }
        y_maker = 2; //variable to help create pattern
        }
        if (crash_counter == 0 && cells[i + 6][j + 1] == grey && cells[i + 6][j] == grey && cells[i + 6][j - 1] == grey) {  //if there are no crashes in the way and the right lane is clear, turning right is possible
         right_turning_capability = true;
        }
      }
      catch (Exception e) {}
      crash_counter = 0;  //reset crash_counter for next iteration
    }
     //println("Left = " + left_turning_capability +  " and Right = " + right_turning_capability); //test if left and right turning capability variable are working as intended
        
        
        
        if (state == REGULAR || state == STOPPED) {
          if (i % laneLength == 3) {
              if (round(random(1, 100)) == 3 && state == REGULAR || round(random(1,10)) == 2 && state == STOPPED) {
                try {
                if (i == 3 && right_turning_capability == true) {
                  cellsnext[i + Direction[1]][j - 1] = cells[i][j];
                  cellsnext[i][j] = grey;
                }
                else if (i == 45 && left_turning_capability == true) {
                  cellsnext[i + Direction[0]][j - 1] = cells[i][j];
                  cellsnext[i][j] = grey;
                }
                else if (left_turning_capability == true) {
                  cellsnext[i + Direction[0]][j - 1] = cells[i][j];
                  cellsnext[i][j] = grey;
                }
                else if (right_turning_capability == true) {
                  cellsnext[i + Direction[1]][j - 1] = cells[i][j];
                  cellsnext[i][j] = grey;
                }
                }
                catch (Exception e) {}
              }
            
            
            else if (state == REGULAR) {  
              try {
                cellsnext[i][j - 1] = cells[i][j];
                cellsnext[i][j] = grey;
              } 
                catch (Exception e) {}
              }
            }
        
        else {
          try {
            if (cells[i][j] == cellsbefore[i - 1][j + 1]) {
              cellsnext[i + 1][j - 1] = cells[i][j];
              if (i % laneLength == 0)
                cellsnext[i][j] = white;
              else
                cellsnext[i][j] = grey;
            } 
            else if (cells[i][j] == cellsbefore[i + 1][j + 1]) {
              cellsnext[i - 1][j - 1] = cells[i][j];
              if (i % laneLength == 0)
                cellsnext[i][j] = white;
              else
                cellsnext[i][j] = grey;
            }
          } 
          catch (Exception e) {
            if (i % laneLength == 0)
              cellsnext[i][j] = white;
            else
              cellsnext[i][j] = grey;
            }
          }
        }
       left_turning_capability = false;
       right_turning_capability = false;
       state = REGULAR;
      }
    }
  }
}

void draw() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      float x = i * cellSize;
      float y = j * cellSize;
      fill(cells[i][j]);
      rect(x, y, cellSize, cellSize);
    }
  }
  nextgen();
  copyNextGenerationToCurrentGeneration();
}

void copyNextGenerationToCurrentGeneration() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      cellsbefore[i][j] = cells[i][j];
      cells[i][j] = cellsnext[i][j];
    }
  }
}
