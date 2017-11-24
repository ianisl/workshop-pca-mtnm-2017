/* Ianis Lallemand, 2016
 * http://github.com/ianisl
 * Adapted from Andre Sier's Boid library
 * http://s373.net/code/boids/
 */

class Swarm {

    List<Agent> agents;
    List<AgentAttractor> agentAttractors;
    float separationRange, alignmentRange, cohesionRange, attractionMinRange, attractionMaxRange;
    float maxTurn, maxSpeed, maxForce;
    float minX, minY, maxX, maxY, minZ, maxZ, boundsWidth, boundsHeight, boundsDepth;
    SwarmBoundMode boundMode;
    boolean isContrainedZ;
    float zConstraint;
    float stepSize;

    Swarm() {
        agents = new ArrayList<Agent>();
        agentAttractors = new ArrayList<AgentAttractor>();
        // Defaults
        boundMode = SwarmBoundMode.CLAMP;
        stepSize = 1;
        separationRange = 50;
        alignmentRange = 100;
        cohesionRange = 75;
        attractionMinRange = 1;
        attractionMaxRange = 100;
        maxSpeed = 2;
        maxForce = 10000;
        isContrainedZ = false;
        zConstraint = 0;
        setBounds(Float.NEGATIVE_INFINITY, Float.NEGATIVE_INFINITY, Float.NEGATIVE_INFINITY, Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY, Float.POSITIVE_INFINITY);
    }

    void add(float x, float y, float z) {
        Agent a = new Agent(this);
        z = isContrainedZ ? zConstraint : z;
        a.setZConstraintFlag(isContrainedZ);
        a.setPos(x, y, z);
        agents.add(a);
    }

    void add(float x, float y, float z, float minR, float maxR) {
        float[] pos = getRandomPos(minR, maxR);
        add(x + pos[0], y + pos[1], z + pos[2]);
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

    void addAgentAttractor(float x, float y, float z) {
        AgentAttractor a = new AgentAttractor(this);
        z = isContrainedZ ? zConstraint : z;
        a.isContrainedZ = isContrainedZ;
        a.setPos(x, y, z);
        agents.add(a);
        agentAttractors.add(a); // Keep track of all attractors
    }

    void addAgentAttractor(float x, float y, float z, float minR, float maxR) {
        float[] pos = getRandomPos(minR, maxR);
        addAgentAttractor(x + pos[0], y + pos[1], z + pos[2]);
    }

    void addAgentAttractor(float x, float y, float z, float maxR) {
        addAgentAttractor(x, y, z, 0, maxR);
    }

    void addAgentAttractor(int count, float x, float y, float z, float minR, float maxR) {
        for (int i = 0; i < count; ++i) {
            addAgentAttractor(x, y, z, minR, maxR);
        }
    }

    void addAgentAttractor(int count, float x, float y, float z, float maxR) {
        addAgentAttractor(count, x, y, z, 0, maxR);
    }

    void remove(int i) {
        agents.remove(i);
    }

    float[] getBounds() {
        return new float[] {boundsWidth, boundsHeight, boundsDepth};
    }

    void setBounds(float minx, float miny, float minz, float maxx, float maxy, float maxz) {
        minX = minx;
        minY = miny;
        maxX = maxx;
        maxY = maxy;
        minZ = minz;
        maxZ = maxz;
        boundsWidth = maxX - minX;
        boundsHeight = maxY - minY;
        boundsDepth = maxZ - minZ;
    }

    void update() {
        for (Agent a : agents) {
            a.update(stepSize);
        }
    }

    int size() {
        return agents.size();
    }

    Agent get(int i) {
        return agents.get(i);
    }

    void drawAgents() {
        for (Agent a : agents) {
            a.draw();
        }
    }

    void setTrailSize(int i) {
        for (Agent a : agents) {
            a.setTrailSize(i);
        }
    }

    void drawTrails() {
        for (Agent a : agents) {
            a.drawTrail();
        }
    }

    void setBoundMode(SwarmBoundMode m) {
        this.boundMode = m;
    }

    float[] getRandomPos(float minR, float maxR) {
        float[] pos = new float[3];
        float r = random(minR, maxR);
        float theta = random(TAU);
        float phi = random(TAU);
        if (!isContrainedZ) {
            pos[0] = r * sin(theta) * cos(phi);
            pos[1] = r * sin(theta) * sin(phi);
            pos[2] = r * cos(theta);
        } else {
            pos[0] = r * cos(theta);
            pos[1] = r * sin(theta);
            pos[2] = zConstraint;
        }
        return pos;
    }

    void constrainZ(float z) {
        // Needs to be called before adding agents if using the minR, maxR method, otherwise those radius won't be respected as agents will be created on a sphere, and projected to the plane.
        isContrainedZ = true;
        zConstraint = z;
        // Update existing agents
        for (Agent a : agents) {
            a.z = z;
            a.isContrainedZ = true;
        }
    }

}

enum SwarmBoundMode {
    NONE,
    CLAMP,
    WRAP
}
