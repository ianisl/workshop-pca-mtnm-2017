class AgentAttractor extends Agent {

    float strength;

    AgentAttractor() {
        super();
    }

    AgentAttractor(Swarm swarm, float strength) {
        super(swarm);
        this.strength = strength;
        println(strength);
    }

    void draw() {
        noStroke();
        fill(255, 0, 0);
        ellipse(x, y, 5, 5);
    }

    float[] computeAttraction() {
        // Overwrite the Agent class method to return 0: an agent attractor is not subject to attraction
        return new float[3];
    }

}
