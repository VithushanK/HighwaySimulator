int laneLength = 6;
int cars = 100;
int n = 50;
int m = 51;
int framerate = 10;
int emptySpace = 0;
int a = 0;

color[][] cells2before = new color[n][m];
color[][] cellsbefore = new color[n][m];
color[][] cells = new color[n][m];
color[][] cellsnext = new color[n][m];
int[] LeftorRight = {-1, 1};

int width = 500;
int height = 800;
int cellSize = width/n;

color black = color(0);
color purple = color(161, 0, 186);
color orange = color(255, 170, 0);
color green = color(0, 255, 0);

color blue = color(0, 0, 255);
color red = color(255, 0, 0);

color white = color(255);
color grey = color(173);

// colors of cars
color[] colors = {blue, red, purple, black};

boolean fast = false;
boolean crash = false;
boolean slow = false;


void setup() {                                      
  size (500, 750);
  frameRate(framerate);
  stroke(255);
  firstgen();
}



void firstgen() {                                    //gives cells[][] the first values to create the highway
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      if (i % laneLength == 0)
        cells[i][j] = white;
      else
        cells[i][j] = grey;
    }
  }
}

void nextgen() {

  for (int i = 0; i < n; i++) {                    // Copying information over to new generation to change cellsnext easier


    for (int j = 0; j < m; j++) {

      cellsnext[i][j] = cells[i][j];
    }
  } 


  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {

      if (frameCount % 5 == round(random(0, 2)))                   //random chance of spawning random colour car every 5 frames (spawns at bottom of screen)
        if (i % laneLength == 3 && j == m-1)
          cellsnext[i][j] = colors[round(random(0, 3))];



      if (cells[i][j] != grey && cells[i][j] != white) {                 // if cell is coloured
        
                                             

            for (int o = -3; o <= 3; o++) {                            // creating 7x7 window around each coloured cell
              for (int p = -3; p <= 3; p++) {
              
                try {
                  if (cells[i+o][j+p] != grey && cells[i+o][j+p] != white  && (pow(o, 2) + pow(p, 2)) != 0) {        //finds coloured cell in 7x7 window that's not the original coloured cell
                    if (pow(o, 2) + pow(p, 2) == 1 || pow(o, 2) + pow(p, 2) == 2) {                                  //finds if new coloured cell is touching the original cell
                      cellsnext[i][j] = cells[i][j];                                                                 //results in crash, freezes both cell in place
                      crash = true;
                    }

                    else if ((p >= 0 && o < 0 && cells[i+o][j+p] == cellsbefore[(i+o)-1][(j+p)+1]) || (p >= 0 && o > 0 && cells[i+o][j+p] == cellsbefore[(i+o)+1][(j+p)+1] && i % laneLength == 3)) { //if car is approaching from behind into original cell's lane
                      cellsnext[i][j-2] = cells[i][j];                                                                                                                                                //makes car faster
                      cellsnext[i][j] = grey;
                      fast = true;
                      
                    
                    }
                    else if ((p < 0 && o < 0 && cells[i+o][j+p] == cellsbefore[(i+o)-1][(j+p)+1]) || (p < 0 && o > 0 && cells[i+o][j+p] == cellsbefore[(i+o)+1][(j+p)+1] && i % laneLength == 3)) {  //if car is approaching from ahead of original cell
                      cellsnext[i][j] = cells[i][j];                                                                                                                                               //makes car slower
                      cellsnext[i][j] = grey;
                      slow = true;
                      
                    
                    }
                    
                  }
                }

                catch (Exception e) {                                              //if car went out of index, replace with grey or white tile depending on location
                  if (i % laneLength == 0)
                    cellsnext[i][j] = white; 
                  else
                    cellsnext[i][j] = grey;
                }
               
              }
            }   
           
           if (i % laneLength == 3) {                                               //if car is in middle of lane
         
            if (round(random(1,100)) == 3 && crash == false) {                      //if random chance and the car isn't fast
              try{
                cellsnext[i+LeftorRight[round(random(0, 1))]][j-1] = cells[i][j];    //randomly turn left or right one tile
                cellsnext[i][j] = grey;
              }
              catch (Exception e) {}  
              }
          
           else if (fast == false || slow == false || crash == false) {                          //if car isn't fast, slow or crashed
                try {
                cellsnext[i][j-1] = cells[i][j];              //moves car forward 1
                cellsnext[i][j] = grey;
                }
                catch (Exception e) {}
                
              }
             
          }




 else {
          try {                                                  
            if (cells[i][j] == cellsbefore[i-1][j+1]) {          //if a car came from the left
              cellsnext[i+1][j-1] = cells[i][j];                 //move car right
              if (i % laneLength == 0)                           
                cellsnext[i][j] = white;
              else
                cellsnext[i][j] = grey;
            } 
            else if (cells[i][j] == cellsbefore[i-1][j+1]) {    //if a car came from the right
              cellsnext[i-1][j-1] = cells[i][j];                //move car left
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
       slow = false;                                          //sets conditions to false at the end of a cycle
       fast = false;
       crash = false;
      }
     }
    }
    
  }



void draw() {                                                //draws grid base on colours from cells[][] and cellSize
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      float x = i*cellSize;
      float y = j*cellSize;
      fill(cells[i][j]);        
      rect(x, y, cellSize, cellSize);
    }
  }
  nextgen();                                                //nextgen changes values of cellsNext which changes cells
  copyNextGenerationToCurrentGeneration();                  
}

void copyNextGenerationToCurrentGeneration() {               //assigns cellsbefore and cells values for each new generation
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < m; j++) {
      cellsbefore[i][j] = cells[i][j];
      cells[i][j] = cellsnext[i][j];
    }
  }
}   
