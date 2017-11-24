import processing.pdf.*;
import controlP5.*;
import java.util.List;

int agentCount = 500;
float minInitRadius = 100;
float maxInitRadius = 200;
float attractorPerc = 0.08;
float separation = 55;
float alignment = 12;
float cohesion = 7;
float attraction = 40;
int backgroundColorR = 255;
int backgroundColorG = 255;
int backgroundColorB = 255;
int agentColorR = 0;
int agentColorG = 0;
int agentColorB = 0;
int agentColorA = 255;
float agentDrawSize = 5;
int attractorColorR = 255;
int attractorColorG = 0;
int attractorColorB = 0;
int attractorColorA = 255;
float attractorDrawSize = 5;
int trailColorR = 120;
int trailColorG = 120;
int trailColorB = 120;
int trailColorAlpha = 255;
float trailWeight = 1;
int trailSize = 1000;
SwarmBoundMode boundMode = SwarmBoundMode.WRAP;
boolean isUpdatingSwarm = true;
boolean isDrawingAgents = true;
boolean isDrawingTrails = true;
boolean isRefreshingBackground = true;

void setup() {
    size(800, 800, P2D);
    render = new Render(this, sketchPath() + java.io.File.separator + "_ Exports");
    drawMargin = 40;
    initSwarm();
    initControlP5();
    background(backgroundColorR, backgroundColorG, backgroundColorB);
}

void draw() {
    if (isRefreshingBackground) {
        background(backgroundColorR, backgroundColorG, backgroundColorB);
    }
    if (isUpdatingSwarm) {
        swarm.update();
    }
    if (isDrawingTrails) {
        swarm.drawTrails();
    }
    if (isDrawingAgents) {
        swarm.drawAgents();
    }
    drawFrame();
    if (!render.isRendering()) {
        if (cp5.isVisible()) {
            noStroke();
            fill(cp5BarColor);
            rect(0, 0, cp5BarWidth, height);
            cp5.draw();
        }
    }
}

void drawFrame() {
    noStroke();
    fill(232);
    beginShape();
    // Exterior part of shape, clockwise winding
    vertex(0, 0);
    vertex(width, 0);
    vertex(width, height);
    vertex(0, height);
    // Interior part of shape, counter-clockwise winding
    beginContour();
    vertex(drawMargin, drawMargin);
    vertex(drawMargin, height-drawMargin);
    vertex(width-drawMargin, height-drawMargin);
    vertex(width-drawMargin, drawMargin);
    endContour();
    endShape(CLOSE);
}

void initSwarm() {
    int c1 = int((1 - attractorPerc) * agentCount);
    int c2 = agentCount - c1;
    float x = (width-2*drawMargin)/2.0+drawMargin;
    float y = (height-2*drawMargin)/2.0+drawMargin;
    float z = 0;
    swarm = new Swarm();
    swarm.setBoundMode(boundMode);
    swarm.setBounds(drawMargin, drawMargin, 0, width-drawMargin, height-drawMargin, 0);
    swarm.constrainZ(0);
    swarm.add(c1, x, y, z, minInitRadius, maxInitRadius);
    swarm.addAgentAttractor(c2, x, y, z, minInitRadius, maxInitRadius);
}

void keyPressed() {
    if (key == 'h') {
        if (cp5.isVisible()) {
            cp5.hide();
        } else {
            cp5.show();
        }
    } else if (key == 's') {
        render.renderPdfAndJpg();
    } else if (key == ' ') {
        isUpdatingSwarm = !isUpdatingSwarm;
    } else if (key == 'r') {
        initSwarm();
    } else if (key == 'b') {
        background(backgroundColorR, backgroundColorG, backgroundColorB);
    }
}


int cp5BarWidth;
int cp5BarColor;
int drawMargin;
int swarmBoundModeSelector;
Swarm swarm;
ControlP5 cp5;
Render render;
