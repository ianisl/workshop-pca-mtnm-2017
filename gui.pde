void initControlP5() {
    cp5BarWidth = 200;
    cp5BarColor = color(20, 150);
    initSwarmBoundModeSelectorValue();
    cp5 = new ControlP5(this);
    cp5.setAutoDraw(false);
    cp5.setColorBackground(color(166));
    cp5.setColorForeground(color(100));
    cp5.setColorActive(color(60));
    cp5.addSlider("agentCount", 1, 1000).setLabel("[R] Agent Count").linebreak();
    cp5.addSlider("attractorPerc", 0.0, 1.0).setLabel("[R] Attractor %").linebreak();
    cp5.addSlider("minInitRadius", 0, swarm.getBounds()[0]/2.0).setLabel("[R] Min Init Radius").linebreak();
    cp5.addSlider("maxInitRadius", 0, swarm.getBounds()[0]/2.0).setLabel("[R] Max Init Radius").linebreak();
    cp5.addSlider("separation", 0, 100).setLabel("Separation").linebreak();
    cp5.addSlider("alignment", 0, 100).setLabel("Alignment").linebreak();
    cp5.addSlider("cohesion", 0, 100).setLabel("Cohesion").linebreak();
    cp5.addSlider("attraction", 0, 100).setLabel("Attraction").linebreak();
    cp5.addToggle("isRefreshingBackground").setLabel("Auto Clear Background").linebreak();
    cp5.addSlider("backgroundColorR", 0, 255).setLabel("Background R").linebreak();
    cp5.addSlider("backgroundColorG", 0, 255).setLabel("Background G").linebreak();
    cp5.addSlider("backgroundColorB", 0, 255).setLabel("Background B").linebreak();
    cp5.addSlider("swarmBoundModeSelector", 0, 2).linebreak();
    cp5.addToggle("isDrawingAgents").setLabel("Draw Agents").linebreak();
    cp5.addSlider("agentColorR", 0, 255).setLabel("Agent R").linebreak();
    cp5.addSlider("agentColorG", 0, 255).setLabel("Agent G").linebreak();
    cp5.addSlider("agentColorB", 0, 255).setLabel("Agent B").linebreak();
    cp5.addSlider("agentColorA", 0, 255).setLabel("Agent A").linebreak();
    cp5.addSlider("agentDrawSize", 1, 150).setLabel("Agent Size").linebreak();
    cp5.addSlider("attractorColorR", 0, 255).setLabel("Attractor R").linebreak();
    cp5.addSlider("attractorColorG", 0, 255).setLabel("Attractor G").linebreak();
    cp5.addSlider("attractorColorB", 0, 255).setLabel("Attractor B").linebreak();
    cp5.addSlider("attractorColorA", 0, 255).setLabel("Attractor A").linebreak();
    cp5.addSlider("attractorDrawSize", 1, 150).setLabel("Attractor Size").linebreak();
    cp5.addToggle("isDrawingTrails").setLabel("Draw Trails").linebreak();
    cp5.addSlider("trailColorR", 0, 255).setLabel("Trail R").linebreak();
    cp5.addSlider("trailColorG", 0, 255).setLabel("Trail G").linebreak();
    cp5.addSlider("trailColorB", 0, 255).setLabel("Trail B").linebreak();
    cp5.addSlider("trailColorAlpha", 0, 255).setLabel("Trail A").linebreak();
    cp5.addSlider("trailWeight", 1, 10).setLabel("[!] Trail Width").linebreak();
    cp5.addSlider("trailSize", 0, 1000).setLabel("Trail Length").linebreak();
    cp5.addTextlabel("label1").setText("PRESS SPACE TO TOGGLE ANIMATION").setPosition(6, 680).linebreak();
    cp5.addTextlabel("label2").setText("                B TO CLEAR BACKGROUND").setPosition(6, 697).linebreak();
    cp5.addTextlabel("label3").setText("                H TO HIDE PANEL").setPosition(6, 714).linebreak();
    cp5.addTextlabel("label4").setText("                S TO SAVE IMAGE").setPosition(6, 731).linebreak();
    cp5.addTextlabel("label5").setText("                R TO RESET").setPosition(6, 748).linebreak();
}

void controlEvent(ControlEvent event) {
    if (event.isFrom("trailSize")) {
        int i = int(event.getValue());
        trailSize = i;
        swarm.setTrailSize(i);
    } else if (event.isFrom("swarmBoundModeSelector")) {
        updateBoundMode();
        swarm.setBoundMode(boundMode);
    }
}

void initSwarmBoundModeSelectorValue() {
    switch (boundMode) {
        case NONE:
            swarmBoundModeSelector = 0;
            break;
        case CLAMP:
            swarmBoundModeSelector = 1;
            break;
        case WRAP:
            swarmBoundModeSelector = 2;
            break;
    }
}

void updateBoundMode() {
    ControllerInterface c = cp5.getController("swarmBoundModeSelector");
    switch (swarmBoundModeSelector) {
        case 0:
            boundMode = SwarmBoundMode.NONE;
            c.setLabel("Bound Mode: NONE");
            break;
        case 1:
            boundMode = SwarmBoundMode.CLAMP;
            c.setLabel("Bound Mode: CLAMP");
            break;
        case 2:
            boundMode = SwarmBoundMode.WRAP;
            c.setLabel("Bound Mode: WRAP");
            break;
    }
}

void restrictSliderToIntValues(String controllerName) {
    Slider c = (Slider) cp5.getController(controllerName);
    int max = int(c.getMax());
    int min = int(c.getMin());
    c.setNumberOfTickMarks(max - min + 1).showTickMarks(false).snapToTickMarks(true);
}
