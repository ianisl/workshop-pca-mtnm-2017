/* Ianis Lallemand, 2016
 * http://github.com/ianisl
 * Adapted from Andre Sier's Boid library
 * http://s373.net/code/boids/
 */

class Swarm {

    List<Agent> agents;
    List<AgentAttractor> agentAttractors;
    float separation, alignment, cohesion;
    float separationRange, alignmentRange, cohesionRange;
    float maxTurn, maxSpeed, maxForce;
    float minX, minY, maxX, maxY, minZ, maxZ, boundsWidth, boundsHeight, boundsDepth;
    SwarmBoundMode boundMode;
    boolean isContrainedZ;
    float zConstraint;

    Swarm() {
        agents = new ArrayList<Agent>();
        agentAttractors = new ArrayList<AgentAttractor>();
        // Defaults
        boundMode = SwarmBoundMode.CLAMP;
        separation = 55.0;
        alignment = 12.0;
        cohesion = 7.0;
        separationRange = 50.0;
        alignmentRange = 100.0;
        cohesionRange = 75.0;
        maxSpeed = 2.;
        maxForce = 10000.0;
        isContrainedZ = false;
        zConstraint = 0;
        setBounds(Float.NEGATIVE_INFINITY, Float.NEGATIVE_INFINITY, Float.NEGATIVE_INFINITY, Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY, 99999999);
    }

    float[] getRandomPos(float minR, float maxR) {
        float[] pos = new float[3];
        float r = random(minR, maxR);
        float theta = random(TAU);
        float phi = random(TAU);
        pos[0] = r * sin(theta) * cos(phi);
        pos[1] = r * sin(theta) * sin(phi);
        pos[2] = r * cos(theta);
        return pos;
    }

    Swarm constrainZ(float z) {
        isContrainedZ = true;
        zConstraint = z;
        // Update existing agents
        for (Agent b : agents) {
            b.z = z;
            b.isContrainedZ = true;
        }
        return this;
    }

    void add(float x, float y, float z) {
        Agent b = new Agent(this);
        z = isContrainedZ ? zConstraint : z;
        b.isContrainedZ = isContrainedZ;
        b.setPos(x, y, z);
        agents.add(b);
    }

    void add(float x, float y, float z, float minR, float maxR) {
        float[] pos = getRandomPos(minR, maxR);
        add(x + pos[0], x + pos[1], x + pos[2]);
    }

    void add(float x, float y, float z, float maxR) {
        add(x, y, z, 0, maxR);
    }

    void add(int count, float x, float y, float z, float minR, float maxR) {
        for (int i = 0; i < count; ++i) {
            add(x, y, z, minR, maxR);
        }
    }

    void add(int count, float x, float y, float z, float maxR) {
        add(count, x, y, z, 0, maxR);
    }

    void addAgentAttractor(float x, float y, float z, float strength) {
        AgentAttractor b = new AgentAttractor(this, strength);
        z = isContrainedZ ? zConstraint : z;
        b.isContrainedZ = isContrainedZ;
        b.setPos(x, y, z);
        agents.add(b);
        agentAttractors.add(b); // Keep track of all attractors
    }

    void addAgentAttractor(float x, float y, float z, float strength, float minR, float maxR) {
        float[] pos = getRandomPos(minR, maxR);
        addAgentAttractor(x + pos[0], x + pos[1], x + pos[2], strength);
    }

    void addAgentAttractor(float x, float y, float z, float strength, float maxR) {
        addAgentAttractor(x, y, z, strength, 0, maxR);
    }

    void addAgentAttractor(int count, float x, float y, float z, float strength, float minR, float maxR) {
        for (int i = 0; i < count; ++i) {
            addAgentAttractor(x, y, z, strength, minR, maxR);
        }
    }

    void addAgentAttractor(int count, float x, float y, float z, float strength, float maxR) {
        addAgentAttractor(count, x, y, z, strength, 0, maxR);
    }

    void remove(int i) {
        agents.remove(i);
    }

    Swarm setBounds(float minx, float miny, float minz, float maxx, float maxy, float maxz) {
        minX = minx;
        minY = miny;
        maxX = maxx;
        maxY = maxy;
        minZ = minz;
        maxZ = maxz;
        boundsWidth = maxX - minX;
        boundsHeight = maxY - minY;
        boundsDepth = maxZ - minZ;
        return this;
    }

    void update(float amount) {
        for (Agent b : agents) {
            b.update(amount);
        }
    }

    int size() {
        return agents.size();
    }

    Agent get(int i) {
        return agents.get(i);
    }

    void drawAgents() {
        for (Agent b : agents) {
            b.draw();
        }
    }

    void setBoundMode(SwarmBoundMode m) {
        this.boundMode = m;
    }

}

enum SwarmBoundMode {
    CLAMP,
    WRAP
}
