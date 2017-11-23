class AgentAttractor extends Agent {

    AgentAttractor(Swarm swarm) {
        super(swarm);
    }

    void draw() {
        noStroke();
        fill(attractorColorR, attractorColorG, attractorColorB, attractorColorA);
        ellipse(x, y, attractorDrawSize, attractorDrawSize);
    }

    float[] computeAttraction() {
        // Overwrite the Agent class method to return 0: an agent attractor is not subject to attraction
        return new float[3];
    }

}
