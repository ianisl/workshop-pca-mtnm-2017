import processing.pdf.*;
import controlP5.*;
import java.util.List;

int drawMargin = 40;
int agentCount = 200;
int attractorCount = 5;
Swarm swarm;
float swarmUpdateStep = 0.2;
float attractorStrength = 40;
float agentAttractorMinRange = 1;
float agentAttractorMaxRange = 100;

void setup() {
    size(800, 800, P2D);
    render = new Render(this, sketchPath() + "/_ Exports");
    initSwarm();
    initGUI();
}

void draw() {
    background(232);
    swarm.update(swarmUpdateStep);
    swarm.drawAgents();
}

void initSwarm() {
    swarm = new Swarm();
    swarm.setBoundMode(SwarmBoundMode.WRAP);
    swarm.setBounds(drawMargin, drawMargin, 0, width-drawMargin, height-drawMargin, 0);
    swarm.constrainZ(0);
    swarm.add(agentCount, (width-drawMargin)/2.0, (height-drawMargin)/2, 0, 100, 200);
    swarm.addAgentAttractor(attractorCount, (width-drawMargin)/2.0, (height-drawMargin)/2, 0, attractorStrength, 100, 200);
}

void initGUI() {
    cp5 = new ControlP5(this);
    cp5.setColorBackground(color(166));
    cp5.setColorForeground(color(117));
    cp5.setColorActive(color(60));
    cp5.addSlider("kinectDepthSkip", 1, 4).setLabel("Subsampling").linebreak();
}

void keyPressed() {
    if (key == 'h') {
        if (cp5.isVisible()) {
            cp5.hide();
        } else {
            cp5.show();
        }
    } else if (key == 's') {
        println("rendering");
        render.renderPdfAndJpg();
    }
}

ControlP5 cp5;
Render render;
